alter table flow.data_type
add column if not exists system_list boolean not null default false;

insert into flow.data_type(data_type, custom_behavior, system_list)
select 'System List', false, true where not exists (select id from flow.data_type where data_type = 'System List');

insert into flow.company_data_type(company_id, company_data_type, data_type_id)
select 1, 'System List', 9 where not exists (select id from flow.company_data_type where company_data_type = 'System List');

CREATE TABLE if not exists flow.system_list_type
(
    id             serial  NOT NULL,
    system_list_type  character varying(50) NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_system_list_type_pk PRIMARY KEY (id)
);

CREATE TABLE if not exists flow.company_system_list_type
(
    id             serial  NOT NULL,
    system_list_type_id  integer NOT NULL,
    company_id  integer               NOT NULL,
    archived       boolean not null default false,
    CONSTRAINT flow_company_system_list_type_pk PRIMARY KEY (id),
    CONSTRAINT cslt_company_id FOREIGN KEY (company_id)
        REFERENCES flow.company (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT cslt_system_list_type_id FOREIGN KEY (system_list_type_id)
        REFERENCES flow.system_list_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION ON DELETE NO ACTION
);

alter table flow.custom_field
add column if not exists system_list_type_id integer references flow.system_list_type(id);

alter table flow.custom_field
    add column if not exists system_list_option_ids integer[];

alter table flow.process_step_requirement
    add column if not exists system_list_option_id integer;

alter table flow.process_step_requirement
    add column if not exists custom_sql_option_id integer;


-- todo: make these work for uat where they already exist
insert into flow.system_list_type (system_list_type, archived)
values ('Users by Organization', false), ( 'Users by Position', false), ('Organizations by Type', false), ('User', false);

insert into flow.company_system_list_type(system_list_type_id, company_id)
 values (1, 1),(2, 1),(3, 1);

-- system data type
insert into flow.operator_data_type(operator_type_id, data_type_id, archived)
values (1, 8, false), (2, 8, false);

insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
values (8, 'null', 2350555), (8, 'not null', 2350555);

-- system list data type
insert into flow.operator_data_type(operator_type_id, data_type_id, archived)
values (1, 9, false), (2, 9, false);

insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
values (9, 'null', 2350555), (9, 'not null', 2350555);

