CREATE TABLE if NOT EXISTS props.proposal
(
    id serial NOT NULL,
    project_id integer NOT NULL
        constraint prop_project_id_fk
            references flow.project(id),
    company_id  integer               NOT NULL,
    customer_name varchar(200),
    address varchar(200),
    city varchar(100),
    state_id  integer,
    zip_code varchar(10),
    phone varchar(50),
    email varchar(255),
    utility_company_id integer constraint prop_utility_company_id_fk
            references props.utility (id),
    product_id integer constraint props_product_fk
            references props.product(id),
    loan_term integer,
    interest_rate numeric(10,3),
    down_payment numeric(10,3),
    promotion varchar(100),
    number_of_ecobees integer,
    number_of_leds integer,
    monitor varchar(100),
    aurora_design_id integer,
    year_output numeric(10,3),
    number_of_panels integer,
    panel_id integer constraint props_panel_fk
            references props.panel(id),
    inverter_id integer constraint props_inverter_fk
            references props.inverter(id),
    proposal_created_by varchar(100),
    qa_completed_by varchar(100),
    notes varchar(255),
    proposal_number integer,
    total_system_price numeric(10,3),
    offset_val numeric(10,3),
    production_factor numeric(10,3),
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT proposal_pk PRIMARY KEY (id),
    CONSTRAINT proposal_company_id FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT proposal_state_id_fk FOREIGN KEY (state_id)
        REFERENCES flow.state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if NOT EXISTS props.proposal_adder
(
    id serial NOT NULL,
    proposal_id  integer not null constraint proposal_adder_proposal_id_fk
            references props.proposal(id),
    adder_id integer not null
        constraint proposal_adder_adder_id_fk
            references props.adder(id),
    CONSTRAINT proposal_adder_pk PRIMARY KEY (id)
);

create sequence if not exists props.proposal_excel_id_seq START WITH 1000;
