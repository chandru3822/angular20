CREATE OR REPLACE FUNCTION flow.process_work_queue_cycle_events(p_project_process_step_event_id integer,
                                                                p_company_event_status_id integer,
                                                                p_event_status_type_id integer,
                                                                p_old_company_process_step_status_type_id integer,
                                                                p_old_process_step_status_type_id integer,
                                                                p_new_company_process_step_status_type_id integer,
                                                                p_new_process_step_status_type_id integer,
                                                                p_old_company_project_status_type_id integer,
                                                                p_old_project_status_type_id integer,
                                                                p_new_company_project_status_type_id integer,
                                                                p_new_project_status_type_id integer,
                                                                p_process_step_event_id integer,
                                                                p_modified_by_id integer)
  RETURNS void AS
$BODY$
declare

BEGIN
  update flow.work_queue_cycle wqc
  set date_exited_queue = now(),
      modified_by_id    = p_modified_by_id
  where wqc.project_process_step_event_id = p_project_process_step_event_id
    and wqc.company_event_status_type_id = p_company_event_status_id
    and wqc.process_step_event_work_queue_type_event_status_type_id in
        (select event.process_step_event_work_queue_type_event_status_type_id
         from flow.get_event_work_queue_type_configs(p_process_step_event_id) event
         where ((p_company_event_status_id = event.company_event_status_type_id or
                 p_event_status_type_id = event.event_status_type_id) and
                (p_old_company_process_step_status_type_id = event.company_process_status_type_id or
                 p_old_process_step_status_type_id = event.process_step_status_type_id) and
                (p_old_company_project_status_type_id = event.company_project_status_type_id or
                 p_old_project_status_type_id = event.project_status_type_id)))
    and wqc.date_exited_queue is null;

  insert into flow.work_queue_cycle(project_process_step_event_id,
                                    company_event_status_type_id,
                                    process_step_event_work_queue_type_event_status_type_id,
                                    date_entered_queue,
                                    created_by_id)
    (select p_project_process_step_event_id,
            p_company_event_status_id,
            event.process_step_event_work_queue_type_event_status_type_id,
            now(),
            p_modified_by_id
     from flow.get_event_work_queue_type_configs(p_process_step_event_id) event
     where ((p_company_event_status_id = event.company_event_status_type_id or
             p_event_status_type_id = event.event_status_type_id) and
            (p_new_company_process_step_status_type_id = event.company_process_status_type_id or
             p_new_process_step_status_type_id = event.process_step_status_type_id) and
            (p_new_company_project_status_type_id = event.company_project_status_type_id or
             p_new_project_status_type_id = event.project_status_type_id)))
  on conflict (project_process_step_event_id, company_event_status_type_id,
    process_step_event_work_queue_type_event_status_type_id)
  where ((date_exited_queue IS NULL) AND (project_process_step_event_id IS NOT NULL) AND
         (company_event_status_type_id IS NOT NULL) AND
         (process_step_event_work_queue_type_event_status_type_id IS NOT NULL)) do nothing;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

