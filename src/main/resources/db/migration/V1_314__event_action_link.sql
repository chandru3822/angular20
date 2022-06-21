-- auto-generated definition
create table if not exists flow.process_step_event_action_link
(
  id                     serial
    constraint process_step_event_action_link_pk
      primary key,
  process_step_event_action_id integer                 not null
    constraint pseal_process_step_event_action_id_fk
      references flow.process_step_event_action,
  link_id                integer                 not null
    constraint pseal_link_id_fk
      references flow.link,
  archived               boolean   default false not null,
  created_by_id          integer
    constraint pseal_created_by_id_fk
      references flow."user",
  date_created           timestamp default now(),
  modified_by_id         integer
    constraint pseal_modified_by_id_fk
      references flow."user",
  date_modified          timestamp default now()
);

create index if not exists pseal_link_id_idx
  on flow.process_step_event_action_link (link_id);

create index if not exists pseal_process_step_action_id_idx
  on flow.process_step_event_action_link (process_step_event_action_id);

