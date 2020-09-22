CREATE TABLE if not exists flow.user_org_access
(
    id                       serial  NOT NULL,
    org_id       integer NOT NULL,
    user_id       integer NOT NULL,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_user_org_access_pk PRIMARY KEY (id),
    CONSTRAINT flow_uoa_org_id_fk FOREIGN KEY (org_id)
        REFERENCES flow.org (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_uoa_user_id_fk FOREIGN KEY (user_id)
        REFERENCES flow."user" (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_s_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_s_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION

);

create unique index if not exists user_org_access_udx
    on flow.user_org_access (user_id, org_id)
where archived is false;