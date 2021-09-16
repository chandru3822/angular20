CREATE OR REPLACE function flow.migrate_insert_event_custom_field_value(p_event_id integer,
                                                                        p_cfga_id integer,
                                                                        p_timestamp timestamp,
                                                                        p_text text,
                                                                        p_int_array integer[],
                                                                        p_date_created timestamp,
                                                                        p_date_modified timestamp,
                                                                        p_created_by_id integer,
                                                                        p_modified_by_id integer,
                                                                        p_new_cfga_id boolean default false,
                                                                        p_event_type_id integer default null)
  returns void as
$$

BEGIN
  --raise notice 'p_event_id = %  p_project_process_step_id = % p_cfga_id = % p_event_type_id = %',p_event_id,p_project_process_step_id,p_cfga_id,p_event_type_id;
  insert into flow.project_process_step_event_custom_field_value(project_process_step_event_id,
                                                                 custom_field_group_assignment_id,
                                                                 timestamp_value,
                                                                 text_value,
                                                                 int_array_value,
                                                                 date_created,
                                                                 date_modified, created_by_id, modified_by_id)
  values (p_event_id,
          case
            when p_new_cfga_id is true and p_cfga_id is not null then
              (select cfga.id
               from flow.custom_field_group_assignment cfga
                      inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                      inner join flow.event e on e.id = cfg.event_id and e.id = p_event_type_id
               where migrated_cfga_id = p_cfga_id)
            else p_cfga_id end,
          p_timestamp,
          p_text,
          p_int_array,
          p_date_created,
          p_date_modified,
          p_created_by_id,
          p_modified_by_id);

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

