drop FUNCTION if  exists flow.set_closer_appointment(p_project_id integer,
                                                     p_current_user_id integer,
                                                     p_project_process_step_id integer,
                                                     p_appointment_start_time timestamp,
                                                     p_users integer array,
                                                     p_remote boolean);

insert into flow.flow_type(flow_type)
  (select 'Event' where not exists(select id from flow.flow_type where flow_type = 'Event'));

insert into flow.object_type(object_type, object_code, flow_type_id, archived)
  (select 'Event', 'EVENT', 4, false where not exists(select id from flow.object_type where object_code = 'EVENT'))
;

-- have to drop this because more has to be returned in the table
drop function if exists flow.get_availability_time_slots(int, timestamp, timestamp, date, boolean);

insert into flow.feature(feature_name, feature_code)
  (select 'Events', 'EVENTS'  where not exists(select id from flow.feature where feature_code = 'EVENTS'));

insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
  (select 'Events', 3, (select id from flow.feature where feature_code = 'EVENTS'), false
   where not exists(select id from flow.company_feature where feature_name = 'Events' and company_id = 3));

insert into flow.feature_access_control(feature_id, access_control_id, created_by_id)
  (select (select id from flow.feature where feature_code = 'EVENTS'), ac.id, 2350555
   from flow.access_control ac
   where not exists (
       select fac.id
       from flow.feature_access_control fac
       where feature_id = (select id from flow.feature where feature_code = 'EVENTS')
         and access_control_id = ac.id
     )
    and ac.id not in (6, 4, 7, 5)
  );

insert into flow.company_object_type(object_type_id, company_id, created_by_id)
  (select (select id from flow.object_type where object_code = 'EVENT'), 3, 2350555
   where not exists(select id
                    from flow.company_object_type
                    where company_id = 3
                      and object_type_id = (select id from flow.object_type where object_code = 'EVENT')));
;

