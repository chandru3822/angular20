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
  v_convert_date      boolean default false;
BEGIN
  if p_contains_children then
    for v_secondary_records in
      select dvcvc.field_to_update,
             dvcvc.data_type_id,
             flow.get_prepared_value(dvcvc.data_type_id,
                                     flow.get_unique_behavior_value(ubt.unique_behavior_type,
                                                                    p_value::integer, p_id)) as value
      from flow.data_view_child_field_config dvcvc
             inner join flow.unique_behavior_type ubt on dvcvc.unique_behavior_type_id = ubt.id
      where data_view_field_config_id = p_dvfc_id
      loop
        if v_secondary_records.data_type_id is not null and p_data_type_id is not null and
           v_secondary_records.data_type_id = 1 and p_data_type_id = 2 then
          v_convert_date = true;
        end if;
        select flow.prepare_update_data_view_details(p_id, p_sql, p_field_to_update,
                                                     p_value, v_secondary_records.field_to_update,
                                                     v_secondary_records.value,
                                                     p_update_first_value_only,
                                                     p_update_first_value_only_id,
                                                     v_convert_date,
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
                                               false,
                                               p_is_last_row)
  into p_sql;
  return p_sql;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

