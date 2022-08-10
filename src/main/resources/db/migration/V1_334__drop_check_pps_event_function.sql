alter table flow.object_type
add column if not exists smartlist boolean not null default false;

update flow.object_type
  set smartlist = true
where object_code != 'ATTACHMENTS';
