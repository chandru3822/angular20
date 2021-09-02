CREATE OR REPLACE function flow.migrate_all_groups(p_event_type_id integer, p_process_step_id integer)
  returns void as
$$
  declare
    v_new_group_id_5 integer;
BEGIN
  /*Schedule closer appointment*/
  if p_process_step_id = 1 then

    perform flow.migrate_group_to_event(2, p_event_type_id, 2);
    perform flow.migrate_group_to_event(396, p_event_type_id, 1);
    perform flow.migrate_group_to_event(6670, p_event_type_id, 3);

    perform flow.migrate_fields_to_group(2, 19033, 7);
  elsif p_process_step_id = 5 then
    select id
    into v_new_group_id_5
    from flow.custom_field_group cfg
    where cfg.group_name = 'Closeout Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_group_to_event(156, p_event_type_id, 1);
    perform flow.migrate_group_to_event(6152, p_event_type_id, 2);
    perform flow.migrate_group_to_event(6817, p_event_type_id, 4);
    perform flow.migrate_group_to_event(6283, p_event_type_id, 5);

    perform flow.migrate_fields_to_group(v_new_group_id_5,20,1);
    perform flow.migrate_fields_to_group(v_new_group_id_5,19137,2);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21533,3);
    perform flow.migrate_fields_to_group(v_new_group_id_5,19360,4);
    perform flow.migrate_fields_to_group(v_new_group_id_5,19363,5);
    perform flow.migrate_fields_to_group(v_new_group_id_5,19364,6);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21122,7);
    perform flow.migrate_fields_to_group(v_new_group_id_5,20859,8);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21201,9);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21202,10);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21205,11);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21203,12);
    perform flow.migrate_fields_to_group(v_new_group_id_5,21204,13);

  end if;
END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

