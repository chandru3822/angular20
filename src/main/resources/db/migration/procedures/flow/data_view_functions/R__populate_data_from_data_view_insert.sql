--TODO only add projects where the project_ids are in the company_process_ids array

CREATE OR REPLACE FUNCTION flow.populate_data_from_data_view_insert()
  RETURNS void
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
v_alias_value varchar;
BEGIN
  v_sql = null;
  --CONTACT UPDATE
  for z in
    select c.schema_name,
           dv.view_name,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id
    from flow.data_view_field_config_data dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 2
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is null
      and processed is false
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'contact' and (v_sql = '') IS NOT FALSE then

        v_sql = $$with update_contact as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_contact uc')::character varying);
      elsif z.object_type = 'contact' and (v_sql = '') IS FALSE and
            position('update_contact' in v_sql) < 1 then
        v_sql = v_sql || $$ update_contact as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_contact uc')::character varying);
      end if;

      v_sql = v_sql || z.column_name || $$ as $$ || z.field_to_update || $$,$$;

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
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.contact c
                            inner join flow.project p on p.contact_id = c.id), $$;

  --PROJECT UPDATE
  for z in
    select c.schema_name,
           dv.view_name,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dvfc2.custom_field_group_assignment_id
    from flow.data_view_field_config_data dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 1
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is null
      and processed is false
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'project' and z.custom_field_group_assignment_id is null and (v_sql = '') IS NOT FALSE then
        v_sql = $$with update_project as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_project up')::character varying);
      elsif z.object_type = 'project' and z.custom_field_group_assignment_id is null and (v_sql = '') IS FALSE and
            position('update_project' in v_sql) < 1 then
        v_sql = v_sql || $$ update_project as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_project up')::character varying);
      end if;

      v_sql = v_sql || z.column_name || $$ as $$ || z.field_to_update || $$,$$;

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
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.$$ || z.object_type || $$ p), $$;

  for z in
    select c.schema_name,
           dv.view_name,
           cfga.id as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id as data_type_id
    from flow.data_view_field_config_data dvfcd
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
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'process_step' and (v_sql = '') IS NOT FALSE then
        v_sql = $$with pp_step as (select pps.project_id as id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('pp_step ps')::character varying);
      elsif z.object_type = 'process_step' and (v_sql = '') IS FALSE and
            position('pp_step' in v_sql) < 1 then
        v_sql = v_sql || $$ pp_step as (select pps.project_id as id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('pp_step ps')::character varying);
      end if;

      v_sql = v_sql || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$ps.$$ || z.field_to_update)::character varying);
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
            array_append(v_text_array_alias_columns, ($$ps.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,
                                                              $$ || case
                                                                                        when z.data_type_id = 1 then 'date_value'
                                                                                        when z.data_type_id = 2 then 'timestamp_value'
                                                                                        when z.data_type_id = 3 then 'boolean_value'
                                                                                        when z.data_type_id = 4 then 'numeric_value'
                                                                                        when z.data_type_id = 5 then 'text_value'
                                                                                        when z.data_type_id = 6 then 'int_value'
                                                                                        when z.data_type_id = 7 then 'int_array_value'
                                                                                        when z.data_type_id in (8, 9) then 'int_value' end || $$, ppscfv.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    end loop;
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.project_process_step pps
                      inner join flow.project_process_step_custom_field_value ppscfv on pps.id = ppscfv.project_process_step_id
                        and ppscfv.custom_field_group_assignment_id = $$||z.custom_field_group_assignment_id||$$
                        order by pps.id), $$;


  for z in
    select c.schema_name,
           dv.view_name,
           cfga.id as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id as data_type_id
    from flow.data_view_field_config_data dvfcd
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
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'project' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS NOT FALSE then

        v_sql = $$with project_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('project_details pd')::character varying);
      elsif z.object_type = 'project' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS FALSE and
            position('project_details' in v_sql) < 1 then
        v_sql = v_sql || $$ project_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('project_details pd')::character varying);
      end if;

      v_sql = v_sql || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$ as $$ || z.field_to_update || $$,$$;


      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$pd.$$ || z.field_to_update)::character varying);
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
            array_append(v_text_array_alias_columns, ($$pd.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,$$
                                                              || case
                                                             when z.data_type_id = 1 then 'date_value'
                                                             when z.data_type_id = 2 then 'timestamp_value'
                                                             when z.data_type_id = 3 then 'boolean_value'
                                                             when z.data_type_id = 4 then 'numeric_value'
                                                             when z.data_type_id = 5 then 'text_value'
                                                             when z.data_type_id = 6 then 'int_value'
                                                             when z.data_type_id = 7 then 'int_array_value'
                                                             when z.data_type_id in (8, 9) then 'int_value' end || $$, pcfv.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    end loop;
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.project p
                      inner join flow.project_custom_field_value pcfv on p.id = pcfv.project_id
                        and pcfv.custom_field_group_assignment_id = $$||z.custom_field_group_assignment_id||$$), $$;

  for z in
    select c.schema_name,
           dv.view_name,
           cfga.id as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id as data_type_id
    from flow.data_view_field_config_data dvfcd
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
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'contact' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS NOT FALSE then

        v_sql = $$with contact_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('contact_details cd')::character varying);
      elsif z.object_type = 'contact' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS FALSE and
            position('contact_details' in v_sql) < 1 then
        v_sql = v_sql || $$ contact_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('contact_details cd')::character varying);
      end if;

      v_sql = v_sql || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$cd.$$ || z.field_to_update)::character varying);
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
            array_append(v_text_array_alias_columns, ($$cd.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,$$
                    || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$, ccfv.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;
    end loop;
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.project p
                      inner join flow.contact c on c.id = p.contact_id
                      inner join flow.contact_custom_field_value ccfv on c.id = ccfv.contact_id
                        and ccfv.custom_field_group_assignment_id = $$||z.custom_field_group_assignment_id||$$), $$;


  for z in
    select c.schema_name,
           dv.view_name,
           cfga.id as custom_field_group_assignment_id,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           dvfc2.field_to_update as column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dt.id as data_type_id,
           dvfc2.process_step_event_id
    from flow.data_view_field_config_data dvfcd
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
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'event' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS NOT FALSE then

        v_sql = $$with event_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('event_details ed')::character varying);
      elsif z.object_type = 'event' and z.custom_field_group_assignment_id is not null and (v_sql = '') IS FALSE and
            position('event_details' in v_sql) < 1 then
        v_sql = v_sql || $$ event_details as (select p.id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('event_details ed')::character varying);
      end if;

      v_sql = v_sql || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$ed.$$ || z.field_to_update)::character varying);
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
            array_append(v_text_array_alias_columns, ($$ed.$$ || x.field_to_update)::character varying);
          v_sql = v_sql || $$ flow.get_unique_behavior_value($$ || x.unique_behavior_type || $$,$$
                    || case
                         when z.data_type_id = 1 then 'date_value'
                         when z.data_type_id = 2 then 'timestamp_value'
                         when z.data_type_id = 3 then 'boolean_value'
                         when z.data_type_id = 4 then 'numeric_value'
                         when z.data_type_id = 5 then 'text_value'
                         when z.data_type_id = 6 then 'int_value'
                         when z.data_type_id = 7 then 'int_array_value'
                         when z.data_type_id in (8, 9) then 'int_value' end || $$, ppsecfv.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;
    end loop;
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.project p
                      inner join flow.project_process_step pps on pps.project_id = p.id
                      inner join flow.project_process_step_event ppse on ppse.project_process_step_id = pps.id and
                                              ppse.process_step_event_id = $$||z.process_step_event_id||$$
                      inner join flow.project_process_step_event_custom_field_value ppsecfv on ppse.id = ppsecfv.project_process_step_event_id
                        and ppsecfv.custom_field_group_assignment_id = $$||z.custom_field_group_assignment_id||$$
                        order by ppse.id), $$;


  for z in
    select c.schema_name,
           dv.view_name,
           dvfc2.default_field_id,
           dvfc2.field_to_update,
           dvfc2.update_first_value_only,
           dvfc2.update_first_value_only_id,
           df.column_name,
           lower(ot.object_code) as object_type,
           dvfc2.id              as data_view_field_config_id,
           dvfc2.custom_field_group_assignment_id,
           dvfc2.process_step_event_id
    from flow.data_view_field_config_data dvfcd
           inner join flow.data_view_field_config dvfc2 on dvfcd.data_view_field_config_id = dvfc2.id
           inner join flow.data_view dv on dvfc2.data_view_id = dv.id
           inner join flow.company c on dv.company_id = c.id
           inner join flow.default_field df on dvfc2.default_field_id = df.id and df.object_type_id = 6
           inner join flow.object_type ot on df.object_type_id = ot.id
           inner join flow.data_type dt on df.data_type_id = dt.id
    where dvfc2.default_field_id is not null
      and dvfc2.process_step_event_id is not null
      and processed is false
      and dvfc2.data_view_id = 1
    loop

      if z.object_type = 'event' and z.custom_field_group_assignment_id is null and  (v_sql = '') IS NOT FALSE then

        v_sql = $$with update_event as (select pps.project_id as id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_event ue')::character varying);
      elsif z.object_type = 'event' and z.custom_field_group_assignment_id is null and (v_sql = '') IS FALSE and
            position('update_event' in v_sql) < 1 then
        v_sql = v_sql || $$ update_event as (select pps.project_id as id,$$;
        v_text_array_tables = array_append(v_text_array_tables, ('update_event ue')::character varying);
      end if;

      v_sql = v_sql || z.column_name || $$ as $$ || z.field_to_update || $$,$$;

      v_text_array_alias_columns =
        array_append(v_text_array_alias_columns, ($$ue.$$ || z.field_to_update)::character varying);
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
                                                              $$ || z.column_name || $$, ppse.id)::$$ || x.data_type ||
                  $$ as $$ || x.field_to_update || $$,$$;
        end loop;

    end loop;
  --TODO check to see if the for loop above ran
  v_sql = trim(trailing ' ,' from v_sql);
  v_sql = v_sql || $$ from flow.project_process_step_event ppse
                            inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
                        where ppse.process_step_event_id = $$||z.process_step_event_id||$$
                            order by ppse.id), $$;


  v_sql = v_sql || $$  update_data as (select o.project_id $$;

  FOREACH v_columns IN ARRAY v_text_array_alias_columns
    LOOP
      v_sql = v_sql || $$ , $$ || v_columns;
    END LOOP;

  v_sql = v_sql || $$ from  $$ || z.schema_name || $$.$$ || z.view_name || $$ o $$;

  FOREACH v_table IN ARRAY v_text_array_tables
    LOOP
    select left(v_table,1)||substring(v_table,position('_' in v_table)+1,1)
    into v_alias_value;
      v_sql = v_sql || $$ inner join $$ || v_table || $$ on o.project_id = $$||v_alias_value||$$.id$$;
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

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

