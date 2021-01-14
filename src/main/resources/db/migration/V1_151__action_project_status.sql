--allow an action to change the project status
alter table flow.process_step_action
add column if not exists company_project_status_type_id int references flow.company_project_status_type(id);

-- allow a project work queue type to choose the root level status
alter table flow.process_step_work_queue_type_project_status_type
add column if not exists project_status_type_id int references flow.project_status_type(id);

alter table flow.process_step_work_queue_type_project_status_type
    alter column company_project_status_type_id drop not null;

ALTER TABLE flow.process_step_work_queue_type_project_status_type
    DROP CONSTRAINT if exists null_company_and_root_project_status_check;

ALTER TABLE flow.process_step_work_queue_type_project_status_type
    ADD CONSTRAINT null_company_and_root_project_status_check
        CHECK (
                project_status_type_id is not null
                OR company_project_status_type_id is not null
            );

insert into flow.process_step_work_queue_type_project_status_type(company_project_status_type_id, project_status_type_id, process_step_work_queue_type_id, created_by_id)
    ( select null, 1, pswqt.id, 2350555
      from flow.process_step_work_queue_type pswqt
      where not exists (
              select *
              from flow.process_step_work_queue_type_project_status_type pswqtpst
              where pswqtpst.process_step_work_queue_type_id = pswqt.id
                and pswqtpst.archived is not true
          )
        and pswqt.archived is not true );
