CREATE TABLE if not exists flow.process_step_work_queue_type_project_status_type
(
    id                       serial  NOT NULL,
    project_status_type_id integer not null,
    process_step_work_queue_type_id integer not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_pswqtpst_project_status_type_id_fk FOREIGN KEY (project_status_type_id)
        REFERENCES flow.project_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pswqtpst_process_step_work_queue_type_id_fk FOREIGN KEY (process_step_work_queue_type_id)
        REFERENCES flow.process_step_work_queue_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pswqtpst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pswqtpst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);


