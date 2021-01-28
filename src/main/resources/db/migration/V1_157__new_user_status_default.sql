alter table flow.user_status_type
add column if not exists new_user_default boolean not null default false;

update flow.user_status_type
set new_user_default = true
where user_status_type = 'New Request';

