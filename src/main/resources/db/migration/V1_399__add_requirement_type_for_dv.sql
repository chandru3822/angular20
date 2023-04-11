insert into flow.process_step_requirement_type(process_step_requirement_type, archived, use_by_event, use_by_process_step, display_order)
select 'Data View Field', false, true, true, 12
where not exists (select id from flow.process_step_requirement_type where process_step_requirement_type = 'Data View Field');

alter table flow.process_step_requirement
add column if not exists data_view_field_config_id int references flow.data_view_field_config(id);

alter table flow.process_step_requirement
  add column if not exists data_view_child_field_config_id int references flow.data_view_child_field_config(id);

create index if not exists psr_company_function_id_idx
  on flow.process_step_requirement (company_function_id);

create index if not exists psr_requirement_nbr_idx
  on flow.process_step_requirement (requirement_nbr);

create index if not exists psr_lov_id_idx
  on flow.process_step_requirement (list_of_value_id);

create index if not exists psr_dvfc_id_idx
  on flow.process_step_requirement (data_view_field_config_id);

create index if not exists psr_dvcfc_id_idx
  on flow.process_step_requirement (data_view_child_field_config_id);

alter table flow.process_step_event_requirement
  add column if not exists data_view_field_config_id int references flow.data_view_field_config(id);

alter table flow.process_step_event_requirement
  add column if not exists data_view_child_field_config_id int references flow.data_view_child_field_config(id);

create index if not exists pser_dvfc_id_idx
  on flow.process_step_event_requirement (data_view_field_config_id);

create index if not exists pser_dvcfc_id_idx
  on flow.process_step_event_requirement (data_view_child_field_config_id);

