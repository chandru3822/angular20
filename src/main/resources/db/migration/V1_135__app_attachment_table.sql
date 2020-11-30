CREATE TABLE if not exists flow.app_type
(
    id                       serial  NOT NULL,
    app_type varchar(10),
    CONSTRAINT flow_app_type_pk PRIMARY KEY (id)
);

insert into flow.app_type(id, app_type)
select 1, 'iOS' where not exists(select id from flow.app_type where app_type = 'iOS');
insert into flow.app_type(id, app_type)
select 2, 'Android' where not exists(select id from flow.app_type where app_type = 'Android');

CREATE TABLE if not exists flow.app_attachment
(
    id                       serial  NOT NULL,
    company_id       integer NOT NULL,
    app_type_id        integer not null,
    attachment_type_id        integer not null,
    filename                  varchar(1000),
    content_type              varchar(100),
    s3_key                    varchar(100),
    size                      integer,
    show                      boolean default false not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_app_attachment_pk PRIMARY KEY (id),
    CONSTRAINT flow_aa_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_aa_attachment_type_id_fk FOREIGN KEY (attachment_type_id)
        REFERENCES flow.attachment_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_aa_app_type_id_fk FOREIGN KEY (app_type_id)
        REFERENCES flow.app_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_aa_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_aa_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION

);
