alter table flow.user_status_type add column if not exists date_created timestamp without time zone default now();
alter table flow.user_status_type add column if not exists date_modified   timestamp without time zone;
alter table flow.user_status_type add column if not exists created_by_id     integer;
alter table flow.user_status_type add column if not exists modified_by_id    integer;

-- set the created_by_id
update flow.user_status_type set created_by_id = 2350555 where id > 0;

-- add not null to created by id
alter table flow.user_status_type alter column created_by_id set not null;
