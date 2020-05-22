CREATE TABLE if not exists flow.postal_code_zone
(
    id              serial  NOT NULL,
    company_id integer not null,
    zone_name            varchar(100) not null,
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT postal_code_zone_pk PRIMARY KEY (id),
    CONSTRAINT pcz_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pcz_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pcz_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.postal_code_zone_user
(
    id              serial  NOT NULL,
    postal_code_zone_id integer not null,
    user_id            integer not null,
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT postal_code_zone_user_pk PRIMARY KEY (id),
    CONSTRAINT pczu_postal_code_zone_id_fk FOREIGN KEY (postal_code_zone_id)
        REFERENCES flow.postal_code_zone (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pczu_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pczu_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pczu_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.postal_code
(
    id              serial  NOT NULL,
    postal_code_zone_id integer not null,
    postal_code         varchar(10),
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT postal_code_pk PRIMARY KEY (id),
    CONSTRAINT pc_postal_code_zone_id_fk FOREIGN KEY (postal_code_zone_id)
        REFERENCES flow.postal_code_zone (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pc_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT pc_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE UNIQUE INDEX if not exists flow_postal_code_uniq_idx
    ON flow.postal_code
        USING btree
        (postal_code COLLATE pg_catalog."default")
    WHERE archived IS FALSE;
