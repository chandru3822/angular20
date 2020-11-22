CREATE TABLE if not exists flow.postal_code_zone_user_type
(
    id                       serial  NOT NULL,
    user_type       varchar(100) NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_postal_code_zone_user_type_pk PRIMARY KEY (id)
);
alter table flow.postal_code_zone_user
    add column if not exists postal_code_zone_user_type_id int references flow.postal_code_zone_user_type;

insert into flow.postal_code_zone_user_type(user_type)
select 'SCHEDULE_TO' WHERE NOT EXISTS(select id from flow.postal_code_zone_user_type where user_type = 'SCHEDULE_TO');
insert into flow.postal_code_zone_user_type(user_type)
select 'SCHEDULE_BY' WHERE NOT EXISTS(select id from flow.postal_code_zone_user_type where user_type = 'SCHEDULE_BY');
