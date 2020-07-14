alter table if exists flow.process_step_requirement
add if not exists custom_field_process_step_id int;

alter table if exists flow.process_step_requirement
drop constraint if exists psr_custom_field_process_step_id;

alter table if exists flow.process_step_requirement
add constraint psr_custom_field_process_step_id foreign key (custom_field_process_step_id) references flow.process_step;