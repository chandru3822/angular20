CREATE OR REPLACE FUNCTION flow.check_pps_has_event_with_value(p_project_process_step_id integer, p_cfga integer,
                                                               p_value_to_check text)
  returns boolean AS
$BODY$
declare
  v_request_is_valid boolean;
  v_data_type_id     int;
BEGIN

  --check that the pps company id and the cfga company id are the same in case the user screwed it up
  select (select ps.company_id
          from flow.project_process_step pps
                 inner join flow.process_step ps on pps.process_step_id = ps.id
          where pps.id = p_project_process_step_id) = (select cot.company_id
                                                       from flow.custom_field_group_assignment cfga
                                                              inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                                                              inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
                                                       where cfga.id = p_cfga)
  into v_request_is_valid;

  if v_request_is_valid is true then


    select cdt.data_type_id
    into v_data_type_id
    from flow.project_process_step pps
           inner join flow.custom_field_group cfg on cfg.process_step_id = pps.process_step_id
           inner join flow.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
           inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
    where pps.id = p_project_process_step_id
    and cfga.id = p_cfga;

    -- 1,date
    -- 2,timestamp
    -- 3,boolean
    -- 4,numeric
    -- 5,text
    -- 6,integer
    -- 7,integer array
    -- 8,system
    -- 9,System List

    --we return true for 1 or many results so we can limit to 1 here
    if v_data_type_id = 1 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.date_value = p_value_to_check::date
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
    elsif v_data_type_id = 2 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.timestamp_value = p_value_to_check::timestamp
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
    elsif v_data_type_id = 3 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.boolean_value = p_value_to_check::boolean
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
    elsif v_data_type_id = 4 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.numeric_value = p_value_to_check::numeric
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
    elsif v_data_type_id = 5 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.text_value = p_value_to_check
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
    elsif v_data_type_id = 6 then
      select case
               when (select ppsecfv.id
                     from flow.project_process_step_event_custom_field_value ppsecfv
                            inner join flow.project_process_step_event ppse
                                       on ppsecfv.project_process_step_event_id = ppse.id and
                                          ppse.project_process_step_id = 4052423
                     where ppse.archived is false
                       and ppsecfv.custom_field_group_assignment_id = p_cfga
                       and ppsecfv.int_value = p_value_to_check::integer
                     limit 1) is not null then true
               else false end
      into v_request_is_valid;
      --             elsif v_data_type_id = 7 then
      --currently not going to code to work for multi-selects

    end if;
    return v_request_is_valid;
  else
    return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
