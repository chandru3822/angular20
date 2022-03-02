create table if not exists flow.pps_event_process_step_event_work_queue_type_note
(
  id                                    serial,
  project_process_step_event_id         int not null
    constraint ppsewqtn_project_process_step_event_id_fk
      references flow.project_process_step_event (id),
  process_step_event_work_queue_type_id int not null
    constraint ppsewqtn_process_step_event_work_queue_type_id_fk
      references flow.process_step_event_work_queue_type (id),
  note_id                               int not null
    constraint ppsewqtn_note_id_fk
      references  flow.note (id)
);