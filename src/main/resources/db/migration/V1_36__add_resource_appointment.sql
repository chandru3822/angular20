CREATE TABLE if not exists flow.resource_appointment
(
    id                       serial  NOT NULL,
    company_id       integer NOT NULL,
    user_id        integer,
    org_id         integer,
    start_time   timestamp not null,
    end_time   timestamp not null,
    all_day boolean not null default false,
    description varchar(50),
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_resource_appointment_pk PRIMARY KEY (id),
    CONSTRAINT flow_ra_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_ra_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_ra_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
