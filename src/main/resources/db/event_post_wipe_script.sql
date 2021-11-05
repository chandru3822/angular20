-- run these functions
--get_pps_with_actions_and_requirements
--get_project_process_step_event_requirements_with_values
--get_availability_time_slots

--add company event statuses
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values ((select id from flow.event_status_type where event_status_type = 'ACTIVE'), 'Active', 3, 2417170);
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values ((select id from flow.event_status_type where event_status_type = 'ACTIVE'), 'Needs Verification', 3, 2417170);
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values (2, 'Complete', 3, 2417170);
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values (3, 'Cancelled', 3, 2417170);
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values ((select id from flow.event_status_type where event_status_type = 'ACTIVE'), 'Ready to Schedule', 3, 2417170);
insert into flow.company_event_status_type(event_status_type_id, event_status_type, company_id, created_by_id)
values ((select id from flow.event_status_type where event_status_type = 'CANCELLED'), 'Not Complete - Other', 3, 2417170);

-- add the current resource custom fields to be available to events
INSERT INTO flow.custom_field_object_type (custom_field_id, company_object_type_id, created_by_id)
select distinct cfga.custom_field_id,
       (select id from flow.company_object_type where company_id = 3 and object_type_id = (select id from flow.object_type where object_code = 'EVENT')) as company_object_type_id,
       2350555 as created_by_id
from flow.custom_field_group_assignment cfga
       inner join flow.custom_field cf on cfga.custom_field_id = cf.id
where cfga.schedule_field_type_id = 3
  and cfga.archived is false
  and cf.company_id = 3;

--add a temporary column to be dropped after migration
alter table flow.event
add column if not exists temp_cfg_id int;
--add events (adds the default resource custom field as well)
insert into flow.event(event_name, company_id, created_by_id, resource_custom_field_id, temp_cfg_id)
select cfg.group_name || ' - ' || ps.process_step_name,
       3,
       2350555,
       (select custom_field_id from flow.custom_field_group_assignment cfga
         where cfga.custom_field_group_id = cfg.id
         and cfga.archived is false
         and cfga.schedule_field_type_id = 3),
       cfg.id
from flow.custom_field_group cfg
       inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
       inner join flow.process_step ps on cfg.process_step_id = ps.id
where cfg.event_type_id is not null
  and cfg.archived is false
  and cot.company_id = 3;

-- add event statuses to events
insert into flow.event_company_event_status_type(event_id, company_event_status_type_id, created_by_id)
select id,
       (select id from flow.company_event_status_type where company_id = 3 and event_status_type = 'Active'),
       2350555
from flow.event;

--add process step events
insert into flow.process_step_event(process_step_id, event_id, initial_company_event_status_type_id, unique_behavior_type_id, display_order, created_by_id)
select (select process_step_id
        from flow.custom_field_group cfg
               inner join flow.process_step ps on ps.id = cfg.process_step_id
        where ps.company_id = 3
          and cfg.archived is false
          and e.temp_cfg_id = cfg.id),
       e.id,
       (select company_event_status_type_id from flow.event_company_event_status_type where event_id = e.id limit 1),
       case when e.event_name = 'Closer Appointment Scheduling - Schedule Closer Appointment' then 1 else null end,
       0,
       2350555
from flow.event e;

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

