CREATE OR REPLACE FUNCTION flow.execute_data_view_field_configs(p_contains_children boolean,
                                                                p_value text,
                                                                p_dvfc_id integer,
                                                                p_id integer,
                                                                p_sql text,
                                                                p_field_to_update varchar,
                                                                p_update_first_value_only boolean,
                                                                p_update_first_value_only_id varchar,
                                                                p_is_last_row boolean,
                                                                p_data_type_id integer)
  RETURNS text
AS
$BODY$
declare
  v_secondary_records record;
  v_object_code       varchar;
BEGIN
  if p_contains_children then
    select ot.object_code
    from flow.data_view_field_config dvfc
           inner join flow.default_field df on dvfc.default_field_id = df.id
           inner join flow.object_type ot on df.object_type_id = ot.id
    where dvfc.id = p_dvfc_id
    union
    select ot.object_code
    from flow.data_view_field_config dvfc
           inner join flow.custom_field_group_assignment cfga on dvfc.custom_field_group_assignment_id = cfga.id
           inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
           inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
           inner join flow.object_type ot on cot.object_type_id = ot.id
    where dvfc.id = p_dvfc_id
    into v_object_code;

--      raise notice 'p_id = %',p_id;
--     raise notice 'p_value = %',p_value;
--     raise notice 'v_object_code = %',v_object_code;
--     raise notice 'p_dvfc_id = %',p_dvfc_id;
    for v_secondary_records in
      select dvcvc.field_to_update,
             ubt.return_data_type_id,
             flow.get_prepared_value(ubt.return_data_type_id,
                                     flow.get_unique_behavior_value(ubt.unique_behavior_code,
                                                                    p_value::text, p_id,v_object_code))  as value
      from flow.data_view_child_field_config dvcvc
             inner join flow.unique_behavior_type ubt on dvcvc.unique_behavior_type_id = ubt.id
      where data_view_field_config_id = p_dvfc_id
      loop

        select flow.prepare_update_data_view_details(p_id, p_sql, p_field_to_update,
                                                     p_value, v_secondary_records.field_to_update::text,
                                                     v_secondary_records.value::text,
                                                     p_update_first_value_only,
                                                     p_update_first_value_only_id,
                                                     p_is_last_row)
        into p_sql;
      end loop;
  end if;

  select flow.get_prepared_value(p_data_type_id, p_value)
  into p_value;
  select flow.prepare_update_data_view_details(p_id, p_sql, p_field_to_update,
                                               p_value, null, null,
                                               p_update_first_value_only,
                                               p_update_first_value_only_id,
                                               p_is_last_row)
  into p_sql;

  return p_sql;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

