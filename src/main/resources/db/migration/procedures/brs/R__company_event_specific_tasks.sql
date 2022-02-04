CREATE OR REPLACE FUNCTION brs.company_event_specific_tasks(p_project_id integer,
                                                            p_project_process_step_event_id integer,
                                                            p_project_process_step_event_custom_field_id integer,
                                                            p_outcome_id integer,
                                                            p_cfga_id integer)
  RETURNS void AS

$BODY$
DECLARE
  v_timestamp_value timestamp;
BEGIN
  if p_cfga_id in (21506, 4) then

    select start_time
    into v_timestamp_value
    from flow.project_process_step_event ppse3
           inner join flow.project_process_step_event_custom_field_value ppsecfv
                      on ppse3.id = ppsecfv.project_process_step_event_id
    where ppse3.id = p_project_process_step_event_id;

    if p_outcome_id is not null then
      update brs.project_details
      set first_appointment_id      = p_outcome_id,
          first_appointment_ppse_id = p_project_process_step_event_id
      where project_id = p_project_id
        and (first_appointment_id is null or
             (first_appointment_ppse_id is not null and first_appointment_ppse_id = p_project_process_step_event_id));
    end if;

    if p_outcome_id in (2, 1139, 1140) then

      update brs.project_details
      set setter_milestone_pay            = coalesce(v_timestamp_value, now()),
          setter_milestone_pay_ppsecfv_id = p_project_process_step_event_custom_field_id
      where project_id = p_project_id
        and (setter_milestone_pay is null or
             (setter_milestone_pay_ppsecfv_id is not null and
              setter_milestone_pay_ppsecfv_id = p_project_process_step_event_custom_field_id));

      update brs.project_details
      set first_appointment_pitched            = coalesce(v_timestamp_value, now()),
          first_appointment_pitched_id         = p_outcome_id,
          first_appointment_pitched_ppsecfv_id = p_project_process_step_event_custom_field_id
      where project_id = p_project_id
        and (first_appointment_pitched is null or
             (first_appointment_pitched_ppsecfv_id is not null and
              first_appointment_pitched_ppsecfv_id = p_project_process_step_event_custom_field_id));
    elsif p_outcome_id in (3) then
      update brs.project_details
      set setter_milestone_pay            = coalesce(v_timestamp_value, now()),
          setter_milestone_pay_ppsecfv_id = p_project_process_step_event_custom_field_id
      where project_id = p_project_id
        and (setter_milestone_pay is null or
             (setter_milestone_pay_ppsecfv_id is not null and
              setter_milestone_pay_ppsecfv_id = p_project_process_step_event_custom_field_id));

      update brs.project_details
      set first_appointment_missed            = coalesce(v_timestamp_value, now()),
          first_appointment_missed_id         = p_outcome_id,
          first_appointment_missed_ppsecfv_id = p_project_process_step_event_custom_field_id
      where project_id = p_project_id
        and (first_appointment_missed is null or
             (first_appointment_missed_ppsecfv_id is not null and
              first_appointment_missed_ppsecfv_id = p_project_process_step_event_custom_field_id));
    elseif p_outcome_id is not null and
           p_outcome_id not in (2, 3, 1139, 1140) then
      update brs.project_details
      set first_appointment_not_pitched_or_missed            =coalesce(v_timestamp_value, now()),
          first_appointment_not_pitched_or_missed_id         = p_outcome_id,
          first_appointment_not_pitched_or_missed_ppsecfv_id = p_project_process_step_event_custom_field_id
      where project_id = p_project_id
        and (first_appointment_not_pitched_or_missed is null or
             (first_appointment_not_pitched_or_missed_ppsecfv_id is not null and
              first_appointment_not_pitched_or_missed_ppsecfv_id = p_project_process_step_event_custom_field_id));
    end if;
  end if;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
