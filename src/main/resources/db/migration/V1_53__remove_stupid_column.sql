alter table if exists flow.custom_field_group_assignment drop constraint if exists cfga_ancillary_process_step_id_fk;

alter table if exists flow.custom_field_group_assignment drop column if exists ancillary_process_step_id;