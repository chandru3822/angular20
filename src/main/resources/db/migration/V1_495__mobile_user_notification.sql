alter table flow.user_notification_token
add column if not exists mobile boolean not null default false;