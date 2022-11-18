alter table flow.custom_field_group_assignment
drop column if exists schedule_field_type_id;

alter table flow.custom_field_group
  drop column if exists event_type_id;

drop function if exists flow.get_user_based_on_event_type(p_project_id bigint,
                                                          p_event_type_id bigint);

drop table if exists flow.event_type;
