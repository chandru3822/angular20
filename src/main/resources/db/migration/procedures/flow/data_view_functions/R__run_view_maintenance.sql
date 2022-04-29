CREATE OR REPLACE function flow.run_view_maintenance()
  returns table
          (
            v_sql text
          )
AS
$BODY$
declare
  x     record;
  v_sql text;
BEGIN

--   for x in select distinct id
--            from flow.data_view where id = 1
--     loop
--       insert into flow.data_view_maintenance(data_view_field_config_id, processed, date_created)
--         (select dvfc2.id, false, now()
--          from flow.data_view_field_config dvfc2
--          where data_view_id = x.id
--            and exists(with current as (select unnest(company_process_ids) company_process_id
--                                        from flow.data_view
--                                        where id = x.id),
--                            updated as (select unnest(company_process_ids) company_process_id
--                                        from flow.data_view_maintenance
--                                        where data_view_id = x.id)
--                       select u.company_process_id
--                       from updated u
--                              inner join current c on c.company_process_id = u.company_process_id))
--       on conflict do nothing;
--     end loop;
create temp table sql_statements
(
  sql_statements text
);

  for x in
    select distinct dvfc.data_view_id, c.schema_name, dv.view_name
    from flow.data_view_maintenance dvm
           inner join flow.data_view_field_config dvfc on dvm.data_view_field_config_id = dvfc.id
           inner join flow.data_view dv on dvfc.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
    where dvm.processed is false
    loop

      with current as (select unnest(company_process_ids) company_process_id
                       from flow.data_view
                       where id = x.data_view_id),
           updated as (select unnest(company_process_ids) company_process_id
                       from flow.data_view_maintenance
                       where data_view_id = x.data_view_id),
           update_data as (select company_process_id
                           from updated
                           except
                           select company_process_id
                           from current)
      select $$delete from $$ || x.schema_name || $$.$$ || x.view_name || $$ where project_id = any( '$$ ||
             array_agg(p.id)::text || $$');$$
      into v_sql
      from flow.project p
             inner join update_data ud2 on ud2.company_process_id = p.company_process_id
      group by x.schema_name, x.view_name;
      if v_sql is not null then
        insert into sql_statements(sql_statements) values (v_sql);
      end if;


      v_sql = null;
      v_sql = flow.populate_data_from_data_maintenance(x.data_view_id);
      if v_sql is not null then
        insert into sql_statements(sql_statements) values (v_sql);
      end if;


      --       with update_data as (select dvm.id
--                            from flow.data_view_maintenance dvm
--                                   inner join flow.data_view_field_config dvfc on dvm.data_view_field_config_id = dvfc.id
--                            where dvm.processed = false
--                              and dvfc.data_view_id = x.data_view_id)
--       update flow.data_view_maintenance dvm2
--       set processed = true
--       from update_data ud
--       where ud.id = dvm2.id;
    end loop;
  return query
    select * from sql_statements;
  drop table if exists sql_statements;
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;



