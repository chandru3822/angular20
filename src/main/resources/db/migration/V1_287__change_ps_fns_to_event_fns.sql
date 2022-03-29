--334 = company_function_id
--64 = db_function_id
--drop function so we can re-add it differently
drop function if exists  brs.populate_proposal_due_date(integer, integer);

--add the parameter description field
alter table flow.db_function_param
add column if not exists description text;

--archive any ps actions using this function
update flow.process_step_action_company_function
  set archived = true
where company_function_id = 334;

-- change from process step actionable to event actionable
update flow.db_function
  set process_step_actionable = false,
      event_actionable = true,
      function_name = 'flow.populate_pps_value_from_event',
      display_name = 'Populate PPS Value From Event',
      description = 'Take a given value from the event and populates a value on a project process step with it.'
where id = 64;

update flow.company_function
  set company_function_name = 'Populate PPS Value From Event'
where id = 334;

--change fn to pass in ppsEventId (remove old ppsId param and add new ppsEventId one)
update flow.db_function_param
set archived = true
where db_function_id = 64
and system_value_id = 3;

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select 64, 'Project Process Step Event ID', 1, 6, 1, 5
where not exists (
  select id from flow.db_function_param
  where db_function_id = 64
  and system_value_id = 5
  )
;

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id, description)
select 64, 'Property to Save', 1, 5, 2, null, 'Options are: start_time, end_time, resource_id, resource_name, status_id, status_type'
where not exists (
  select id from flow.db_function_param
  where db_function_id = 64
    and parameter_type_id = 2
    and data_type_id = 5
  )
;

-- add this child function to various actions:
--4 = request proposal
insert into flow.process_step_event_action_company_function(process_step_event_action_id, company_function_id, created_by_id, modified_by_id, display_order)
select 4,334, 2417170, 2417170, 0
where not exists (select id from flow.process_step_event_action_company_function
  where company_function_id = 334
  and process_step_event_action_id = 4
  );
--5 = request regen
insert into flow.process_step_event_action_company_function(process_step_event_action_id, company_function_id, created_by_id, modified_by_id, display_order)
select 5, 334, 2417170, 2417170, 0
where not exists (select id from flow.process_step_event_action_company_function
                  where company_function_id = 334
                    and process_step_event_action_id = 5
  );
--3 = Request Pre-Design Rework
insert into flow.process_step_event_action_company_function(process_step_event_action_id, company_function_id, created_by_id, modified_by_id, display_order)
select 3, 334, 2417170, 2417170, 0
where not exists (select id from flow.process_step_event_action_company_function
                  where company_function_id = 334
                    and process_step_event_action_id = 3
  );
--1 = schedule
insert into flow.process_step_event_action_company_function(process_step_event_action_id, company_function_id, created_by_id, modified_by_id, display_order)
select 1, 334, 2417170, 2417170, 0
where not exists (select id from flow.process_step_event_action_company_function
                  where company_function_id = 334
                    and process_step_event_action_id = 1
  );
--ps event 14 - Action:
-- Request Proposal, 4
-- Request Regen,  5
-- Request Pre-Design Rework, 3
-- Schedule 1

-- change all of these actions to change ps status to Pending Event: Request Proposal, Request Regen, Request Pre-Design Rework to NOT change process step status
update flow.process_step_event_action
set company_process_step_status_type_id = (select id
                                           from flow.company_process_step_status_type
                                           where process_step_status_type = 'Pending Event'
                                             and company_id = 3
  )
where id in (4,5,3,1);



-- SEND TEXT TO SCHEDULED RESOURCE STUFF
drop function if exists  brs.send_text_to_scheduled_resource(integer, integer, integer);

--UPDATE FROM PS ACTIONABLE TO EVENT ACTIONABLE
update flow.db_function
set process_step_actionable = false,
    event_actionable = true
where id = 54;

--change fn to pass in ppsEventId (remove old ppsId param and add new ppsEventId one)
update flow.db_function_param
set archived = true
where db_function_id = 54
  and system_value_id = 3;

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select 54, 'Project Process Step Event ID', 0, 6, 1, 5
where not exists (
  select id from flow.db_function_param
  where db_function_id = 54
    and system_value_id = 5
  )
;

--not sure how this got set to true, update it back
update flow.db_function
set process_step_actionable = false
where function_name = 'flow.create_child_ps_from_event';
