alter table flow.custom_field_group_assignment
add column if not exists data_view_child_field_config_id int references flow.data_view_child_field_config(id);

alter table flow.custom_field_group_assignment drop constraint if exists null_custom_ancillary_default_check;
alter table flow.custom_field_group_assignment
  add constraint null_custom_ancillary_default_check
    check ((custom_field_id IS NOT NULL)
      OR (ancillary_custom_field_group_assignment_id IS NOT NULL)
      OR (default_field_id IS NOT NULL)
      OR (data_view_field_config_id IS NOT NULL)
      OR (data_view_child_field_config_id IS NOT NULL)
      );


alter table flow.data_view_child_field_config alter column unique_behavior_type_id set not null;
