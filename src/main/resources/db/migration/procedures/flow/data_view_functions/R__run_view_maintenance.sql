drop procedure if exists flow.run_view_maintenance();
CREATE OR REPLACE procedure flow.run_view_maintenance()
AS
$BODY$
declare
  x                 record;
  v_sql             text;
  v_count           bigint;
  v_view_name       text;
  v_field_to_update text;
  v_schema_name     text;
  v_insert_sql      text;
  v_data_type_id    bigint;
BEGIN

  for x in select dvm.data_view_id,
                  dvm.id,
                  dvm.company_process_ids,
                  v.view_name,
                  c2.schema_name,
                  c2.id as company_id
           from flow.data_view_maintenance dvm
                  inner join flow.data_view v on v.id = dvm.data_view_id
                  inner join flow.company c2 on c2.id = v.company_id
           where company_process_ids_added is true
             and processed = false
             and data_view_field_config_id is null
    loop
      insert into flow.data_view_maintenance(data_view_field_config_id, processed, date_created,
                                             company_process_ids_added, company_process_ids)
        (select id, false, now(), false, x.company_process_ids
         from flow.data_view_field_config dvfc2
         where dvfc2.data_view_id = x.data_view_id
          -- and dvfc2.id in (414,415)
        );
      v_sql = $$insert into $$ || x.schema_name || $$.$$ || x.view_name || $$(project_id, contact_id,company_id, date_modified)
          (select p.id,p.contact_id,$$ || x.company_id || $$,now()
            from flow.project p
            where p.company_process_id = any('$$ || x.company_process_ids::text || $$')); $$;
      if v_sql is not null then
        --raise notice 'v_sql_line: %', v_sql;
        execute v_sql;
      end if;
      update flow.data_view_maintenance d
      set processed = true
      where d.id = x.id;
    end loop;

  -- --  this updates all fields in the data_view_maintenance table if they cfga id goes back to the same custom_field_id.  we only
--   -- need to update the field once.
  UPDATE flow.data_view_maintenance m
  SET processed = true
  FROM (SELECT m1.*, ROW_NUMBER() OVER (PARTITION BY cfga.custom_field_id ORDER BY m1.id) as seqnum
        FROM flow.data_view_maintenance m1
               inner join flow.data_view_field_config dvfc3 on dvfc3.id = m1.data_view_field_config_id
               inner join flow.custom_field_group_assignment cfga on cfga.id = dvfc3.custom_field_group_assignment_id
        where processed is false) m2
  WHERE m2.id = m.id
    and m2.seqnum > 1;
--
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
      elsif x.data_view_field_config_id is not null and x.company_process_ids_added is false then
        v_sql = null;
        v_insert_sql = null;
        call flow.populate_data_from_data_maintenance(x.id, x.data_view_id, v_sql, x.company_process_ids);
        if v_sql is not null then
          v_insert_sql = $$insert into flow.data_view_update(generated_update)
          ($$ || v_sql || $$);$$;
          raise notice 'v_insert_sql: %', v_insert_sql;
          --raise notice 'v_sql: %', v_sql;
          --execute v_insert_sql;
        end if;
      end if;
      update flow.data_view_maintenance dvm2
      set processed = true
      where processed = false
        and dvm2.id = x.id;
    end loop;
  v_sql = null;

  for x in select *
           from flow.data_view_maintenance dvm
           where dvm.lov_old_name is not null
             and dvm.lov_new_name is not null
             and dvm.processed = false

    loop
      v_sql = null;
      select distinct dv.view_name, dvcfc.field_to_update, c.schema_name, cdt.data_type_id
      into v_view_name,v_field_to_update,v_schema_name,v_data_type_id
      from flow.data_view_field_config dvfc
             left join flow.custom_field_group_assignment a on a.id = dvfc.custom_field_group_assignment_id
             left join flow.custom_field cf on cf.id = a.custom_field_id
             left join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
             inner join flow.data_view dv on dv.id = dvfc.data_view_id
             inner join flow.company c on c.id = dv.company_id
             inner join flow.data_view_child_field_config dvcfc on dvcfc.data_view_field_config_id = dvfc.id
      where dvfc.id = x.data_view_field_config_id;

      if v_data_type_id is not null and v_data_type_id = 7 then
        v_sql = $$update $$ || v_schema_name || $$.$$ || v_view_name || $$ set $$ || v_field_to_update || $$ =
                replace($$||v_field_to_update||$$,$$||quote_literal(x.lov_old_name)||$$,$$||quote_literal(x.lov_new_name)||$$)$$ || $$ where $$
                  || v_field_to_update || $$ like $$ || quote_literal(concat($$%$$,x.lov_old_name,$$%$$)) ||$$;$$;
      else
        v_sql = $$update $$ || v_schema_name || $$.$$ || v_view_name || $$ set $$ || v_field_to_update || $$ = $$ ||
                quote_literal(x.lov_new_name) || $$ where $$ || v_field_to_update || $$ = $$ || quote_literal(x.lov_old_name) ||$$;$$;
      end if;

      if v_sql is not null then
        --raise notice 'v_sql_line: %', v_sql;
        execute v_sql;
      end if;
    end loop;
  --call flow.process_data_view_updates();
END
$BODY$
  LANGUAGE plpgsql;



