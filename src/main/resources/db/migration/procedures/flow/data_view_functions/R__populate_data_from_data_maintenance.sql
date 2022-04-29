--write code for adding and removing company_process_ids
CREATE OR REPLACE FUNCTION flow.populate_data_from_data_maintenance(p_data_view_id integer)
  RETURNS text
AS
$BODY$
declare
  z                          record;
  x                          record;
  v_sql                      text;
  v_text_array_columns       character varying[];
  v_text_array_alias_columns character varying[];
  v_text_array_tables        character varying[];
  v_second_value             character varying;
  v_columns                  character varying;
  v_table                    character varying;
  v_in_contact               integer = 0;
  v_in_project               integer = 0;
  v_in_ppscfv                integer = 0;
  v_in_project_details       integer = 0;
  v_in_contact_details       integer = 0;
  v_in_event_details         integer = 0;
  v_in_event                 integer = 0;
  v_alias_value              varchar;
BEGIN
  v_sql = null;
  --CONTACT UPDATE
  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 2
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_contact = v_in_contact + 1;
      if z.object_type = 'contact' and (v_sql = '') IS NOT FALSE then
        v_sql = $$with update_contact as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_contact uc')::character varying);
      elsif z.object_type = 'contact' and (v_sql = '') IS FALSE and
            position('update_contact' in v_sql) < 1 then
        v_sql = v_sql || $$ update_contact as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_contact uc')::character varying);
      end if;

      v_sql = v_sql ||$$c.$$|| z.column_name || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$uc.$$ || z.field_to_update)::character varying);
      v_text_array_columns = array_append(v_text_array_columns, z.field_to_update);
      for x in select dvcfc.field_to_update,
                      quote_literal(ubt.unique_behavior_type) as unique_behavior_type,
                      dvcfc.data_type_id,
                      dt.data_type
               from flow.data_view_child_field_config dvcfc
                      inner join flow.unique_behavior_type ubt on dvcfc.unique_behavior_type_id = ubt.id
                      inner join flow.data_type dt on dvcfc.data_type_id = dt.id
               where dvcfc.data_view_field_config_id = z.data_view_field_config_id
        loop
          v_text_array_columns = array_append(v_text_array_columns, x.field_to_update);
          v_text_array_alias_columns =
            array_append(v_text_array_alias_columns, ($$uc.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,
                                                              $$ || z.column_name || $$, c.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    end loop;
  if v_in_contact > 0 then
    v_sql = trim(trailing ' ,' from v_sql);
    v_sql = v_sql || $$ from flow.contact c
                              inner join flow.project p on p.contact_id = c.id
                              where p.company_process_id = any('$$||z.company_process_ids::text||$$'::integer[])), $$;
  end if;

  --PROJECT UPDATE
  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dvfc2.custom_field_group_assignment_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 1
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_project = v_in_project + 1;
      if z.object_type = 'project' and (v_sql = '') IS NOT FALSE then
        v_sql = $$with update_project as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_project up')::character varying);
      elsif z.object_type = 'project' and (v_sql = '') IS FALSE and
            position('update_project' in v_sql) < 1 then
        v_sql = v_sql || $$ update_project as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_project up')::character varying);
      end if;

      v_sql = v_sql ||$$p.$$||z.column_name || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$up.$$ || z.field_to_update)::character varying);
      v_text_array_columns = array_append(v_text_array_columns, z.field_to_update);
      for x in select dvcfc.field_to_update,
                      quote_literal(ubt.unique_behavior_type) as unique_behavior_type,
                      dvcfc.data_type_id,
                      dt.data_type
               from flow.data_view_child_field_config dvcfc
                      inner join flow.unique_behavior_type ubt on dvcfc.unique_behavior_type_id = ubt.id
                      inner join flow.data_type dt on dvcfc.data_type_id = dt.id
               where dvcfc.data_view_field_config_id = z.data_view_field_config_id
        loop
          v_text_array_columns = array_append(v_text_array_columns, x.field_to_update);
          v_text_array_alias_columns =
            array_append(v_text_array_alias_columns, ($$up.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,
                                                              $$ || z.column_name || $$, p.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    end loop;
  if v_in_project > 0 then
    v_sql = trim(trailing ' ,' from v_sql);
    v_sql = v_sql || $$ from flow.$$ || z.object_type || $$ p
    where p.company_process_id = any('$$||z.company_process_ids::text||$$'::integer[])), $$;
  end if;


  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           cfga.id               as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id                 as data_type_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.custom_field_group_assignment cfga on dvfc2.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
           inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
           inner join flow.object_type ot on cot.object_type_id = ot.id and ot.id = 4
           inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           inner join flow.data_type dt on cdt.data_type_id = dt.id
    where dvfc2.custom_field_group_assignment_id is not null
      and dvfc2.process_step_event_id is null
      and dvfc2.default_field_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_ppscfv = v_in_ppscfv + 1;
      call flow.generate_sql_for_ppscfv(z,
                                        v_in_ppscfv,
                                        v_sql,
                                        v_text_array_tables,
                                        v_text_array_alias_columns,
                                        v_text_array_columns);
    end loop;

  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           cfga.id               as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id                 as data_type_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.custom_field_group_assignment cfga on dvfc2.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
           inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
           inner join flow.object_type ot on cot.object_type_id = ot.id and ot.id = 1
           inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           inner join flow.data_type dt on cdt.data_type_id = dt.id
    where dvfc2.custom_field_group_assignment_id is not null
      and dvfc2.process_step_event_id is null
      and dvfc2.default_field_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_project_details = v_in_project_details + 1;
      call flow.generate_sql_for_pcfv(z,
                                        v_in_project_details,
                                        v_sql,
                                        v_text_array_tables,
                                        v_text_array_alias_columns,
                                        v_text_array_columns);

    end loop;
  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           cfga.id               as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id                 as data_type_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.custom_field_group_assignment cfga on dvfc2.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
           inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
           inner join flow.object_type ot on cot.object_type_id = ot.id and ot.id = 2
           inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           inner join flow.data_type dt on cdt.data_type_id = dt.id
    where dvfc2.custom_field_group_assignment_id is not null
      and dvfc2.process_step_event_id is null
      and dvfc2.default_field_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_contact_details = v_in_contact_details + 1;
      call flow.generate_sql_for_ccfv(z,
                                      v_in_contact_details,
                                      v_sql,
                                      v_text_array_tables,
                                      v_text_array_alias_columns,
                                      v_text_array_columns);

    end loop;



  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           cfga.id               as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id                 as data_type_id,
           dvfc2.process_step_event_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.custom_field_group_assignment cfga on dvfc2.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
           inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
           inner join flow.object_type ot on cot.object_type_id = ot.id and ot.id = 6
           inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
           inner join flow.data_type dt on cdt.data_type_id = dt.id
    where dvfc2.custom_field_group_assignment_id is not null
      and dvfc2.process_step_event_id is not null
      and dvfc2.default_field_id is null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_event_details = v_in_event_details + 1;
      call flow.generate_sql_for_event_details(z,
                                      v_in_contact_details,
                                      v_sql,
                                      v_text_array_tables,
                                      v_text_array_alias_columns,
                                      v_text_array_columns);

  end loop;

  for z in
    select c.schema_name,
           dv.view_name,
           dv.company_process_ids,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dvfc2.custom_field_group_assignment_id,
           dvfc2.process_step_event_id
    from flow.data_view_maintenance dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 6
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is not null
      and processed is false
      and dvfc2.data_view_id = p_data_view_id
    loop
      v_in_event = v_in_event + 1;
      call flow.generate_sql_for_event(z,
                                               v_in_contact_details,
                                               v_sql,
                                               v_text_array_tables,
                                               v_text_array_alias_columns,
                                               v_text_array_columns);
    end loop;

  v_sql = v_sql || $$  update_data as (select o.project_id $$;

  FOREACH v_columns IN ARRAY v_text_array_alias_columns
    LOOP
      v_sql = v_sql || $$ , $$ || v_columns;
    END LOOP;

  v_sql = v_sql || $$ from  $$ || z.schema_name || $$.$$ || z.view_name || $$ o $$;

  FOREACH v_table IN ARRAY v_text_array_tables
    LOOP
      select left(v_table, 1) || substring(v_table, position('_' in v_table) + 1, 1)
      into v_alias_value;
      v_sql = v_sql || $$ inner join $$ || v_table || $$ on o.project_id = $$ || v_alias_value || $$.id$$;
    END LOOP;
  v_sql = v_sql || $$)$$;

  v_sql = v_sql || $$ update $$ || z.schema_name || $$.$$ || z.view_name || $$ foo set $$;
  if array_length(v_text_array_columns, 1) > 0 then

    FOREACH v_second_value IN ARRAY v_text_array_columns
      LOOP
        v_sql = v_sql || $$  $$ || v_second_value || $$ = ud.$$ || v_second_value || $$,$$;
      END LOOP;
  end if;
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from update_data ud where ud.project_id = foo.id;$$;
  raise notice 'v_sql = %',v_sql;
  return v_sql;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

