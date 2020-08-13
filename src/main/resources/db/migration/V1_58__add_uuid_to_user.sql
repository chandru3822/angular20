alter table flow."user"
add column if not exists uuid uuid;

alter table flow."user"
    add column if not exists expiry_date timestamp;
