alter table flow.process_step_action_child_process
add column if not exists company_process_step_status_type_id int references flow.company_process_step_status_type(id);

-- update all child processes to have a status to use for cancelled
update flow.process_step_action_child_process as t1 set
    company_process_step_status_type_id = (select cpsst.id
                                           from flow.company_process_step_status_type cpsst
                                           where cpsst.process_step_status_type_id = 3
                                             and cpsst.company_id = ps.company_id
                                             and cpsst.archived is not true)
from flow.process_step ps
    where ps.id = t1.process_step_id;

alter table flow.process_step_action
add column if not exists multiple_uses boolean not null default false;

alter table flow.project_process_step_action
add column if not exists allow_multiple_uses boolean not null default false;
;

CREATE TABLE if not exists flow.process_step_work_queue_type_process_step_status_type
(
    id                       serial  NOT NULL,
    company_process_step_status_type_id integer,
    process_step_status_type_id integer,
    process_step_work_queue_type_id integer not null,
    date_created     timestamp without time zone DEFAULT now(),
    date_modified   timestamp without time zone,
    created_by_id    integer      not null,
    modified_by_id  integer,
    archived       boolean not null default false,
    CONSTRAINT flow_pswqtpsst_company_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
        REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pswqtpsst_process_step_status_type_id_fk FOREIGN KEY (process_step_status_type_id)
        REFERENCES flow.process_step_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pswqtpsst_process_step_work_queue_type_id_fk FOREIGN KEY (process_step_work_queue_type_id)
        REFERENCES flow.process_step_work_queue_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pswqtpsst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pswqtpsst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into flow.process_step_work_queue_type_process_step_status_type(company_process_step_status_type_id, process_step_status_type_id, process_step_work_queue_type_id, created_by_id)
    ( select null, 1, pswqt.id, 2350555
      from flow.process_step_work_queue_type pswqt
      where not exists (
              select *
              from flow.process_step_work_queue_type_process_step_status_type pswqtpst
              where pswqtpst.process_step_work_queue_type_id = pswqt.id
                and pswqtpst.archived is not true
          )
        and pswqt.archived is not true )
;
