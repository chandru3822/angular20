drop function if exists brs.populate_values_from_log_history(p_project_id bigint,
                                                             p_user_id bigint,
                                                             p_table_name text,
                                                             p_cfga_log_id bigint,
                                                             p_column_name text,
                                                             p_override_existing boolean,
                                                             p_cfga_id_to_populate bigint);
CREATE OR REPLACE FUNCTION brs.populate_values_from_log_history(p_project_id bigint,
                                                                p_user_id bigint,
                                                                p_table_name text,
                                                                p_cfga_log_id bigint,
                                                                p_column_name text,
                                                                p_override_existing boolean,
                                                                p_cfga_id_to_populate bigint)
  returns boolean AS
$BODY$
declare
  v_log_id bigint;
  v_sql    text;
  v_value  text;

BEGIN

  select ppscfv.int_value
  into v_log_id
  from flow.project_process_step pps
         inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and
                                                                           ppscfv.custom_field_group_assignment_id =
                                                                           p_cfga_log_id
  where pps.project_id = p_project_id
    and pps.main is true;

  if v_log_id is not null then
    v_sql = $$select $$ || p_column_name || $$::text
            from $$ || p_table_name || $$
      where id = $$ || v_log_id;

    begin
      execute v_sql
        into v_value;
    exception when others then
      return false;
    end;

    if v_value is not null then
      perform flow.set_pps_cfv(p_project_id, p_user_id, p_cfga_id_to_populate, v_value, p_override_existing);
    else
      return false;
    end if;
    --raise notice 'v_value %',v_value;
  else
    return false;
  end if;


  return true;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



