drop view if exists brs.closer_dashboard_drilldown_vw;
create or replace view brs.closer_dashboard_drilldown_vw as
(
select pd.closer_name                 as owner_name,
       o.org_name                        office,
       pd.project_state_abbreviation     state,
       pd.company_project_status_type as status_type,
       pd.contact_name                as customer_name,
       pd.contact_id,
       pd.project_id,
       up.user_id, --this is the closer user id (i am pretty sure)
       up.org_id,
       pd.source_name,
       pd.system_size,
       pd.closer_user_position_id,
       pd.primary_financier_name         financier,
       ppse.start_time                   appointment_date,
       pd.cancelled_date,
       lov.name                          appointment_outcome,
       pps.process_step_id,
       coalesce(ppscfv2.timestamp_value, ppsea.date_created) as checked_in_time,
       ppscfv1.int_value              as closer_appt_outcome_int_value,
       pd.closer_appointment_start
from brs.project_details pd
       inner join flow.user_position up on up.id = pd.closer_user_position_id
       inner join flow.org o on o.id = up.org_id
       inner join flow.project_process_step pps on pps.project_id = pd.project_id
       inner join flow.project_process_step_event ppse
                  on ppse.project_process_step_id = pps.id
       left join flow.project_process_step_event_custom_field_value ppscfv1
                 on ppse.id = ppscfv1.project_process_step_event_id and
                    ppscfv1.custom_field_group_assignment_id = 4 -- Closer Appointment Outcome
       left join flow.list_of_value lov on lov.id = ppscfv1.int_value
       left join flow.project_process_step_event_action ppsea on ppsea.project_process_step_event_id = ppse.id and
                                                                 ppsea.process_step_event_action_id =
                                                                 408 --408 = check in action on event
       left join flow.project_process_step_event_custom_field_value ppscfv2
                 on ppse.id = ppscfv2.project_process_step_event_id and ppscfv2.custom_field_group_assignment_id = 1377
where pd.company_id = 3
  and pps.process_step_id = 1
  );
