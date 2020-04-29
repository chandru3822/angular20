alter table props.product_utility_state
    add column if not exists active boolean not null default false;

alter table props.panel
    add column if not exists wattage integer not null;

alter table props.panel
    add column if not exists panel_type character VARYING(100) not null;

alter table props.panel
    add column if not exists panel_color character VARYING(100) not null;

CREATE TABLE if NOT EXISTS props.adder_state
(
    id              serial                NOT NULL,
    adder_id integer not null,
    company_state_id integer not null,
    adder_amount     numeric(10,3),
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT adder_state_pk PRIMARY KEY (id),
    CONSTRAINT adder_state_adder_id_fk FOREIGN KEY (adder_id)
        REFERENCES props.adder (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT adder_state_company_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT adder_state_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT adder_state_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.inverter
(
    id              serial                NOT NULL,
    inverter_name character VARYING(100) not null,
    brand character VARYING(100),
    inverter_type character VARYING(100),
    company_id integer not null,
    archived boolean not null default false,
    active boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT inverter_pk PRIMARY KEY (id),
    CONSTRAINT inverter_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT inverter_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT inverter_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if NOT EXISTS props.inverter_state
(
    id              serial                NOT NULL,
    inverter_id integer not null,
    company_state_id integer not null,
    adder_amount     numeric(10,3),
    archived boolean not null default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT inverter_state_pk PRIMARY KEY (id),
    CONSTRAINT inverter_state_inverter_id_fk FOREIGN KEY (inverter_id)
        REFERENCES props.inverter (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT inverter_state_company_state_id_fk FOREIGN KEY (company_state_id)
        REFERENCES flow.company_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT inverter_state_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT inverter_state_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);

CREATE TABLE if NOT EXISTS props.zip_code
(
    id              serial                NOT NULL,
    zip_code varchar(10) NOT NULL,
    company_id integer NOT NULL,
    archived boolean NOT NULL default false,
    active boolean NOT NULL default false,
    date_created      timestamp without time zone DEFAULT now() not null,
    date_modified      timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT zip_code_pk PRIMARY KEY (id),
    CONSTRAINT zip_code_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT zip_code_created_by_id_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT zip_code_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
);
