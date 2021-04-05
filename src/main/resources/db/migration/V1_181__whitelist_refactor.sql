-- for when i forget to reset the table name and flyway dies
-- alter table flow.white_listed_position
--     rename to custom_field_group_assignment_white_listed_position;

CREATE TABLE if not exists flow.white_list_type
(
    id                       serial  NOT NULL,
    white_list_type       varchar(100) NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_white_list_type_pk PRIMARY KEY (id)
);

insert into flow.white_list_type (white_list_type)
select 'CFGA_READ_ONLY' WHERE not exists( select id from flow.white_list_type where white_list_type = 'CFGA_READ_ONLY');

insert into flow.white_list_type (white_list_type)
select 'CFGA_HIDDEN' WHERE not exists( select id from flow.white_list_type where white_list_type = 'CFGA_HIDDEN');

insert into flow.white_list_type (white_list_type)
select 'PROJECT_STATUS_READ_ONLY' WHERE not exists( select id from flow.white_list_type where white_list_type = 'PROJECT_STATUS_READ_ONLY');

insert into flow.white_list_type (white_list_type)
select 'PROJECT_OWNER_READ_ONLY' WHERE not exists( select id from flow.white_list_type where white_list_type = 'PROJECT_OWNER_READ_ONLY');

insert into flow.white_list_type (white_list_type)
select 'CONTACT_OWNER_READ_ONLY' WHERE not exists( select id from flow.white_list_type where white_list_type = 'CONTACT_OWNER_READ_ONLY');

ALTER TABLE flow.custom_field_group_assignment_white_listed_position
add column white_list_type_id integer references flow.white_list_type(id);

ALTER TABLE flow.custom_field_group_assignment_white_listed_position
    add column company_id integer references flow.company(id);

alter table flow.custom_field_group_assignment_white_listed_position alter column custom_field_group_assignment_id drop not null;

update flow.custom_field_group_assignment_white_listed_position
    set white_list_type_id = 1;

alter table flow.custom_field_group_assignment_white_listed_position alter column white_list_type_id set not null;

alter table flow.custom_field_group_assignment_white_listed_position
rename to white_listed_position;

alter table flow.custom_field_group_assignment
add column if not exists hidden boolean not null default false;


alter table flow.company_object_type
    add column if not exists  date_created timestamp without time zone DEFAULT now() not null;
alter table flow.company_object_type
    add column if not exists  date_modified timestamp without time zone;
alter table flow.company_object_type
    add column if not exists  created_by_id int references flow."user"(id);
alter table flow.company_object_type
    add column if not exists modified_by_id int references flow."user"(id);
alter table flow.company_object_type
    add column if not exists status_read_only boolean not null default false;
alter table flow.company_object_type
    add column if not exists owner_read_only boolean not null default false;

alter table flow.company
drop column if exists project_owner_readonly;
