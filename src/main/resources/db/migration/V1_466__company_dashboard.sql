create table if not exists brs.company_dashboard_daily_metric(
                                                               id bigserial,
                                                               metric_date date,
                                                               first_time_appointment_created bigint,
                                                               planned_appointments bigint,
                                                               pitches bigint,
                                                               bookings bigint,
                                                               site_surveys_verified bigint,
                                                               final_designs_created bigint,
                                                               final_designs_sent bigint,
                                                               final_designs_approved bigint,
                                                               final_designs_completed bigint,
                                                               plan_sets_created bigint,
                                                               permit_packs_created bigint,
                                                               permits_submitted bigint,
                                                               permits_approved bigint,
                                                               installations_made_ready_to_schedule bigint,
                                                               installations_scheduled bigint,
                                                               planned_installations bigint,
                                                               substantial_completions bigint,
                                                               inspections_scheduled bigint,
                                                               planned_inspections bigint,
                                                               inspections_passed bigint,
                                                               inspection_results_submitted bigint,
                                                               final_completions bigint,
                                                               UNIQUE (metric_date)
);

create index if not exists company_dashboard_daily_metric_metric_date_idx
  on brs.company_dashboard_daily_metric (metric_date);


-- create table if not exists flow.cron_job_config_type(
--   id bigserial primary key ,
--   cron_job_config_type varchar(50),
--   cron_job_config_code varchar(50),
--   unique (cron_job_config_type,cron_job_config_code)
-- );
--
-- create table if not exists flow.cron_job_config(
--   id bigserial,
--   last_modified_date timestamp,
--   cron_job_config_type_id bigint references flow.cron_job_config_type(id)
-- );
--
-- insert into flow.cron_job_config_type(cron_job_config_type, cron_job_config_code)
-- (select 'Company Dashboard Daily Metric','COMPANY_DASHBOARD_DAILY_METRIC'
--  where not exists (select id from flow.cron_job_config_type where cron_job_config_code = 'COMPANY_DASHBOARD_DAILY_METRIC'));


CREATE INDEX if not exists project_details_archived_idx
  ON brs.project_details (archived)
  WHERE archived = false;

-- ALTER TABLE brs.project_details
--   ADD COLUMN if not exists permit_pack_submission_date date GENERATED ALWAYS AS (
--     LEAST(
--       (online_submission_time AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain',
--       permit_pack_submittal_verified_date
--     )::date
--     ) STORED;

create index if not exists pd_first_time_appointment_created_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, first_time_appointment_created))::date));

create index if not exists pd_first_time_appointment_created1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, first_time_appointment_created))::date))
where archived is false;

create index if not exists pd_first_appointment1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, first_appointment))::date))
  where archived is false;

create index if not exists pd_first_appointment_pitched1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, first_appointment_pitched))::date))
  where archived is false;

create index if not exists pd_final_design_created_timestamp1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, final_design_created_timestamp))::date))
  where archived is false;

create index if not exists pd_final_design_sent_to_homeowner_date1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, final_design_sent_to_homeowner_date))::date))
  where archived is false;

create index if not exists pd_online_submission_time1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, online_submission_time))::date))
  where archived is false;

create index if not exists wqc_date_entered_queue_ix
  on flow.work_queue_cycle ((timezone('US/Mountain'::text, timezone('UTC'::text, date_entered_queue))::date));

create index if not exists pd_installation_start_time1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, installation_start_time))::date))
  where archived is false;

create index if not exists pd_installation_closeout_start_time1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, installation_closeout_start_time))::date))
  where archived is false;

create index if not exists pd_ahj_inspection_start_time1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, ahj_inspection_start_time))::date))
  where archived is false;

create index if not exists pd_ahj_reinspection_start_time1_mdt_ix
  on brs.project_details ((timezone('US/Mountain'::text, timezone('UTC'::text, ahj_reinspection_start_time))::date))
  where archived is false;


--  CREATE INDEX idx_permit_pack_submission_date ON brs.project_details (permit_pack_submission_date);


drop table if exists brs.dashboard_milestone_column;
drop table if exists brs.dashboard_milestone;
drop table if exists brs.dashboard_milestone_type;

create table if not exists brs.dashboard_milestone_type(
  id bigserial primary key ,
  dashboard_milestone_type text not null,
  dashboard_milestone_code text not null,
  date_created   timestamp default now(),
  date_modified  timestamp default now(),
  created_by_id  bigint
    constraint dashboard_milestone_type_created_by_id_fk
      references flow.user,
  modified_by_id bigint
    constraint dashboard_milestone_type_modified_by_id_fk
      references flow.user
);
CREATE UNIQUE INDEX if not exists dashboard_milestone_code_idx ON brs.dashboard_milestone_type (dashboard_milestone_code);
CREATE UNIQUE INDEX if not exists dashboard_milestone_type_idx ON brs.dashboard_milestone_type (dashboard_milestone_type);


