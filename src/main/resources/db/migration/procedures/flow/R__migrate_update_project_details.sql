CREATE OR REPLACE function flow.migrate_update_project_details()
  returns void as
$$
BEGIN

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
    inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.setter_milestone_pay_ppsecfv_id
    where setter_milestone_pay is not null and setter_milestone_pay_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set setter_milestone_pay_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_pitched_ppsecfv_id
    where first_appointment_pitched is not null and first_appointment_pitched_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_pitched_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_missed_ppsecfv_id
    where first_appointment_missed is not null and first_appointment_missed_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_missed_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_not_pitched_or_missed_ppsecfv_id
    where first_appointment_not_pitched_or_missed is not null and first_appointment_not_pitched_or_missed_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_not_pitched_or_missed_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.site_survey_verified_date_ppsecfv_id
    where site_survey_verified_date is not null and site_survey_verified_date_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set site_survey_verified_date_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.appointment_check_in_ppsecfv_id
    where pd.appointment_check_in is not null and appointment_check_in_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set appointment_check_in_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;



  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.ahj_final_inspection_verified_ppsecfv_id
    where pd.ahj_final_inspection_verified is not null and ahj_final_inspection_verified_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set ahj_final_inspection_verified_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.ahj_inspection_scheduled_date_ppsecfv_id
    where pd.ahj_inspection_scheduled_date is not null and ahj_inspection_scheduled_date_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set appointment_check_in_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.installation_scheduled_ppsecfv_id
    where pd.installation_scheduled is not null and installation_scheduled_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set installation_scheduled_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

