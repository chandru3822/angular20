drop schema if exists props cascade;

--------------------------------------------------------------------------------
-- build the schema
--------------------------------------------------------------------------------
create schema props;

CREATE TABLE if NOT EXISTS props.incentive_category
(
    id              serial                NOT NULL,
    incentive_category character VARYING(100) not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT incentive_category_pk PRIMARY KEY (id),
    CONSTRAINT incentive_category_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT incentive_category_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into props.incentive_category(incentive_category, date_created, created_by_id)
    (select 'Country',now(),2350555
     where not exists (select id
                       from props.incentive_category ic
                       where ic.incentive_category = 'Country'));

insert into props.incentive_category(incentive_category, date_created, created_by_id)
    (select 'State',now(),2350555
     where not exists (select id
                       from props.incentive_category ic
                       where ic.incentive_category = 'State'));

insert into props.incentive_category(incentive_category, date_created, created_by_id)
    (select 'Utility State',now(),2350555
     where not exists (select id
                       from props.incentive_category ic
                       where ic.incentive_category = 'Utility State'));

CREATE TABLE if NOT EXISTS props.incentive_type
(
    id              serial                NOT NULL,
    incentive_type character VARYING(100) not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT incentive_type_pk PRIMARY KEY (id),
    CONSTRAINT incentive_type_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT incentive_type_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into props.incentive_type(incentive_type, date_created, created_by_id)
(select '% of Total Cost',now(),2350555
    where not exists (select id
                        from props.incentive_type
                        where incentive_type.incentive_type = '% of Total Cost'));

insert into props.incentive_type(incentive_type, date_created, created_by_id)
    (select 'Per Watt',now(),2350555
     where not exists (select id
                       from props.incentive_type
                       where incentive_type.incentive_type = 'Per Watt'));

CREATE TABLE if NOT EXISTS props.utility
(
    id              serial                NOT NULL,
    utility_company character VARYING(100) not null,
    company_id integer not null,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT utility_pk PRIMARY KEY (id),
    CONSTRAINT utility_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT utility_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT utility_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE IF NOT EXISTS props.financier
(
    id                serial        not null,
    company_id        integer       not null,
    name              varchar(100)  not null,
    submission_method varchar(255),
    archived          boolean not null       default false,
    date_created      timestamp without time zone DEFAULT now(),
    created_by_id     integer,
    date_modified     timestamp without time zone,
    modified_by_id    integer,
    active boolean not null default false,
    CONSTRAINT financier_pk PRIMARY KEY (id),
    CONSTRAINT financier_name_uk UNIQUE (name),
    CONSTRAINT financier_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT financier_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT financier_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE if NOT EXISTS props.product
(
    id              serial                NOT NULL,
    product_name character VARYING(100) not null,
    financier_id integer,
    interest_rate numeric(10,3),
    term_length integer,
    dealer_fee numeric(10,3),
    company_id integer not null,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT product_pk PRIMARY KEY (id),
    CONSTRAINT product_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT product_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT product_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT product_financier_id_fk FOREIGN KEY (financier_id)
        REFERENCES props.financier (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if NOT EXISTS props.panel
(
    id              serial                NOT NULL,
    panel_name character VARYING(100) not null,
    company_id integer not null,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT panel_pk PRIMARY KEY (id),
    CONSTRAINT panel_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT panel_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT panel_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


CREATE TABLE if NOT EXISTS props.state_incentive
(
    id              serial                NOT NULL,
    company_state_id integer not null,
    incentive_type_id integer not null,
    incentive_category_id integer not null,
    amount numeric(10,3),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT state_incentive_pk PRIMARY KEY (id),
    CONSTRAINT si_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT si_incentive_type_id_fk FOREIGN KEY (incentive_type_id)
        REFERENCES props.incentive_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT si_incentive_category_id_fk FOREIGN KEY (incentive_category_id)
        REFERENCES props.incentive_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT si_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT si_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);


CREATE TABLE if NOT EXISTS props.country_incentive
(
    id              serial                NOT NULL,
    company_country_id integer not null,
    incentive_type_id integer not null,
    incentive_category_id integer not null,
    amount numeric(10,3),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    company_id integer,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT country_incentive_pk PRIMARY KEY (id),
    CONSTRAINT ci_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_incentive_type_id_fk FOREIGN KEY (incentive_type_id)
        REFERENCES props.incentive_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_incentive_category_id_fk FOREIGN KEY (incentive_category_id)
        REFERENCES props.incentive_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT si_country_id_fk FOREIGN KEY (company_country_id)
        REFERENCES flow.company_country (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);


CREATE TABLE if NOT EXISTS props.panel_state
(
    id              serial                NOT NULL,
    panel_id integer not null,
    company_state_id integer not null,
    adder_amount     numeric(10,3),
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT panel_state_pk PRIMARY KEY (id),
    CONSTRAINT panel_state_panel_id_fk FOREIGN KEY (panel_id)
        REFERENCES props.panel (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT panel_state_company_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT panel_state_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT panel_state_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.utility_state
(
    id              serial                NOT NULL,
    utility_id integer not null,
    company_state_id integer not null,
    cost_per_kwh    numeric(10,3),
    escalator        numeric(10,3),
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT utility_state_pk PRIMARY KEY (id),
    CONSTRAINT utility_state_utility_id_fk FOREIGN KEY (utility_id)
        REFERENCES props.utility (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
     CONSTRAINT utility_state_company_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT utility_state_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT utility_state_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.utility_state_incentive
(
    id              serial                NOT NULL,
    utility_state_id integer not null,
    incentive_type_id integer not null,
    incentive_category_id integer not null,
    amount numeric(10,3),
    start_date timestamp without time zone,
    end_date timestamp without time zone,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT utility_state_incentive_pk PRIMARY KEY (id),
    CONSTRAINT usi_company_id_fk FOREIGN KEY (utility_state_id)
        REFERENCES props.utility_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT usi_incentive_type_id_fk FOREIGN KEY (incentive_type_id)
        REFERENCES props.incentive_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT usi_incentive_category_id_fk FOREIGN KEY (incentive_category_id)
        REFERENCES props.incentive_category (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ci_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.adder_type
(
    id              serial                NOT NULL,
    adder_type character VARYING(100) not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT adder_type_pk PRIMARY KEY (id),
    CONSTRAINT adder_type_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT adder_type_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into props.adder_type(adder_type, date_created, created_by_id)
    (select 'Flat Fee',now(),2350555
     where not exists (select id
                       from props.adder_type
                       where adder_type.adder_type = 'Flat Fee'));

insert into props.adder_type(adder_type, date_created, created_by_id)
    (select 'Cost Per Watt',now(),2350555
     where not exists (select id
                       from props.adder_type
                       where adder_type.adder_type = 'Cost Per Watt'));

CREATE TABLE if NOT EXISTS props.adder
(
    id              serial                NOT NULL,
    adder_name character varying(100) not null,
    adder_type_id integer not null,
    company_id integer not null,
    amount    numeric(10,3),
    escalator        numeric(10,3),
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT cost_per_watt_adder_pk PRIMARY KEY (id),
    CONSTRAINT cpwa_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cpwa_adder_type_id_fk FOREIGN KEY (adder_type_id)
        REFERENCES props.adder_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cpwa_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cpwa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);



CREATE TABLE if NOT EXISTS props.product_utility_state
(
    id              serial                NOT NULL,
    utility_state_id integer not null,
    product_id  integer not null,
    funding_cap    numeric(10,3) not null,
    target_production_factor    numeric(10,3) not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT product_utility_state_pk PRIMARY KEY (id),
    CONSTRAINT pus_utility_state_id_fk FOREIGN KEY (utility_state_id)
        REFERENCES props.utility_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pus_product_id_fk FOREIGN KEY (product_id)
        REFERENCES props.product (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pus_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pus_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.proposal_log
(
    id              serial                NOT NULL,
    project_id integer not null,
    proposal_number integer not null,
    number_of_panels integer not null,
    panel_wattage integer not null,
    annual_production integer not null,
    product_utility_state_id integer not null,
    annual_usage integer not null,
    panel_state_id integer not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT proposal_log_pk PRIMARY KEY (id),
    CONSTRAINT pl_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pl_product_utility_state_id_fk FOREIGN KEY (product_utility_state_id)
        REFERENCES props.product_utility_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pl_panel_state_id_fk FOREIGN KEY (panel_state_id)
        REFERENCES props.panel_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pl_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pl_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);


CREATE TABLE if NOT EXISTS props.proposal_log_adder
(
    id              serial                NOT NULL,
    proposal_log_id integer not null,
    adder_id integer not null,
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT proposal_log_flat_fee_adder_pk PRIMARY KEY (id),
    CONSTRAINT plffa_proposal_log_id_fk FOREIGN KEY (proposal_log_id)
        REFERENCES props.proposal_log (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT plffa_flat_fee_adder_id_fk FOREIGN KEY (adder_id)
        REFERENCES props.adder (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT plffa_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT plffa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);



create table if not exists brs.commission_plan_status
(
    id          integer not null
        constraint commission_plan_status_pk
            primary key,
    status_type varchar(20)
);


create table if not exists brs.commission_plan
(
    id          serial                   not null
        constraint commission_plan_pk
            primary key,
    name        text,
    total       numeric(10, 2) default 0 not null,
    status_id   integer        default 1
        constraint commission_plan_commission_plan_status_id_fk
            references brs.commission_plan_status,
    position_id integer
        constraint commission_plan_position_id_fk
            references flow.position,
    approved    timestamp with time zone,
    created     timestamp with time zone,
    created_by  integer
        constraint commission_plan_created_by_user_id_fk
            references flow."user",
    approved_by integer
        constraint commission_plan_approved_by_user_id_fk
            references flow."user",
    parent_id   integer
        constraint commission_plan_commission_plan_id_fk
            references brs.commission_plan,
    description text,
    notes       text
);

create index if not exists commission_plan_name_trgm_idx
    on brs.commission_plan (name);


create table if not exists brs.commission_plan_user
(
    id                 serial  not null
        constraint commission_plan_user_pk
            primary key,
    commission_plan_id integer not null
        constraint commission_plan_user_commission_plan_id_fk
            references brs.commission_plan,
    user_id            integer not null
        constraint commission_plan_user_user_id_fk
            references flow."user",
    start_date         date    not null,
    end_date           date,
    note               text
);

create index if not exists commission_plan_user_user_id_daterange_excl
    on brs.commission_plan_user (user_id, daterange(start_date, end_date, '[]'::text));

create table if not exists brs.milestone_type
(
    id             serial            not null
        constraint milestone_type_pk
            primary key,
    milestone_type varchar(100),
    active         boolean default true,
    display_order  integer default 1 not null
);

create table if not exists brs.fee_type
(
    id       serial not null
        constraint fee_type_pk
            primary key,
    fee_type varchar(100)
);


create table if not exists brs.commission_plan_source_allocation
(
    id                 serial  not null
        constraint commission_plan_source_allocation_pk
            primary key,
    commission_plan_id integer not null
        constraint commission_plan_source_allocation_id_fk
            references brs.commission_plan,
    milestone_id       integer not null
        constraint commission_plan_source_allocation_milestone_fk
            references brs.milestone_type,
    fee_amount         numeric(10, 2),
    fee_type_id        integer not null
        constraint commission_plan_fee_type_id_fkey
            references brs.fee_type,
    source_id          integer not null
);


create table if not exists brs.commission_plan_allocation
(
    id                           serial  not null
        constraint commission_plan_user_allocation_pk
            primary key,
    commission_plan_id           integer not null
        constraint commission_plan_allocation_plan_id_fk
            references brs.commission_plan,
    milestone_id integer not null
        constraint commission_plan_allocation_milestone_id_fk
            references brs.milestone_type,
    allocation                   numeric(10, 2)
);

create table if not exists brs.payroll_status
(
    id             integer not null
        constraint payroll_status_pk
            primary key,
    payroll_status varchar(20)
);


create table if not exists brs.payroll
(
    id                serial                          not null
        constraint payroll_pk
            primary key,
    period_end        date,
    paid_date         date,
    description       text,
    payroll_status_id integer  default 1              not null
        constraint payroll_payroll_status_id_fk
            references brs.payroll_status,
    created           timestamp with time zone,
    updated           timestamp with time zone,
    created_by        integer
        constraint payroll_created_by_fk
            references flow."user",
    updated_by        integer
        constraint payroll_updated_by_fkey
            references flow."user",
    current           boolean  default false          not null,
    selected_project_ids bigint[] default '{}'::bigint[] not null
);

create table if not exists brs.payroll_adjustment_type
(
    id              integer not null
        constraint payroll_adjustment_type_pk
            primary key,
    adjustment_type varchar(20)
);

create table if not exists brs.payroll_adjustment
(
    id                         serial  not null
        constraint payroll_adjustment_pk
            primary key,
    payroll_id                 integer not null
        constraint payroll_commission_adjustment_payroll_id_fk
            references brs.payroll
            on delete cascade,
    project_id                    bigint  not null
        constraint payroll_commission_adjustment_project_id_fk
            references flow.project
            on delete cascade,
    closer_id                  integer not null
        constraint payroll_commission_adjustment_closer_id_fk
            references flow."user",
    amount                     numeric(10, 2),
    note                       text,
    created_by                 integer
        constraint payroll_commission_adjustment_created_by_fk
            references flow."user",
    created                    timestamp with time zone,
    payroll_adjustment_type_id integer not null
        constraint payroll_adjustment_payroll_adjustment_type_id_fk
            references brs.payroll_adjustment_type
);

create table if not exists brs.payroll_action_type
(
    id          integer not null
        constraint payroll_action_type_pk
            primary key,
    action_type varchar(30)
);

create table if not exists brs.payroll_action_history
(
    payroll_id             integer                  not null
        constraint payroll_action_history_payroll_id_fk
            references brs.payroll,
    payroll_action_type_id integer                  not null
        constraint payroll_action_history_action_type_id_fk
            references brs.payroll_action_type,
    action_date            timestamp with time zone not null,
    user_id                integer                  not null
        constraint payroll_action_history_user_id_fk
            references flow."user",
    note                   text
);

create table if not exists brs.ledger_type
(
    id          integer not null
        constraint ledger_type_pk
            primary key,
    ledger_type varchar(30)
);

create table if not exists brs.project_commission_ledger
(
    id             serial  not null
        constraint project_commission_ledger_pk
            primary key,
    project_id        integer
        constraint project_commission_ledger_project_id_fk
            references flow.project,
    closer_id      integer
        constraint project_commission_ledger_closer_id_fk
            references flow."user",
    ledger_type_id integer
        constraint project_commission_ledger_ledger_type_id_fk
            references brs.ledger_type,
    amount         numeric(10, 2) default 0,
    note           text,
    created_by     integer not null
        constraint project_commission_ledger_created_by_fk
            references flow."user",
    created        timestamp with time zone,
    payroll_id     integer not null
        constraint project_commission_ledger_payroll_id_fk
            references brs.payroll
            on delete cascade,
    paid_to_date   numeric(10, 2)
);


create index if not exists project_commission_ledger_project_id_idx
    on brs.project_commission_ledger (project_id);


create table if not exists brs.project_commission_snapshot
(
    id                          serial  not null
        constraint project_commission_snapshot_pk
            primary key,
    payroll_id                  integer not null
        constraint project_commission_snapshot_payroll_id_fk
            references brs.payroll,
    project_id                     integer not null
        constraint project_commission_snapshot_project_id_fk
            references flow.project,
    customer_name               varchar(200),
    system_size                 numeric(10, 2),
    sales_rep_id                integer,
    sales_rep                   varchar(200),
    source                      varchar(200),
    stage                       varchar(200),
    cancelled                   date,
    commission_plan_id          integer,
    commission_plan             varchar(200),
    install_agreement_signed    date,
    final_design_signed         date,
    financial_agreement_sent    date,
    deposit                     date,
    hoi                         date,
    sc                          date,
    commissions_earned          numeric(10, 2),
    override_earned             numeric(10, 2),
    override_plan_id            integer,
    override_plan               varchar(200),
    commission_adjustment       numeric(10, 2),
    commission_paid_to_date     numeric(10, 2),
    overrides_paid_to_date      numeric(10, 2),
    remaining_value             numeric(10, 2),
    current_pay                 numeric(10, 2),
    project_total_value            numeric(10, 2),
    updated                     timestamp with time zone,
    override_adjustment         numeric(10, 2),
    total_commissions           numeric(10, 2),
    current_pay_commissions     numeric(10, 2),
    remaining_value_commissions numeric(10, 2),
    total_overrides             numeric(10, 2),
    remaining_value_overrides   numeric(10, 2),
    current_pay_overrides       numeric(10, 2),
    percent_of_cash_deposit     numeric(10, 2),
    utility_bill_verified_date  date
);


create unique index if not exists project_commission_snapshot_project_id_payroll_id_udx
    on brs.project_commission_snapshot (project_id, payroll_id);


create table if not exists brs.project_override_commission_snapshot
(
    id                          serial not null
        constraint project_override_commission_snapshot_pk
            primary key,
    project_commission_snapshot_id integer
        constraint project_override_commission_snapshot_id_fk
            references brs.project_commission_snapshot
            on delete cascade,
    user_id                     integer
        constraint project_override_commission_snapshot_user_id_fk
            references flow."user",
    milestone_type_id           integer
        constraint project_override_commission_snapshot_milestone_type_id_fk
            references brs.milestone_type,
    total                       numeric(10, 2)
);

create unique index if not exists project_commission_snapshot_id_user_id_milestone_type_id_udx
    on brs.project_override_commission_snapshot (project_commission_snapshot_id, user_id, milestone_type_id);

create table if not exists brs.override_plan_status
(
    id          integer not null
        constraint override_plan_status_pk
            primary key,
    status_type varchar(20)
);

create table if not exists brs.override_plan
(
    id          serial                   not null
        constraint override_plan_pk
            primary key,
    name        text,
    description text,
    total       numeric(10, 2) default 0 not null,
    status_id   integer        default 1
        constraint override_plan_status_id_fk
            references brs.override_plan_status,
    position_id integer
        constraint override_plan_position_id_
            references flow.position,
    created_by  integer
        constraint override_plan_created_by_fk
            references flow."user",
    created     timestamp with time zone,
    updated_by  integer
        constraint override_plan_updated_by_fk
            references flow."user",
    updated     timestamp with time zone,
    approved_by integer
        constraint override_plan_approved_by_fk
            references flow."user",
    approved    timestamp with time zone,
    parent_id   integer
        constraint override_plan_parent_id_fk
            references brs.override_plan
);



create table if not exists brs.override_plan_receiving_user
(
    id serial not null
        constraint override_plan_receiving_user_pk
            primary key,
    override_plan_id integer                  not null
        constraint override_plan_receiving_user_override_plan_id_fk
            references brs.override_plan,
    user_id          integer                  not null
        constraint override_plan_receiving_user_user_id_fk
            references blueraven."user",
    m1_allocation       numeric(10, 2) default 0 not null,
    m2_allocation       numeric(10, 2) default 0 not null,
    note             text,
    constraint override_plan_receiving_user_uk
        unique  (override_plan_id, user_id)
);

create table if not exists brs.override_plan_assigned_user
(
    id               serial  not null
         constraint override_plan_assigned_user_pk
             primary key,
    override_plan_id integer not null
        constraint override_plan_assigned_user_override_plan_id_fk
            references brs.override_plan,
    user_id          integer not null
        constraint override_plan_assigned_user_user_id_fk
            references flow."user",
    start_date       date,
    end_date         date,
    note             text
);


create index if not exists override_plan_assigned_user_user_id_daterange_excl
    on brs.override_plan_assigned_user (user_id, daterange(start_date, end_date, '[]'::text));




create table if not exists brs.project_commission
(
    id               serial  not null
        constraint project_commission_pk
            primary key,
    project_id integer not null,
    commission_plan_id integer not null,
        CONSTRAINT pc_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
            CONSTRAINT pc_commission_plan_id_fk FOREIGN KEY (commission_plan_id)
            REFERENCES brs.commission_plan (id) MATCH SIMPLE
            ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pc_comp_uk unique  (commission_plan_id,project_id)
);


create table if not exists brs.project_override
(
    id               serial  not null
        constraint project_override_pk
            primary key,
    project_id integer not null,
    override_plan_id integer not null,
        CONSTRAINT po_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT po_override_plan_id_fk FOREIGN KEY (override_plan_id)
        REFERENCES brs.override_plan (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT po_comp_uk unique  (override_plan_id,project_id)
);


create table if not exists brs.exclude_commission
(
    id               serial  not null
        constraint exclude_commission_pk
            primary key,
    project_id integer not null,
    CONSTRAINT ec_project_id_fk FOREIGN KEY (project_id)
        REFERENCES flow.project (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT po_project_id_uk unique  (project_id)
);

--TODO migrate this data
alter table flow."user" drop column if exists employee_id;
alter table flow."user" drop column if exists start_date;
alter table flow."user" drop column if exists end_date;
alter table flow."user" drop column if exists notes;
alter table flow."user" drop column if exists employment_type_id;
alter table flow."user" drop column if exists compensation_type_id;
alter table flow."user" drop column if exists personal_email;
alter table flow."user" drop column if exists recruited_by_user_id;
alter table flow."user" drop column if exists recruited_by;
alter table flow."user" drop column if exists referred_by_user_id;
alter table flow."user" drop column if exists onboarded_by_user_id;
alter table flow."user" drop column if exists hire_date;
alter table flow."user" drop column if exists image_id;



CREATE TABLE if not exists flow.process_step_action_company_function
(
    id                     serial  not null,
    process_step_action_id        integer not null,
    company_function_id    integer not null,
    trigger_automatically  boolean not null default false,
    date_created           timestamp without time zone DEFAULT now(),
    date_modified           timestamp without time zone,
    created_by_id          integer not null,
    modified_by_id         integer,
    archived boolean not null default false,
    display_order         integer not null,
    CONSTRAINT process_step_action_company_function_pk PRIMARY KEY (id),
    CONSTRAINT psacf_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psacf_company_function_id_fk FOREIGN KEY (company_function_id)
        REFERENCES flow.company_function (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT psacf_action_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT psacf_action_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psacf_process_step_id_idx ON flow.process_step_action_company_function (process_step_action_id);
CREATE INDEX if not exists psacf_company_function_id_idx ON flow.process_step_action_company_function (company_function_id);



CREATE TABLE if NOT EXISTS flow.action_param_dynamic_value
(
    id        serial                NOT NULL,
    db_function_param_id integer NOT NULL,
    process_step_action_company_function_id integer not null,
    dynamic_value character varying(50),
    archived boolean not null default false,
    created_by_id                         integer,
    date_created                         timestamp   without time zone DEFAULT now(),
    modified_by_id                        integer,
    date_modified                        timestamp      without time zone,
    CONSTRAINT action_param_dynamic_value_pk PRIMARY KEY (id),
    CONSTRAINT apdv_db_function_param_id_fk FOREIGN KEY (db_function_param_id)
        REFERENCES flow.db_function_param (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT apdv_process_step_action_company_function_id_fk FOREIGN KEY (process_step_action_company_function_id)
        REFERENCES flow.process_step_action_company_function (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT apdv_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT apdv_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists apdv_db_function_param_id_idx ON flow.action_param_dynamic_value (db_function_param_id);
CREATE INDEX if not exists apdv_process_step_requirement_id_idx ON flow.action_param_dynamic_value (process_step_action_company_function_id);


alter table flow.project_process_step alter column process_step_complete_date type timestamp without time zone;

alter table flow.process_step_action_company_function drop column if exists trigger_automatically;
