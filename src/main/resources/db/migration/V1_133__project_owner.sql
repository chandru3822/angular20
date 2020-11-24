alter table flow.position
add column  if not exists project_owner boolean not null default false;

alter table flow.company
add column if not exists project_owner_readonly boolean not null default false;

update flow.company
set project_owner_readonly = true
where id > 1;