CREATE TABLE if not exists flow.event
(
  id                       serial            NOT NULL,
  event_name               character varying NOT NULL,
  resource_custom_field_id integer,
  company_id               integer           NOT NULL,
  date_created             timestamp without time zone DEFAULT now(),
  date_modified            timestamp without time zone,
  created_by_id            integer           not null,
  modified_by_id           integer,
  archived                 boolean           not null  default false,
  CONSTRAINT flow_event_pk PRIMARY KEY (id),
  CONSTRAINT flow_e_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_e_resource_custom_field_id_fk FOREIGN KEY (resource_custom_field_id)
    REFERENCES flow.custom_field (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_e_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_e_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION

);
--drop table flow.event_attachment_type
CREATE TABLE if not exists flow.event_attachment_type
(
  id                 serial  NOT NULL,
  attachment_type_id integer NOT NULL,
  event_id           integer NOT NULL,
  read_only          boolean not null            default false,
  date_created       timestamp without time zone DEFAULT now(),
  date_modified      timestamp without time zone,
  display_order      integer,
  created_by_id      integer not null,
  modified_by_id     integer,
  archived           boolean not null            default false,
  CONSTRAINT event_attachment_type_pk PRIMARY KEY (id),
  CONSTRAINT eat_attachment_id_fk FOREIGN KEY (attachment_type_id)
    REFERENCES flow.attachment_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT eat_event_id_fk FOREIGN KEY (event_id)
    REFERENCES flow.event (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT eat_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT eat_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.custom_field_group
  add column if not exists event_id int references flow.event (id);

--active failed cancelled
CREATE TABLE if NOT EXISTS flow.event_status_type
(
  id                serial                not null,
  event_status_type character varying(50) NOT NULL,
  archived          boolean               not null default false,
  CONSTRAINT event_status_type_pk primary key (id)
);

insert into flow.event_status_type(event_status_type)
  (select 'ACTIVE' where not exists(select id from flow.event_status_type where event_status_type = 'ACTIVE'));

insert into flow.event_status_type(event_status_type)
  (select 'COMPLETE' where not exists(select id from flow.event_status_type where event_status_type = 'COMPLETE'));

insert into flow.event_status_type(event_status_type)
  (select 'CANCELLED' where not exists(select id from flow.event_status_type where event_status_type = 'CANCELLED'));

CREATE TABLE if NOT EXISTS flow.company_event_status_type
(
  id                   serial                not null,
  event_status_type_id integer               not null,
  event_status_type    character varying(50) NOT NULL,
  company_id           integer               not null,
  archived             boolean               not null default false,
  date_created         timestamp without time zone    DEFAULT now(),
  date_modified        timestamp without time zone,
  created_by_id        integer,
  modified_by_id       integer,
  CONSTRAINT company_event_status_type_pk primary key (id),
  CONSTRAINT cest_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT cest_event_status_type_id_fk FOREIGN KEY (event_status_type_id)
    REFERENCES flow.event_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT cest_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT cest_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cest_event_status_type_id_idx ON flow.company_event_status_type (event_status_type_id);
CREATE INDEX if not exists cest_company_id_idx ON flow.company_event_status_type (company_id);

CREATE TABLE if not exists flow.event_company_event_status_type
(
  id                           serial  NOT NULL,
  event_id                     integer NOT NULL,
  company_event_status_type_id integer NOT NULL,
  date_created                 timestamp without time zone DEFAULT now(),
  date_modified                timestamp without time zone,
  created_by_id                integer not null,
  modified_by_id               integer,
  archived                     boolean not null            default false,
  CONSTRAINT flow_event_company_event_status_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_ecest_process_step_id_fk FOREIGN KEY (event_id)
    REFERENCES flow.process_step (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_ecest_company_process_step_status_type_id_fk FOREIGN KEY (company_event_status_type_id)
    REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_ecest_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_ecest_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- delete all of them so this won't break stage (i already manually added them
delete
from flow.event_company_event_status_type
where id > 0;

CREATE TABLE if not exists flow.process_step_event
(
  id                                   serial  not null,
  process_step_id                      integer,
  event_id                             integer not null,
  initial_company_event_status_type_id integer not null,
  date_created                         timestamp without time zone DEFAULT now(),
  unique_behavior_type_id              integer,
  display_order                        integer not null,
  date_modified                        timestamp without time zone,
  created_by_id                        integer not null,
  modified_by_id                       integer,
  archived                             boolean not null            default false,
  CONSTRAINT process_step_event_pk PRIMARY KEY (id),
  CONSTRAINT pse_process_step_id_fk FOREIGN KEY (process_step_id)
    REFERENCES flow.process_step (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pse_initial_company_event_status_type_id_fk FOREIGN KEY (initial_company_event_status_type_id)
    REFERENCES flow.company_event_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pse_unique_behavior_type_id_fk FOREIGN KEY (unique_behavior_type_id)
    REFERENCES flow.unique_behavior_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pse_event_id_fk FOREIGN KEY (event_id)
    REFERENCES flow.event (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT pse_action_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT pse_action_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index if not exists pse_process_step_event_id_idx
  on flow.process_step_event (process_step_id);
create index if not exists pse_event_id_idx
  on flow.process_step_event (event_id);
create index if not exists pse_initial_company_event_status_type_id_idx
  on flow.process_step_event (initial_company_event_status_type_id);
create index if not exists pse_unique_behavior_type_id_idx
  on flow.process_step_event (unique_behavior_type_id);

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

CREATE TABLE if NOT EXISTS flow.process_step_event_action
(
  id                                  serial                not null,
  process_step_event_id               integer               not null,
  display_order                       integer               not null,
  company_event_status_type_id        integer,
  company_process_step_status_type_id integer,
  require_start_time                  boolean               not null default false,
  require_end_time                    boolean               not null default false,
  require_resource                    boolean               not null default false,
  always_enabled                      boolean               not null default false,
  multiple_uses                       boolean               not null default false,
  action_name                         character varying(50) NOT NULL,
  archived                            boolean               not null default false,
  date_created                        timestamp without time zone    DEFAULT now(),
  date_modified                       timestamp without time zone,
  created_by_id                       integer,
  modified_by_id                      integer,
  CONSTRAINT process_step_event_action_pk primary key (id),
  CONSTRAINT psea_process_step_event_id_fk FOREIGN KEY (process_step_event_id)
    REFERENCES flow.process_step_event (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psea_company_event_status_type_id_fk FOREIGN KEY (company_event_status_type_id)
    REFERENCES flow.company_event_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psea_company_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
    REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psea_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psea_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psea_process_step_event_id_idx ON
  flow.process_step_event_action (process_step_event_id);
CREATE INDEX if not exists psea_company_event_status_type_id_idx ON
  flow.process_step_event_action (company_event_status_type_id);
CREATE INDEX if not exists psea_company_process_step_status_type_id_idx ON
  flow.process_step_event_action (company_process_step_status_type_id);

CREATE TABLE if NOT EXISTS flow.process_step_event_action_field
(
  id                               serial  not null,
  process_step_event_action_id     integer not null,
  custom_field_group_assignment_id integer not null,
  required                         boolean not null            default false,
  archived                         boolean not null            default false,
  date_created                     timestamp without time zone DEFAULT now(),
  date_modified                    timestamp without time zone,
  created_by_id                    integer,
  modified_by_id                   integer,
  CONSTRAINT process_step_event_action_field_pk primary key (id),
  CONSTRAINT psearf_process_step_event_action_id_fk FOREIGN KEY (process_step_event_action_id)
    REFERENCES flow.process_step_event_action (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psearf_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psearf_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psearf_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pseaf_process_step_event_action_id_idx ON
  flow.process_step_event_action_field (process_step_event_action_id);
CREATE INDEX if not exists pseaf_custom_field_group_assignment_id_idx ON
  flow.process_step_event_action_field (custom_field_group_assignment_id);

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

alter table flow.custom_field_group_assignment
  add column if not exists detail_view boolean not null default false;


--event requirements stuff

--process step custom field or event custom field or function
CREATE TABLE if not exists flow.process_step_event_requirement
(
  id                               serial  not null,
  process_step_requirement_type_id integer not null,
  process_step_event_id            integer not null,
  operator_type_id                 integer not null,
  requirement_value                varchar,
  data_type_requirement_id         integer,
  secondary_requirement_value      varchar,
  custom_field_group_assignment_id integer,
  company_function_id              integer,
  requirement_nbr                  integer not null,
  date_created                     timestamp without time zone DEFAULT now(),
  date_modified                    timestamp without time zone,
  created_by_id                    integer not null,
  modified_by_id                   integer,
  archived                         boolean not null            default false,
  list_of_value_id                 integer,
  list_of_value_ids                integer[],
  immutable                        boolean                     default false not null,
  system_list_option_id            integer,
  custom_sql_option_id             integer,
  migrated_company_id              integer,
  migrated_original_id             integer,
  reference_process_step_id        integer
    constraint process_step_event_requirement_reference_process_step_id_fkey
      references flow.process_step,
  CONSTRAINT process_event_requirement_process_step_pk primary key (id),
  CONSTRAINT perps_process_step_event_requirement_type_id_fk FOREIGN KEY (process_step_requirement_type_id)
    REFERENCES flow.process_step_requirement_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT perps_process_step_event_id_fk FOREIGN KEY (process_step_event_id)
    REFERENCES flow.process_step (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,

  CONSTRAINT perps_operator_type_id_fk FOREIGN KEY (operator_type_id)
    REFERENCES flow.operator_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT perps_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT perps_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT perps_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT perps_data_type_requirement_id_fk FOREIGN KEY (data_type_requirement_id)
    REFERENCES flow.data_type_requirement (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists perps_process_requirement_type_id_idx ON flow.process_step_event_requirement (process_step_requirement_type_id);
CREATE INDEX if not exists perps_process_step_event_id_idx ON flow.process_step_event_requirement (process_step_event_id);
CREATE INDEX if not exists perps_operator_type_id_idx ON flow.process_step_event_requirement (operator_type_id);
CREATE INDEX if not exists perps_custom_field_group_assignment_id_idx ON flow.process_step_event_requirement (custom_field_group_assignment_id);
CREATE INDEX if not exists perps_data_type_requirement_id_idx ON flow.process_step_event_requirement (data_type_requirement_id);

CREATE TABLE if not exists flow.process_step_event_logic
(
  id                                serial  not null,
  process_step_event_requirement_id integer,
  operation_type_id                 integer,
  sql_order                         integer,
  process_step_event_action_id      integer,
  date_created                      timestamp without time zone DEFAULT now(),
  date_modified                     timestamp without time zone,
  created_by_id                     integer not null,
  modified_by_id                    integer,
  archived                          boolean not null            default false,
  CONSTRAINT process_step_event_logic_pk primary key (id),
  CONSTRAINT psel_operation_type_id_fk FOREIGN KEY (operation_type_id)
    REFERENCES flow.operation_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psel_process_event_requirement_process_step_id_fk FOREIGN KEY (process_step_event_requirement_id)
    REFERENCES flow.process_step_event_requirement (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psel_process_step_event_action_id_fk FOREIGN KEY (process_step_event_action_id)
    REFERENCES flow.process_step_event_action (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psel_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psel_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE INDEX if not exists psel_operator_type_id_idx ON flow.process_step_logic (operation_type_id);
CREATE INDEX if not exists psel_process_event_requirement_process_step_id_idx ON flow.process_step_event_logic (process_step_event_requirement_id);
CREATE INDEX if not exists psel_process_step_action_id_idx ON flow.process_step_event_logic (process_step_event_action_id);

CREATE TABLE if NOT EXISTS flow.event_requirement_param_dynamic_value
(
  id                                serial  NOT NULL,
  db_function_param_id              integer NOT NULL,
  process_step_event_requirement_id integer not null,
  dynamic_value                     character varying(50),
  archived                          boolean not null            default false,
  created_by_id                     integer,
  date_created                      timestamp without time zone DEFAULT now(),
  modified_by_id                    integer,
  date_modified                     timestamp without time zone,
  CONSTRAINT event_requirement_param_dynamic_value_pk PRIMARY KEY (id),
  CONSTRAINT erpdv_db_function_param_id_fk FOREIGN KEY (db_function_param_id)
    REFERENCES flow.db_function_param (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT erpdv_process_step_requirement_id_fk FOREIGN KEY (process_step_event_requirement_id)
    REFERENCES flow.process_step_event_requirement (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT erpdv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT erpdv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists erpdv_db_function_param_id_idx ON flow.event_requirement_param_dynamic_value (db_function_param_id);
CREATE INDEX if not exists erpdv_process_step_event_requirement_id_idx ON flow.event_requirement_param_dynamic_value (process_step_event_requirement_id);

--add column for fn params
alter table flow.requirement_param_dynamic_value
  add column if not exists process_step_event_requirement_id int references flow.process_step_event_requirement (id);




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


