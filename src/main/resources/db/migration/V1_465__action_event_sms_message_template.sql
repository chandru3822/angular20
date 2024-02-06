create table if not exists flow.process_step_event_action_message_template
(
  id                           bigserial
    constraint process_step_event_action_message_template_pk
      primary key,
  process_step_event_action_id bigint                 not null
    constraint pseamt_process_step_event_action_id_fk
      references flow.process_step_event_action
      on update restrict on delete restrict,
  message_template_id          bigint                 not null
    constraint pseamt_message_template_id_fk
      references flow.message_template
      on update restrict on delete restrict,
  sms_team_ids                 bigint[]                not null,
  date_created                 timestamp default now(),
  date_modified                timestamp,
  created_by_id                bigint                 not null
    constraint pseamt_event_action_created_by_id_fk
      references flow."user",
  modified_by_id               bigint
    constraint pseamt_event_action_modified_by_id_fk
      references flow."user",
  archived                     boolean   default false not null
);

create index pseamt_message_template_id_idx
  on flow.process_step_event_action_message_template (message_template_id);

create index pseamt_process_step_event_action_id_idx
  on flow.process_step_event_action_message_template (process_step_event_action_id);

