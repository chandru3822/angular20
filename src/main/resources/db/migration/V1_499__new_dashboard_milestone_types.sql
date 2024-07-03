insert into brs.dashboard_milestone_type (dashboard_milestone_type, dashboard_milestone_code, created_by_id, modified_by_id)
select 'Closer Dashboard FDC Pipeline', 'CLOSER_DASHBOARD_FDC_PIPELINE', 2384850, 2384850 where not exists (select id from brs.dashboard_milestone_type where dashboard_milestone_code = 'CLOSER_DASHBOARD_FDC_PIPELINE');

--update missing sequence
SELECT setval('brs.dashboard_milestone_id_seq',
              COALESCE((SELECT MAX(id) + 1
                        FROM brs.dashboard_milestone), 1), false);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Total Planned Appointments', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Total Planned Appointments' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Cancelled in advance', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Ineligible for solar', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Total Eligible Planned Appointments', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Pitched', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Pitched' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Homeowner no show', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Homeowner no show' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Closer missed appointment', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Turned away at the door', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Turned away at the door' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Yet to occur', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Yet to occur' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Non-dispositioned appointments', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Rescheduled', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Rescheduled' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'No utility bill', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'No utility bill' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Credits run', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Credits run' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Credits passed', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Credits passed' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Bookings Complete', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Bookings Complete' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Site Surveys Verified', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Site Surveys Verified' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Final Designs sent to Homeowner', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Final Designs Approved', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Final Designs Completed', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Completed' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone (dashboard_milestone_type_id, name, display_order, created_by_id, modified_by_id)
select 2, 'Installations Completed', 0, 2384850, 2384850
where not exists (select id from brs.dashboard_milestone where name = 'Installations Completed' and dashboard_milestone_type_id = 2);

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Total Planned Appointments' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Total Planned Appointments' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Rescheduled' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Rescheduled' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Rescheduled' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Rescheduled' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Homeowner no show' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Homeowner no show' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Homeowner no show' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Homeowner no show' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Turned away at the door' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Turned away at the door' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Turned away at the door' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Turned away at the door' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'No utility bill' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'No utility bill' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'No utility bill' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'No utility bill' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Yet to occur' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Yet to occur' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Yet to occur' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Yet to occur' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Pitched' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Pitched' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Pitched' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Pitched' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2), 'Event ID', 6, 'project_process_step_event_id', 2384850, 2384850, 7
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Event ID' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                         where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Credits run' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Credits run' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Credits run' and dashboard_milestone_type_id = 2), 'Credit Decision Date', 2, 'credit_decision_date', 2384850, 2384850, 14
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Credit Decision Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                     where name = 'Credits run' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Credits passed' and dashboard_milestone_type_id = 2), 'Appointment Outcome', 5, 'appointment_outcome', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Appointment Outcome' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                    where name = 'Credits passed' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Credits passed' and dashboard_milestone_type_id = 2), 'Credit Decision Date', 2, 'credit_decision_date', 2384850, 2384850, 14
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Credit Decision Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                     where name = 'Credits passed' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Credits passed' and dashboard_milestone_type_id = 2), 'Credit Check', 5, 'credit_check', 2384850, 2384850, 15
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Credit Check' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                             where name = 'Credits passed' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Bookings Complete' and dashboard_milestone_type_id = 2), 'Installation Agreement Signed Date', 2, 'installation_agreement_signed_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Installation Agreement Signed Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                                   where name = 'Bookings Complete' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Bookings Complete' and dashboard_milestone_type_id = 2), 'Site Survey Date', 2, 'site_survey_completed_date', 2384850, 2384850, 14
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Site Survey Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                 where name = 'Bookings Complete' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Site Surveys Verified' and dashboard_milestone_type_id = 2), 'Site Survey Verified Date', 2, 'site_survey_verified_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Site Survey Verified Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                          where name = 'Site Surveys Verified' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2), 'FD Sent to Homeowner Date', 2, 'final_design_sent_to_homeowner_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'FD Sent to Homeowner Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                          where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2), 'Final Design Approved', 2, 'final_design_signed_date', 2384850, 2384850, 14
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Final Design Approved' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                      where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2), 'Final Design Approved', 2, 'final_design_signed_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Final Design Approved' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                      where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2), 'Proof of HOI Obtained Date', 2, 'proof_of_homeowners_insurance_obtained_date', 2384850, 2384850, 14
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Proof of HOI Obtained Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                           where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2), 'Utility Bill Verified Date', 2, 'utility_bill_verified_date', 2384850, 2384850, 15
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Utility Bill Verified Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                           where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2), 'Financial Agreement Signed', 2, 'financial_agreement_signed_date', 2384850, 2384850, 16
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Financial Agreement Signed' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                           where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2));

-- TODO: don't know the data_dype_id for this one
insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2), 'Cash Down Payment', 2, 'cash_down_payment', 2384850, 2384850, 17
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Cash Down Payment' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                  where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Final Designs Completed' and dashboard_milestone_type_id = 2), 'Final Design Completed', 2, 'final_design_complete_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Final Design Completed' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                       where name = 'Final Designs Completed' and dashboard_milestone_type_id = 2));

