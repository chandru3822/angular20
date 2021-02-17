CREATE TABLE if not exists flow.process_step_company_process_step_status_type
(
    id                                  serial  NOT NULL,
    process_step_id                     integer NOT NULL,
    company_process_step_status_type_id integer NOT NULL,
    date_created                        timestamp without time zone DEFAULT now(),
    date_modified                       timestamp without time zone,
    created_by_id                       integer not null,
    modified_by_id                      integer,
    archived                            boolean not null            default false,
    CONSTRAINT flow_process_step_company_process_step_status_type_pk PRIMARY KEY (id),
    CONSTRAINT flow_pscpsst_process_step_id_fk FOREIGN KEY (process_step_id)
        REFERENCES flow.process_step (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pscpsst_company_process_step_status_type_id_fk FOREIGN KEY (company_process_step_status_type_id)
        REFERENCES flow.company_process_step_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT,
    CONSTRAINT flow_pscpsst_created_by_id_fk FOREIGN KEY (created_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT flow_pscpsst_modified_by_id_fk FOREIGN KEY (modified_by_id)
        REFERENCES flow.user (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

-- delete all of them so this won't break stage (i already manually added them
delete from flow.process_step_company_process_step_status_type where id > 0;

-- inserts the actives
insert into flow.process_step_company_process_step_status_type(process_step_id, company_process_step_status_type_id, created_by_id)
select ps.id as process_step_id,
       (select id from flow.company_process_step_status_type cpsst where cpsst.company_id = ps.company_id and cpsst.process_step_status_type_id = 1 and cpsst.process_step_status_type = 'Active'),
       2350555
from flow.process_step ps;

-- inserts the completes
insert into flow.process_step_company_process_step_status_type(process_step_id, company_process_step_status_type_id, created_by_id)
select ps.id as process_step_id,
       (select id from flow.company_process_step_status_type cpsst where cpsst.company_id = ps.company_id and cpsst.process_step_status_type_id = 2 and cpsst.process_step_status_type = 'Complete'),
       2350555
from flow.process_step ps;

-- inserts the cancelled
insert into flow.process_step_company_process_step_status_type(process_step_id, company_process_step_status_type_id, created_by_id)
select ps.id as process_step_id,
       (select id from flow.company_process_step_status_type cpsst where cpsst.company_id = ps.company_id and cpsst.process_step_status_type_id = 3 and cpsst.process_step_status_type = 'Cancelled'),
       2350555
from flow.process_step ps;
