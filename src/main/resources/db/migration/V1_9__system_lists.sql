alter table flow.data_type
add column if not exists system_list boolean not null default false;



CREATE TABLE if not exists flow.system_list_type
(
    id             serial  NOT NULL,
    system_list_type  character varying(50) NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_system_list_type_pk PRIMARY KEY (id)
);

CREATE TABLE if not exists flow.system_list
(
    id             serial  NOT NULL,
    system_list  character varying(50) NOT NULL,
    system_list_type_id  integer not null,
    has_sub_options boolean not null default false,
    archived       boolean not null default false,
    CONSTRAINT flow_system_list_pk PRIMARY KEY (id),
    CONSTRAINT system_list_type_id FOREIGN KEY (system_list_type_id)
        REFERENCES flow.system_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.company_system_list
(
    id             serial  NOT NULL,
    system_list_id  integer NOT NULL,
    company_id  integer               NOT NULL,
    schedulable boolean not null default false,
    archived       boolean not null default false,
    CONSTRAINT flow_company_system_list_pk PRIMARY KEY (id),
    CONSTRAINT csl_company_id FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT csl_system_list_id FOREIGN KEY (system_list_id)
        REFERENCES flow.system_list (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.custom_field
add column if not exists company_system_list_id integer references flow.company_system_list(id);

alter table flow.custom_field
    add column if not exists system_list_option_ids integer[];

alter table flow.process_step_requirement
    add column if not exists system_list_option_id integer;

alter table flow.process_step_requirement
    add column if not exists custom_sql_option_id integer;


