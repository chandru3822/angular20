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
select 'Users by Organization', false  where not exists (select id from flow.system_list_type where system_list_type = 'Users by Organization');
insert into flow.system_list_type (system_list_type, archived)
select 'Users by Position', false  where not exists (select id from flow.system_list_type where system_list_type = 'Users by Position');
insert into flow.system_list_type (system_list_type, archived)
select 'Organizations by Type', false  where not exists (select id from flow.system_list_type where system_list_type = 'Organizations by Type');

insert into flow.company_system_list_type (system_list_type_id, company_id)
select 1, 1  where not exists (select id from flow.company_system_list_type where system_list_type_id = 1);
insert into flow.company_system_list_type (system_list_type_id, company_id)
select 2, 1  where not exists (select id from flow.company_system_list_type where system_list_type_id = 2);
insert into flow.company_system_list_type (system_list_type_id, company_id)
select 3, 1  where not exists (select id from flow.company_system_list_type where system_list_type_id = 3);

-- system data type
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 1, 8, false  where not exists (select id from flow.operator_data_type where operator_type_id = 1 and data_type_id = 8);
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 2, 8, false  where not exists (select id from flow.operator_data_type where operator_type_id = 2 and data_type_id = 8);

insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 8, 'null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 8 and data_type_value = 'null');
insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 8, 'not null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 8 and data_type_value = 'not null');

-- system list data type
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 1, 9, false  where not exists (select id from flow.operator_data_type where operator_type_id = 1 and data_type_id = 9);
insert into flow.operator_data_type (operator_type_id, data_type_id, archived)
select 2, 9, false  where not exists (select id from flow.operator_data_type where operator_type_id = 2 and data_type_id = 9);

insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 9, 'null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 9 and data_type_value = 'null');
insert into flow.data_type_requirement (data_type_id, data_type_value, created_by_id)
select 9, 'not null', 2350555  where not exists (select id from flow.data_type_requirement where data_type_id = 9 and data_type_value = 'not null');

