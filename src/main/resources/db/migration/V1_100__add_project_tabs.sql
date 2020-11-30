CREATE TABLE if not exists flow.company_object_type_tab
(
    id                       serial  NOT NULL,
    tab_name        varchar(255) not null,
    display_order int not null,
    company_object_type_id integer not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_company_object_type_tab_pk PRIMARY KEY (id),
    CONSTRAINT flow_cott_company_object_type_id_fk FOREIGN KEY (company_object_type_id)
        REFERENCES flow.company_object_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_cott_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cott_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.custom_field_group
add column if not exists company_object_type_tab_id int references flow.company_object_type_tab(id);

