CREATE TABLE if not exists flow.company_state
(
    id             serial  NOT NULL,
    state_id       integer not null,
    company_id     integer NOT NULL,
    map_latitude   numeric(14, 11),
    map_longitude  numeric(14, 11),
    map_zoom       numeric(14, 11),
    active         boolean not null default true,
    archived       boolean not null default false,
    CONSTRAINT flow_company_state_pk PRIMARY KEY (id),
    CONSTRAINT flow_cs_state_id_fk FOREIGN KEY (state_id)
        REFERENCES flow.state (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cs_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
);

alter table flow.state
add column if not exists country_id integer references flow.country(id);

CREATE TABLE if not exists flow.company_country
(
    id             serial  NOT NULL,
    country_id       integer not null,
    company_id     integer NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_company_country_pk PRIMARY KEY (id),
    CONSTRAINT flow_cc_country_id_fk FOREIGN KEY (country_id)
        REFERENCES flow.country (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cs_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT
);
