--------------------------------------------------------------------------------
-- start fresh: wipe out the old version of the schema
--------------------------------------------------------------------------------
drop schema if exists brs cascade;


--------------------------------------------------------------------------------
-- build the schema
--------------------------------------------------------------------------------
create schema brs;

CREATE TABLE if not exists  brs.sales_area_type
(
    id              serial                not null,
    sales_area_type character varying(20) not null,
    archived        boolean default false not null,
    CONSTRAINT sales_area_type_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.sales_area
(
    id                 serial                                    not null,
    area               character varying(20)                     not null,
    sales_area_type_id integer                                   not null,
    state_id           integer,
    archived           boolean                     default false not null,
    date_created       timestamp without time zone default now(),
    created_by_id      integer,
    date_modified      timestamp without time zone default now(),
    modified_by_id     integer,
    CONSTRAINT sales_area_pk PRIMARY KEY (id),
    CONSTRAINT sa_sales_area_type_id_fk FOREIGN KEY (sales_area_type_id)
        REFERENCES brs.sales_area_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT sa_state_id_fk FOREIGN KEY (state_id)
        REFERENCES flow.state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT sa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT sa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE INDEX if not exists sa_state_id_idx
    ON brs.sales_area
        USING btree
        (state_id);



CREATE INDEX if not exists sa_sales_area_type_id_idx
    ON brs.sales_area
        USING btree
        (sales_area_type_id);



CREATE TABLE if not exists  brs.sales_metro_area
(
    id                   serial                                    not null,
    sales_metro_area     character varying(100)                    not null,
    sales_area_id        integer                                   not null,
    archived             boolean                     default false not null,
    date_created         timestamp without time zone default now(),
    created_by_id        integer,
    date_modified        timestamp without time zone default now(),
    modified_by_id       integer,
    final_design_minimum integer,
    fixed_grace_days     integer,
    area_average_fds     numeric(10, 2),
    CONSTRAINT sales_metro_area_pk PRIMARY KEY (id),
    CONSTRAINT sma_sales_area_id_fk FOREIGN KEY (sales_area_id)
        REFERENCES brs.sales_area (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT sma_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT sma_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.podium_location
(
    id             serial                                    not null,
    podium_id      integer                                   not null,
    name           text                                      not null,
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT podium_location_pk PRIMARY KEY (id),
    CONSTRAINT pl_name_uk UNIQUE (name),
    CONSTRAINT pl_podium_id_uk UNIQUE (podium_id),
    CONSTRAINT pl_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pl_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.birdeye_location
(
    business_id character varying(64) not null,
    alias       character varying(64),
    archived    boolean default false not null,
    CONSTRAINT birdeye_location_pk PRIMARY KEY (business_id)
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.budget_type
(
    id             serial                                    not null,
    name           text                                      not null,
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT budget_type_pk PRIMARY KEY (id),
    CONSTRAINT bt_name_uk UNIQUE (name),
    CONSTRAINT budget_type_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT budget_type_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.budget_template
(
    id             serial                                    not null,
    user_id        integer,
    budget_type_id integer,
    amount         numeric(12, 2),
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT budget_template_pk PRIMARY KEY (id),
    CONSTRAINT bt_budget_type_id_fk FOREIGN KEY (budget_type_id)
        REFERENCES brs.budget_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT bt_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT bt_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT bt_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.expense_budget
(
    id                         serial                                    not null,
    user_id                    integer,
    budget_type_id             integer,
    amount                     numeric(12, 2),
    archived                   boolean                     default false not null,
    date_created               timestamp without time zone default now(),
    created_by_id              integer,
    date_modified              timestamp without time zone default now(),
    modified_by_id             integer,
    start_date                 date                                      not null,
    end_date                   date                                      not null,
    original_expense_budget_id integer,
    notes                      text,
    CONSTRAINT expense_budget_pk PRIMARY KEY (id),
    CONSTRAINT eb_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT eb_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.reimbursement_request_status
(
    id                           serial                not null,
    reimbursement_request_status character varying(30) not null,
    archived                     boolean default false not null,
    CONSTRAINT reimbursement_request_status_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.reimbursement_request
(
    id                              serial                                    not null,
    details                         text,
    notes                           text,
    amount                          numeric(12, 2)                            not null,
    expense_budget_id               integer,
    attachment_id                   integer,
    expense_date                    timestamp without time zone               not null,
    archived                        boolean                     default false not null,
    date_created                    timestamp without time zone default now(),
    created_by_id                   integer                                   not null,
    date_modified                   timestamp without time zone default now(),
    modified_by_id                  integer,
    reimbursement_request_status_id integer,
    CONSTRAINT reimbursement_request_pk PRIMARY KEY (id),
    CONSTRAINT rr_attachment_id_fk FOREIGN KEY (attachment_id)
        REFERENCES flow.attachment (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rr_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rr_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rr_expense_budget_id_fk FOREIGN KEY (expense_budget_id)
        REFERENCES brs.expense_budget (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT rr_reimbursement_request_status_id_fk FOREIGN KEY (reimbursement_request_status_id)
        REFERENCES brs.reimbursement_request_status (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.gl_code
(
    id             serial                                    not null,
    code           text                                      not null,
    description    text                                      not null,
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT gl_code_pk PRIMARY KEY (id),
    CONSTRAINT gl_code_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT gl_code_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.expense
(
    id                       serial                                    not null,
    user_id                  integer,
    expense_budget_id        integer,
    gl_code_id               integer,
    notes                    text,
    expense_date             date                                      not null,
    expense_amount           numeric(12, 2)                            not null,
    archived                 boolean                     default false not null,
    date_created             timestamp without time zone default now(),
    created_by_id            integer,
    date_modified            timestamp without time zone default now(),
    modified_by_id           integer,
    date_submitted           timestamp without time zone default now(),
    submitted_by_id          integer,
    reimbursement_request_id integer,
    approval_date            timestamp without time zone,
    approved_by_id           integer,
    paid_date                timestamp without time zone,
    paid_by_id               integer,
    skip_approval            boolean                     default false,
    rejected_date            date,
    rejected_by_id           integer,
    CONSTRAINT expense_pk PRIMARY KEY (id),
    CONSTRAINT e_approved_by_id_fk FOREIGN KEY (approved_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_expense_budget_id_fk FOREIGN KEY (expense_budget_id)
        REFERENCES brs.expense_budget (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_gl_code_id_fk FOREIGN KEY (gl_code_id)
        REFERENCES brs.gl_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_paid_by_id_fk FOREIGN KEY (paid_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_reimbursement_request_id_fk FOREIGN KEY (reimbursement_request_id)
        REFERENCES brs.reimbursement_request (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_submitted_by_id_fk FOREIGN KEY (submitted_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT e_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.expense_gl_code
(
    id             serial,
    expense_id     integer,
    gl_code_id     integer,
    amount         numeric(12, 2)                            not null,
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT expense_gl_code_pk PRIMARY KEY (id),
    CONSTRAINT egc_expense_id_fk FOREIGN KEY (expense_id)
        REFERENCES brs.expense (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT egc_gl_code_id_fk FOREIGN KEY (gl_code_id)
        REFERENCES brs.gl_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT egc_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT egc_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.metro_area
(
    id             serial                                    not null,
    metro_area     character varying(100)                    not null,
    sales_area_id  integer                                   not null,
    archived       boolean                     default false not null,
    date_created   timestamp without time zone default now(),
    created_by_id  integer,
    date_modified  timestamp without time zone default now(),
    modified_by_id integer,
    CONSTRAINT metro_area_pk PRIMARY KEY (id),
    CONSTRAINT ma_sales_area_id_fk FOREIGN KEY (sales_area_id)
        REFERENCES brs.sales_area (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT metro_area_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT metro_area_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.org_metro_area
(
    id            serial  NOT NULL,
    org_id        integer NOT NULL,
    metro_area_id integer NOT NULL,
    CONSTRAINT org_metro_area_pk PRIMARY KEY (id),
    CONSTRAINT oma_metro_area_id_fk FOREIGN KEY (metro_area_id)
        REFERENCES brs.metro_area (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT oma_org_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE TABLE if not exists  brs.ahj
(
    id             serial                 NOT NULL,
    name           character varying(100) NOT NULL,
    archived       boolean                NOT NULL DEFAULT false,
    date_created   timestamp without time zone,
    created_by_id  integer,
    date_modified  timestamp without time zone,
    modified_by_id integer,
    metro_area_id  integer,
    CONSTRAINT ahj_pk PRIMARY KEY (id),
    CONSTRAINT ahj_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ahj_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ahj_metro_area_id_fk FOREIGN KEY (metro_area_id)
        REFERENCES brs.metro_area (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


CREATE INDEX ahj_name_idx
    ON brs.ahj
        USING btree
        (name COLLATE pg_catalog."default");


CREATE UNIQUE INDEX ahj_com1_idx
    ON brs.ahj
        USING btree
        (name COLLATE pg_catalog."default", metro_area_id)
    WHERE archived IS FALSE;


CREATE TABLE if not exists  brs.custom_dropdown_screen
(
    id       serial NOT NULL,
    screen   character varying(100),
    code     character varying(100),
    archived boolean DEFAULT false,
    CONSTRAINT custom_dropdown_screen_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );



CREATE TABLE if not exists  brs.custom_dropdown_field
(
    id                        serial                not null,
    field                     character varying(100),
    code                      character varying(100),
    custom_dropdown_screen_id integer,
    archived                  boolean default false not null,
    date_modified             timestamp without time zone,
    modified_by_id            integer,
    CONSTRAINT custom_dropdown_field_pk PRIMARY KEY (id),
    CONSTRAINT cdf_custom_dropdown_screen_id_fk FOREIGN KEY (custom_dropdown_screen_id)
        REFERENCES brs.custom_dropdown_screen (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cdf_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.custom_dropdown_value
(
    id                       serial                not null,
    title                    varchar(100),
    custom_dropdown_field_id integer,
    archived                 boolean default false not null,
    date_created             timestamp,
    created_by_id            integer,
    date_modified            timestamp,
    modified_by_id           integer,
    display_order            integer,
    constraint custom_dropdown_value_pkey
        primary key (id),
    constraint custom_dropdown_value_custom_dropdown_field_id_fkey
        foreign key (custom_dropdown_field_id) references brs.custom_dropdown_field (id),
    constraint custom_dropdown_value_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint custom_dropdown_value_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);


CREATE TABLE if not exists  brs.ahj_simple_list_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_simple_list_type_pk PRIMARY KEY (id),
    CONSTRAINT ahj_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_pto_followup_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_pto_followup_type_pk PRIMARY KEY (id),
    CONSTRAINT apft_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_utility_inspection_submission_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_utility_inspection_submission_type_pk PRIMARY KEY (id),
    CONSTRAINT auist_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_signature_requested_at_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_signature_requested_at_type_pk PRIMARY KEY (id),
    CONSTRAINT asrat_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_utility_submission_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_utility_submission_type_pk PRIMARY KEY (id),
    CONSTRAINT aust_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_utility_method_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_utility_method_type_pk PRIMARY KEY (id),
    CONSTRAINT aumt_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_when_to_create_application_type
(
    id       serial                 not null,
    name     character varying(100) not null,
    archived boolean default false  not null,
    CONSTRAINT ahj_when_to_create_application_type_pk PRIMARY KEY (id),
    CONSTRAINT awtcat_name_uk UNIQUE (name)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists  brs.ahj_utility
(
    id                                         serial  NOT NULL,
    name                                       text,
    archived                                   boolean default false not null,
    date_created                               timestamp without time zone DEFAULT now(),
    created_by_id                              integer,
    date_modified                              timestamp without time zone DEFAULT now(),
    modified_by_id                             integer,
    timelines_and_stages                       text,
    regulated_by                               text,
    monthly_facility_charge                    text,
    population_of_service                      text,
    net_metering_rate                          text,
    rebate_rates                               text,
    utility_rate_notes                         text,
    customer_signature_instructions            text,
    expected_approval_timeline                 text,
    rejection_instructions                     text,
    notes                                      text,
    submission_instructions                    text,
    final_completion_instructions              text,
    overview_of_submission_process             text,
    timelines                                  text,
    pto_followup_instructions                  text,
    rebate_program_type_id                     integer,
    rebate_program_type_other                  character varying(255),
    signature_required_prior_type_id           integer,
    signature_required_prior_type_other        character varying(255),
    signature_requested_at_type_id             integer,
    signature_requested_at_type_other          character varying(255),
    customer_signature_resubmission_type_id    integer,
    customer_signature_resubmission_type_other character varying(255),
    when_to_create_application_type_id         integer,
    when_to_create_application_type_other      character varying(255),
    submission_method_type_id                  integer,
    submission_method_type_other               character varying(255),
    interconnection_fee_type_id                integer,
    interconnection_fee_type_other             character varying(255),
    utility_method_type_id                     integer,
    utility_method_type_other                  character varying(255),
    inspection_submission_type_id              integer,
    inspection_submission_type_other           character varying(255),
    utility_inspection_required_type_id        integer,
    utility_inspection_required_type_other     character varying(255),
    followup_method_type_id                    integer,
    followup_method_type_other                 character varying(255),
    metro_area_id                              integer,
    ac_disconnect_required                     integer,
    meter_can_taps_allowed                     integer,
    pv_production_meter_required               integer,
    pv_ac_swap_locations                       integer,
    utility_warning_labels_override            integer,
    CONSTRAINT ahj_utility_pk PRIMARY KEY (id),
    CONSTRAINT ahj_utility_created_by_id_fkey FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ahj_utility_modified_by_id_fkey FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_ac_disconnect_required_fk FOREIGN KEY (ac_disconnect_required)
        REFERENCES brs.custom_dropdown_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_customer_signature_resubmission_type_id_fk FOREIGN KEY (customer_signature_resubmission_type_id)
        REFERENCES brs.ahj_simple_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_followup_method_type_id_fk FOREIGN KEY (followup_method_type_id)
        REFERENCES brs.ahj_pto_followup_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_inspection_submission_type_id_fk FOREIGN KEY (inspection_submission_type_id)
        REFERENCES brs.ahj_utility_inspection_submission_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_interconnection_fee_type_id_fk FOREIGN KEY (interconnection_fee_type_id)
        REFERENCES brs.ahj_simple_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_meter_can_taps_allowed_fk FOREIGN KEY (meter_can_taps_allowed)
        REFERENCES brs.custom_dropdown_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_metro_area_id_fk FOREIGN KEY (metro_area_id)
        REFERENCES brs.metro_area (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_pv_ac_swap_locations_fk FOREIGN KEY (pv_ac_swap_locations)
        REFERENCES brs.custom_dropdown_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_pv_production_meter_required_fk FOREIGN KEY (pv_production_meter_required)
        REFERENCES brs.custom_dropdown_field (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_rebate_program_type_id_fk FOREIGN KEY (rebate_program_type_id)
        REFERENCES brs.ahj_simple_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_signature_requested_at_type_id_fk FOREIGN KEY (signature_requested_at_type_id)
        REFERENCES brs.ahj_signature_requested_at_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_signature_required_prior_type_id_fk FOREIGN KEY (signature_required_prior_type_id)
        REFERENCES brs.ahj_simple_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_submission_method_type_id_fk FOREIGN KEY (submission_method_type_id)
        REFERENCES brs.ahj_utility_submission_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_utility_inspection_required_type_id_fk FOREIGN KEY (utility_inspection_required_type_id)
        REFERENCES brs.ahj_simple_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_utility_method_type_id_fk FOREIGN KEY (utility_method_type_id)
        REFERENCES brs.ahj_utility_method_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT au_when_to_create_application_type_id_fk FOREIGN KEY (when_to_create_application_type_id)
        REFERENCES brs.ahj_when_to_create_application_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ahj_utility_utility_warning_labels_override_fkey FOREIGN KEY (utility_warning_labels_override)
        REFERENCES brs.custom_dropdown_value (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );



--------------------------------------------------------------------------------
-- create AHJ tables
--------------------------------------------------------------------------------
CREATE TABLE if not exists  brs.ahj_checklist_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_checklist_type_pkey
        primary key (id),
    constraint ahj_checklist_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_checklist
(
    id                            serial                not null,
    description                   text                  not null,
    display_order                 integer default 0     not null,
    archived                      boolean default false not null,
    date_created                  timestamp,
    created_by_id                 integer,
    date_modified                 timestamp,
    modified_by_id                integer,
    checklist_type_id             integer,
    failed_inspection_resource_id integer,
    failed_inspection_date        timestamp,
    failed_inspection_project     varchar(100),
    constraint ahj_checklist_pkey
        primary key (id),
    constraint ahj_checklist_checklist_type_id_fkey
        foreign key (checklist_type_id) references brs.ahj_checklist_type,
    constraint ahj_checklist_created_by_id_fkey
        foreign key (created_by_id) references flow."user"
        on update no action on delete no action,
    constraint ahj_checklist_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
        on update no action on delete no action
);

CREATE TABLE if not exists  brs.ahj_contact_type
(
    id       serial                not null,
    type     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_contact_type_pkey
        primary key (id)
);

CREATE TABLE if not exists  brs.ahj_contact
(
    id              serial                not null,
    name            varchar(255),
    title           varchar(255),
    email           varchar(255),
    phone_number    varchar(255),
    address         text,
    notes           text,
    hours           varchar(255),
    archived        boolean default false not null,
    date_created    timestamp,
    created_by_id   integer,
    date_modified   timestamp,
    modified_by_id  integer,
    contact_type_id integer,
    constraint ahj_contact_pkey
        primary key (id),
    constraint ahj_contact_contact_type_id_fkey
        foreign key (contact_type_id) references brs.ahj_contact_type,
    constraint ahj_contact_created_by_id_fkey
        foreign key (created_by_id) references flow."user"
        on update no action on delete no action,
    constraint ahj_contact_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
        on update no action on delete no action
);

CREATE TABLE if not exists  brs.ahj_link_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_link_type_pkey
        primary key (id),
    constraint ahj_link_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_handy_information_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_handy_information_type_pkey
        primary key (id),
    constraint ahj_handy_information_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_inspection_capacity_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_inspection_capacity_type_pkey
        primary key (id),
    constraint ahj_inspection_capacity_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_placard_required_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_placard_required_type_pkey
        primary key (id),
    constraint ahj_placard_required_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_plans_required_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_plans_required_type_pkey
        primary key (id),
    constraint ahj_plans_required_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_reinspection_fee_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_reinspection_fee_type_pkey
        primary key (id),
    constraint ahj_reinspection_fee_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_representative_required_onsite_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_representative_required_onsite_type_pkey
        primary key (id),
    constraint ahj_representative_required_onsite_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_results_documentation_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_results_documentation_type_pkey
        primary key (id),
    constraint ahj_results_documentation_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_rough_inspection_required_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_rough_inspection_required_type_pkey
        primary key (id),
    constraint ahj_rough_inspection_required_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_scheduling_lead_time_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_scheduling_lead_time_type_pkey
        primary key (id),
    constraint ahj_scheduling_lead_time_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_scheduling_method_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_scheduling_method_type_pkey
        primary key (id),
    constraint ahj_scheduling_method_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_site_access_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_site_access_type_pkey
        primary key (id),
    constraint ahj_site_access_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_soladeck_access_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_soladeck_access_type_pkey
        primary key (id),
    constraint ahj_soladeck_access_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_special_documents_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_special_documents_type_pkey
        primary key (id),
    constraint ahj_special_documents_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_special_equipment_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_special_equipment_type_pkey
        primary key (id),
    constraint ahj_special_equipment_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_inspection
(
    id                                        serial                    not null,
    ahj_id                                    integer                   not null,
    inspection_fee                            varchar(100),
    re_inspection_fee                         numeric(10, 2),
    payment_method                            varchar(255),
    scheduling_method_type_other              varchar(255),
    inspection_time_window                    varchar(100),
    homeowner_required_on_site                varchar(10) default false,
    brs_inspection_rep                        varchar(255),
    portal_url                                varchar(255),
    portal_username                           varchar(100),
    portal_password                           varchar(100),
    obtaining_results_method                  varchar(255),
    approval_document_method                  varchar(255),
    obtaining_results_portal_url              varchar(255),
    obtaining_results_portal_username         varchar(100),
    obtaining_results_portal_password         varchar(100),
    business_license                          varchar(100),
    contractor_license                        varchar(100),
    archived                                  boolean default false     not null,
    date_created                              timestamp,
    created_by_id                             integer,
    date_modified                             timestamp,
    modified_by_id                            integer,
    call_for_time_window                      varchar(10),
    ladder_required                           varchar(10),
    time_window                               varchar(255),
    time_window_call_time                     varchar(255),
    time_window_phone                         varchar(255),
    scheduling_note                           text,
    technician_instruction_note               text,
    scheduling_with_customer_note             text,
    obtaining_results_note                    text,
    reinspection_note                         text,
    documentation_note                        text,
    scheduling_method_type_id                 integer,
    handy_information_type_id                 integer,
    handy_information_type_other              varchar(255),
    scheduling_lead_time_type_id              integer,
    scheduling_lead_time_type_other           varchar(255),
    inspection_capacity_type_id               integer,
    inspection_capacity_type_other            varchar(255),
    site_access_type_id                       integer,
    site_access_type_other                    varchar(255),
    rough_inspection_required_type_id         integer,
    rough_inspection_required_type_other      varchar(255),
    soladeck_access_type_id                   integer,
    soladeck_access_type_other                varchar(255),
    placard_required_type_id                  integer,
    placard_required_type_other               varchar(255),
    required_inspection_types                 varchar(255),
    representative_required_onsite_type_id    integer,
    representative_required_onsite_type_other varchar(255),
    special_equipment_type_id                 integer,
    special_equipment_type_other              varchar(255),
    plans_required_type_id                    integer,
    plans_required_type_other                 varchar(255),
    special_documents_type_id                 integer,
    special_documents_type_other              varchar(255),
    fall_protection_required                  varchar(10),
    results_documentation_type_id             integer,
    results_documentation_type_other          varchar(255),
    reinspection_fee_type_id                  integer,
    reinspection_fee_type_other               varchar(255),
    midpoint_inspection_lead_time_type_id     integer,
    midpoint_inspection_lead_time_type_other  varchar(255),
    homeowner_required                        integer,
    brs_tech_required                         integer,
    mpu_inspection_note                       text,
    constraint ahj_inspection_pkey
        primary key (id),
    constraint ahj_inspection_ahj_id_key
        unique (ahj_id),
    constraint ahj_inspection_ahj_id_fkey
        foreign key (ahj_id) references brs.ahj,
    constraint ahj_inspection_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_inspection_handy_information_type_id_fkey
        foreign key (handy_information_type_id) references brs.ahj_handy_information_type,
    constraint ahj_inspection_inspection_capacity_type_id_fkey
        foreign key (inspection_capacity_type_id) references brs.ahj_inspection_capacity_type,
    constraint ahj_inspection_placard_required_type_id_fkey
        foreign key (placard_required_type_id) references brs.ahj_placard_required_type,
    constraint ahj_inspection_plans_required_type_id_fkey
        foreign key (plans_required_type_id) references brs.ahj_plans_required_type,
    constraint ahj_inspection_reinspection_fee_type_id_fkey
        foreign key (reinspection_fee_type_id) references brs.ahj_reinspection_fee_type,
    constraint ahj_inspection_representative_required_onsite_type_id_fkey
        foreign key (representative_required_onsite_type_id) references brs.ahj_representative_required_onsite_type,
    constraint ahj_inspection_results_documentation_type_id_fkey
        foreign key (results_documentation_type_id) references brs.ahj_results_documentation_type,
    constraint ahj_inspection_rough_inspection_required_type_id_fkey
        foreign key (rough_inspection_required_type_id) references brs.ahj_rough_inspection_required_type,
    constraint ahj_inspection_scheduling_lead_time_type_id_fkey
        foreign key (scheduling_lead_time_type_id) references brs.ahj_scheduling_lead_time_type,
    constraint ahj_inspection_scheduling_method_type_id_fkey
        foreign key (scheduling_method_type_id) references brs.ahj_scheduling_method_type,
    constraint ahj_inspection_site_access_type_id_fkey
        foreign key (site_access_type_id) references brs.ahj_site_access_type,
    constraint ahj_inspection_soladeck_access_type_id_fkey
        foreign key (soladeck_access_type_id) references brs.ahj_soladeck_access_type,
    constraint ahj_inspection_special_documents_type_id_fkey
        foreign key (special_documents_type_id) references brs.ahj_special_documents_type,
    constraint ahj_inspection_special_equipment_type_id_fkey
        foreign key (special_equipment_type_id) references brs.ahj_special_equipment_type,
    constraint ahj_inspection_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user",
    constraint ahj_inspection_homeowner_required_fkey
        foreign key (homeowner_required) references brs.custom_dropdown_value,
    constraint ahj_inspection_brs_tech_required_fkey
        foreign key (brs_tech_required) references brs.custom_dropdown_value
);

CREATE TABLE if not exists  brs.ahj_inspection_link
(
    id                serial                not null,
    ahj_inspection_id integer               not null,
    name              varchar(100)          not null,
    link              varchar(255)          not null,
    username          varchar(255),
    password          varchar(255),
    notes             text,
    archived          boolean default false not null,
    date_created      timestamp,
    created_by_id     integer,
    date_modified     timestamp,
    modified_by_id    integer,
    link_type_id      integer,
    constraint ahj_inspection_link_pkey
        primary key (id),
    constraint ahj_inspection_link_ahj_inspection_id_fkey
        foreign key (ahj_inspection_id) references brs.ahj_inspection,
    constraint ahj_inspection_link_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_inspection_link_link_type_id_fkey
        foreign key (link_type_id) references brs.ahj_link_type,
    constraint ahj_inspection_link_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_submit_type
(
    id       serial                not null,
    name     varchar(100)          not null,
    archived boolean default false not null,
    constraint ahj_submit_type_pkey
        primary key (id),
    constraint ahj_submit_type_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_permit
(
    id                                 serial                not null,
    ahj_id                             integer               not null,
    deposit_amount                     varchar(100),
    average_permit_fee                 numeric(10, 2),
    engineering_letter_required        varchar(255),
    print_location                     varchar(255),
    stamped_plan                       varchar(100),
    submission_payment_type_other      varchar(500),
    archived                           boolean default false not null,
    date_created                       timestamp,
    created_by_id                      integer,
    date_modified                      timestamp,
    modified_by_id                     integer,
    submittal_type_other               varchar(255),
    delivery_pickup_type_other         varchar(100),
    business_license_expiration_date   date,
    contractor_license_expiration_date date,
    business_license                   varchar(255),
    contractor_license                 varchar(255),
    submission_note                    text,
    revision_note                      text,
    as_built_note                      text,
    delivery_note                      text,
    submittal_type_id                  integer,
    revision_submittal_type_id         integer,
    revision_submittal_type_other      varchar(255),
    as_built_submittal_type_id         integer,
    as_built_submittal_type_other      varchar(255),
    delivery_pickup_type_id            integer,
    submission_payment_type_id         integer,
    revision_payment_type_id           integer,
    revision_payment_type_other        varchar(255),
    as_built_payment_type_id           integer,
    as_built_payment_type_other        varchar(255),
    follow_up_payment_type_id          integer,
    follow_up_payment_type_other       varchar(255),
    delivery_payment_type_id           integer,
    delivery_payment_type_other        varchar(255),
    revision_fee_amount                varchar(100),
    as_built_fee_amount                varchar(100),
    follow_up_fee_amount               varchar(100),
    delivery_fee_amount                varchar(100),
    approval_timeline                  varchar(255),
    documents_available                varchar(255),
    hoa_approval_required_type_id      integer,
    hoa_approval_required_type_other   varchar(255),
    nem_approval_required_type_id      integer,
    nem_approval_required_type_other   varchar(255),
    other_license                      varchar(255),
    other_license_expiration_date      date,
    constraint ahj_permit_pkey
        primary key (id),
    constraint ahj_permit_ahj_id_key
        unique (ahj_id),
    constraint ahj_permit_ahj_id_fkey
        foreign key (ahj_id) references brs.ahj,
    constraint ahj_permit_as_built_payment_type_id_fkey
        foreign key (as_built_payment_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_as_built_submittal_type_id_fkey
        foreign key (as_built_submittal_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_permit_delivery_payment_type_id_fkey
        foreign key (delivery_payment_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_delivery_pickup_type_id_fkey
        foreign key (delivery_pickup_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_follow_up_payment_type_id_fkey
        foreign key (follow_up_payment_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_hoa_approval_required_type_id_fkey
        foreign key (hoa_approval_required_type_id) references brs.ahj_simple_list_type,
    constraint ahj_permit_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user",
    constraint ahj_permit_nem_approval_required_type_id_fkey
        foreign key (nem_approval_required_type_id) references brs.ahj_simple_list_type,
    constraint ahj_permit_revision_payment_type_id_fkey
        foreign key (revision_payment_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_revision_submittal_type_id_fkey
        foreign key (revision_submittal_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_submission_payment_type_id_fkey
        foreign key (submission_payment_type_id) references brs.ahj_submit_type,
    constraint ahj_permit_submittal_type_id_fkey
        foreign key (submittal_type_id) references brs.ahj_submit_type
);

CREATE TABLE if not exists  brs.ahj_permit_link
(
    id             serial                not null,
    ahj_permit_id  integer               not null,
    name           varchar(255)          not null,
    link           varchar(255)          not null,
    username       varchar(255),
    password       varchar(255),
    notes          text,
    archived       boolean default false not null,
    date_created   timestamp,
    created_by_id  integer,
    date_modified  timestamp,
    modified_by_id integer,
    link_type_id   integer,
    constraint ahj_permit_link_pkey
        primary key (id),
    constraint ahj_permit_link_ahj_permit_id_fkey
        foreign key (ahj_permit_id) references brs.ahj_permit,
    constraint ahj_permit_link_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_permit_link_link_type_id_fkey
        foreign key (link_type_id) references brs.ahj_link_type,
    constraint ahj_permit_link_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_utility_link
(
    id             serial                not null,
    ahj_utility_id integer               not null,
    name           varchar(100)          not null,
    link           varchar(255)          not null,
    username       varchar(255),
    password       varchar(255),
    notes          text,
    link_type_id   integer,
    archived       boolean default false not null,
    date_created   timestamp,
    created_by_id  integer,
    date_modified  timestamp,
    modified_by_id integer,
    constraint ahj_utility_link_pkey
        primary key (id),
    constraint ahj_utility_link_ahj_utility_id_fkey
        foreign key (ahj_utility_id) references brs.ahj_utility,
    constraint ahj_utility_link_link_type_id_fkey
        foreign key (link_type_id) references brs.ahj_link_type,
    constraint ahj_utility_link_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_utility_link_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_note_type
(
    id   serial                    not null,
    type varchar(100)              not null,
    archived boolean default false not null,
    constraint ahj_note_type_pkey
        primary key (id)
);

CREATE TABLE if not exists  brs.ahj_note
(
    id             serial                not null,
    note           text                  not null,
    archived       boolean default false not null,
    date_created   timestamp,
    created_by_id  integer,
    date_modified  timestamp,
    modified_by_id integer,
    note_type_id   integer,
    constraint ahj_note_pkey
        primary key (id),
    constraint ahj_note_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_note_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user",
    constraint ahj_note_note_type_id_fkey
        foreign key (note_type_id) references brs.ahj_note_type
);

CREATE TABLE if not exists  brs.ahj_utility_contact
(
    ahj_utility_id integer              not null,
    ahj_contact_id integer              not null,
    constraint ahj_utility_contact_ahj_utility_id_fkey
        foreign key (ahj_utility_id) references brs.ahj_utility,
    constraint ahj_utility_contact_ahj_contact_id_fkey
        foreign key (ahj_contact_id) references brs.ahj_contact,
    constraint ahj_utility_contact_ahj_utility_id_ahj_contact_id_key
        unique (ahj_utility_id, ahj_contact_id)
);

CREATE TABLE if not exists  brs.ahj_utility_checklist
(
    ahj_utility_id   integer            not null,
    ahj_checklist_id integer            not null,
    constraint ahj_utility_checklist_ahj_utility_id_fkey
        foreign key (ahj_utility_id) references brs.ahj_utility,
    constraint ahj_utility_checklist_ahj_checklist_id_fkey
        foreign key (ahj_checklist_id) references brs.ahj_checklist,
    constraint ahj_utility_checklist_ahj_utility_id_ahj_checklist_id_key
        unique (ahj_utility_id, ahj_checklist_id)
);

CREATE TABLE if not exists  brs.ahj_requirement_type
(
    id             serial                not null,
    name           text,
    archived       boolean default false not null,
    date_created   timestamp default now(),
    created_by_id  integer,
    date_modified  timestamp,
    modified_by_id integer,
    constraint ahj_requirement_type_pkey
        primary key (id),
    constraint ahj_requirement_type_name_key
        unique (name),
    constraint ahj_requirement_type_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_requirement_type_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_requirement
(
    id                  serial                not null,
    requirement_type_id integer,
    description         text                  not null,
    archived            boolean default false not null,
    date_created        timestamp default now(),
    created_by_id       integer,
    date_modified       timestamp default now(),
    modified_by_id      integer,
    constraint ahj_requirement_pkey
        primary key (id),
    constraint ahj_requirement_requirement_type_id_fkey
        foreign key (requirement_type_id) references brs.ahj_requirement_type,
    constraint ahj_requirement_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_requirement_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_requirement_status
(
    id                           serial not null,
    name          text,
    display_order integer,
    archived      boolean default false not null,
    constraint ahj_requirement_status_pkey
        primary key (id),
    constraint ahj_requirement_status_name_key
        unique (name)
);

CREATE TABLE if not exists  brs.ahj_utility_requirements
(
    utility_id              integer,
    requirement_id          integer,
    position                integer   default 0,
    original_requirement_id integer,
    status_id               integer   default 1,
    complete                boolean   default false not null,
    archived                boolean   default false not null,
    date_created            timestamp default now(),
    created_by_id           integer,
    date_modified           timestamp default now(),
    modified_by_id          integer,
    constraint ahj_utility_requirements_utility_id_fkey
        foreign key (utility_id) references brs.ahj_utility,
    constraint ahj_utility_requirements_requirement_id_fkey
        foreign key (requirement_id) references brs.ahj_requirement,
    constraint ahj_utility_requirements_original_requirement_id_fkey
        foreign key (original_requirement_id) references brs.ahj_requirement,
    constraint ahj_utility_requirements_status_id_fkey
        foreign key (status_id) references brs.ahj_requirement_status,
    constraint ahj_utility_requirements_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_utility_requirements_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user"
);

CREATE TABLE if not exists  brs.ahj_permit_contact
(
    ahj_permit_id  integer              not null,
    ahj_contact_id integer              not null,
    constraint ahj_permit_contact_ahj_permit_id_fkey
        foreign key (ahj_permit_id) references brs.ahj_permit,
    constraint ahj_permit_contact_ahj_contact_id_fkey
        foreign key (ahj_contact_id) references brs.ahj_contact,
    constraint ahj_permit_contact_ahj_permit_id_ahj_contact_id_key
        unique (ahj_permit_id, ahj_contact_id)
);

CREATE TABLE if not exists  brs.ahj_permit_note
(
    ahj_permit_id integer               not null,
    ahj_note_id   integer               not null,
    constraint ahj_permit_note_ahj_permit_id_fkey
        foreign key (ahj_permit_id) references brs.ahj_permit,
    constraint ahj_permit_note_ahj_note_id_fkey
        foreign key (ahj_note_id) references brs.ahj_note,
    constraint ahj_permit_note_ahj_permit_id_ahj_note_id_key
        unique (ahj_permit_id, ahj_note_id)
);

CREATE TABLE if not exists  brs.ahj_permit_checklist
(
    ahj_permit_id    integer            not null,
    ahj_checklist_id integer            not null,
    constraint ahj_permit_checklist_ahj_permit_id_fkey
        foreign key (ahj_permit_id) references brs.ahj_permit,
    constraint ahj_permit_checklist_ahj_checklist_id_fkey
        foreign key (ahj_checklist_id) references brs.ahj_checklist,
    constraint ahj_permit_checklist_ahj_permit_id_ahj_checklist_id_key
        unique (ahj_permit_id, ahj_checklist_id)
);

CREATE TABLE if not exists  brs.ahj_design
(
    id                                         serial                not null,
    ahj_id                                     integer               not null,
    codes                                      text,
    archived                                   boolean default false not null,
    date_created                               timestamp,
    created_by_id                              integer,
    date_modified                              timestamp,
    modified_by_id                             integer,
    utility_id                                 integer,
    note                                       text,
    reference_standards                        text,
    electrical_code_id                         integer,
    building_code_id                           integer,
    electrical_engineer_id                     integer,
    structural_engineer_id                     integer,
    standard_racking_equipment_id              integer,
    railless_landscape_attachment_spacing_id   integer,
    fire_setbacks_id                           integer,
    railless_portrait_attachment_spacing_id    integer,
    standard_conduit_run_id                    integer,
    warning_labels_id                          integer,
    supplemental_ground_rod_required_id        integer,
    load_standard_id                           integer,
    wood_standard_id                           integer,
    ground_snow_load                           varchar(100),
    wind_speed                                 varchar(100),
    ult_id                                     integer,
    seismic_design_category_id                 integer,
    roof_snow_load                             varchar(100),
    roof_snow_load_ahj_override_id             integer,
    snow_load_reduction_allowed_id             integer,
    wind_exposure_factor_id                    integer,
    wind_exposure_factor_ahj_override_id       integer,
    risk_category_id                           integer,
    stamp_type_id                              integer,
    structural_post_install_letter_required_id integer,
    constraint ahj_design_pkey
        primary key (id),
    constraint ahj_design_ahj_id_key
        unique (ahj_id),
    constraint ahj_design_ahj_id_fkey
        foreign key (ahj_id) references brs.ahj,
    constraint ahj_design_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_design_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user",
    constraint ahj_design_ahj_utility_fkey
        foreign key (utility_id) references brs.ahj_utility,
    constraint ahj_design_electrical_code_id_fkey
        foreign key (electrical_code_id) references brs.custom_dropdown_value,
    constraint ahj_design_building_code_id_fkey
        foreign key (building_code_id) references brs.custom_dropdown_value,
    constraint ahj_design_electrical_engineer_id_fkey
        foreign key (electrical_engineer_id) references brs.custom_dropdown_value,
    constraint ahj_design_structural_engineer_id_fkey
        foreign key (structural_engineer_id) references brs.custom_dropdown_value,
    constraint ahj_design_standard_racking_equipment_id_fkey
        foreign key (standard_racking_equipment_id) references brs.custom_dropdown_value,
    constraint ahj_design_railless_landscape_attachment_spacing_id_fkey
        foreign key (railless_landscape_attachment_spacing_id) references brs.custom_dropdown_value,
    constraint ahj_design_fire_setbacks_id_fkey
        foreign key (fire_setbacks_id) references brs.custom_dropdown_value,
    constraint ahj_design_railless_portrait_attachment_spacing_id_fkey
        foreign key (railless_portrait_attachment_spacing_id) references brs.custom_dropdown_value,
    constraint ahj_design_standard_conduit_run_id_fkey
        foreign key (standard_conduit_run_id) references brs.custom_dropdown_value,
    constraint ahj_design_warning_labels_id_fkey
        foreign key (warning_labels_id) references brs.custom_dropdown_value,
    constraint ahj_design_supplemental_ground_rod_required_id_fkey
        foreign key (supplemental_ground_rod_required_id) references brs.custom_dropdown_value,
    constraint ahj_design_load_standard_id_fkey
        foreign key (load_standard_id) references brs.custom_dropdown_value,
    constraint ahj_design_wood_standard_id_fkey
        foreign key (wood_standard_id) references brs.custom_dropdown_value,
    constraint ahj_design_ult_id_fkey
        foreign key (ult_id) references brs.custom_dropdown_value,
    constraint ahj_design_seismic_design_category_id_fkey
        foreign key (seismic_design_category_id) references brs.custom_dropdown_value,
    constraint ahj_design_roof_snow_load_ahj_override_id_fkey
        foreign key (roof_snow_load_ahj_override_id) references brs.custom_dropdown_value,
    constraint ahj_design_snow_load_reduction_allowed_id_fkey
        foreign key (snow_load_reduction_allowed_id) references brs.custom_dropdown_value,
    constraint ahj_design_wind_exposure_factor_id_fkey
        foreign key (wind_exposure_factor_id) references brs.custom_dropdown_value,
    constraint ahj_design_wind_exposure_factor_ahj_override_id_fkey
        foreign key (wind_exposure_factor_ahj_override_id) references brs.custom_dropdown_value,
    constraint ahj_design_risk_category_id_fkey
        foreign key (risk_category_id) references brs.custom_dropdown_value,
    constraint ahj_design_stamp_type_id_fkey
        foreign key (stamp_type_id) references brs.custom_dropdown_value,
    constraint ahj_design_structural_post_install_letter_required_id_fkey
        foreign key (structural_post_install_letter_required_id) references brs.custom_dropdown_value
);

CREATE TABLE if not exists  brs.ahj_design_contact
(
    ahj_design_id  integer              not null,
    ahj_contact_id integer              not null,
    constraint ahj_design_contact_ahj_design_id_fkey
        foreign key (ahj_design_id) references brs.ahj_design,
    constraint ahj_design_contact_ahj_contact_id_fkey
        foreign key (ahj_contact_id) references brs.ahj_contact,
    constraint ahj_design_contact_ahj_design_id_ahj_contact_id_key
        unique (ahj_design_id, ahj_contact_id)
);

CREATE TABLE if not exists  brs.ahj_design_note
(
    ahj_design_id integer               not null,
    ahj_note_id   integer               not null,
    constraint ahj_design_note_ahj_design_id_fkey
        foreign key (ahj_design_id) references brs.ahj_design,
    constraint ahj_design_note_ahj_note_id_fkey
        foreign key (ahj_note_id) references brs.ahj_note,
    constraint ahj_design_note_ahj_design_id_ahj_note_id_key
        unique (ahj_design_id, ahj_note_id)
);

CREATE TABLE if not exists  brs.ahj_base_note_template
(
    id             serial                     not null,
    title          varchar(255)               not null,
    note           text,
    archived       boolean                    not null default false,
    date_created   timestamp without time zone,
    created_by_id  integer,
    date_modified  timestamp without time zone,
    modified_by_id integer,
    constraint ahj_base_note_template_pkey
        primary key (id),
    constraint ahj_base_note_template_created_by_id_fk foreign key (created_by_id)
        references flow."user" (id) match simple
        on update no action on delete no action,
    constraint ahj_base_note_template_modified_by_id_fk foreign key (modified_by_id)
        references flow."user" (id) match simple
        on update no action on delete no action
);

CREATE TABLE if not exists  brs.ahj_inspection_base_note
(
    ahj_inspection_id         integer,
    ahj_base_note_template_id integer,
    constraint ahj_inspection_base_note_ahj_inspection_id_fkey
        foreign key (ahj_inspection_id) references brs.ahj_inspection,
    constraint ahj_inspection_base_note_ahj_base_note_template_id_fkey
        foreign key (ahj_base_note_template_id) references brs.ahj_base_note_template
);

CREATE TABLE if not exists  brs.ahj_inspection_checklist
(
    ahj_inspection_id integer           not null,
    ahj_checklist_id  integer           not null,
    constraint ahj_inspection_checklist_ahj_inspection_id_fkey
        foreign key (ahj_inspection_id) references brs.ahj_inspection,
    constraint ahj_inspection_checklist_ahj_checklist_id_fkey
        foreign key (ahj_checklist_id) references brs.ahj_checklist,
    constraint ahj_inspection_checklist_ahj_inspection_id_ahj_checklist_id_key
        unique (ahj_inspection_id, ahj_checklist_id)
);

CREATE TABLE if not exists  brs.ahj_inspection_contact
(
    ahj_inspection_id integer           not null,
    ahj_contact_id    integer           not null,
    constraint ahj_inspection_contact_ahj_inspection_id_fkey
        foreign key (ahj_inspection_id) references brs.ahj_inspection,
    constraint ahj_inspection_contact_ahj_contact_id_fkey
        foreign key (ahj_contact_id) references brs.ahj_contact,
    constraint ahj_inspection_contact_ahj_inspection_id_ahj_contact_id_key
        unique (ahj_inspection_id, ahj_contact_id)
);

CREATE TABLE if not exists  brs.ahj_inspection_note
(
    ahj_inspection_id integer           not null,
    ahj_note_id       integer           not null,
    constraint ahj_inspection_note_ahj_inspection_id_fkey
        foreign key (ahj_inspection_id) references brs.ahj_inspection,
    constraint ahj_inspection_note_ahj_note_id_fkey
        foreign key (ahj_note_id) references brs.ahj_note,
    constraint ahj_inspection_note_ahj_inspection_id_ahj_note_id_key
        unique (ahj_inspection_id, ahj_note_id)
);

CREATE TABLE if not exists  brs.ahj_requirements
(
    ahj_id                  integer,
    requirement_id          integer,
    original_requirement_id integer,
    status_id               integer   default 1,
    position                integer   default 0,
    complete                boolean   default false not null,
    archived                boolean   default false not null,
    date_created            timestamp default now(),
    created_by_id           integer,
    date_modified           timestamp,
    modified_by_id          integer,
    constraint ahj_requirements_ahj_id_fkey
        foreign key (ahj_id) references brs.ahj,
    constraint ahj_requirements_requirement_id_fkey
        foreign key (requirement_id) references brs.ahj_requirement,
    constraint ahj_requirements_original_requirement_id_fkey
        foreign key (original_requirement_id) references brs.ahj_requirement,
    constraint ahj_requirements_status_id_fkey
        foreign key (status_id) references brs.ahj_requirement_status,
    constraint ahj_requirements_created_by_id_fkey
        foreign key (created_by_id) references flow."user",
    constraint ahj_requirements_modified_by_id_fkey
        foreign key (modified_by_id) references flow."user",
    constraint ahj_requirements_ahj_id_requirement_id_key
        unique (ahj_id, requirement_id)
);