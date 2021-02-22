insert into flow.feature(feature_name, feature_code)
select 'Call Groups', 'CALL_GROUPS'
    where not exists (select id from flow.feature where feature_code = 'CALL_GROUPS');

insert into flow.company_feature(feature_name, company_id, feature_id)
select 'Call Groups', 3, (select id from flow.feature where feature_code = 'CALL_GROUPS')
where not exists (select id from flow.company_feature where feature_name = 'Call Groups' and company_id = 3);

CREATE TABLE if not exists brs.call_group
(
    id              serial  NOT NULL,
    company_id integer not null,
    call_group_name            varchar(100) not null,
    phone_number               varchar(50) not null,
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT call_group_pk PRIMARY KEY (id),
    CONSTRAINT call_group_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cg_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cg_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists brs.call_group_postal_code
(
    id              serial  NOT NULL,
    call_group_id integer not null,
    postal_code         varchar(10),
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT cgpc_pk PRIMARY KEY (id),
    CONSTRAINT cgpc_id_fk FOREIGN KEY (call_group_id)
    REFERENCES brs.call_group (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cgpc_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cgpc_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
                                      ON UPDATE NO ACTION ON DELETE NO ACTION
);
