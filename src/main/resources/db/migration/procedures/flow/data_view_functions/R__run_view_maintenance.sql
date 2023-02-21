drop function if exists flow.run_view_maintenance();
CREATE OR REPLACE function flow.run_view_maintenance()
  returns void
AS
$BODY$
declare
  x                 record;
  v_sql             text;
  v_count           bigint;
  v_view_name       text;
  v_field_to_update text;
  v_schema_name     text;
BEGIN

  for x in select data_view_id,id
           from flow.data_view_maintenance
           where company_process_ids_added is true
             and processed = false
             and data_view_field_config_id is null
    loop
      insert into flow.data_view_maintenance(data_view_field_config_id, processed, date_created,
                                             company_process_ids_added)
        (select id, false, now(), false
         from flow.data_view_field_config dvfc2
         where dvfc2.data_view_id = x.data_view_id);
      update flow.data_view_maintenance d
    set processed = true
    where d.id = x.id;
    end loop;

  for x in select distinct coalesce(dv.id, dvm.data_view_id)       as data_view_id,
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
           where dvm.processed is false
             and dvm.lov_new_name is null
             and dvm.lov_old_name is null
            order by dvm.id
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
         -- raise notice 'v_sql_line: %', v_sql;
          execute v_sql;
        end if;
      elsif x.data_view_field_config_id is null and x.company_process_ids_added is true then
        v_sql = $$insert into $$ || x.schema_name || $$.$$ || x.view_name || $$(project_id, contact_id,company_id, date_modified)
          (select p.id,p.contact_id,$$ || x.company_id || $$,now()
            from flow.project p
            where p.company_process_id = any('$$ || x.company_process_ids::text || $$')); $$;
        if v_sql is not null then
          --raise notice 'v_sql_line: %', v_sql;
          execute v_sql;
        end if;
        v_sql = null;
        v_sql = flow.populate_data_from_data_maintenance(x.id,x.data_view_id, x.company_process_ids);
        if v_sql is not null then
          --raise notice 'v_sql_line: %', v_sql;
          execute v_sql;
        end if;
      elsif x.data_view_field_config_id is not null and x.company_process_ids_added is false then
        v_sql = null;
        v_sql = flow.populate_data_from_data_maintenance(x.id,x.data_view_id);
        if v_sql is not null then
          --raise notice 'v_sql_line: %', v_sql;
          execute v_sql;
        end if;
      end if;
      update flow.data_view_maintenance dvm2
      set processed = true
      where processed = false and dvm2.id = x.id;
    end loop;
  v_sql = null;

  for x in select *
           from flow.data_view_maintenance dvm
           where dvm.lov_old_name is not null
             and dvm.lov_new_name is not null
             and dvm.processed = false

    loop
      v_sql = null;
      select distinct dv.view_name, dvcfc.field_to_update, c.schema_name
      into v_view_name,v_field_to_update,v_schema_name
      from flow.data_view_field_config dvfc
             inner join flow.data_view dv on dv.id = dvfc.data_view_id
             inner join flow.company c on c.id = dv.company_id
             inner join flow.data_view_child_field_config dvcfc on dvcfc.data_view_field_config_id = dvfc.id
      where dvfc.id = x.data_view_field_config_id;

      v_sql = 'update ' || v_schema_name || '.' || v_view_name || ' set ' || v_field_to_update || ' = ''' ||
              x.lov_new_name || ''' where ' || v_field_to_update || ' = ''' || x.lov_old_name || ''';';

      if v_sql is not  null then
        --raise notice 'v_sql_line: %', v_sql;
        execute v_sql;
      end if;
    end loop;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;



