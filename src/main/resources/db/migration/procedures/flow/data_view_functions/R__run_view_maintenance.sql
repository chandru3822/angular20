CREATE OR REPLACE function flow.run_view_maintenance()
  returns table
          (
            v_sql text
          )
AS
$BODY$
declare
  x       record;
  v_sql   text;
  v_count integer;
BEGIN

  create temp table sql_statements
  (
    sql_statements text
  ) on commit drop;

  create temp table temp_data_view_maintenance on commit drop as
    (select distinct coalesce(dv.id, dvm.data_view_id)       as data_view_id,
                     coalesce(c.schema_name, c1.schema_name) as schema_name,
                     coalesce(dv.view_name, dv1.view_name)   as view_name,
                     dvm.company_process_ids,
                     dvm.company_process_ids_added,
                     dvm.data_view_field_config_id,
                     coalesce(c.id, c1.id)                   as company_id,
                     dvm.id
     from flow.data_view_maintenance dvm
            left join flow.data_view_field_config dvfc on dvm.data_view_field_config_id = dvfc.id
            left join flow.data_view dv on dvfc.data_view_id = dv.id
            left join flow.company c on dv.company_id = c.id
            left join flow.data_view dv1 on dvm.data_view_id = dv1.id
            left join flow.company c1 on dv1.company_id = c1.id
     where dvm.processed is false);

  for x in select data_view_id
           from flow.data_view_maintenance
           where company_process_ids_added is true
             and processed = false
             and data_view_field_config_id is null
    loop
      insert into flow.data_view_maintenance(data_view_field_config_id, processed, date_created,
                                             company_process_ids_added)
        (select id, false, now(), true
         from flow.data_view_field_config dvfc2
         where dvfc2.data_view_id = x.data_view_id);
    end loop;

  for x in select data_view_id,
                  schema_name,
                  view_name,
                  company_process_ids,
                  company_process_ids_added,
                  data_view_field_config_id,
                  company_id,
                  id
           from temp_data_view_maintenance

    loop
      v_sql = null;
      if x.data_view_field_config_id is null and x.company_process_ids_added is false then
        select $$delete from $$ || x.schema_name || $$.$$ || x.view_name || $$ where project_id = any( '$$ ||
               array_agg(p.id)::text || $$');$$
        into v_sql
        from flow.project p
        where p.company_process_id = any (x.company_process_ids)
        group by x.schema_name, x.view_name;

        if v_sql is not null then
          insert into sql_statements(sql_statements) values (v_sql);
        end if;
      elsif x.data_view_field_config_id is null and x.company_process_ids_added is true then
        v_sql = $$insert into $$ || x.schema_name || $$.$$ || x.view_name || $$(project_id, contact_id,company_id, date_modified)
          (select p.id,p.contact_id,$$ || x.company_id || $$,now()
            from flow.project p
            where p.company_process_id = any('$$ || x.company_process_ids::text || $$')); $$;
        if v_sql is not null then
          execute v_sql;
        end if;
        v_sql = null;
        v_sql = flow.populate_data_from_data_maintenance(x.data_view_id, x.company_process_ids);
        if v_sql is not null then
          insert into sql_statements(sql_statements) values (v_sql);
        end if;
      elsif x.data_view_field_config_id is not null and x.company_process_ids_added is false then
        v_sql = null;
        v_sql = flow.populate_data_from_data_maintenance(x.data_view_id);
        if v_sql is not null then
          insert into sql_statements(sql_statements) values (v_sql);
        end if;
      end if;
    end loop;
  select count(1)
  into v_count
  from sql_statements;
  if v_count > 0 then
    update flow.data_view_maintenance
    set processed = true
    where processed = false;
  end if;
  return query
    select * from sql_statements;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;



