alter table flow.user
    add column if not exists notification_type_id integer default 1;
