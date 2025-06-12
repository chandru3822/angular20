-- Create Post Unqualified Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_unqualified_event_to_klaviyo', null, 2, 'Post Unqualified Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_unqualified_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Unqualified Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_unqualified_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Unqualified Event To Klaviyo'
                      AND company_id = 3
                );
-- Create Post Booked Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_booked_event_to_klaviyo', null, 2, 'Post Booked Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_booked_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Booked Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_booked_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Booked Event To Klaviyo'
                      AND company_id = 3
                );
-- Create Post Final Design Completed Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_final_design_completed_event_to_klaviyo', null, 2, 'Post Final Design Completed Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_final_design_completed_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Final Design Completed Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_final_design_completed_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Final Design Completed Event To Klaviyo'
                      AND company_id = 3
                );
-- Create Post Appointment Set Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_appointment_set_event_to_klaviyo', null, 2, 'Post Appointment Set Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_appointment_set_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Appointment Set Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_appointment_set_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Appointment Set Event To Klaviyo'
                      AND company_id = 3
                );

-- Create Post Pitched Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_pitched_event_to_klaviyo', null, 2, 'Post Pitched Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_pitched_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Pitched Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_pitched_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Pitched Event To Klaviyo'
                      AND company_id = 3
                );
-- Create Post Substantial Completion Event To Klaviyo function
insert into flow.db_function (function_name, return_data_type_id, db_function_type_id, display_name, run_in_backend, description, process_step_actionable, event_actionable)
select 'brs.post_substantial_completion_event_to_klaviyo', null, 2, 'Post Substantial Completion Event To Klaviyo', true, null, true, true
  where not exists (
            select id from flow.db_function where function_name = 'brs.post_substantial_completion_event_to_klaviyo'
        );

INSERT INTO flow.company_function (company_function_name, db_function_id, company_id)
SELECT 'Post Substantial Completion Event To Klaviyo',
       (SELECT id FROM flow.db_function WHERE function_name = 'brs.post_substantial_completion_event_to_klaviyo'),
       3
  WHERE NOT EXISTS (
                    SELECT id
                    FROM flow.company_function
                    WHERE company_function_name = 'Post Substantial Completion Event To Klaviyo'
                      AND company_id = 3
                );
