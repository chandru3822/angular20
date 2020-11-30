alter table flow."user"
    add column if not exists login_attempts int default 0;
