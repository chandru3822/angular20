alter table flow.user_company
add column  if not exists full_calendar_access boolean not null default false;

alter table flow.user_company
  add column  if not exists modified_by_id bigint references flow.user(id);
