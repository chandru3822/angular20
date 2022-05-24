alter table flow.process_step_action
  add column if not exists bg_color varchar(10);

alter table flow.process_step_event_action
  add column if not exists bg_color varchar(10);
