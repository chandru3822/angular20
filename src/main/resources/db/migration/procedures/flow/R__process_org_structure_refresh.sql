drop routine if exists flow.process_org_structure_refresh();
CREATE OR REPLACE procedure flow.process_org_structure_refresh() AS
$BODY$
declare
  x         record;
  v_org_ids bigint[];
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


  for x in select c3.id,
                  (select array_agg(distinct org_id)
                   from flow.user_position u
                   where u.id = any (c3.owner_position_ids)) as org_ids
           from flow.org_structure_refresh osr
                  inner join flow.contact c3 on osr.org_id = any (c3.owner_org_ids)
           where osr.org_id is not null
    loop
      v_org_ids = null;
      select distinct array_agg(distinct t.id)
      into v_org_ids
      from flow.org_hierarchy_filter_up_search(coalesce(x.org_ids, '{0}')) as t;

      update flow.contact c2
      set owner_org_ids = v_org_ids
      where x.id = c2.id;
      commit;
    end loop;

END
$BODY$
  LANGUAGE plpgsql;
