CREATE OR REPLACE function flow.migrate_update_project_details()
  returns void as
$$
BEGIN
raise notice '1';
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

raise notice '2';
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


raise notice '3';
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

raise notice '4';
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

raise notice '5';
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


raise notice '6';
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


raise notice '7';
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


raise notice '8';
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

raise notice '9';
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


raise notice '10';
  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.online_submission_time_ppsecfv_id
    where pd.online_submission_time is not null and online_submission_time_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set online_submission_time_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;


raise notice '11';
  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.first_appointment_id_ppsecfv_id
    where pd.first_appointment_id is not null and first_appointment_id_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set first_appointment_id_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

raise notice '12';
  with update_data as (
    select ppse2.id as project_process_step_event_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.id = pd.ahj_inspection_start_time_ppse_id
           inner join flow.project_process_step_event ppse2  on ppse2.project_process_step_id = ppscfv.project_process_step_id
    where pd.ahj_inspection_start_time is not null and ahj_inspection_start_time_ppse_id is not null
  )
  update brs.project_details pd2
  set ahj_inspection_start_time_ppse_id = ud.project_process_step_event_id
  from update_data ud
  where ud.project_details_id = pd2.id;

raise notice '13';
  with update_data as (
    select ppse2.id as project_process_step_event_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.id = pd.permit_pack_submittal_end_time_ppse_id
           inner join flow.project_process_step_event ppse2  on ppse2.project_process_step_id = ppscfv.project_process_step_id
    where pd.permit_pack_submittal_end_time is not null and permit_pack_submittal_end_time_ppse_id is not null
  )
  update brs.project_details pd2
  set permit_pack_submittal_end_time_ppse_id = ud.project_process_step_event_id
  from update_data ud
  where ud.project_details_id = pd2.id;

raise notice '14';
  with update_data as (
    select ppsecfv.id as project_process_step_event_custom_field_value_id,
           pd.id as project_details_id
    from brs.project_details pd
           inner join flow.project_process_step_event_custom_field_value ppsecfv on ppsecfv.migrate_project_process_step_custom_field_value_id = pd.substantial_completion_date_ppsecfv_id
    where pd.substantial_completion_date is not null and substantial_completion_date_ppsecfv_id is not null
  )
  update brs.project_details pd2
  set substantial_completion_date_ppsecfv_id = ud.project_process_step_event_custom_field_value_id
  from update_data ud
  where ud.project_details_id = pd2.id;

raise notice '15';
  with update_data as (
    select ppse.id as project_process_step_event_id,pd.id as project_details_id
    from flow.project_process_step_event ppse
    inner join brs.project_details pd on pd.first_appointment_ppse_id = ppse.project_process_step_id
    and first_appointment is not null
  )
  update brs.project_details pd3
        set first_appointment_ppse_id = ud2.project_process_step_event_id
  from update_data ud2
        where pd3.id = ud2.project_details_id;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

