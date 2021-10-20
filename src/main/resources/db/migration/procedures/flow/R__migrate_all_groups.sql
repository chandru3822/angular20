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
  v_new_group_id_16_SC   integer;
  v_new_group_id_16_RPPD integer;
  v_new_group_id_13_D    integer;
  v_new_group_id_13_OC   integer;
  v_new_group_id_13_RS   integer;
  v_new_group_id_85_D    integer;
  v_new_group_id_85_OC   integer;
  v_new_group_id_85_RS   integer;
  v_new_group_id_3431_D  integer;
  v_new_group_id_3431_OC integer;
  v_new_group_id_3431_RS integer;
  v_new_group_id_129_OC  integer;
  v_new_group_id_129_D   integer;
  v_new_group_id_138_OC  integer;
  v_new_group_id_138_D   integer;
  v_new_group_id_146_OC  integer;
  v_new_group_id_146_D   integer;
  v_new_group_id_140_OC  integer;
  v_new_group_id_140_D   integer;
  v_new_group_id_144_OC  integer;
  v_new_group_id_144_D   integer;
  v_new_group_id_142_OC  integer;
  v_new_group_id_142_D   integer;
  v_new_group_id_148_OC  integer;
  v_new_group_id_148_D   integer;
  v_new_group_id_3414_OC integer;
  v_new_group_id_3414_D  integer;
  v_new_group_id_3362_OC integer;
  v_new_group_id_3362_D  integer;
  v_new_group_id_134_OC  integer;
  v_new_group_id_134_D   integer;
  v_new_group_id_28_OC   integer;
  v_new_group_id_28_D    integer;
  v_new_group_id_3487_OC integer;
  v_new_group_id_3487_D  integer;
  v_new_group_id_3409_OC integer;
  v_new_group_id_3409_D  integer;
  v_new_group_id_54_D    integer;
  v_new_group_id_54_RD   integer;
  v_new_group_id_54_OC   integer;
  v_new_group_id_54_NS   integer;
  v_new_group_id_2838_D  integer;
  v_new_group_id_2838_RD integer;
  v_new_group_id_2838_OC integer;
  v_new_group_id_2838_NS integer;
  v_new_group_id_2841_D  integer;
  v_new_group_id_2841_RD integer;
  v_new_group_id_2841_OC integer;
  v_new_group_id_2841_NS integer;
