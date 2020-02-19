CREATE TABLE if not exists flow.project_status_type
(
    id                 serial                NOT NULL,
    project_status_type varchar(100) NOT NULL,
    archived           boolean not null default false,
    CONSTRAINT project_status_type_pk PRIMARY KEY (id)
)
    WITH (
        OIDS= FALSE
    );

CREATE TABLE if not exists flow.company_project_status_type
(
    id                 serial                NOT NULL,
    project_status_type_id integer NOT NULL,
    project_status_type varchar(100) NOT NULL,
    company_id integer NOT NULL,
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT company_project_status_type_pk PRIMARY KEY (id),
    CONSTRAINT flow_cpst_project_status_type_id_fk FOREIGN KEY (project_status_type_id)
        REFERENCES flow.project_status_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cpst_company_id_fk FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cpst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_cpst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );


alter table flow.project
    add column if not exists company_project_status_type_id integer references flow.company_project_status_type(id);

select d.id, current_stage_id, s.stage_name
from blueraven.deal d
inner join blueraven.stage s on s.id = d.current_stage_id

;

select id, stage_name
from blueraven.stage
order by id
