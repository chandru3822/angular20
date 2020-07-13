alter table if exists flow.custom_field_group_assignment
add if not exists ancillary_process_step_id int;

alter table if exists flow.custom_field_group_assignment
drop constraint if exists cfga_ancillary_process_step_id_fk;

alter table if exists flow.custom_field_group_assignment
add constraint cfga_ancillary_process_step_id_fk foreign key (ancillary_process_step_id) references flow.process_step;w