v_new_group_id_3091_D integer;
v_new_group_id_3480_D integer;
  v_new_group_id_3441_D integer;

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
    perform flow.migrate_fields_to_group(v_new_group_id_16_RPPD, 1371, 1);
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

  elsif p_process_step_id = 3431 then
    select id
    into v_new_group_id_3431_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3431_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3431_RS
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3431_D, 21529, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3431_D, 21523, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3431_OC, 21528, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3431_OC, 21530, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3431_RS, 21527, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3431_RS, 21525, 2);

  elsif p_process_step_id = 129 then
    select id
    into v_new_group_id_129_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_129_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_129_D, 21131, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_129_OC, 21132, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_129_OC, 21536, 2);

  elsif p_process_step_id = 138 then
    select id
    into v_new_group_id_138_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_138_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_138_D, 19088, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_138_D, 17500, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_138_D, 17323, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_138_D, 19514, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_138_OC, 547, 1);

  elsif p_process_step_id = 146 then
    select id
    into v_new_group_id_146_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_146_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_146_D, 19070, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_146_D, 17504, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_146_D, 17327, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_146_D, 19509, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_146_OC, 552, 1);

  elsif p_process_step_id = 140 then
    select id
    into v_new_group_id_140_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_140_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_140_D, 19086, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_140_D, 17501, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_140_D, 17324, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_140_D, 19512, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_140_OC, 549, 1);

  elsif p_process_step_id = 144 then
    select id
    into v_new_group_id_144_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_144_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_144_D, 19089, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_144_D, 17503, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_144_D, 17326, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_144_D, 19515, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_144_OC, 551, 1);

  elsif p_process_step_id = 142 then
    select id
    into v_new_group_id_142_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_142_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_142_D, 19090, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_142_D, 17502, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_142_D, 17325, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_142_D, 19516, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_142_OC, 550, 1);
  elsif p_process_step_id = 148 then
    select id
    into v_new_group_id_148_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_148_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_148_D, 19087, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_148_D, 17505, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_148_D, 17328, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_148_OC, 553, 1);

  elsif p_process_step_id = 3414 then
    select id
    into v_new_group_id_3414_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3414_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3414_D, 21222, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3414_D, 21223, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3414_D, 21227, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_3414_OC, 21224, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3414_OC, 21226, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3414_OC, 21225, 3);

  elsif p_process_step_id = 3362 then
    select id
    into v_new_group_id_3362_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3362_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3362_D, 19588, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3362_D, 19589, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3362_D, 19590, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3362_D, 19591, 4);


    perform flow.migrate_fields_to_group(v_new_group_id_3362_OC, 19594, 1);

  elsif p_process_step_id = 134 then
    select id
    into v_new_group_id_134_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_134_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_134_D, 19083, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_134_D, 17321, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_134_D, 19511, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_134_OC, 542, 1);

  elsif p_process_step_id = 28 then
    select id
    into v_new_group_id_28_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_28_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_28_D, 1234, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_28_D, 17309, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_28_D, 19431, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_28_D, 21310, 4);


    perform flow.migrate_fields_to_group(v_new_group_id_28_OC, 543, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_28_OC, 19433, 2);

  elsif p_process_step_id = 3487 then
    select id
    into v_new_group_id_3487_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3487_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3487_D, 22067, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_D, 22374, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_D, 22066, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22375, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22079, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22089, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22080, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22081, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22082, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_3487_OC, 22068, 7);

  elsif p_process_step_id = 3409 then
    select id
    into v_new_group_id_3409_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3409_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3409_D, 21107, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_D, 21106, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_D, 21108, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_D, 21288, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_D, 21109, 5);


    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21610, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21110, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21111, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21112, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21113, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21121, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21115, 7);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21116, 8);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21117, 9);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21118, 10);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21244, 11);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21119, 12);
    perform flow.migrate_fields_to_group(v_new_group_id_3409_OC, 21120, 13);

  elsif p_process_step_id = 54 then
    select id
    into v_new_group_id_54_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_54_RD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_54_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_54_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 19081, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 18773, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 1207, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 17256, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 17316, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 18771, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_54_D, 20960, 7);

    perform flow.migrate_fields_to_group(v_new_group_id_54_RD, 19190, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_54_RD, 19187, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_54_OC, 162, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_54_NS, 992, 1);

    update flow.custom_field_group
    set process_step_id = 54,
        group_order     = 3
    where id = 6217;
    update flow.custom_field_group
    set group_order = 4
    where id = 6888;

  elsif p_process_step_id = 2838 then
    select id
    into v_new_group_id_2838_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_2838_RD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_2838_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_2838_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 19082, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 18774, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 17466, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 17467, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 18772, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_D, 20961, 6);


    perform flow.migrate_fields_to_group(v_new_group_id_2838_RD, 19189, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_2838_RD, 17476, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_2838_OC, 17475, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_2838_NS, 17474, 1);

    update flow.custom_field_group
    set process_step_id = 2838,
        group_order     = 3
    where id = 6218;
    update flow.custom_field_group
    set group_order = 4
    where id = 6889;

  elsif p_process_step_id = 2841 then
    select id
    into v_new_group_id_2841_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_2841_RD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_2841_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_2841_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 20962, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 17495, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 17480, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 17481, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 17490, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_D, 20963, 6);


    perform flow.migrate_fields_to_group(v_new_group_id_2841_RD, 17488, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_2841_RD, 17489, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_2841_OC, 17487, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_2841_NS,19188 , 1);

    update flow.custom_field_group
    set process_step_id = 2841,
        group_order     = 3
    where id = 6219;
    update flow.custom_field_group
    set group_order = 4
    where id = 6890;
  elsif p_process_step_id = 3091 then
    select id
    into v_new_group_id_3091_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_3091_D,19018 , 1);
  elsif p_process_step_id = 3480 then
    select id
    into v_new_group_id_3480_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_3480_D,21951 , 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3480_D,21952 , 2);

  elsif p_process_step_id = 3441 then
    select id
    into v_new_group_id_3441_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_3441_D,21607 , 1);


  end if;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

