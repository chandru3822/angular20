CREATE OR REPLACE function flow.migrate_all_groups(p_event_type_id integer, p_process_step_id integer)
  returns void as
$$
declare
  v_new_group_id_5       integer;
  v_new_group_id_98_RSS  integer;
  v_new_group_id_98_NS   integer;
  v_new_group_id_168_RI  integer;
  v_new_group_id_168_NS  integer;
  v_new_group_id_168_IO  integer;
  v_new_group_id_153_RI  integer;
  v_new_group_id_3365_SD integer;
  v_new_group_id_3365_IO integer;
  v_new_group_id_3365_NS integer;
v_new_group_id_16_SC     integer;
v_new_group_id_16_RPPD  integer;
v_new_group_id_13_D integer;
v_new_group_id_13_OC integer;
v_new_group_id_13_RS integer;
  v_new_group_id_85_D integer;
  v_new_group_id_85_OC integer;
  v_new_group_id_85_RS integer;

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

    perform flow.migrate_fields_to_group(v_new_group_id_5, 20, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 19137, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21533, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 19360, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 19363, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 19364, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21122, 7);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 20859, 8);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21201, 9);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21202, 10);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21205, 11);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21203, 12);
    perform flow.migrate_fields_to_group(v_new_group_id_5, 21204, 13);

  elsif p_process_step_id = 98 then

    select id
    into v_new_group_id_98_RSS
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Site Survey'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_98_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_group_to_event(308, p_event_type_id, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_98_RSS, 1353, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_98_RSS, 1072, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_98_NS, 1006, 1);
    insert into brs.project_details_config(company_id, custom_field_group_assignment_id,
                                           field_to_update, data_type_id, display_name,
                                           second_field_to_update, second_data_type_id,
                                           update_first_value_only, update_first_value_only_id)
      (select company_id,
              (select id from flow.custom_field_group_assignment where migrated_cfga_id = 21122),
              field_to_update,
              data_type_id,
              display_name,
              second_field_to_update,
              second_data_type_id,
              update_first_value_only,
              update_first_value_only_id
       from brs.project_details_config
       where company_id = 3
         and custom_field_group_assignment_id = 21122);
  elsif p_process_step_id = 168 then

    select id
    into v_new_group_id_168_IO
    from flow.custom_field_group cfg
    where cfg.group_name = 'Inspection Outcome'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_168_RI
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Inspection'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_168_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_group_to_event(335, p_event_type_id, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_168_IO, 153, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_168_IO, 152, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_168_RI, 19027, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_168_RI, 19028, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_168_RI, 21609, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_168_NS, 998, 1);

  elsif p_process_step_id = 40 then

    perform flow.migrate_group_to_event(334, p_event_type_id, 1);
    insert into brs.project_details_config(company_id, custom_field_group_assignment_id,
                                           field_to_update, data_type_id, display_name,
                                           second_field_to_update, second_data_type_id,
                                           update_first_value_only, update_first_value_only_id)
      (select company_id,
              (select cfga.id
               from flow.custom_field_group_assignment cfga
                      inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                      inner join flow.event e on e.id = cfg.event_id and e.temp_cfg_id = 57
               where migrated_cfga_id = 152),
              field_to_update,
              data_type_id,
              display_name,
              second_field_to_update,
              second_data_type_id,
              update_first_value_only,
              update_first_value_only_id
       from brs.project_details_config
       where company_id = 3
         and custom_field_group_assignment_id = 152);

  elsif p_process_step_id = 153 then
    select id
    into v_new_group_id_153_RI
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Inspection'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_group_to_event(338, p_event_type_id, 1);


    insert into brs.project_details_config(company_id, custom_field_group_assignment_id,
                                           field_to_update, data_type_id, display_name,
                                           second_field_to_update, second_data_type_id,
                                           update_first_value_only, update_first_value_only_id)
      (select company_id,
              (select cfga.id
               from flow.custom_field_group_assignment cfga
                      inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                      inner join flow.event e on e.id = cfg.event_id and e.temp_cfg_id = 5644
               where migrated_cfga_id = 152),
              field_to_update,
              data_type_id,
              display_name,
              second_field_to_update,
              second_data_type_id,
              update_first_value_only,
              update_first_value_only_id
       from brs.project_details_config
       where company_id = 3
         and custom_field_group_assignment_id = 152);
  elsif p_process_step_id = 3365 then
    select id
    into v_new_group_id_3365_SD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3365_IO
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3365_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3365_SD, 19661, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_SD, 19662, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_SD, 21015, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_SD, 19667, 4);

    perform flow.migrate_group_to_event(6347, p_event_type_id, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_IO, 20994, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_IO, 21504, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3365_IO, 22019, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_3365_NS, 19681, 1);

  elsif p_process_step_id = 3383 then
    perform flow.migrate_group_to_event(6360, p_event_type_id, 1);
    perform flow.migrate_group_to_event(6660, p_event_type_id, 2);
  elsif p_process_step_id = 16 then
    perform flow.migrate_group_to_event(6174, p_event_type_id, 1);
    select id
    into v_new_group_id_16_SC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Scheduling Complete'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_16_SC, 1279, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_16_SC, 17311, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_16_SC, 18958, 4);

    perform flow.migrate_group_to_event(75, p_event_type_id, 2);
    perform flow.migrate_group_to_event(6971, p_event_type_id, 3);
    select id
    into v_new_group_id_16_RPPD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Permit Pickup/Delivery'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_16_RPPD, 21984, 0);
  elsif p_process_step_id = 13 then
    select id
    into v_new_group_id_13_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_13_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_13_RS
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 19085, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 19107, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 19108, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 1268, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 100, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 101, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 103, 7);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 22000, 8);
    perform flow.migrate_fields_to_group(v_new_group_id_13_D, 22001, 9);

    perform flow.migrate_fields_to_group(v_new_group_id_13_OC, 18956, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_13_OC, 104, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_13_OC, 1019, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_13_RS, 21983, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_13_RS, 1355, 2);

  elsif p_process_step_id = 85 then
    select id
    into v_new_group_id_85_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_85_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_85_RS
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_85_D, 1327, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_85_D, 17319, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_85_D, 1291, 0);
    perform flow.migrate_fields_to_group(v_new_group_id_85_D, 19325, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_85_OC, 478, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_85_OC, 989, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_85_OC, 1002, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_85_RS, 1416, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_85_RS, 1417, 2);



  end if;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

