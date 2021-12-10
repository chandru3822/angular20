-- run these functions
--get_pps_with_actions_and_requirements
--get_project_process_step_event_requirements_with_values
--get_availability_time_slots

--change the Installer unique behavior to be on Schedule Closer Appt instead of Closer Appt - per M.M. per Judson
update flow.custom_field_group
set unique_behavior_type_id = 2
where process_step_id = 1
  and group_name = 'Closer Appointment Scheduling'
  and archived is false;

--attachment types

--DROPS
-- drop table flow.event cascade;
-- drop table flow.event_attachment_type cascade;
-- drop table flow.event_status_type cascade;
-- drop table flow.company_event_status_type cascade;
-- drop table flow.event_company_event_status_type cascade;
-- drop table flow.process_step_event cascade;
-- drop table flow.project_process_step_event cascade;
-- drop table flow.project_process_step_event_custom_field_value cascade;
-- drop table flow.project_process_step_event_attachment cascade;
-- drop table flow.process_step_event_action cascade;
-- drop table flow.process_step_event_action_field cascade;
-- drop table flow.project_process_step_event_action cascade;
-- drop table flow.process_step_event_requirement cascade;
-- drop table flow.process_step_event_logic cascade;
-- drop table flow.event_requirement_param_dynamic_value cascade;

