alter table flow.company_data_type
    add column if not exists allow_multiple boolean not null default false;

update flow.company_data_type
set allow_multiple = true
where data_type_id = 7 and has_list_values is true;

alter table flow.process_step_requirement
    add column if not exists list_of_value_id integer references flow.list_of_value(id);

alter table flow.process_step_requirement
    add column if not exists list_of_value_ids integer[];
