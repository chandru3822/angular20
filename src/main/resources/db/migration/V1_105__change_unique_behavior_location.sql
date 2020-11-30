alter table flow.custom_field_group
    add column if not exists unique_behavior_type_id int references flow.unique_behavior_type(id);

update flow.custom_field_group
    set unique_behavior_type_id = 1
where process_step_id = 1
  and archived is not true
  and event_type_id = 1
;



alter table flow.process_step
    drop column if exists unique_behavior_type_id;
