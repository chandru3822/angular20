alter table flow.company
add column if not exists banner_color varchar(20);
alter table flow.company
    add column if not exists primary_color varchar(20);
;