create table if not exists brs.dashboard_milestone(
  id bigserial primary key,
  dashboard_milestone_type_id bigint
    constraint dashboard_milestone_dashboard_milestone_type_id_fk
    references brs.dashboard_milestone_type,
  name text not null,
  major_milestone boolean not null default false,
  display_order integer not null,
  date_created   timestamp default now(),
  date_modified  timestamp default now(),
  created_by_id  bigint
    constraint dashboard_milestone_created_by_id_fk
      references flow.user,
  modified_by_id bigint
    constraint dashboard_milestone_modified_by_id_fk
      references flow.user

);
CREATE UNIQUE INDEX if not exists dashboard_milestone_type_id_name_idx ON brs.dashboard_milestone (dashboard_milestone_type_id,name);
CREATE INDEX if not exists dashboard_milestone_type_id_idx ON brs.dashboard_milestone (dashboard_milestone_type_id);
CREATE INDEX if not exists dashboard_milestone_type_name_idx ON brs.dashboard_milestone (name);

create table if not exists brs.dashboard_milestone_column(
      id bigserial primary key ,
      dashboard_milestone_id bigint
        constraint dashboard_milestone_column_dashboard_milestone_id_fk
        references brs.dashboard_milestone,
  title text not null,
  data_type_id bigint not null
    constraint dashboard_milestone_column_data_type_id_fk
    references flow.data_type,
  display_value text not null,
  display_order integer not null default 1,
  use_date_in_where_clause boolean not null default true,
  use_greatest boolean,
      date_created   timestamp default now(),
      date_modified  timestamp default now(),
      created_by_id  bigint
        constraint dashboard_milestone_column_created_by_id_fk
          references flow.user,
      modified_by_id bigint
        constraint dashboard_milestone_column_modified_by_id_fk
          references flow.user
);


CREATE INDEX if not exists dashboard_milestone_id_idx ON brs.dashboard_milestone_column (dashboard_milestone_id);
CREATE INDEX if not exists data_type_id_idx ON brs.dashboard_milestone_column (data_type_id);


insert into brs.dashboard_milestone_type(dashboard_milestone_type, dashboard_milestone_code, created_by_id, modified_by_id)
(SELECT 'Company Dashboard','COMPANY_DASHBOARD',2384850,2384850
 WHERE not exists (select id from brs.dashboard_milestone_type
                             where dashboard_milestone_code = 'COMPANY_DASHBOARD'));


  insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                      created_by_id, modified_by_id,major_milestone)
  (select 1,(select id from brs.dashboard_milestone_type
                             where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'First Time Appointments Created',1,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'First Time Appointments Created'));


insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
(select dm.id,'Appointments Created Date',2,'first_time_appointment_created',2384850,2384850
 from brs.dashboard_milestone dm
 where dm.name = 'First Time Appointments Created' and
       not exists (select id from brs.dashboard_milestone_column
                             where title = 'Appointments Created Date'));

  insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                      created_by_id, modified_by_id,major_milestone)
    (select 2,(select id from brs.dashboard_milestone_type
             where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
            'Planned Appointments',2,2384850,2384850,false
     where not exists (select id from brs.dashboard_milestone where name = 'Planned Appointments'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Appointment Date',2,'first_appointment',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Planned Appointments'  and
         not exists (select id from brs.dashboard_milestone_column
                     where title = 'Appointment Date'));



  insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                      created_by_id, modified_by_id,major_milestone)
    (select 3,(select id from brs.dashboard_milestone_type
             where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
            'Pitches',3,2384850,2384850,false
     where not exists (select id from brs.dashboard_milestone where name = 'Pitches'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order)
  (select dm.id,'Appointment Date',2,'first_appointment_pitched',2384850,2384850,1
   from brs.dashboard_milestone dm
   where dm.name = 'Pitches' and
         not exists (select id from brs.dashboard_milestone_column
                     where title = 'Appointment Date' and display_value = 'first_appointment_pitched'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,use_date_in_where_clause,display_order)
  (select dm.id,'Appointment Outcome',5,'appointment_outcome',2384850,2384850,false,2
   from brs.dashboard_milestone dm
   where dm.name = 'Pitches' and
         not exists (select id from brs.dashboard_milestone_column
                     where title = 'Appointment Outcome'));



insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 4,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Bookings',4,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Bookings'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Installation Agreement Signed Date',1,'installation_agreement_signed_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Bookings'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Installation Agreement Signed Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 5,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Site Surveys Verified',5,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Site Surveys Verified'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Site Survey Verified Date',1,'site_survey_verified_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Site Surveys Verified'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Site Survey Verified Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 6,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Final Designs Created',6,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Created'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Final Design Created Date',2,'final_design_created_timestamp',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Final Designs Created'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Final Design Created Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 7,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Final Designs Sent',7,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Sent'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Final Design Sent to Homeowner Date',2,'final_design_sent_to_homeowner_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Final Designs Sent'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Final Design Sent to Homeowner Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 8,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Final Designs Approved',8,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Approved'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Final Design Approved Date',1,'final_design_signed_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Final Designs Approved'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Final Design Approved Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 9,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Final Designs Completed',9,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Final Designs Completed'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Final Design Completed Date',1,'final_design_complete_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Final Designs Completed'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Final Design Completed Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 10,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Plan Sets Created',10,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Plan Sets Created'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Plan Set Created Date',1,'plan_set_created_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Plan Sets Created'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Plan Set Created Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 11,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Permit Packs Created',11,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Permit Packs Created'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Permit Pack Complete Date',1,'permit_pack_complete',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Permit Packs Created'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Permit Pack Complete Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 12,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Permits Submitted',12,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Permits Submitted'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,use_greatest)
  (select dm.id,'Permit Submitted Date',1,'permit_pack_submittal_verified_date',2384850,2384850,false
   from  brs.dashboard_milestone dm
   where dm.name = 'Permits Submitted'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Permit Submitted Date'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,use_greatest)
  (select dm.id,'Online Submission Time',2,'online_submission_time',2384850,2384850,false
   from  brs.dashboard_milestone dm
   where dm.name = 'Permits Submitted'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Online Submission Time'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 13,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Permits Approved',13,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Permits Approved'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Permit Approved Date',1,'permit_approved_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Permits Approved'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Permit Approved Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 22,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Installations Made Ready to Schedule',14,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Installations Made Ready to Schedule'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Ready to Schedule Installation Date',1,'date_entered_queue',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Installations Made Ready to Schedule'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Installation Scheduled Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 14,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Installations Scheduled',15,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Installations Scheduled'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order)
  (select dm.id,'Installation Scheduled Date',1,'installation_scheduled',2384850,2384850,1
   from  brs.dashboard_milestone dm
   where dm.name = 'Installations Scheduled'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Installation Scheduled Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 15,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Planned Installations',16,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Planned Installations'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,use_greatest)
  (select dm.id,'Installation Date',2,'installation_start_time',2384850,2384850,true
   from  brs.dashboard_milestone dm
   where dm.name = 'Planned Installations'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Installation Date'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order,use_greatest)
  (select dm.id,'Installation Closeout Date',2,'installation_closeout_start_time',2384850,2384850,2,true
   from  brs.dashboard_milestone dm
   where dm.name = 'Planned Installations'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Installation Closeout Date'));

insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 16,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Substantial Completions',17,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Substantial Completions'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order)
  (select dm.id,'Substantial Completion Date',1,'substantial_completion_date',2384850,2384850,1
   from  brs.dashboard_milestone dm
   where dm.name = 'Substantial Completions'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Substantial Completion Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 17,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Inspections Scheduled',18,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Inspections Scheduled'));


insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order)
  (select dm.id,'AHJ Inspection Scheduled Date',1,'ahj_inspection_scheduled_date',2384850,2384850,1
   from  brs.dashboard_milestone dm
   where dm.name = 'Inspections Scheduled'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'AHJ Inspection Scheduled Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 18,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Planned Inspections',19,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Planned Inspections'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'AHJ Inspection Date',2,'ahj_inspection_start_time',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Planned Inspections'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'AHJ Inspection Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 19,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Inspections Passed',20,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Inspections Passed'));


insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'AHJ Final Inspection Verified Date',1,'ahj_final_inspection_verified',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Inspections Passed'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'AHJ Final Inspection Verified Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 20,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Inspection Results Submitted',21,2384850,2384850,false
   where not exists (select id from brs.dashboard_milestone where name = 'Inspection Results Submitted'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order,use_greatest)
  (select dm.id,'Verified Inspection Approval Received by Utility Date',1,'verified_inspection_approval_received_by_utility_date',2384850,2384850,2,false
   from  brs.dashboard_milestone dm
   where dm.name = 'Inspection Results Submitted'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Verified Inspection Approval Received by Utility Date'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id,display_order,use_greatest)
  (select dm.id,'AHJ Inspection Approval Submitted Date',1,'ahj_inspection_approval_submitted_date',2384850,2384850,1,false
   from  brs.dashboard_milestone dm
   where dm.name = 'Inspection Results Submitted'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'AHJ Inspection Approval Submitted Date'));


insert into brs.dashboard_milestone(id,dashboard_milestone_type_id, name, display_order,
                                    created_by_id, modified_by_id,major_milestone)
  (select 21,(select id from brs.dashboard_milestone_type
           where dashboard_milestone_code = 'COMPANY_DASHBOARD'),
          'Final Completions',22,2384850,2384850,true
   where not exists (select id from brs.dashboard_milestone where name = 'Final Completions'));

insert into brs.dashboard_milestone_column(dashboard_milestone_id, title,
                                           data_type_id, display_value, created_by_id,
                                           modified_by_id)
  (select dm.id,'Final Completion Submitted Date',1,'final_completion_submitted_date',2384850,2384850
   from  brs.dashboard_milestone dm
   where dm.name = 'Final Completions'  and
     not exists (select id from brs.dashboard_milestone_column
                 where title = 'Final Completion Submitted Date'));


CREATE INDEX if not exists greatest_date1_idx
  ON brs.project_details (greatest(((installation_start_time at time zone 'UTC') at time zone 'US/Mountain') :: date,
                                   ((installation_closeout_start_time at time zone 'UTC') at time zone
                                    'US/Mountain') :: date ));

create index if not exists least_date1_idx
  on brs.project_details (least(verified_inspection_approval_received_by_utility_date,ahj_inspection_approval_submitted_date));
