alter table flow.app_attachment
    add column if not exists version_number varchar(20);
alter table flow.app_attachment
    add column if not exists build_number int;
alter table flow.app_attachment
    add column if not exists display_name varchar(100);