insert into brs.dashboard_milestone_column (dashboard_milestone_id, title, data_type_id, display_value, created_by_id, modified_by_id, display_order)
select (select id from brs.dashboard_milestone
        where name = 'Installations Completed' and dashboard_milestone_type_id = 2), 'Substantial Completion Date', 2, 'substantial_completion_date', 2384850, 2384850, 13
where not exists (select id from brs.dashboard_milestone_column
                  where title = 'Substantial Completion Date' and dashboard_milestone_id = (select id from brs.dashboard_milestone
                                                                                            where name = 'Installations Completed' and dashboard_milestone_type_id = 2));

alter table brs.funnel add column if not exists dashboard_milestone_id bigint references brs.dashboard_milestone(id);

update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Total Planned Appointments' and dashboard_milestone_type_id = 2) where name = 'Total Planned Appointments' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Cancelled in advance' and dashboard_milestone_type_id = 2) where name = 'Cancelled in advance' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Total Eligible Planned Appointments' and dashboard_milestone_type_id = 2) where name = 'Total Eligible Planned Appointments' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Pitched' and dashboard_milestone_type_id = 2) where name = 'Pitched' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Homeowner no show' and dashboard_milestone_type_id = 2) where name = 'Homeowner no show' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Ineligible for solar' and dashboard_milestone_type_id = 2) where name = 'Ineligible for solar' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Closer missed appointment' and dashboard_milestone_type_id = 2) where name = 'Closer missed appointment' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Turned away at the door' and dashboard_milestone_type_id = 2) where name = 'Turned away at the door' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Yet to occur' and dashboard_milestone_type_id = 2) where name = 'Yet to occur' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Non-dispositioned appointments' and dashboard_milestone_type_id = 2) where name = 'Non-dispositioned appointments' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Rescheduled' and dashboard_milestone_type_id = 2) where name = 'Rescheduled' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'No utility bill' and dashboard_milestone_type_id = 2) where name = 'No utility bill' and funnel_type_id = 1;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Credits run' and dashboard_milestone_type_id = 2) where name = 'Credits run' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Credits passed' and dashboard_milestone_type_id = 2) where name = 'Credits passed' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Bookings Complete' and dashboard_milestone_type_id = 2) where name = 'Bookings Complete' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Site Surveys Verified' and dashboard_milestone_type_id = 2) where name = 'Site Surveys Verified' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Final Designs sent to Homeowner' and dashboard_milestone_type_id = 2) where name = 'Final Designs sent to Homeowner' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Final Designs Approved' and dashboard_milestone_type_id = 2) where name = 'Final Designs Approved' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Final Designs Completed' and dashboard_milestone_type_id = 2) where name = 'Final Designs Completed' and funnel_type_id = 3;
update brs.funnel set dashboard_milestone_id = (select id from brs.dashboard_milestone where name = 'Installations Completed' and dashboard_milestone_type_id = 2) where name = 'Installations Completed' and funnel_type_id = 3;

--this is from what should have been 502 but there are issues with that.
update brs.dashboard_milestone
set major_milestone = true
where dashboard_milestone_type_id = 2
  and name in ('Total Planned Appointments',
               'Total Eligible Planned Appointments',
               'Pitched',
               'Bookings Complete');



update brs.dashboard_milestone set display_order = 0 where name = 'Total Planned Appointments';
update brs.dashboard_milestone set display_order = 1 where name = 'Cancelled in advance';
update brs.dashboard_milestone set display_order = 2 where name = 'Ineligible for solar';
update brs.dashboard_milestone set display_order = 3 where name = 'Total Eligible Planned Appointments';
update brs.dashboard_milestone set display_order = 4 where name = 'Rescheduled';
update brs.dashboard_milestone set display_order = 5 where name = 'Homeowner no show';
update brs.dashboard_milestone set display_order = 6 where name = 'Closer missed appointment';
update brs.dashboard_milestone set display_order = 7 where name = 'Turned away at the door';
update brs.dashboard_milestone set display_order = 8 where name = 'No utility bill';
update brs.dashboard_milestone set display_order = 9 where name = 'Non-dispositioned appointments';
update brs.dashboard_milestone set display_order = 10 where name = 'Yet to occur';
update brs.dashboard_milestone set display_order = 11 where name = 'Pitched';
update brs.dashboard_milestone set display_order = 12 where name = 'Credits run';
update brs.dashboard_milestone set display_order = 13 where name = 'Credits passed';
update brs.dashboard_milestone set display_order = 14 where name = 'Bookings Complete';
update brs.dashboard_milestone set display_order = 15 where name = 'Site Surveys Verified';
update brs.dashboard_milestone set display_order = 16 where name = 'Final Designs sent to Homeowner';
update brs.dashboard_milestone set display_order = 17 where name = 'Final Designs Approved';
update brs.dashboard_milestone set display_order = 18 where name = 'Final Designs Completed';
update brs.dashboard_milestone set display_order = 19 where name = 'Installations Completed';

alter table brs.dashboard_milestone
    add column if not exists inverse_trend boolean not null default false;

update brs.dashboard_milestone
set inverse_trend = true
where dashboard_milestone_type_id = 2
  and name in (
               'Cancelled in advance',
               'Ineligible for solar',
               'Rescheduled',
               'Homeowner no show',
               'Closer missed appointment',
               'Turned away at the door',
               'No utility bill',
               'Non-dispositioned appointments'
    );

alter table brs.dashboard_milestone
    add column if not exists archived boolean not null default false;