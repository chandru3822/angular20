--------------------------------------------------------------------------------
-- start fresh: wipe out the old version of the schema
--------------------------------------------------------------------------------
drop schema if exists flow cascade;


--------------------------------------------------------------------------------
-- build the schema
--------------------------------------------------------------------------------
create schema flow;

CREATE TABLE if NOT EXISTS flow.key_pattern
(
    id        serial                NOT NULL,
    key_pattern character varying(100) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT key_pattern_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.custom_field_sql_key
(
    id        serial                NOT NULL,
    sql_key character varying(100) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT custom_field_sql_key_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.parameter_type
(
    id        serial                NOT NULL,
    parameter_type character varying(50) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT parameter_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.country
(
    id        serial                NOT NULL,
    country character varying(50) NOT NULL,
    active_flag boolean not null default true,
    abbreviation character varying(10),
    CONSTRAINT country_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.system_value
(
    id        serial                NOT NULL,
    system_value character varying(50) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT system_value_pk PRIMARY KEY (id)
);

CREATE TABLE if not exists flow.company
(
    id                serial,
    parent_company_id integer,
    company_name      CHARACTER VARYING(50) not null,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    aws_bucket        character varying (200) not null,
    abbreviation      character varying (50) not null,
    CONSTRAINT company_pk PRIMARY KEY (id),
    CONSTRAINT c_parent_company_id_fk FOREIGN KEY (parent_company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists company_parent_company_id_idx ON flow.company (parent_company_id);

CREATE TABLE if not exists flow.event_type
(
    id              serial                NOT NULL,
    company_id      integer,
    event_type character varying(30),
    archived boolean default false,
    CONSTRAINT event_type_pk PRIMARY KEY (id),
    CONSTRAINT st_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists st_company_id_idx ON flow.event_type (company_id);

CREATE TABLE if not exists flow.work_queue_category
(
    id                       serial  NOT NULL,
    company_id integer not null,
    work_queue_category       character varying(250) not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id integer,
    archived       boolean not null default false,
    CONSTRAINT flow_work_queue_category_pk PRIMARY KEY (id),
    CONSTRAINT flow_wqc_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_wqc_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_wqc_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.work_queue_type
(
    id              serial                NOT NULL,
    company_id      integer,
    work_queue_type character varying(30),
    work_queue_category_id int not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id integer,
    archived boolean default false,
    CONSTRAINT work_queue_type_pk PRIMARY KEY (id),
    CONSTRAINT wt_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_wqt_work_queue_category_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.work_queue_category (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_wqt_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_wqt_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists wqt_company_id_idx ON flow.work_queue_type (company_id);

CREATE TABLE if NOT EXISTS flow.flow_type
(
    id          serial                NOT NULL,
    flow_type character varying(50) NOT NULL,
    CONSTRAINT flow_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.bucket_type
(
    id          serial                NOT NULL,
    bucket_type character varying(50) NOT NULL,
    CONSTRAINT bucket_type_pk PRIMARY KEY (id)
);

--project table or customer table
CREATE TABLE if NOT EXISTS flow.object_type
(
    id          serial                NOT NULL,
    object_type character varying(50) NOT NULL,
    object_code character varying(50) NOT NULL,
    flow_type_id integer not null,
    archived boolean not null default false,
    CONSTRAINT object_type_pk PRIMARY KEY (id),
    CONSTRAINT ot_flow_type_id FOREIGN KEY (flow_type_id)
        REFERENCES flow.flow_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ot_flow_type_id_idx ON flow.object_type (flow_type_id);

--active inactive
CREATE TABLE if NOT EXISTS flow.status_type
(
    id          serial,
    status_type character VARYING(50) not null,
    archived boolean not null default false,
    CONSTRAINT status_type_pk PRIMARY KEY (id)
);

--button or URL to another page
CREATE TABLE if NOT EXISTS flow.action_type
(
    id          serial,
    action_type character VARYING(50) not null,
    CONSTRAINT action_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.attachment_type
(
    id              serial                NOT NULL,
    attachment_type character VARYING(100) not null,
    attachment_code character VARYING(100),
    company_id integer,
    archived boolean not null default false,
    key_pattern_id integer,
    is_system boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT attachment_type_pk PRIMARY KEY (id),
    CONSTRAINT at_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT at_key_pattern_id_fk FOREIGN KEY (key_pattern_id)
        REFERENCES flow.key_pattern (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists at_company_id__idx ON flow.attachment_type (company_id);
CREATE INDEX if not exists at_key_pattern_id_idx ON flow.attachment_type (key_pattern_id);


CREATE TABLE if NOT EXISTS flow.link
(
    id              serial                NOT NULL,
    link character VARYING(30) not null,
    url character VARYING(100) not null,
    company_id integer not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT link_pk PRIMARY KEY (id),
    CONSTRAINT link_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists link_company_id__idx ON flow.link (company_id);

CREATE TABLE if not exists  flow.attachment
(
    id                 serial  not null,
    attachment_type_id integer,
    company_id         integer not null,
    filename           character varying(100),
    content_type       character varying(100),
    s3_key             character varying(100),
    size               integer,
    archived           boolean not null default false,
    date_created            timestamp without time zone,
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT attachment_pk PRIMARY KEY (id),
    CONSTRAINT a_attachment_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT a_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists a_attachment_type_id_idx ON flow.attachment (attachment_type_id);


CREATE TABLE if not exists  flow.attachment_source
(
    id                        serial  NOT NULL,
    attachment_id             integer NOT NULL,
    source_id                 integer NOT NULL,
    CONSTRAINT attachment_source_pk PRIMARY KEY (id),
    CONSTRAINT as_attachment_id_fk FOREIGN KEY (attachment_id)
        REFERENCES flow.attachment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists as_attachment_id_idx ON flow.attachment_source (attachment_id);

--lead or contact
CREATE TABLE if NOT EXISTS flow.customer_type
(
    id            serial                NOT NULL,
    customer_type character varying(50) not null,
    CONSTRAINT customer_type_pk PRIMARY KEY (id)
);
--Integer character boolean etc
CREATE TABLE if NOT EXISTS flow.data_type
(
    id        serial                NOT NULL,
    data_type character varying(50) NOT NULL,
    custom_behavior boolean not null default false,
    CONSTRAINT data_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.db_function
(
    id          serial                NOT NULL,
    function_name character varying(50) NOT NULL,
    archived boolean not null default false,
    return_data_type_id integer not null,
    CONSTRAINT db_function_pk PRIMARY KEY (id),
    CONSTRAINT df_return_data_type_id_fk FOREIGN KEY (return_data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists df_return_data_type_id_idx ON flow.db_function (return_data_type_id);

CREATE TABLE if NOT EXISTS flow.db_function_param
(
    id          serial                NOT NULL,
    db_function_id integer NOT NULL,
    parameter_name character varying(50) not null,
    archived boolean not null default false,
    display_order integer not null,
    data_type_id integer not null,
    parameter_type_id integer not null,
    CONSTRAINT db_function_param_pk PRIMARY KEY (id),
    CONSTRAINT dfp_db_function_id_fk FOREIGN KEY (db_function_id)
        REFERENCES flow.db_function (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT df_parameter_data_type_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT df_parameter_type_id_fk FOREIGN KEY (parameter_type_id)
        REFERENCES flow.parameter_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists dfp_db_function_id_idx ON flow.db_function_param (db_function_id);
CREATE INDEX if not exists dfp_data_type_id_idx ON flow.db_function_param (data_type_id);
CREATE INDEX if not exists dfp_parameter_type_id_idx ON flow.db_function_param (parameter_type_id);

CREATE TABLE if NOT EXISTS flow.company_function
(
    id          serial                NOT NULL,
    company_function_name character varying(50) NOT NULL,
    db_function_id integer not null,
    archived boolean not null default false,
    company_id integer not null,
    CONSTRAINT company_function_pk PRIMARY KEY (id),
    CONSTRAINT cf_db_function_id_fk FOREIGN KEY (db_function_id)
        REFERENCES flow.db_function (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cf_db_function_id_idx ON flow.company_function (db_function_id);
CREATE INDEX if not exists cf_company_id_id_idx ON flow.company_function (company_id);

CREATE TABLE if NOT EXISTS flow.operation_type
(
    id            serial,
    operation_type character varying(10) NOT NULL,
    operation_code character varying(10) not null,
    archived  boolean not null default false,
    CONSTRAINT operation_type_pk primary key (id)
);

CREATE TABLE if NOT EXISTS flow.operator_type
(
    id            serial,
    operator_type character varying(100) NOT NULL,
    archived  boolean not null default false,
    CONSTRAINT operator_type_pk primary key (id)
);


CREATE TABLE if NOT EXISTS flow.operator_data_type
(
    id        serial                NOT NULL,
    operator_type_id integer NOT NULL,
    data_type_id integer not null,
    archived boolean not null default false,
    CONSTRAINT operator_data_type_pk PRIMARY KEY (id),
    CONSTRAINT odt_operator_type_id_fk FOREIGN KEY (operator_type_id)
        REFERENCES flow.operator_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT odt_data_type_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists odt_operator_type_id_id_idx ON flow.operator_data_type (operator_type_id);
CREATE INDEX if not exists odt_data_type_id_id_idx ON flow.operator_data_type (data_type_id);

--function or custom field
CREATE TABLE if NOT EXISTS flow.process_step_requirement_type
(
    id               serial                not null,
    process_step_requirement_type character varying(30) NOT NULL,
    archived  boolean not null default false,
    CONSTRAINT process_step_requirement_type_pk primary key (id)
);


CREATE TABLE if not exists flow.state
(
    id                     serial                 NOT NULL,
    state                  character varying(100) NOT NULL,
    active_flag            boolean                NOT NULL DEFAULT false,
    abbreviation           character varying(2),
    time_zone_abbreviation character varying(30),
    map_latitude           numeric(14, 11),
    map_longitude          numeric(14, 11),
    map_zoom               numeric(14, 11),
    CONSTRAINT state_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists flow.org_type
(
    id                 serial                NOT NULL,
    org_type           character varying(50) NOT NULL,
    org_parent_type_id integer,
    org_level_id       integer not null,
    company_id         integer               NOT NULL,
    archived           boolean not null default false,
    date_created            timestamp without time zone,
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT org_type_pk PRIMARY KEY (id),
    CONSTRAINT ot_org_parent_type_id_fk FOREIGN KEY (org_parent_type_id)
        REFERENCES flow.org_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ot_org_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists ot_org_parent_type_id_idx ON flow.org_type (org_parent_type_id);
CREATE INDEX if not exists ot_company_id_idx ON flow.org_type (company_id);


CREATE TABLE if not exists flow.user_status_type
(
    id               serial                NOT NULL,
    user_status_type character varying(20) NOT NULL,
    company_id integer not null,
    archived boolean not null default false,
    CONSTRAINT user_status_type_pk PRIMARY KEY (id),
    CONSTRAINT ust_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );
CREATE INDEX if not exists ust_company_id_idx ON flow.user_status_type (company_id);


CREATE TABLE if NOT EXISTS flow.company_data_type
(
    id        serial                NOT NULL,
    company_id integer not null,
    company_data_type character varying(50) NOT NULL,
    data_type_id integer not null,
    has_list_values boolean not null default false,
    archived boolean not null default false,
    CONSTRAINT company_data_type_pk PRIMARY KEY (id),
    CONSTRAINT cdt_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cdt_data_type_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cdt_company_id_idx ON flow.company_data_type (company_id);
CREATE INDEX if not exists cdt_data_type_id_idx ON flow.company_data_type (data_type_id);

CREATE TABLE if not exists flow."user"
(
    id                                 bigserial NOT NULL,
    first_name                         character varying(50),
    last_name                          character varying(50),
    email                              character varying(255),
    password                           character varying(100),
    start_date                         date,
    end_date                           date,
    phone_number                       character varying(50),
    notes                              text,
    employee_id                        integer,
    user_status_type_id                integer   NOT NULL DEFAULT 1,
    employment_type_id                 integer,
    compensation_type_id               integer,
    created_by_id                         integer,
    date_created                         date      NOT NULL DEFAULT ('now'::text)::date,
    modified_by_id                        integer,
    date_modified                        date      NOT NULL DEFAULT ('now'::text)::date,
    personal_email                     character varying(255),
    recruited_by                       character varying(50),
    recruited_by_user_id               integer,
    referred_by_user_id                integer,
    onboarded_by_user_id               integer,
    hire_date                          date,
    image_id                           bigint,
    default_company_id                 integer references flow.company(id),
    username                           character varying(255) not null,
    CONSTRAINT user_pk PRIMARY KEY (id),
--     CONSTRAINT u_user_status_type_id_fk FOREIGN KEY (user_status_type_id)
--         REFERENCES flow.user_status_type (id) MATCH SIMPLE
--         ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT u_onboarded_by_user_id_fk FOREIGN KEY (onboarded_by_user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT u_recruited_by_user_id_fk FOREIGN KEY (recruited_by_user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT u_referred_by_user_id_fk FOREIGN KEY (referred_by_user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT u_default_company_id_fk FOREIGN KEY (default_company_id)
        REFERENCES flow."company" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT u_email_fk UNIQUE (email),
    CONSTRAINT user_personal_email_uk UNIQUE (personal_email),
    CONSTRAINT user_username_uk UNIQUE (username)
)
    WITH (
        OIDS= FALSE
    );


alter table flow.company
    add CONSTRAINT c_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.company
    add CONSTRAINT c_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.org_type
    add CONSTRAINT org_type_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.org_type
    add CONSTRAINT org_type_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.attachment
    add CONSTRAINT att_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.attachment
    add CONSTRAINT att_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;


alter table flow.link
    add CONSTRAINT link_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.link
    add CONSTRAINT link_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

alter table flow.attachment_type
    add CONSTRAINT at_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;
alter table flow.attachment_type
    add CONSTRAINT at_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION;

CREATE INDEX if not exists u_user_status_type_id_idx
    ON flow."user"
        USING btree
        (user_status_type_id);


CREATE INDEX if not exists u_employment_type_id_idx
    ON flow."user"
        USING btree
        (employment_type_id);

CREATE INDEX if not exists u_compensation_type_id_idx
    ON flow."user"
        USING btree
        (compensation_type_id);


CREATE INDEX if not exists u_email_idx
    ON flow."user"
        USING btree
        (lower(email::text) COLLATE pg_catalog."default");



CREATE INDEX if not exists u_personal_email_idx
    ON flow."user"
        USING btree
        (lower(personal_email::text) COLLATE pg_catalog."default");



CREATE UNIQUE INDEX if not exists u_employee_id_idx
    ON flow."user"
        USING btree
        (employee_id);

CREATE INDEX if not exists u_first_name_idx
    ON flow."user"
        USING gin
        (first_name COLLATE pg_catalog."default" gin_trgm_ops);


CREATE INDEX if not exists u_last_name_idx
    ON flow."user"
        USING gin
        (last_name COLLATE pg_catalog."default" gin_trgm_ops);


alter table flow."user"
    add column if not exists archived boolean default false;

CREATE TABLE if not exists flow.user_company
(
    id              serial                NOT NULL,
    company_id      integer,
    user_id integer,
    archived boolean default false,
    is_default boolean default false,
    CONSTRAINT user_company_pk PRIMARY KEY (id),
    CONSTRAINT uc_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT uc_user_id_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists uc_company_id_idx ON flow.user_company (company_id);
CREATE INDEX if not exists uc_user_id_idx ON flow.user_company (user_id);

--active failed cancelled
CREATE TABLE if NOT EXISTS flow.process_step_status_type
(
    id                  serial                not null,
    process_step_status_type character varying(50) NOT NULL,
    archived boolean not null default false,
    CONSTRAINT process_step_status_type_pk primary key (id)
);

CREATE TABLE if NOT EXISTS flow.company_process_step_status_type
(
    id                  serial                not null,
    process_step_status_type_id integer not null,
    process_step_status_type character varying(50) NOT NULL,
    company_id  integer not null,
    archived boolean not null default false,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer,
    modified_by_id       integer,
    CONSTRAINT company_process_step_status_type_pk primary key (id),
    CONSTRAINT psst_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT cpsst_process_step_status_type_id_fk FOREIGN KEY (process_step_status_type_id)
        REFERENCES flow.process_step_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT cpsst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cpsst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cpst_process_step_status_type_id_idx ON flow.company_process_step_status_type (process_step_status_type_id);
CREATE INDEX if not exists cpst_company_id_idx ON flow.company_process_step_status_type (company_id);



CREATE TABLE if not exists  flow."position"
(
    id                    serial                 NOT NULL,
    company_id            integer                NOT NULL,
    "position"            character varying(100) NOT NULL,
    org_type_id           integer,
    secondary_org_type_id integer,
    active                boolean DEFAULT true,
    archived              boolean not null DEFAULT false,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer,
    modified_by_id       integer,
    CONSTRAINT position_pk PRIMARY KEY (id),
    CONSTRAINT p_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT p_org_type_id_fk FOREIGN KEY (org_type_id)
        REFERENCES flow.org_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT p_secondary_org_type_id_fk FOREIGN KEY (secondary_org_type_id)
        REFERENCES flow.org_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT p_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT p_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE INDEX p_company_id_idx
    ON flow."position"
        USING btree
        (company_id);



CREATE INDEX p_org_type_id_idx
    ON flow."position"
        USING btree
        (org_type_id);



CREATE INDEX p_secondary_org_type_id_idx
    ON flow."position"
        USING btree
        (secondary_org_type_id);



CREATE TABLE if NOT EXISTS flow.owner_type
(
    id        serial                NOT NULL,
    owner_type character varying(10) not null,
    CONSTRAINT owner_type_pk PRIMARY KEY (id)
);

CREATE TABLE if NOT EXISTS flow.owner_position_id
(
    id        serial                NOT NULL,
    company_id  integer not null references flow.company(id),
    position_ids  integer[] not null,
    owner_type_id integer not null references flow.owner_type(id),
    CONSTRAINT owner_position_pk PRIMARY KEY (id)
);


CREATE TABLE if not exists flow.org
(
    id                  serial                 NOT NULL,
    company_id          integer,
    org_name            character varying(100) NOT NULL,
    parent_org_id       integer,
    sales_area_id       integer,
    org_type_id         integer                NOT NULL,
    display_order       integer,
    active_flag         boolean DEFAULT true,
    color               character varying(20),
    email               character varying(255),
    calendar_oid        character varying(100),
    sales_metro_area_id integer,
    originator_id       integer,
    owning_org          boolean not null default false,
    CONSTRAINT org_pk PRIMARY KEY (id),
    CONSTRAINT o_org_type_id_fk FOREIGN KEY (org_type_id)
        REFERENCES flow.org_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT o_parent_org_id_fk FOREIGN KEY (parent_org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT o_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE INDEX if not exists o_parent_org_id_idx
    ON flow.org
        USING btree
        (parent_org_id);



CREATE INDEX if not exists o_sales_area_id_idx
    ON flow.org
        USING btree
        (sales_area_id);



CREATE INDEX if not exists o_org_type_id_idx
    ON flow.org
        USING btree
        (org_type_id);



CREATE INDEX if not exists o_org_name_idx
    ON flow.org
        USING btree
        (org_name COLLATE pg_catalog."default");


CREATE INDEX if not exists o_company_id_idx
    ON flow.org
        USING btree
        (company_id);

CREATE TABLE if not exists flow.user_position
(
    id               serial  NOT NULL,
    user_id          integer NOT NULL,
    position_id      integer NOT NULL,
    start_date       date,
    end_date         date,
    active           boolean NOT NULL DEFAULT true,
    org_id           integer,
    secondary_org_id integer,
    primary_flag     boolean NOT NULL DEFAULT false,
    CONSTRAINT user_position_pk PRIMARY KEY (id),
    CONSTRAINT up_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT up_postiion_id_fk FOREIGN KEY (position_id)
        REFERENCES flow."position" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT up_org_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT up_secondary_org_id_fk FOREIGN KEY (secondary_org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );



CREATE INDEX if not exists up_position_id_idx
    ON flow.user_position
        USING btree
        (position_id);



CREATE INDEX if not exists up_org_id_idx
    ON flow.user_position
        USING btree
        (org_id);



CREATE INDEX if not exists up_secondary_org_id_idx
    ON flow.user_position
        USING btree
        (secondary_org_id);



CREATE INDEX if not exists user_position_user_id_idx
    ON flow.user_position
        USING btree
        (user_id);


CREATE TABLE if NOT EXISTS flow.process
(
    id             serial,
    parent_company_id integer not null,
    process_name     character VARYING(50) not null,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer not null,
    modified_by_id integer,
    archived       boolean not null default false,
    CONSTRAINT process_pk PRIMARY KEY (id),
    CONSTRAINT process_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT process_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT process_parent_company_id_fk FOREIGN KEY (parent_company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );
CREATE INDEX if not exists process_parent_company_id_idx ON flow.process (parent_company_id);


CREATE TABLE if not exists flow.company_process
(
    id             serial  NOT NULL,
    company_id     integer not null,
    process_id       integer not null,
    status_type_id integer not null,
    archived       boolean not null default false,
    CONSTRAINT company_process_pk PRIMARY KEY (id),
    CONSTRAINT cp_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cp_scope_id_fk FOREIGN KEY (process_id)
        REFERENCES flow.process (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cp_status_type_id_fk FOREIGN KEY (status_type_id)
        REFERENCES flow.status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cp_company_id_idx ON flow.company_process (company_id);

CREATE INDEX if not exists cp_process_id_idx ON flow.company_process (process_id);
CREATE INDEX if not exists cp_status_type_id_idx ON flow.company_process (status_type_id);


CREATE TABLE if not EXISTS flow.customer
(
    id                   serial NOT NULL,
    customer_type_id     integer not null,
    first_name           character varying(100),
    last_name            character varying(100),
    street1              character varying(100),
    street2              character varying(100),
    city                 character varying(100),
    state                character varying(50),
    state_id             integer,
    postal_code          character varying(10),
    country_id           integer,
    phone                character varying(50),
    email                character varying(255),
    prospect_status      character varying(50),
    mobile               character varying(50),
    latitude             double precision,
    longitude            double precision,
    location_unavailable boolean,
    time_zone            character varying(100),
    mailing_street1      character varying(100),
    mailing_street2      character varying(100),
    mailing_city         character varying(100),
    mailing_state        character varying(50),
    mailing_postal_code  character varying(10),
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer not null,
    modified_by_id       integer,
    company_id           integer not null,
    archived             boolean not null default false,
    title                text,
    owner_user_position_id             integer,
    migrate_lead_id     integer,
    CONSTRAINT customer_pk PRIMARY KEY (id),
    CONSTRAINT customer_customer_type_id_fk FOREIGN KEY (customer_type_id)
        REFERENCES flow.customer_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_owner_id_fk FOREIGN KEY (owner_user_position_id)
        REFERENCES flow.user_position (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_country_id_fk FOREIGN KEY (country_id)
        REFERENCES flow.country (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT customer_state_id_fk FOREIGN KEY (state_id)
        REFERENCES flow.state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists c_customer_type_id_idx ON flow.customer (customer_type_id);
CREATE INDEX if not exists c_owner_user_position_id_idx ON flow.customer (owner_user_position_id);
CREATE INDEX if not exists c_company_id_idx ON flow.customer (company_id);
CREATE INDEX if not exists c_country_id_idx ON flow.customer (country_id);
CREATE INDEX if not exists c_state_id_idx ON flow.customer (state_id);

alter table flow.org
    alter column company_id set not null;


alter table flow.position
    alter column company_id set not null;


CREATE TABLE if not exists flow.permission
(
    id              serial                NOT NULL,
    permission_name character varying(250) not null,
    permission_code character varying(50) NOT NULL,
    archived        boolean DEFAULT false,
    is_system boolean not null default false,
    CONSTRAINT permission_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.company_permission
(
    id              serial                NOT NULL,
    permission_name character varying(250) not null,
    company_id integer not null,
    permission_id integer not null,
    archived        boolean DEFAULT false,
    CONSTRAINT company_permission_pk PRIMARY KEY (id),
    CONSTRAINT p_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT p_permission_id_fk FOREIGN KEY (permission_id)
        REFERENCES flow.permission (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists cp1_company_id_idx ON flow.company_permission (company_id);
CREATE INDEX if not exists cp1_permission_id_idx ON flow.company_permission (permission_id);

CREATE TABLE if not exists flow.role
(
    id         serial NOT NULL,
    company_id integer,
    role_name  character varying(20),
    archived   boolean  not null DEFAULT false,
    is_system boolean not null default false,
    CONSTRAINT role_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.position_role
(
    id            serial  NOT NULL,
    role_id       integer NOT NULL,
    position_id integer NOT NULL,
    archived          boolean default false,
    CONSTRAINT position_role_pk PRIMARY KEY (id),
    CONSTRAINT pr_permission_id_fk FOREIGN KEY (role_id)
        REFERENCES flow.role (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pr_position_id_fk FOREIGN KEY (position_id)
        REFERENCES flow.position (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists pr_role_id_idx ON flow.position_role (role_id);
CREATE INDEX if not exists pr_position_id_idx ON flow.position_role (position_id);



CREATE TABLE if not exists flow.role_permission
(
    id            serial  NOT NULL,
    role_id       integer NOT NULL,
    company_permission_id integer NOT NULL,
    CONSTRAINT role_permission_pk PRIMARY KEY (id),
    CONSTRAINT rp_permission_id_fk FOREIGN KEY (company_permission_id)
        REFERENCES flow.company_permission (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT rp_role_id_fk FOREIGN KEY (role_id)
        REFERENCES flow.role (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );


CREATE INDEX if not exists rp_permission_id_idx
    ON flow.role_permission
        USING btree
        (company_permission_id);

CREATE INDEX if not exists rp_role_id_idx
    ON flow.role_permission
        USING btree
        (role_id);


CREATE TABLE if not exists flow.user_permission
(
    id            serial  NOT NULL,
    user_id       integer NOT NULL,
    company_permission_id integer NOT NULL,
    deny          boolean default false,
    CONSTRAINT user_permission_pk PRIMARY KEY (id),
    CONSTRAINT up_permission_id_fk FOREIGN KEY (company_permission_id)
        REFERENCES flow.company_permission (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT up_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );




CREATE INDEX if not exists up_permission_id_idx
    ON flow.user_permission
        USING btree
        (company_permission_id);


CREATE INDEX if not exists user_permission_user_id_idx
    ON flow.user_permission
        USING btree
        (user_id);


CREATE TABLE if not exists flow.user_role
(
    id      serial  NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    CONSTRAINT user_role_pk PRIMARY KEY (id),
    CONSTRAINT ur_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ur_role_id_fk FOREIGN KEY (role_id)
        REFERENCES flow.role (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );


CREATE INDEX if not exists ur_user_id_idx
    ON flow.user_role
        USING btree
        (user_id);


CREATE INDEX if not exists ur_role_id_idx
    ON flow.user_role
        USING btree
        (role_id);



alter table flow.role
    alter column company_id set not null;


CREATE TABLE if not exists  flow.asset_type
(
    id     serial NOT NULL,
    type   character varying(50),
    active boolean DEFAULT true,
    CONSTRAINT asset_type_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  flow.asset
(
    id            serial  NOT NULL,
    company_id    integer,
    tag           character varying(50),
    model         character varying(50),
    asset_type_id integer NOT NULL,
    active        boolean DEFAULT true,
    archived      boolean DEFAULT false,
    CONSTRAINT asset_pk PRIMARY KEY (id),
    CONSTRAINT a_asset_type_id_fk FOREIGN KEY (asset_type_id)
        REFERENCES flow.asset_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT a_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE INDEX if not exists asset_company_id_idx ON flow.asset (company_id);




CREATE UNIQUE INDEX a_comp1_uk
    ON flow.asset
        USING btree
        (tag COLLATE pg_catalog."default", asset_type_id)
    WHERE archived IS TRUE;



CREATE TABLE if not exists  flow.user_asset
(
    id       serial  NOT NULL,
    user_id  integer NOT NULL,
    asset_id integer NOT NULL,
    CONSTRAINT user_asset_pk PRIMARY KEY (id),
    CONSTRAINT ua_asset_id_fk FOREIGN KEY (asset_id)
        REFERENCES flow.asset (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ua_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE UNIQUE INDEX ua_comp1_uk
    ON flow.user_asset
        USING btree
        (user_id, asset_id);


CREATE TABLE if not exists  flow.user_asset_history
(
    id          serial                NOT NULL,
    first_name  character varying(50) NOT NULL,
    last_name   character varying(50) NOT NULL,
    user_id     integer               NOT NULL,
    asset_id    integer               NOT NULL,
    update_date timestamp without time zone,
    action_type character varying(20),
    CONSTRAINT user_asset_history_pk PRIMARY KEY (id),
    CONSTRAINT uah_asset_id_fk FOREIGN KEY (asset_id)
        REFERENCES flow.asset (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT uah_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


alter table flow.asset
    alter column company_id set not null;


CREATE TABLE if not exists  flow.associated_org_type
(
    id                  serial                NOT NULL,
    associated_org_type character varying(20) NOT NULL,
    CONSTRAINT associated_org_type_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE  if not exists flow.associated_org
(
    id                     serial  NOT NULL,
    org_id                 integer NOT NULL,
    associated_org_id      integer NOT NULL,
    associated_org_type_id integer NOT NULL,
    CONSTRAINT associated_org_pk PRIMARY KEY (id),
    CONSTRAINT ao_associated_org_type_id_fk FOREIGN KEY (associated_org_type_id)
        REFERENCES flow.associated_org_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT ao_org_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
)
    WITH (
        OIDS= FALSE
    );

CREATE INDEX if not exists ao_associated_org_type_id_idx ON flow.associated_org (associated_org_type_id);
CREATE INDEX if not exists ao_org_id_idx ON flow.associated_org (org_id);

CREATE TABLE if not exists flow.process_step
(
    id             serial                 NOT NULL,
    company_id     integer not null,
    process_step_name   character varying(100) NOT NULL,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer                not null,
    modified_by_id integer,
    archived boolean not null default false,
    CONSTRAINT process_step_pk PRIMARY KEY (id),
    CONSTRAINT process_step_parent_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT process_step_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT process_step_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ps_company_id_idx ON flow.process_step (company_id);

CREATE TABLE if not exists flow.process_step_work_queue_type
(
    id              serial                NOT NULL,
    process_step_id      integer,
    work_queue_type_id integer,
    archived boolean default false,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer                not null,
    modified_by_id integer,
    CONSTRAINT process_step_work_queue_type_pk PRIMARY KEY (id),
    CONSTRAINT pswqt_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pswqt_work_queue_type_id_fk FOREIGN KEY (work_queue_type_id)
        REFERENCES flow.work_queue_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pswqt_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pswqt_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.process_step_action
(
    id                     serial  not null,
    process_step_id        integer,
    action_type_id integer not null,
    action_name           varchar(100) not null,
    company_process_step_status_type_id integer,
    automatic_completion   boolean not null default false,
    date_created           timestamp without time zone DEFAULT now(),
    date_modified           timestamp without time zone,
    created_by_id          integer not null,
    modified_by_id         integer,
    archived boolean not null default false,
    CONSTRAINT process_step_action_pk PRIMARY KEY (id),
    CONSTRAINT psa_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psa_action_type_id_fk FOREIGN KEY (action_type_id)
        REFERENCES flow.action_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psa_action_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psa_action_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psa_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
        REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psa_process_step_id_idx ON flow.process_step_action (process_step_id);

CREATE INDEX if not exists psa_process_action_type_id_idx ON flow.process_step_action (action_type_id);
CREATE INDEX if not exists psa_company_process_step_status_type_id_idx ON flow.process_step_action (company_process_step_status_type_id);



CREATE TABLE if not exists flow.process_step_process
(
    id              serial  NOT NULL,
    process_id        integer NOT NULL,
    process_step_id integer not null,
    org_id          integer not null,
    display_order         integer not null,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    initial_step boolean not null default false,
    company_process_step_status_type_id   integer,
    archived boolean not null default false,
    CONSTRAINT process_step_process_pk PRIMARY KEY (id),
    CONSTRAINT psp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psp_process_id_fk FOREIGN KEY (process_id)
        REFERENCES flow.process (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psp_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
        REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psp_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psp_org_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psp_process_id_idx ON flow.process_step_process (process_id);
CREATE INDEX if not exists psp_company_process_step_status_type_id_idx ON flow.process_step_process (company_process_step_status_type_id);
CREATE INDEX if not exists psp_process_step_id_idx ON flow.process_step_process (process_step_id);
CREATE INDEX if not exists psp_org_id_idx ON flow.process_step_process (org_id);


--name of field sections for field names grouped
CREATE TABLE if NOT EXISTS flow.custom_field_group
(
    id          serial,
    group_name character VARYING(100) not null,
    object_type_id integer not null,
    group_order integer,
    archived boolean not null default false,
    process_step_id integer,
    event_type_id integer,
    CONSTRAINT custom_field_group_pk PRIMARY KEY (id),
    CONSTRAINT cfgt_object_type_id_fk FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfgt_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfgt_event_type_id_fk FOREIGN KEY (event_type_id)
        REFERENCES flow.event_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cfgt_object_type_id_idx ON flow.custom_field_group (object_type_id);
CREATE INDEX if not exists cfgt_process_step_id_idx ON flow.custom_field_group (process_step_id);
CREATE INDEX if not exists cfgt_event_type_id_idx ON flow.custom_field_group (event_type_id);

COMMENT ON TABLE flow.custom_field_group IS
    'Stores metadata for groups of custom fields. May retrieve custom fields
     using join table flow.custom_field_group.';

CREATE TABLE if not exists flow.object_attachment_type
(
    id              serial  NOT NULL,
    attachment_type_id   integer NOT NULL,
    object_type_id integer NOT NULL,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    archived boolean not null default false,
    CONSTRAINT object_attachment_type_pk PRIMARY KEY (id),
    CONSTRAINT oat_attachment_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT oat_object_type_id_fk FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT oat_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT oat_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists oat_attachment_type_id_idx ON flow.object_attachment_type (attachment_type_id);
CREATE INDEX if not exists oat_object_type_id_idx ON flow.object_attachment_type (object_type_id);

CREATE TABLE if not exists flow.process_step_attachment_type
(
    id              serial  NOT NULL,
    attachment_type_id   integer NOT NULL,
    process_step_id integer NOT NULL,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    archived boolean not null default false,
    CONSTRAINT process_step_attachment_pk PRIMARY KEY (id),
    CONSTRAINT psa_attachment_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psa_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psa_attachment_id_idx ON flow.process_step_attachment_type (attachment_type_id);

CREATE INDEX if not exists psa_process_step_id1_idx ON flow.process_step_attachment_type (process_step_id);


CREATE TABLE if not exists flow.process_step_link
(
    id              serial  NOT NULL,
    link_id   integer NOT NULL,
    process_step_id integer NOT NULL,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    archived boolean not null default false,
    CONSTRAINT process_step_link_pk PRIMARY KEY (id),
    CONSTRAINT psl_link_id_fk FOREIGN KEY (link_id)
        REFERENCES flow.link (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psl_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psl_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psl_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psl_link_id_idx ON flow.process_step_link (link_id);

CREATE INDEX if not exists psl_process_step_id1_idx ON flow.process_step_link (process_step_id);

CREATE TABLE if not exists flow.project
(
    id               serial                 NOT NULL,
    customer_id      integer                not null,
    company_process_id integer                not null,
    project_name     character varying(100) not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified     timestamp without time zone,
    created_by_id    integer                not null,
    modified_by_id   integer,
    CONSTRAINT project_pk PRIMARY KEY (id),
    CONSTRAINT p_company_process_id_fk FOREIGN KEY (company_process_id)
        REFERENCES flow.company_process (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT p_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES flow.customer (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT p_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT p_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION

);

CREATE INDEX if not exists p_company_id1_idx ON flow.project (company_process_id);

CREATE INDEX if not exists p_customer_id_idx ON flow.project (customer_id);

CREATE TABLE if not exists flow.project_attachment_type
(
    id              serial  NOT NULL,
    attachment_type_id   integer NOT NULL,
    company_id integer NOT NULL,
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    archived boolean not null default false,
    CONSTRAINT project_attachment_type_pk PRIMARY KEY (id),
    CONSTRAINT pat_attachment_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pat_process_step_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pat_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pat_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pat_attachment_id_idx ON flow.project_attachment_type (attachment_type_id);

CREATE INDEX if not exists pat_company_id_idx ON flow.project_attachment_type (company_id);

CREATE TABLE if not exists flow.project_process_step
(
    id                         serial  NOT NULL,
    project_id                 integer not null,
    process_step_id            integer not null,
    user_position_id           integer,
    company_process_step_status_type_id     integer not null,
    process_step_complete_date date,
    date_created               timestamp without time zone DEFAULT now(),
    date_modified              timestamp without time zone,
    created_by_id              integer not null,
    modified_by_id             integer,
    -- CONSTRAINT project_process_step_pk PRIMARY KEY (id),
    CONSTRAINT pps_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id),
    CONSTRAINT pps_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
        REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pps_user_position_id_fk FOREIGN KEY (user_position_id)
        REFERENCES flow.user_position (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pps_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pps_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pps_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
) PARTITION BY LIST(process_step_id);

CREATE INDEX if not exists pps_project_id_idx ON flow.project_process_step (project_id);

CREATE INDEX if not exists pps_process_step_id_idx ON flow.project_process_step (process_step_id);

CREATE INDEX if not exists pps_process_step_status_id_idx ON flow.project_process_step (company_process_step_status_type_id);

CREATE INDEX if not exists pps_user_position_id_idx ON flow.project_process_step (user_position_id);

CREATE TABLE if not exists flow.project_process_step_attachment
(
    id                      serial  not null,
    attachment_id           integer not null,
    project_process_step_id integer not null,
    date_created            timestamp without time zone DEFAULT now(),
    date_modified            timestamp without time zone,
    created_by_id           integer not null,
    modified_by_id          integer,
    constraint project_process_step_attachment_pk primary key (id),
    CONSTRAINT ppsa_attachment_id_fk FOREIGN KEY (attachment_id)
        REFERENCES flow.attachment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    -- CONSTRAINT ppsa_project_process_step_id_fk FOREIGN KEY (project_process_step_id)
    --    REFERENCES flow.project_process_step (id) MATCH SIMPLE
    --    ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppsa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppsa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ppsa_attachment_id_idx ON flow.project_process_step_attachment (attachment_id);

CREATE INDEX if not exists ppsa_project_process ON flow.project_process_step_attachment (project_process_step_id);


CREATE TABLE if not exists flow.project_attachment
(
    id             serial  not null,
    attachment_id  integer not null,
    project_id     integer not null,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer not null,
    modified_by_id integer,
    constraint project_attachment_pk primary key (id),
    CONSTRAINT pa_attachment_id_fk FOREIGN KEY (attachment_id)
        REFERENCES flow.attachment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pa_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pa_attachment_id_idx ON flow.project_attachment (attachment_id);

CREATE INDEX if not exists pa_project_process ON flow.project_attachment (project_id);


CREATE TABLE if not exists flow.user_project
(
    id               serial  not null,
    project_id       integer not null,
    user_position_id integer not null,
    archived         boolean not null default false,
    start_date       timestamp without time zone not null,
    end_date         timestamp without time zone,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified     timestamp without time zone,
    created_by_id    integer not null,
    modified_by_id   integer,
    constraint user_project_pk PRIMARY KEY (id),
    CONSTRAINT up_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT up_user_position_id_fk FOREIGN KEY (user_position_id)
        REFERENCES flow.user_position (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT up_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT up_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists up_project_id_idx ON flow.user_project (project_id);

CREATE INDEX if not exists up_user_position_id_idx ON flow.user_project (user_position_id);


CREATE TABLE if not exists flow.process_step_action_child_process
(
    id                     serial  not null,
    process_step_action_id integer not null,
    process_step_id        integer not null,
    trigger_automatically boolean not null default false,
    display_order         integer not null,
    archived              boolean not null default false,
    date_created           timestamp without time zone DEFAULT now(),
    date_modified           timestamp without time zone,
    created_by_id          integer not null,
    modified_by_id         integer,
    CONSTRAINT process_step_action_child_process_pk PRIMARY KEY (id),
    CONSTRAINT psacp_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
        REFERENCES flow.process_step_action (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psacp_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psacp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psacp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psacp_process_step_action_id_idx ON flow.process_step_action_child_process (process_step_action_id);

CREATE INDEX if not exists psacp_process_step_id_idx ON flow.process_step_action_child_process (process_step_id);



CREATE TABLE if not exists flow.list_of_value
(
    id             serial       NOT NULL,
    name           varchar(100) not null,
    code           varchar(10),
    parent_id      integer,
    display_order  integer,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer      not null,
    modified_by_id integer,
    archived       boolean      default false,
    CONSTRAINT list_of_value_pk PRIMARY KEY (id),
    CONSTRAINT lov_parent_id_fk FOREIGN KEY (parent_id)
        REFERENCES flow.list_of_value (id),
    CONSTRAINT lov_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT lov_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists lov_parent_id_idx ON flow.list_of_value (parent_id);

CREATE TABLE if not exists flow.note
(
    id             serial  NOT NULL,
    parent_id      integer,
    note            text not null,
    date_created   timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id  integer not null,
    modified_by_id integer,
    archived        boolean not null default  false,
    CONSTRAINT note_pk PRIMARY KEY (id),
    CONSTRAINT note_parent_id_fk FOREIGN KEY (parent_id)
        REFERENCES flow.note (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT note_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT note_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists note_parent_id_idx ON flow.note (parent_id);




CREATE TABLE if not exists flow.custom_field
(
    id                   serial       NOT NULL,
    list_of_value_id     integer,
    custom_field_sql_key_id integer,
    company_id           integer not null,
    field_name           varchar(100) not null,
    company_data_type_id         integer      NOT NULL,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer      not null,
    modified_by_id       integer,
    archived             boolean default false not null,
    CONSTRAINT custom_field_pk PRIMARY KEY (id),
    CONSTRAINT cf_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_list_of_value_id_fk FOREIGN KEY (list_of_value_id)
        REFERENCES flow.list_of_value (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_company_data_type_id_fk FOREIGN KEY (company_data_type_id)
        REFERENCES flow.company_data_type (id)
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cf_custom_field_sql_key_id_fk FOREIGN KEY (custom_field_sql_key_id)
        REFERENCES flow.custom_field_sql_key (id)
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cf_list_of_value_id_idx ON flow.custom_field (list_of_value_id);

CREATE INDEX if not exists cf_data_type_id_idx ON flow.custom_field (company_data_type_id);

CREATE INDEX if not exists cf_company_id_idx ON flow.custom_field (company_id);

CREATE INDEX if not exists cf_custom_field_sql_key_id_idx ON flow.custom_field (custom_field_sql_key_id);

CREATE TABLE if NOT EXISTS flow.custom_field_object_type
(
    id  serial  NOT NULL,
    custom_field_id integer NOT NULL,
    object_type_id integer NOT NULL,
    archived boolean default false,
    show_on_insert       boolean not null default false,
    CONSTRAINT custom_field_object_type_pk PRIMARY KEY (id),
    CONSTRAINT cf_object_type_id_fk FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id),
    CONSTRAINT cf_custom_field_id_fk FOREIGN KEY (custom_field_id)
        REFERENCES flow.custom_field (id)
);

CREATE INDEX if not exists cfot_object_type_id_idx ON flow.custom_field_object_type (object_type_id);
CREATE INDEX if not exists cfot_custom_field_id_idx ON flow.custom_field_object_type (custom_field_id);

--group custom fields together
CREATE TABLE if NOT EXISTS flow.custom_field_group_assignment
(
    id        serial                NOT NULL,
    custom_field_group_id integer not null,
    custom_field_id            integer,
    ancillary_custom_field_group_assignment_id integer,
    field_order                integer not null,
    archived                   boolean not null default false,
    date_created         timestamp without time zone DEFAULT now(),
    date_modified         timestamp without time zone,
    created_by_id        integer      not null,
    modified_by_id       integer,
    CONSTRAINT custom_field_group_assignment_pk PRIMARY KEY (id),
    CONSTRAINT cfga_custom_field_group_id_fk FOREIGN KEY (custom_field_group_id)
        REFERENCES flow.custom_field_group (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfga_custom_field_id_fk FOREIGN KEY (custom_field_id)
        REFERENCES flow.custom_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfga_ancillary_custom_field_group_assignment_id_fk FOREIGN KEY (ancillary_custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfga_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfga_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cfga_custom_field_group_id_idx ON flow.custom_field_group_assignment (custom_field_group_id);

CREATE INDEX if not exists cfga_custom_field_id_idx ON flow.custom_field_group_assignment (custom_field_id);

CREATE INDEX if not exists cfga_ancillary_custom_field_group_assignment_id_idx ON flow.custom_field_group_assignment (ancillary_custom_field_group_assignment_id);


COMMENT ON TABLE flow.custom_field_group_assignment IS
    'Join table linking custom field metadata (flow.custom_field_group)
     with sets of custom fields.';

COMMENT ON COLUMN flow.custom_field_group_assignment.custom_field_id IS
    'If present, defines the custom fields native to (or owned by) a particular
     group.';

COMMENT ON COLUMN flow.custom_field_group_assignment.ancillary_custom_field_group_assignment_id IS
    'If present, defines the custom fields ancillary to a particular group.
     "Ancillary" means the custom field is not owned or editable from the group,
     but is native (owned) by a different group.';


CREATE TABLE if NOT EXISTS flow.company_function_param
(
    id          serial                NOT NULL,
    company_function_id integer NOT NULL,
    custom_field_group_assignment_id integer,
    archived boolean not null default false,
    system_value_id integer,
    db_function_param_id integer not null,
    created_by_id                         integer,
    date_created                         timestamp  without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp without time zone,
    CONSTRAINT company_function_param_pk PRIMARY KEY (id),
    CONSTRAINT cfp_company_function_id_fk FOREIGN KEY (company_function_id)
        REFERENCES flow.company_function (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfp_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfp_system_value_id_fk FOREIGN KEY (system_value_id)
        REFERENCES flow.system_value (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfp_db_function_param_id_fk FOREIGN KEY (db_function_param_id)
        REFERENCES flow.db_function_param (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfp_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfp_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cfp_company_function_id_idx ON flow.company_function_param (company_function_id);
CREATE INDEX if not exists cfp_custom_field_group_assignment_id_idx ON flow.company_function_param (custom_field_group_assignment_id);
CREATE INDEX if not exists cfp_system_value_id_idx ON flow.company_function_param (system_value_id);
CREATE INDEX if not exists cfp_db_function_param_id_idx ON flow.company_function_param (db_function_param_id);

CREATE TABLE if not exists flow.customer_custom_field_value
(
    id              serial  not null,
    customer_id     integer not null,
    date_value      date,
    custom_field_group_assignment_id integer not null,
    timestamp_value timestamp,
    boolean_value   boolean,
    text_value      text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    CONSTRAINT customer_custom_field_value_pk PRIMARY KEY (id),
    CONSTRAINT ccfv_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES flow.customer (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ccfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ccfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ccfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ccfv_customer_id_idx ON flow.customer_custom_field_value (customer_id);

CREATE INDEX if not exists ccfv_custom_field_group_assignment_id_idx ON flow.customer_custom_field_value (custom_field_group_assignment_id);

CREATE TABLE if not exists flow.user_note
(
    id             serial  NOT NULL,
    user_id    integer NOT NULL,
    note_id        integer NOT NULL,
    CONSTRAINT user_note_pk PRIMARY KEY (id),
    CONSTRAINT un_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT un_note_id_fk FOREIGN KEY (note_id)
        REFERENCES flow.note (id)
);

CREATE INDEX if not exists un_user_id_idx ON flow.user_note (user_id);

CREATE INDEX if not exists un_note_id_idx ON flow.user_note (note_id);


CREATE TABLE if not exists flow.customer_note
(
    id             serial  NOT NULL,
    customer_id    integer NOT NULL,
    note_id        integer NOT NULL,
    CONSTRAINT customer_note_pk PRIMARY KEY (id),
    CONSTRAINT cn_customer_id_fk FOREIGN KEY (customer_id)
        REFERENCES flow.customer (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cn_note_id_fk FOREIGN KEY (note_id)
        REFERENCES flow.note (id)
);

CREATE INDEX if not exists cn_customer_id_idx ON flow.customer_note (customer_id);

CREATE INDEX if not exists cn_note_id_idx ON flow.customer_note (note_id);


CREATE TABLE if NOT EXISTS flow.data_type_requirement
(
    id        serial                NOT NULL,
    data_type_id integer NOT NULL,
    data_type_value character varying (75) not null,
    secondary_requirement boolean not null default false,
    archived boolean not null default false,
    created_by_id                         integer,
    date_created                         timestamp   without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp      without time zone,
    CONSTRAINT data_type_requirement_pk PRIMARY KEY (id),
    CONSTRAINT dtr_process_step_action_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT dtr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT dtr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists dtr_company_data_type_id ON flow.data_type_requirement (data_type_id);
create index if not exists dtr_data_type_value_idx on flow.data_type_requirement (data_type_value);


CREATE TABLE if not exists flow.process_step_requirement
(
    id                           serial  not null,
    process_step_requirement_type_id  integer not null,
    process_step_id   integer not null,
    operator_type_id             integer not null,
    requirement_value    varchar,
    data_type_requirement_id    integer,
    secondary_requirement_value  varchar,
    custom_field_group_assignment_id integer ,
    company_function_id integer,
    requirement_nbr              integer not null,
    date_created                 timestamp without time zone DEFAULT now(),
    date_modified                 timestamp without time zone,
    created_by_id                integer not null,
    modified_by_id               integer,
    archived boolean not null default false,
    CONSTRAINT process_requirement_process_step_pk primary key (id),
    CONSTRAINT prps_process_requirement_type_id_fk FOREIGN KEY (process_step_requirement_type_id)
        REFERENCES flow.process_step_requirement_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT prps_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,

    CONSTRAINT prps_operator_type_id_fk FOREIGN KEY (operator_type_id)
        REFERENCES flow.operator_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT prps_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT prps_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT prps_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT prps_data_type_requirement_id_fk FOREIGN KEY (data_type_requirement_id)
        REFERENCES flow.data_type_requirement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists prps_process_requirement_type_id_idx ON flow.process_step_requirement (process_step_requirement_type_id);

CREATE INDEX if not exists prps_process_step_id_idx ON flow.process_step_requirement (process_step_id);

CREATE INDEX if not exists prps_operator_type_id_idx ON flow.process_step_requirement (operator_type_id);

CREATE INDEX if not exists prps_custom_field_group_assignment_id_idx ON flow.process_step_requirement (custom_field_group_assignment_id);

CREATE INDEX if not exists prps_data_type_requirement_id_idx ON flow.process_step_requirement (data_type_requirement_id);

CREATE TABLE if not exists flow.process_step_logic
(
    id                                  serial  not null,
    process_step_requirement_id integer,
    operation_type_id                    integer,
    sql_order                           integer,
    process_step_action_id              integer,
    date_created                        timestamp without time zone DEFAULT now(),
    date_modified                        timestamp without time zone,
    created_by_id                       integer not null,
    modified_by_id                      integer,
    archived boolean not null default false,
    CONSTRAINT process_step_logic_pk primary key (id),
    CONSTRAINT psl_operation_type_id_fk FOREIGN KEY (operation_type_id)
        REFERENCES flow.operation_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psl_process_requirement_process_step_id_fk FOREIGN KEY (process_step_requirement_id)
        REFERENCES flow.process_step_requirement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psl_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
        REFERENCES flow.process_step_action (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psl_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psl_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE INDEX if not exists pl_operator_type_id_idx ON flow.process_step_logic (operation_type_id);

CREATE INDEX if not exists pl_process_requirement_process_step_id_idx ON flow.process_step_logic (process_step_requirement_id);

CREATE INDEX if not exists pl_process_step_action_id_idx ON flow.process_step_logic (process_step_action_id);


CREATE TABLE if not exists flow.project_custom_field_value
(
    id              serial  not null,
    project_id      integer not null,
    custom_field_group_assignment_id integer not null,
    date_value      date,
    timestamp_value timestamp,
    boolean_value   boolean,
    text_value      text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    CONSTRAINT project_custom_field_value_pk primary key (id),
    CONSTRAINT pcfv_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pcfv_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pcfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pcfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pcfv_project_id_idx ON flow.project_custom_field_value (project_id);

CREATE INDEX if not exists pcfv_custom_field_group_assignment_id_idx ON flow.project_custom_field_value (custom_field_group_assignment_id);


CREATE TABLE if not exists flow.project_note
(
    id             serial  NOT NULL,
    project_id     integer not null,
    note_id        integer not null,
    CONSTRAINT project_note_pk PRIMARY KEY (id),
    CONSTRAINT pn_note_id FOREIGN KEY (note_id)
        REFERENCES flow.note (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pn_project_id FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists pn_note_id_idx ON flow.project_note (note_id);

CREATE INDEX if not exists pn_project_id_idx ON flow.project_note (project_id);


CREATE TABLE if not exists flow.project_process_step_custom_field_value
(
    id                      serial  NOT NULL,
    project_process_step_id integer NOT NULL,
    custom_field_group_assignment_id         integer NOT NULL,
    date_value              date,
    timestamp_value         timestamp,
    boolean_value           bool not null default false,
    text_value              text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created            timestamp without time zone DEFAULT now(),
    date_modified            timestamp without time zone,
    created_by_id           integer not null,
    modified_by_id          integer,
    CONSTRAINT project_process_step_custom_field_value_pk PRIMARY KEY (id),
    -- CONSTRAINT ppsf_project_process_step_id_fk FOREIGN KEY (project_process_step_id)
    --     REFERENCES flow.project_process_step (id) MATCH SIMPLE
    --     ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppscfv_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppscfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppscfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ppscfv_project_process_step_id_idx ON flow.project_process_step_custom_field_value (project_process_step_id);

CREATE INDEX if not exists ppscfv_custom_field_group_assignment_id_idx ON flow.project_process_step_custom_field_value (custom_field_group_assignment_id);

CREATE TABLE if not exists flow.project_process_step_note
(
    id                      serial  not null,
    project_process_step_id integer not null,
    note_id                 integer not null,
    CONSTRAINT project_process_step_note_pk PRIMARY KEY (id),
    CONSTRAINT ppsn_note_id FOREIGN KEY (note_id)
        REFERENCES flow.note (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
    -- CONSTRAINT ppsn_project_process_step_id FOREIGN KEY (project_process_step_id)
    --     REFERENCES flow.project_process_step (id) MATCH SIMPLE
    --     ON UPDATE NO ACTION ON DELETE NO ACTION,
);

CREATE INDEX if not exists ppsn_note_id_idx ON flow.project_process_step_note (note_id);

CREATE INDEX if not exists ppsn_project_process_step_id_idx ON flow.project_process_step_note (project_process_step_id);


CREATE TABLE if not exists flow.user_custom_field_value
(
    id              serial  not null,
    user_id         integer not null,
    date_value      date,
    custom_field_group_assignment_id integer not null,
    timestamp_value timestamp,
    boolean_value   boolean,
    text_value      text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    CONSTRAINT user_custom_field_value_pk PRIMARY KEY (id),
    CONSTRAINT ucfv_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ucfv_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ucfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ucfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ucfv_customer_id_idx ON flow.user_custom_field_value (user_id);

CREATE INDEX if not exists ucfv_custom_field_group_assignment_id_idx ON flow.user_custom_field_value (custom_field_group_assignment_id);


--------------------------------------------------------------------------------
-- make orgs easily searchable
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS flow.org_level (
                                              id SERIAL not null,
                                              company_id INTEGER,
                                              level INTEGER,
                                              CONSTRAINT org_level_pk PRIMARY KEY (id),
                                              CONSTRAINT ol_company_id FOREIGN KEY (company_id)
                                                  REFERENCES flow.company (id),
                                              UNIQUE (company_id, level)
);

CREATE INDEX if not exists ol_company_id_idx ON flow.org_level (company_id);

ALTER TABLE flow.org_type
    ADD CONSTRAINT ot_org_level FOREIGN KEY (org_level_id)
        REFERENCES flow.org_level (id);

CREATE INDEX if not exists ot_org_level_id_idx ON flow.org_type (org_level_id);

CREATE TABLE flow.org_filter (
                                 id serial not null,
                                 org_level_id INTEGER,
                                 title VARCHAR(64),
                                 rank INTEGER,
                                 show_type boolean not null default false,
                                 UNIQUE (org_level_id, rank),
                                 CONSTRAINT of_level FOREIGN KEY (org_level_id)
                                     REFERENCES flow.org_level (id)
);

CREATE INDEX if not exists of_org_level_id_idx ON flow.org_filter (org_level_id);

CREATE OR REPLACE FUNCTION flow.project_process_step_insert_function()
    RETURNS TRIGGER AS $$
DECLARE
    v_process_name TEXT;
BEGIN
    v_process_name := 'project_process_step_' || new.id;
    IF NOT EXISTS
        (SELECT 1
         FROM   information_schema.tables
         WHERE  table_name = v_process_name)
    THEN
        --RAISE NOTICE 'A partition has been created %', v_process_name;
        --raise notice 'table %',format(E'CREATE TABLE flow.%I PARTITION OF flow.project_process_step FOR VALUES IN (%s)', v_process_name,new.id);
        EXECUTE format(E'CREATE TABLE flow.%I PARTITION OF flow.project_process_step FOR VALUES IN (%s)', v_process_name,new.id);
        -- EXECUTE format('GRANT SELECT ON TABLE %I TO readonly', partition_name); -- use this if you use role based permission
    END IF;
    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER insert_project_process_step_trg
    after INSERT ON flow.process_step
    FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_insert_function();


CREATE TABLE if NOT EXISTS flow.requirement_param_dynamic_value
(
    id        serial                NOT NULL,
    db_function_param_id integer NOT NULL,
    process_step_requirement_id integer not null,
    dynamic_value character varying(50),
    archived boolean not null default false,
    created_by_id                         integer,
    date_created                         timestamp   without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp      without time zone,
    CONSTRAINT requirement_param_dynamic_value_pk PRIMARY KEY (id),
    CONSTRAINT rpdv_db_function_param_id_fk FOREIGN KEY (db_function_param_id)
        REFERENCES flow.db_function_param (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rpdv_process_step_requirement_id_fk FOREIGN KEY (process_step_requirement_id)
        REFERENCES flow.process_step_requirement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rpdv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rpdv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists rpdv_db_function_param_id_idx ON flow.requirement_param_dynamic_value (db_function_param_id);
CREATE INDEX if not exists rpdv_process_step_requirement_id_idx ON flow.requirement_param_dynamic_value (process_step_requirement_id);

CREATE TABLE if NOT EXISTS flow.process_step_action_link
(
    id        serial                NOT NULL,
    process_step_action_id integer NOT NULL,
    link_id integer not null,
    archived boolean not null default false,
    created_by_id                         integer,
    date_created                         timestamp   without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp      without time zone,
    CONSTRAINT process_step_action_link_pk PRIMARY KEY (id),
    CONSTRAINT psal_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
        REFERENCES flow.process_step_action (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psal_link_id_fk FOREIGN KEY (link_id)
        REFERENCES flow.process_step_requirement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psal_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psal_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psal_process_step_action_id_idx ON flow.process_step_action_link (process_step_action_id);

CREATE INDEX if not exists psal_link_id_idx ON flow.process_step_action_link (link_id);


/*
CREATE TABLE if not exists flow.custom_field_report
(
    id                serial,
    object_type_id   integer not null,
    company_id       integer not null,
    report_name      CHARACTER VARYING(100) not null,
    default_report   boolean not null default false,
    archived         boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT custom_field_report_pk PRIMARY KEY (id),
    CONSTRAINT cfr_object_type_id_fk FOREIGN KEY (object_type_id)
        REFERENCES flow.object_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfr_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.custom_field_report_assignment
(
    id                serial,
    custom_field_report_id   integer not null,
    custom_field_group_assignment_id   integer,
    field_order      integer not null,
    show_on_grid    boolean not null default false,
    archived        boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT custom_field_report_assignment_pk PRIMARY KEY (id),
    CONSTRAINT cfra_custom_field_report_id_fk FOREIGN KEY (custom_field_report_id)
        REFERENCES flow.custom_field_report (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfra_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfra_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfra_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.custom_field_report_requirement
(
    id                serial,
    custom_field_report_id integer not null,
    operator_type_id   integer not null,
    requirement_value  varchar,
    custom_field_group_assignment_id   integer not null,
    requirement_nbr  integer not null,
    archived         boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT custom_field_report_requirement_pk PRIMARY KEY (id),
    CONSTRAINT cfrr_operator_type_id_fk FOREIGN KEY (operator_type_id)
        REFERENCES flow.operator_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrr_custom_field_group_assignment_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrr_custom_field_report_id_fk FOREIGN KEY (custom_field_report_id)
        REFERENCES flow.custom_field_report (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.custom_field_report_logic
(
    id                serial,
    custom_field_report_requirement_id integer,
    sql_order          integer not null,
    operation_type_id   integer,
    archived          boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT custom_field_report_logic_pk PRIMARY KEY (id),
    CONSTRAINT cfrl_custom_field_report_requirement_id_fk FOREIGN KEY (custom_field_report_requirement_id)
        REFERENCES flow.custom_field_report_requirement (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrl_operation_type_id_fk FOREIGN KEY (operation_type_id)
        REFERENCES flow.operation_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrl_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cfrl_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

*/

CREATE INDEX trgm_customer_full_name_search_idx ON flow.customer USING gin ( (first_name || ' ' || last_name) gin_trgm_ops);


CREATE TABLE if not exists flow.organization_custom_field_value
(
    id              serial  not null,
    org_id      integer not null,
    custom_field_group_assignment_id integer not null,
    date_value      date,
    timestamp_value timestamp,
    boolean_value   boolean,
    text_value      text,
    numeric_value   numeric,
    int_value       integer,
    int_array_value integer[],
    date_created    timestamp without time zone DEFAULT now(),
    date_modified    timestamp without time zone,
    created_by_id   integer not null,
    modified_by_id  integer,
    CONSTRAINT organization_custom_field_value_pk primary key (id),
    CONSTRAINT ocfv_project_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ocfv_custom_field_group_id_fk FOREIGN KEY (custom_field_group_assignment_id)
        REFERENCES flow.custom_field_group_assignment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ocfv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ocfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ocfv_project_id_idx ON flow.organization_custom_field_value (org_id);

CREATE INDEX if not exists ocfv_custom_field_group_assignment_id_idx ON flow.organization_custom_field_value (custom_field_group_assignment_id);




CREATE TABLE if NOT EXISTS flow.data_type_requirement
(
    id        serial                NOT NULL,
    data_type_id integer NOT NULL,
    data_type_value character varying (75) not null,
    secondary_requirement boolean not null default false,
    archived boolean not null default false,
    created_by_id                         integer,
    date_created                         timestamp   without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp      without time zone,
    CONSTRAINT data_type_requirement_pk PRIMARY KEY (id),
    CONSTRAINT dtr_process_step_action_id_fk FOREIGN KEY (data_type_id)
        REFERENCES flow.data_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT dtr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT dtr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists dtr_company_data_type_id ON flow.data_type_requirement (data_type_id);
create index if not exists dtr_data_type_value_idx on flow.data_type_requirement (data_type_value);




CREATE TABLE if not exists flow.project_custom_field_value_audit
(
    id              serial  not null,
    project_custom_field_value_id integer not null,
    old_value        text,
    new_value        text,
    date_modified    timestamp without time zone,
    modified_by_id  integer,
    CONSTRAINT project_custom_field_value_audit_pk primary key (id),
    CONSTRAINT pcfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION flow.project_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.project_custom_field_value_audit(project_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER project_audit_trg
    after INSERT or update or delete ON flow.project_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_audit();



CREATE TABLE if not exists flow.user_custom_field_value_audit
(
    id              serial  not null,
    user_custom_field_value_id integer not null,
    old_value        text,
    new_value        text,
    date_modified    timestamp without time zone,
    modified_by_id  integer,
    CONSTRAINT user_custom_field_value_audit_pk primary key (id),
    CONSTRAINT ucfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION flow.user_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.user_custom_field_value_audit(user_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER user_audit_trg
    after INSERT or update or delete ON flow.user_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.user_audit();


CREATE TABLE if not exists flow.customer_custom_field_value_audit
(
    id              serial  not null,
    customer_custom_field_value_id integer not null,
    old_value        text,
    new_value        text,
    date_modified    timestamp without time zone,
    modified_by_id  integer,
    CONSTRAINT customer_custom_field_value_audit_pk primary key (id),
    CONSTRAINT ccfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION flow.customer_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.customer_custom_field_value_audit(customer_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.customer_custom_field_value_audit(customer_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.customer_custom_field_value_audit(customer_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER customer_audit_trg
    after INSERT or update or delete ON flow.customer_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.customer_audit();


CREATE TABLE if not exists flow.organization_custom_field_value_audit
(
    id              serial  not null,
    organization_custom_field_value_id integer not null,
    old_value        text,
    new_value        text,
    date_modified    timestamp without time zone,
    modified_by_id  integer,
    CONSTRAINT organization_custom_field_value_audit_pk primary key (id),
    CONSTRAINT ocfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION flow.organization_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.organization_custom_field_value_audit(organization_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER organization_audit_trg
    after INSERT or update or delete ON flow.organization_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.organization_audit();



CREATE TABLE if not exists flow.project_process_step_custom_field_value_audit
(
    id              serial  not null,
    project_process_step_custom_field_value_id integer not null,
    old_value        text,
    new_value        text,
    date_modified    timestamp without time zone,
    modified_by_id  integer,
    CONSTRAINT project_process_step_custom_field_value_audit_pk primary key (id),
    CONSTRAINT ppscfva_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE OR REPLACE FUNCTION flow.project_process_step_audit()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(new.id,null,case when new.date_value is not null then new.date_value::text
                                when new.timestamp_value is not null then new.timestamp_value::text
                                when new.boolean_value is not null then new.boolean_value::text
                                when new.text_value is not null then new.text_value
                                when new.numeric_value is not null then new.numeric_value::text
                                when new.int_value is not null then new.int_value::text
                                when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    elsif (TG_OP = 'UPDATE') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               case when new.date_value is not null then new.date_value::text
                    when new.timestamp_value is not null then new.timestamp_value::text
                    when new.boolean_value is not null then new.boolean_value::text
                    when new.text_value is not null then new.text_value
                    when new.numeric_value is not null then new.numeric_value::text
                    when new.int_value is not null then new.int_value::text
                    when new.int_array_value is not null then new.int_array_value::text end,
               now(),
               new.modified_by_id);
    ELSIF (TG_OP = 'DELETE') THEN
        insert into flow.project_process_step_custom_field_value_audit(project_process_step_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
        values(old.id,case when old.date_value is not null then old.date_value::text
                           when old.timestamp_value is not null then old.timestamp_value::text
                           when old.boolean_value is not null then old.boolean_value::text
                           when old.text_value is not null then old.text_value
                           when old.numeric_value is not null then old.numeric_value::text
                           when old.int_value is not null then old.int_value::text
                           when old.int_array_value is not null then old.int_array_value::text end,
               null,
               now(),
               new.modified_by_id);
    end if;

    RETURN NULL;
END
$$
    LANGUAGE plpgsql;


CREATE TRIGGER project_process_step_audit_trg
    after INSERT or update or delete ON flow.project_process_step_custom_field_value
    FOR EACH ROW EXECUTE PROCEDURE flow.project_process_step_audit();



