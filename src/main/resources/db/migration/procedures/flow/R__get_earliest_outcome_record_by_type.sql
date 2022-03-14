CREATE OR REPLACE FUNCTION brs.get_earliest_outcome_record_by_type(p_project_process_step_event_id integer, p_config_code varchar,
                                                                  p_has_outcome boolean default true)
  RETURNS TABLE
          (
            int_value  integer,
            start_time timestamp,
            id         integer
          )
AS
$BODY$
BEGIN

  case when p_config_code is not null or p_has_outcome is true then
    return query
      select distinct on (ppse2.start_time ,ppsecfv2.int_value) ppsecfv2.int_value, ppse2.start_time, ppse2.id
      from flow.project_process_step_event ppse
             inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
             inner join flow.project_process_step pps1 on pps1.project_id = pps.project_id and pps1.process_step_id = 1
             inner join flow.project_process_step_event ppse2 on ppse2.project_process_step_id = pps1.id
             inner join flow.project_process_step_event_custom_field_value ppsecfv2
                        on ppse2.id = ppsecfv2.project_process_step_event_id
                          and ppsecfv2.custom_field_group_assignment_id = 4
      where ppse.id = p_project_process_step_event_id
        and case
              when p_config_code is not null and p_config_code = 'OUTCOME_NOT_PITCHED_MISSED' then
                  ppsecfv2.int_value not in (select unnest(string_to_array(value, ',')::int[])
                                             from flow.company_configuration_value
                                             where code = p_config_code)
              when p_config_code is not null and p_config_code != 'OUTCOME_NOT_PITCHED_MISSED' then
                  ppsecfv2.int_value in (select unnest(string_to_array(value, ',')::int[])
                                         from flow.company_configuration_value
                                         where code = p_config_code)
              else 1 = 1 end
      order by ppse2.start_time, ppsecfv2.int_value
      limit 1;
    else
      return query
        select distinct on (ppse2.start_time ) null::integer, ppse2.start_time, ppse2.id
        from flow.project_process_step_event ppse
               inner join flow.project_process_step pps on pps.id = ppse.project_process_step_id
               inner join flow.project_process_step pps1 on pps1.project_id = pps.project_id and pps1.process_step_id = 1
               inner join flow.project_process_step_event ppse2 on ppse2.project_process_step_id = pps1.id
        where ppse.id = p_project_process_step_event_id
        order by ppse2.start_time
        limit 1;
      end case;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

