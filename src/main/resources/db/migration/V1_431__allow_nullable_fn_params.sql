-- used to dynamically filter custom fields on the proposal screen

alter table flow.db_function_param
  add column if not exists nullable boolean not null default false;
