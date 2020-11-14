alter table flow.position
add column if not exists contact_owner boolean not null default false;

update flow.position
set contact_owner = true
where id = 4;

drop table if exists flow.owner_position_id;
drop table if exists flow.owner_type;
