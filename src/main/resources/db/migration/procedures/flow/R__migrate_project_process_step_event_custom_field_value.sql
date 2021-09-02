CREATE OR REPLACE function flow.migrate_project_process_step_event_custom_field_value(p_event_id integer,
                                                                                      p_group_id integer,
                                                                                      p_project_process_step_id integer,
                                                                                      p_cfga_id integer)
  returns void as
$$
  declare
  v_cfga_ids integer[];
BEGIN
  if p_group_id is not null then
    select array_agg(cfga.id)::integer[]
    into v_cfga_ids
    from flow.custom_field_group_assignment cfga
    where cfga.custom_field_group_id = p_group_id
    and cfga.archived is false and cfga.ancillary_custom_field_group_assignment_id is null;
  else
    select array_agg(cfga.id)::integer[]
    into v_cfga_ids
    from flow.custom_field_group_assignment cfga
    where cfga.id = p_cfga_id;
  end if;

  insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id,
                                                                 custom_field_group_assignment_id,
                                                                 date_value, timestamp_value, boolean_value,
                                                                 text_value,
                                                                 numeric_value, int_value, int_array_value,
                                                                 date_created,
                                                                 date_modified, created_by_id, modified_by_id,
                                                                 migrate_project_process_step_custom_field_value_id)
    (select p_event_id,
            ppscfv2.custom_field_group_assignment_id,
            ppscfv2.date_value,
            ppscfv2.timestamp_value,
            ppscfv2.boolean_value,
            ppscfv2.text_value,
            ppscfv2.numeric_value,
            ppscfv2.int_value,
            ppscfv2.int_array_value,
            ppscfv2.date_created,
            ppscfv2.date_modified,
            ppscfv2.created_by_id,
            ppscfv2.modified_by_id,
            ppscfv2.id
     from flow.project_process_step_custom_field_value ppscfv2
     where ppscfv2.custom_field_group_assignment_id = any (v_cfga_ids)
       and ppscfv2.project_process_step_id = p_project_process_step_id
    );

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

