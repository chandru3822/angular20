-- run these functions
--get_pps_with_actions_and_requirements
--get_project_process_step_event_requirements_with_values
--get_availability_time_slots
--pps_has_active_events
--get_project_available_owners

drop function if exists flow.get_project_available_owners(int, int, boolean);

drop FUNCTION if  exists flow.set_closer_appointment(p_project_id integer,
                                                     p_current_user_id integer,
                                                     p_project_process_step_id integer,
                                                     p_appointment_start_time timestamp,
                                                     p_users integer array,
                                                     p_remote boolean);

-- have to drop this because more has to be returned in the table
drop function if exists flow.get_availability_time_slots(int, timestamp, timestamp, date, boolean);

CREATE TABLE if not exists flow.project_process_step_event
(
  id                           serial  NOT NULL,
  project_process_step_id      integer not null,
  process_step_event_id        integer not null,
  resource_id                  integer,
  company_event_status_type_id integer,
  start_time                   timestamp,
  end_time                     timestamp,
  date_created                 timestamp without time zone DEFAULT now(),
  date_modified                timestamp without time zone,
  created_by_id                integer not null,
  modified_by_id               integer,
  archived                     boolean not null            default false,
  constraint project_process_step_event_pk primary key (id),
  CONSTRAINT ppe_project_process_step_id_fk FOREIGN KEY (project_process_step_id)
    REFERENCES flow.project_process_step (id),
  CONSTRAINT ppe_event_status_type_id_fk FOREIGN KEY (company_event_status_type_id)
    REFERENCES flow.company_event_status_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppe_process_step_event_id_fk FOREIGN KEY (process_step_event_id)
    REFERENCES flow.process_step_event (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppe_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppe_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists ppse_project_process_step_id_idx
  on flow.project_process_step_event (project_process_step_id);
create index if not exists ppse_process_step_event_id_idx
  on flow.project_process_step_event (process_step_event_id);
create index if not exists ppse_resource_id_idx
  on flow.project_process_step_event (resource_id);
create index if not exists ppse_company_event_status_type_id_idx
  on flow.project_process_step_event (company_event_status_type_id);
create index if not exists ppse_date_created_idx
  on flow.project_process_step_event (date_created);

CREATE TABLE if not exists flow.project_process_step_event_custom_field_value
(
  id                               serial  NOT NULL,
  project_process_step_event_id    integer NOT NULL,
  custom_field_group_assignment_id integer NOT NULL,
  date_value                       date,
  timestamp_value                  timestamp,
  boolean_value                    bool,
  text_value                       text,
  numeric_value                    numeric,
  int_value                        integer,
  int_array_value                  integer[],
  date_created                     timestamp without time zone DEFAULT now(),
  date_modified                    timestamp without time zone,
  created_by_id                    integer not null,
  modified_by_id                   integer,
  CONSTRAINT project_process_step_event_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT ppsecfv_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppsecfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppsecfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ppsecfv_project_process_step_event_id_idx ON flow.project_process_step_event_custom_field_value (project_process_step_event_id);

CREATE INDEX if not exists ppsecfv_custom_field_group_assignment_id_idx ON flow.project_process_step_event_custom_field_value (custom_field_group_assignment_id);
CREATE INDEX if not exists ppsecfv_date_value_idx ON
  flow.project_process_step_event_custom_field_value (date_value);
CREATE INDEX if not exists ppsecfv_timestamp_value_idx ON
  flow.project_process_step_event_custom_field_value (timestamp_value);
CREATE INDEX if not exists ppsecfv_boolean_value_idx ON
  flow.project_process_step_event_custom_field_value (boolean_value);
-- CREATE INDEX if not exists ppsecfv_text_value_idx ON
--   flow.project_process_step_event_custom_field_value (text_value);
CREATE INDEX if not exists ppsecfv_numeric_value_idx ON
  flow.project_process_step_event_custom_field_value (numeric_value);
CREATE INDEX if not exists ppsecfv_int_value_idx ON
  flow.project_process_step_event_custom_field_value (int_value);
CREATE INDEX if not exists ppsecfv_int_array_value_idx ON
  flow.project_process_step_event_custom_field_value (int_array_value);

alter table flow.project_process_step_event_custom_field_value drop constraint  if exists ppsecfv_unique_cfga_pps_event_id;
ALTER TABLE flow.project_process_step_event_custom_field_value
  ADD CONSTRAINT ppsecfv_unique_cfga_pps_event_id UNIQUE (project_process_step_event_id, custom_field_group_assignment_id);

CREATE TABLE if not exists flow.project_process_step_event_attachment
(
  id                            serial  not null,
  attachment_id                 integer not null,
  project_process_step_event_id integer not null,
  date_created                  timestamp without time zone DEFAULT now(),
  date_modified                 timestamp without time zone,
  created_by_id                 integer not null,
  modified_by_id                integer,
  archived                      boolean not null default false,
  constraint project_process_step_event_attachment_pk primary key (id),
  CONSTRAINT ppsea_attachment_id_fk FOREIGN KEY (attachment_id)
    REFERENCES flow.attachment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
--   CONSTRAINT ppsea_project_process_step_event_id_fk FOREIGN KEY (project_process_step_event_id)
--     REFERENCES flow.project_process_step_event (id) MATCH SIMPLE
--     ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppsea_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ppsea_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ppsea_attachment_id_idx ON
  flow.project_process_step_event_attachment (attachment_id);
CREATE INDEX if not exists ppsea_project_process_step_event_id_idx ON
  flow.project_process_step_event_attachment (project_process_step_event_id);

CREATE TABLE if NOT EXISTS flow.project_process_step_event_action
(
  id                            serial                                    not null,
  project_process_step_event_id integer                                   not null,
  process_step_event_action_id  integer                                   not null,
  allow_multiple_uses           boolean                     default false not null,
  date_created                  timestamp without time zone DEFAULT now(),
  created_by_id                 integer,
  CONSTRAINT project_process_step_event_action_pk primary key (id),
  CONSTRAINT ppsea_project_process_step_event_id_fk FOREIGN KEY (project_process_step_event_id)
    REFERENCES flow.project_process_step_event (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ppsea_process_step_event_action_id_fk FOREIGN KEY (process_step_event_action_id)
    REFERENCES flow.process_step_event_action (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT ppsea_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ppsea_project_process_step_event_id_idx ON
  flow.project_process_step_event_action (project_process_step_event_id);
CREATE INDEX if not exists ppsea_process_step_event_action_id_idx ON
  flow.project_process_step_event_action (process_step_event_action_id);

create index if not exists ppsea_project_process_step_event_id_idx on flow.project_process_step_event_action (project_process_step_event_id);

-- this table is already in prod and the values for require_start_time are supposed to be always true.  this is fixed in the code but we will need
-- this in the script so it updates prod when that goes live
update flow.process_step_event_action
set require_start_time = true
where require_end_time is false;

-- todo: need to do this but dont do it until after the migration happens
-- alter table flow.custom_field_group
--   drop column if exists event_type_id;
-- alter table flow.custom_field_group_assignment
--   drop column if exists schedule_field_type_id;

create table if not exists flow.project_process_step_event_audit
(
  id                           serial
    constraint project_process_step_event_audit_pk
      primary key,
  project_process_step_event_id integer,
  project_process_step_id      integer,
  process_step_event_id        integer,
  resource_id                  integer,
  company_event_status_type_id integer,
  start_time                   timestamp,
  end_time                     timestamp,
  date_created                 timestamp,
  date_modified                timestamp,
  created_by_id                integer,
  modified_by_id               integer,
  archived                     boolean
);

create index if not exists ppsea_project_process_step_event_id_idx
  on flow.project_process_step_event_audit (project_process_step_event_id);
create index if not exists ppsea_project_process_step_id_idx
  on flow.project_process_step_event_audit (project_process_step_id);
create index if not exists ppsea_process_step_event_id_idx
  on flow.project_process_step_event_audit (process_step_event_id);


create table if not exists flow.project_process_step_event_custom_field_value_audit
(
  id                                         serial
    constraint project_process_step_event_custom_field_value_audit_pk
      primary key,
  project_process_step_event_custom_field_value_id integer not null,
  old_value                                  text,
  new_value                                  text,
  date_modified                              timestamp,
  modified_by_id                             integer
);

create index if not exists ppsea_project_process_step_event_cfv_audit_id_idx
  on flow.project_process_step_event_custom_field_value_audit (project_process_step_event_custom_field_value_id);


alter table flow.project_process_step_event_custom_field_value
add column  if not exists migrate_project_process_step_custom_field_value_id integer;

create index if not exists ppsecfv_migrate_project_process_step_custom_field_value_id_idx
  on flow.project_process_step_event_custom_field_value (migrate_project_process_step_custom_field_value_id);

DO
$$
  BEGIN
    ALTER TABLE brs.project_details
      RENAME COLUMN  setter_milestone_pay_ppscfv_id TO setter_milestone_pay_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'setter_milestone_pay_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN
    ALTER TABLE brs.project_details
      RENAME COLUMN first_appointment_pitched_ppscfv_id TO first_appointment_pitched_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_pitched_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN
    ALTER TABLE brs.project_details
      RENAME COLUMN first_appointment_missed_ppscfv_id TO first_appointment_missed_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_missed_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN first_appointment_not_pitched_or_missed_ppscfv_id TO first_appointment_not_pitched_or_missed_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_not_pitched_or_missed_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN site_survey_verified_date_ppscfv_id TO site_survey_verified_date_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'site_survey_verified_date_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN appointment_check_in_ppscfv_id TO appointment_check_in_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'appointment_check_in_ppsecfv_id does not exists';
  END;
$$;


DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN ahj_final_inspection_verified_ppscfv_id TO ahj_final_inspection_verified_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'ahj_final_inspection_verified_ppsecfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN ahj_inspection_scheduled_date_ppscfv_id TO ahj_inspection_scheduled_date_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'ahj_inspection_scheduled_date_ppsecfv_id does not exists';
  END;
$$;


DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN installation_scheduled_ppscfv_id TO installation_scheduled_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'installation_scheduled_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN online_submission_time_ppscfv_id TO online_submission_time_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'online_submission_time_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN first_appointment_pps_id TO first_appointment_ppse_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_pps_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN first_appointment_id_pps_id TO first_appointment_id_ppse_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_id_pps_id does not exists';
  END;
$$;

-- DO
-- $$
--   BEGIN
--
--     ALTER TABLE brs.project_details
--       RENAME COLUMN ahj_inspection_start_time_ppscfv_id TO ahj_inspection_start_time_ppse_id;
--   EXCEPTION
--     WHEN undefined_column THEN RAISE NOTICE 'ahj_inspection_start_time_ppscfv_id does not exists';
--   END;
-- $$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN permit_pack_submittal_end_time_ppscfv_id TO permit_pack_submittal_end_time_ppse_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'permit_pack_submittal_end_time_ppscfv_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN substantial_completion_date_ppscfv_id TO substantial_completion_date_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'substantial_completion_date_ppscfv_id does not exists';
  END;
$$;





-- update brs.project_details_config
-- set update_first_value_only_id = 'setter_milestone_pay_ppsecfv_id'
-- where update_first_value_only_id = 'setter_milestone_pay_ppscfv_id';

-- update brs.project_details_config
-- set update_first_value_only_id = 'first_appointment_pitched_ppsecfv_id'
-- where update_first_value_only_id = 'first_appointment_pitched_ppscfv_id';

-- update brs.project_details_config
-- set update_first_value_only_id = 'first_appointment_missed_ppsecfv_id'
-- where update_first_value_only_id = 'first_appointment_missed_ppscfv_id';

-- update brs.project_details_config
-- set update_first_value_only_id = 'first_appointment_not_pitched_or_missed_ppsecfv_id'
-- where update_first_value_only_id = 'first_appointment_not_pitched_or_missed_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'site_survey_verified_date_ppsecfv_id'
where update_first_value_only_id = 'site_survey_verified_date_ppscfv_id'
and custom_field_group_assignment_id = 21122;

update brs.project_details_config
set update_first_value_only_id = 'appointment_check_in_ppsecfv_id'
where update_first_value_only_id = 'appointment_check_in_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'ahj_final_inspection_verified_ppsecfv_id'
where update_first_value_only_id = 'ahj_final_inspection_verified_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'ahj_inspection_scheduled_date_ppsecfv_id'
where update_first_value_only_id = 'ahj_inspection_scheduled_date_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'installation_scheduled_ppsecfv_id'
where update_first_value_only_id = 'installation_scheduled_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'online_submission_time_ppsecfv_id'
where update_first_value_only_id = 'online_submission_time_ppscfv_id';


-- update brs.project_details_configpermit_pack_submittal_end_time
-- set update_first_value_only_id = 'ahj_inspection_start_time_ppsecfv_id'
-- where update_first_value_only_id = 'ahj_inspection_start_time_ppscfv_id';

-- update brs.project_details_config
-- set update_first_value_only_id = 'permit_pack_submittal_end_time_ppsecfv_id'
-- where update_first_value_only_id = 'permit_pack_submittal_end_time_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'substantial_completion_date_ppsecfv_id'
where update_first_value_only_id = 'substantial_completion_date_ppscfv_id';







alter table brs.project_details drop column if exists first_appointment_pps_id;
alter table brs.project_details drop column if exists first_appointment_id_pps_id;

alter table flow.custom_field_group_assignment add column  if not exists  migrated_cfga_id integer;
alter table brs.set_closer_appointment_audit add column if not exists project_process_step_event_id integer;


create table brs.project_detail_events_config
(
  id                               serial
    constraint project_detail_events_config_pk
      primary key,
  company_id                       integer               not null
    constraint pdec_company_id_fk
      references flow.company,
  process_step_event_id    integer               not null
    constraint pdec_process_step_event_id_fk
      references flow.process_step_event,
  field_to_update                  varchar(100)          not null,
  field_to_use                     varchar(100)                not null,
  display_name                     varchar(100),
  second_field_to_update           varchar(100),
  update_first_value_only          boolean default false not null,
  update_first_value_only_id       varchar
);

create index pdec_process_step_event_id_idx
  on brs.project_detail_events_config (process_step_event_id);

create index pdec_company_id_idx
  on brs.project_detail_events_config (company_id);

drop FUNCTION if exists brs.set_project_owner(int);
-- @keller - if this function goes away then these records need to get archived

update flow.process_step_action_company_function psacf
  set archived = true
from flow.company_function cf
where cf.id = psacf.company_function_id
and cf.db_function_id = 14;

update flow.company_function
  set archived = true
where db_function_id = 14;

update flow.db_function
  set archived = true
where id = 14;


insert into flow.system_value(system_value, archived)
  (select 'Current Project Process Step Event ID', false
   where not exists (select id from flow.system_value where system_value = 'Current Project Process Step Event ID'));

--change the Installer unique behavior to be on Schedule Closer Appt instead of Closer Appt - per M.M. per Judson
update flow.custom_field_group
set unique_behavior_type_id = 2
where process_step_id = 1
  and group_name = 'Closer Appointment Scheduling'
  and archived is false;

-- add the db function that checks for active events on a pps
insert into flow.db_function(function_name, return_data_type_id, db_function_type_id, display_name, description)
  select 'flow.pps_has_active_events', 3, 1, 'Project Process Step has Active Events', 'Checks to see if a project process step has any active events assigned to it.'
   where not exists (select id from flow.db_function where function_name = 'flow.pps_has_active_events');
;

insert into flow.db_function_param(db_function_id, parameter_name, display_order, data_type_id, parameter_type_id, system_value_id)
select (select id from flow.db_function where function_name = 'flow.pps_has_active_events'), 'Project Process Step ID', 0,
    6, 1, 3
      where not exists ( select id from flow.db_function_param where db_function_id = (select id from flow.db_function where function_name = 'flow.pps_has_active_events')
        and parameter_name = 'Project Process Step ID');

insert into flow.company_function(company_function_name, db_function_id, company_id)
select 'Project Process Step has Active Events', (select id from flow.db_function where function_name = 'flow.pps_has_active_events'), 3
where not exists (select id from flow.company_function where company_function_name = 'Project Process Step has Active Events');

-- SMARTLIST STUFF
alter table if exists flow.smartlist_field_assignment
add if not exists process_step_event_id int;

alter table if exists flow.smartlist_field_assignment
drop constraint if exists sfa_process_step_event_id_fk;

alter table if exists flow.smartlist_field_assignment
add constraint sfa_process_step_event_id_fk foreign key (process_step_event_id) references flow.process_step_event;

alter table if exists flow.smartlist_requirement
add if not exists process_step_event_id int;

alter table if exists flow.smartlist_requirement
drop constraint if exists sr_process_step_event_id_fk;

alter table if exists flow.smartlist_requirement
add constraint sr_process_step_event_id_fk foreign key (process_step_event_id) references flow.process_step_event;

-- archive smartlist field assignments which point to fields that were migrated from a process step to event
with offendingFields as (
  select sfa.id
  from flow.smartlist_field_assignment sfa
         inner join flow.smartlist s on s.id = sfa.smartlist_id
         inner join flow.custom_field_group_assignment cfga on cfga.id = sfa.custom_field_group_assignment_id
         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
         inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
  where s.archived is false and
        sfa.archived is false and
        cot.object_type_id = 6
)
update flow.smartlist_field_assignment sfa1
set archived = true
from offendingFields
where sfa1.id = offendingFields.id;

-- archive smartlist requirements which point to fields that were migrated from a process step to event
with offendingRequirements as (
  select sr.id
  from flow.smartlist_requirement sr
         inner join flow.smartlist s on s.id = sr.smartlist_id
         inner join flow.custom_field_group_assignment cfga on cfga.id = sr.custom_field_group_assignment_id
         inner join flow.custom_field_group cfg on cfg.id = cfga.custom_field_group_id
         inner join flow.company_object_type cot on cot.id = cfg.company_object_type_id
         inner join flow.custom_field cf on cf.id = cfga.custom_field_id
  where s.archived is false and
        sr.archived is false and
        cot.object_type_id = 6
)
update flow.smartlist_requirement sr
set archived = true
from offendingRequirements
where sr.id = offendingRequirements.id;

--system fields
insert into flow.smartlist_field (company_object_type_id, name, reference_table, reference_column, created_by_id, company_data_type_id, join_table, join_column, smartlist_system_list_id)
values (91, 'Event ID', 'flow.project_process_step_event', 'id', 99999999, 5, null, null, null),
       (91, 'Event Name', 'flow.event', 'event_name', 99999999, 1, null, null, null),
       (91, 'Event Created', 'flow.project_process_step_event', 'date_created', 99999999, 3, null, null, null),
       (91, 'Event Start Time', 'flow.project_process_step_event', 'start_time', 99999999, 3, null, null, null),
       (91, 'Event End Time', 'flow.project_process_step_event', 'end_time', 99999999, 3, null, null, null),
       (91, 'Event Resource', 'flow.user', 'concat(\"%s\".first_name, '' '', \"%s\".last_name)', 99999999, 7, 'flow.project_process_step_event', 'resource_id', null),
       (91, 'Event Status', 'flow.company_event_status_type', 'event_status_type', 99999999, 7, 'flow.project_process_step_event', 'company_event_status_type_id', null),
       (91, 'Event Category', 'flow.event_status_type', 'event_status_type', 99999999, 7, 'flow.company_event_status_type', 'event_status_type_id', null);
-- END SMARTLIST STUFF

-- *** WORK QUEUE STUFF ***
--add a column to determine if work queue type is for process steps or events
-- todo: v2 they want the 2 types to be used together.  see if we can do that in v1 before truly going this route
alter table flow.work_queue_type
  add column if not exists use_event_data boolean not null default false;

--add the tables to hold the work queue event status stuff
CREATE TABLE if not exists flow.process_step_event_work_queue_type
(
  id              serial                NOT NULL,
  process_step_event_id      integer,
  work_queue_type_id integer,
  archived boolean default false,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id  integer                not null,
  modified_by_id integer,
  CONSTRAINT process_step_event_work_queue_type_pk PRIMARY KEY (id),
  CONSTRAINT psewqt_process_step_event_id_fk FOREIGN KEY (process_step_event_id)
    REFERENCES flow.process_step_event (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psewqt_work_queue_type_id_fk FOREIGN KEY (work_queue_type_id)
    REFERENCES flow.work_queue_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psewqt_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psewqt_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists psewqt_process_step_event_id_idx
  on flow.process_step_event_work_queue_type (process_step_event_id);

ALTER TABLE flow.process_step_event_work_queue_type
  DROP CONSTRAINT if exists psewqt_process_step_event_work_queue_type_uk;
alter table flow.process_step_event_work_queue_type
  add constraint psewqt_process_step_event_work_queue_type_uk
    unique (process_step_event_id, work_queue_type_id);

CREATE INDEX if not exists fki_psewqt_work_queue_type_id
  on flow.process_step_event_work_queue_type (work_queue_type_id);

create unique index if not exists psewqt_uniq_idx
  on flow.process_step_event_work_queue_type (process_step_event_id, work_queue_type_id)
  where (archived IS FALSE);

CREATE TABLE if not exists flow.process_step_event_work_queue_type_process_step_status_type
(
  id                       serial  NOT NULL,
  company_process_step_status_type_id integer,
  process_step_status_type_id integer,
  process_step_event_work_queue_type_id integer not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT process_step_event_work_queue_type_process_step_status_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_psewqtpsst_company_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
    REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpsst_process_step_status_type_id_fk FOREIGN KEY (process_step_status_type_id)
    REFERENCES flow.process_step_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpsst_process_step_event_work_queue_type_id_fk FOREIGN KEY (process_step_event_work_queue_type_id)
    REFERENCES flow.process_step_event_work_queue_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpsst_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_psewqtpsst_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE flow.process_step_event_work_queue_type_process_step_status_type
  ADD CONSTRAINT null_company_and_root_process_step_status_check
    CHECK (
        process_step_status_type_id is not null
        OR company_process_step_status_type_id is not null
      );

create index process_step_event_wqt_project_process_step_status_type_id_idx
  on flow.process_step_event_work_queue_type_process_step_status_type (process_step_status_type_id);

create index process_step_event_wqt_company_process_step_status_type_idx
  on flow.process_step_event_work_queue_type_process_step_status_type (company_process_step_status_type_id);

create unique index process_step_event_work_queue_type_process_step_status_type_udx
  on flow.process_step_event_work_queue_type_process_step_status_type (company_process_step_status_type_id, process_step_event_work_queue_type_id)
  where (archived IS FALSE);

create unique index psewqtpsst_handle_unique_null_idx
  on flow.process_step_event_work_queue_type_process_step_status_type (COALESCE(company_process_step_status_type_id, '-1'::integer), COALESCE(process_step_status_type_id, '-1'::integer), process_step_event_work_queue_type_id);

create index psewqtpsst_work_queue_type_pk
  on flow.process_step_event_work_queue_type_process_step_status_type (process_step_event_work_queue_type_id);

alter table flow.process_step_event_work_queue_type_process_step_status_type
  add constraint psewqtpst_process_step_status_type_uk
    unique (company_process_step_status_type_id, process_step_status_type_id, process_step_event_work_queue_type_id);

CREATE TABLE if not exists flow.process_step_event_work_queue_type_project_status_type
(
  id                       serial  NOT NULL,
  company_project_status_type_id integer,
  project_status_type_id integer,
  process_step_event_work_queue_type_id integer not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT process_step_event_work_queue_type_project_status_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_psewqtpst_company_project_status_type_id_fk FOREIGN KEY (company_project_status_type_id)
    REFERENCES flow.company_project_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpst_project_status_type_id_fk FOREIGN KEY (project_status_type_id)
    REFERENCES flow.project_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpst_process_step_work_queue_type_id_fk FOREIGN KEY (process_step_event_work_queue_type_id)
    REFERENCES flow.process_step_event_work_queue_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtpst_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_psewqtpst_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE flow.process_step_event_work_queue_type_project_status_type
  ADD CONSTRAINT null_company_and_root_project_status_check
    CHECK (
        project_status_type_id is not null
        OR company_project_status_type_id is not null
      );


create index process_step_event_wqt_project_project_status_type_id_idx
  on flow.process_step_event_work_queue_type_project_status_type (project_status_type_id);


create unique index process_step_event_work_queue_type_project_status_type_udx
  on flow.process_step_event_work_queue_type_project_status_type (company_project_status_type_id, process_step_event_work_queue_type_id)
  where (archived IS FALSE);

create unique index psewqtpst_handle_unique_null_idx
  on flow.process_step_event_work_queue_type_project_status_type (COALESCE(company_project_status_type_id, '-1'::integer), COALESCE(project_status_type_id, '-1'::integer), process_step_event_work_queue_type_id);

create index psewqtpst_work_queue_type_fk
  on flow.process_step_event_work_queue_type_project_status_type (process_step_event_work_queue_type_id);

alter table flow.process_step_event_work_queue_type_project_status_type
  add constraint psewqtpst_project_status_type_uk
    unique (company_project_status_type_id, project_status_type_id, process_step_event_work_queue_type_id);


CREATE TABLE if not exists flow.process_step_event_work_queue_type_event_status_type
(
  id                       serial  NOT NULL,
  company_event_status_type_id integer,
  event_status_type_id integer,
  process_step_event_work_queue_type_id integer not null,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT process_step_event_work_queue_type_event_status_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_psewqtest_company_event_status_type_id_fk FOREIGN KEY (company_event_status_type_id)
    REFERENCES flow.company_event_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtest_event_status_type_id_fk FOREIGN KEY (event_status_type_id)
    REFERENCES flow.event_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtest_process_step_work_queue_type_id_fk FOREIGN KEY (process_step_event_work_queue_type_id)
    REFERENCES flow.process_step_event_work_queue_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_psewqtest_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_psewqtest_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE flow.process_step_event_work_queue_type_event_status_type
  ADD CONSTRAINT null_company_and_root_event_status_check
    CHECK (
        event_status_type_id is not null
        OR company_event_status_type_id is not null
      );

create index process_step_event_wqt_project_event_status_type_id_idx
  on flow.process_step_event_work_queue_type_event_status_type (event_status_type_id);

create index process_step_event_work_queue_type_event_status_type_idx
  on flow.process_step_event_work_queue_type_event_status_type (company_event_status_type_id);

create unique index process_step_event_work_queue_type_event_status_type_udx
  on flow.process_step_event_work_queue_type_event_status_type (company_event_status_type_id, process_step_event_work_queue_type_id)
  where (archived IS FALSE);

create unique index psewqtest_handle_unique_null_idx
  on flow.process_step_event_work_queue_type_event_status_type (COALESCE(company_event_status_type_id, '-1'::integer), COALESCE(event_status_type_id, '-1'::integer), process_step_event_work_queue_type_id);

create index psewqtest_work_queue_type_fk
  on flow.process_step_event_work_queue_type_event_status_type (process_step_event_work_queue_type_id);

alter table flow.process_step_event_work_queue_type_event_status_type
  add constraint psewqtest_event_status_type_uk
    unique (company_event_status_type_id, event_status_type_id, process_step_event_work_queue_type_id);
-- *** END WORK QUEUE STUFF ***

-- EVENT READ ONLY/WHITE LIST DEFAULT FIELDS
alter table flow.event
  add column if not exists start_time_read_only boolean not null default false;

alter table flow.event
  add column if not exists end_time_read_only boolean not null default false;

alter table flow.event
  add column if not exists resource_read_only boolean not null default false;

alter table flow.white_listed_position
  add column if not exists event_id int references flow.event(id);

insert into flow.white_list_type(white_list_type, archived)
  (select 'EVENT_START_TIME_READ_ONLY', false
   where not exists (select id from flow.white_list_type where white_list_type = 'EVENT_START_TIME_READ_ONLY'));

insert into flow.white_list_type(white_list_type, archived)
  (select 'EVENT_END_TIME_READ_ONLY', false
   where not exists (select id from flow.white_list_type where white_list_type = 'EVENT_END_TIME_READ_ONLY'));

insert into flow.white_list_type(white_list_type, archived)
  (select 'EVENT_RESOURCE_READ_ONLY', false
   where not exists (select id from flow.white_list_type where white_list_type = 'EVENT_RESOURCE_READ_ONLY'));


CREATE TABLE if NOT EXISTS flow.migration_child_process_step
(
  id                            serial                                    not null,
  project_process_id integer                                   not null,
  process_step_ids  integer[]                                   not null,
  CONSTRAINT migration_child_process_step_pk primary key (id)
);



insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(1,'{1,2}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(5,'{5,60,3346}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(98,'{98,99,3346}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(168,'{168,204,152,46}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(40,'{40,204,152,46}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(153,'{153,205,154,46}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3365,'{3365}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3383,'{3383}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(16,'{16,233,17}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(13,'{13,94,67}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(85,'{85,96,97}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3431,'{3431}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(129,'{129}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(138,'{138,210,139}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(146,'{146,214,147}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(140,'{140,211,141}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(144,'{144,213,145}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(142,'{142,212,143}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(148,'{148,149}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3414,'{3414}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3362,'{3362,3363,3364}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(134,'{134,208,135}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(28,'{28,239,137}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3487,'{3487}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3409,'{3409}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(54,'{54,104,55}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(2838,'{2838,2839,2840}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(2841,'{2841,2842,2843}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3091,'{3091}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3480,'{3480}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3441,'{3441}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(165,'{165,166,167}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(66,'{66,228,71}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3107,'{3107,3108,3109}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(192,'{192,193,194}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3103,'{3103,3104,3105}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3099,'{3099,3100,3101}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(196,'{196,234,197}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3359,'{3359}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3360,'{3360}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(44,'{44,156,157}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3479,'{3479}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(222,'{222,223}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(172,'{172,236,173}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3427,'{3427}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3428,'{3428}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3397,'{3397,3398}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3478,'{3478}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3395,'{3395}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3399,'{3399}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3471,'{3471}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3459,'{3459}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3470,'{3470}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3473,'{3473}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3472,'{3472}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3474,'{3474}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(3391,'{3391}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(170,'{170,206,207,171}');
insert into flow.migration_child_process_step(project_process_id, process_step_ids)
values(25,'{25,235,26}');

alter table brs.project_detail_events_config add column  if not exists  permit_pack_submittal_start_time_ppse_id integer;
create index if not exists pdec_permit_pack_submittal_start_time_ppse_id_idx
  on brs.project_detail_events_config (permit_pack_submittal_start_time_ppse_id);
alter table brs.project_detail_events_config add column  if not exists  permit_pack_submittal_resource_ppse_id integer;
create index if not exists pdec_permit_pack_submittal_resource_ppse_id_idx
  on brs.project_detail_events_config (permit_pack_submittal_resource_ppse_id);

alter table brs.project_details drop column if exists ahj_inspection_start_time_ppse_id;
alter table brs.project_details drop column if exists first_appointment_missed_ppsecfv_id;
alter table brs.project_details drop column if exists first_appointment_not_pitched_or_missed_ppsecfv_id;
alter table brs.project_details drop column if exists first_appointment_pitched_ppsecfv_id;
alter table brs.project_details drop column if exists setter_milestone_pay_ppsecfv_id;






