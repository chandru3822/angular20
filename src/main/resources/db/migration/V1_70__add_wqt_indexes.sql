create index if not exists process_step_work_queue_type_project_status_type_pk
    on flow.process_step_work_queue_type_project_status_type (project_status_type_id);
create index if not exists pswqtpst_work_queue_type_pk
    on flow.process_step_work_queue_type_project_status_type (process_step_work_queue_type_id);
create index if not exists cpst_project_status_type_pk
    on flow.company_project_status_type (project_status_type_id);
create index if not exists cpst_company_id_pk
    on flow.company_project_status_type (company_id);
create index if not exists project_company_process_id_pk
    on flow.project (company_process_id);
create index if not exists pps_project_id_pk
    on flow.project_process_step (project_id);
create index if not exists pps_process_step_id_pk
    on flow.project_process_step (process_step_id);
create index if not exists pps_company_process_step_status_type_id_pk
    on flow.project_process_step (company_process_step_status_type_id);
create index if not exists pps_user_position_id_pk
    on flow.project_process_step (user_position_id);
create index if not exists pswqt_process_step_id_pk
    on flow.process_step_work_queue_type (process_step_id);
create index if not exists pswqt_work_queue_type_id_pk
    on flow.process_step_work_queue_type (work_queue_type_id);

ALTER TABLE flow.process_step_work_queue_type_project_status_type
    DROP CONSTRAINT if exists flow_pswqtpst_project_status_type_id_fk;
-- dropping it so re-adding it doesn't throw an error
ALTER TABLE flow.process_step_work_queue_type_project_status_type
    DROP CONSTRAINT if exists flow_pswqtpst_company_project_status_type_id_fk;
ALTER TABLE flow.process_step_work_queue_type_project_status_type
    ADD CONSTRAINT flow_pswqtpst_company_project_status_type_id_fk FOREIGN KEY (company_project_status_type_id)
        REFERENCES flow.company_project_status_type (id) MATCH SIMPLE
        ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table flow.process_step_work_queue_type_project_status_type
rename column project_status_type_id to company_project_status_type_id;
