drop routine if exists flow.process_org_structure_refresh();
CREATE OR REPLACE procedure flow.process_org_structure_refresh() AS
$BODY$
declare
  x         record;
  y         record;
  v_org_ids bigint[];
  v_rowcount bigint;
BEGIN
  --   for x in select c.id,
--                   (select array_agg(distinct org_id) org_ids
--                    from flow.user_position u
--                    where u.id = any (c.owner_position_ids)) as org_ids
--            from flow.org_structure_refresh osr
--                   inner join flow.contact c on osr.user_position_id = any (c.owner_position_ids)
--            where user_position_id is not null
--     loop
--
--       v_org_ids = null;
--       select distinct t.id
--       into v_org_ids
--       from flow.org_hierarchy_filter_up_search(coalesce(x.org_ids, '{0}')) as t;
--
--       update flow.contact c2
--       set owner_org_ids = v_org_ids
--       where x.id = c2.id;
--       commit;
--     end loop;
  SET session_replication_role = replica;


  create temp table org_hierarchy as (
    select o.id as org_id,array_agg(t.id) as org_ids
    from flow.org o
           join lateral flow.org_hierarchy_filter_up_search(array[o.id]) as t on true
    where o.active_flag is true and archived is not true
    group by o.id);
  CREATE INDEX if not exists orgh ON org_hierarchy (org_id);
  v_rowcount = 0;
  for y in select *
           from flow.org_structure_refresh osr
         -- where org_id = 716
    loop
      for x in select distinct c3.id,
                               (select array_agg(distinct org_id)
                                from flow.user_position u
                                where u.id = any (c3.owner_position_ids)) as org_ids
               from flow.contact c3
               where y.org_id = any (c3.owner_org_ids)
        loop
          v_rowcount = v_rowcount + 1;
          v_org_ids = null;
          select array_agg(distinct orgs)
          into v_org_ids
          from (
                 select unnest(oh.org_ids) orgs
                 from org_hierarchy oh
                 where org_id = any(x.org_ids))as foo;

          update flow.contact c2
          set owner_org_ids = v_org_ids
          where x.id = c2.id;
          if v_rowcount = 1000 then
          commit;
          v_rowcount = 0;
          end if;
        end loop;
    v_rowcount = 0;
      delete from flow.org_structure_refresh o
      where o.org_id = y.org_id;
      commit;
    end loop;
  commit;
  drop table org_hierarchy;
  SET session_replication_role = default;
END
$BODY$
  LANGUAGE plpgsql;
