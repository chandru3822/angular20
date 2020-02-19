alter table flow.process_step_process
    drop column if exists org_id;

alter table flow.org
    drop column if exists owning_org;

CREATE TABLE if not exists flow.process_step_process_owning_position
(
    id                 serial                NOT NULL,
    position_id        integer NOT NULL,
    process_step_process_id integer NOT NULL,
    archived           boolean not null default false,
    date_created            timestamp without time zone default now(),
    date_modified            timestamp without time zone,
    created_by_id     integer,
    modified_by_id    integer,
    CONSTRAINT process_step_process_owning_position_pk PRIMARY KEY (id),
    CONSTRAINT pspop_position_id_fk FOREIGN KEY (position_id)
        REFERENCES flow.position (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT pspop_process_step_process_id_fk FOREIGN KEY (process_step_process_id)
        REFERENCES flow.process_step_process (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pspop__created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pspop__modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
)
    WITH (
        OIDS= FALSE
    );

