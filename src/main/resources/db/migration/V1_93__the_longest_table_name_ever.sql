CREATE TABLE if not exists flow.project_process_step_process_step_work_queue_type_note
(
    id                      serial  not null,
    project_process_step_id integer not null,
    process_step_work_queue_type_id integer not null,
    note_id                 integer not null,
    CONSTRAINT project_process_step_process_step_work_queue_type_note_pk PRIMARY KEY (id),
    CONSTRAINT ppspswqtn_note_id FOREIGN KEY (note_id)
        REFERENCES flow.note (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppspswqtn_process_step_work_queue_type_id FOREIGN KEY (process_step_work_queue_type_id)
        REFERENCES flow.process_step_work_queue_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT ppspswqtn_project_process_step_id FOREIGN KEY (project_process_step_id)
        REFERENCES flow.project_process_step (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);
