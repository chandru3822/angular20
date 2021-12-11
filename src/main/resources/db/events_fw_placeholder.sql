-- run these functions
--get_pps_with_actions_and_requirements
--get_project_process_step_event_requirements_with_values
--get_availability_time_slots
--pps_has_active_events

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
      RENAME COLUMN first_appointment_id_pps_id TO first_appointment_id_ppsecfv_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'first_appointment_id_pps_id does not exists';
  END;
$$;

DO
$$
  BEGIN

    ALTER TABLE brs.project_details
      RENAME COLUMN ahj_inspection_start_time_ppscfv_id TO ahj_inspection_start_time_ppse_id;
  EXCEPTION
    WHEN undefined_column THEN RAISE NOTICE 'ahj_inspection_start_time_ppscfv_id does not exists';
  END;
$$;

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





update brs.project_details_config
set update_first_value_only_id = 'setter_milestone_pay_ppsecfv_id'
where update_first_value_only_id = 'setter_milestone_pay_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'first_appointment_pitched_ppsecfv_id'
where update_first_value_only_id = 'first_appointment_pitched_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'first_appointment_missed_ppsecfv_id'
where update_first_value_only_id = 'first_appointment_missed_ppscfv_id';

update brs.project_details_config
set update_first_value_only_id = 'first_appointment_not_pitched_or_missed_ppsecfv_id'
where update_first_value_only_id = 'first_appointment_not_pitched_or_missed_ppscfv_id';

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
