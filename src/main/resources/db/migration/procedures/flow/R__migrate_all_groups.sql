CREATE OR REPLACE function flow.migrate_all_groups(p_event_type_id integer, p_process_step_id integer)
  returns void as
$$
declare
  v_new_group_id_5         integer;
  v_new_group_id_98_RSS    integer;
  v_new_group_id_98_NS     integer;
  v_new_group_id_168_RI    integer;
  v_new_group_id_168_NS    integer;
  v_new_group_id_168_IO    integer;
  v_new_group_id_153_RI    integer;
  v_new_group_id_3365_SD   integer;
  v_new_group_id_3365_IO   integer;
  v_new_group_id_3365_NS   integer;
  v_new_group_id_16_SC     integer;
  v_new_group_id_16_RPPD   integer;
  v_new_group_id_13_D      integer;
  v_new_group_id_13_OC     integer;
  v_new_group_id_13_RS     integer;
  v_new_group_id_85_D      integer;
  v_new_group_id_85_OC     integer;
  v_new_group_id_85_RS     integer;
  v_new_group_id_3431_D    integer;
  v_new_group_id_3431_OC   integer;
  v_new_group_id_3431_RS   integer;
  v_new_group_id_129_OC    integer;
  v_new_group_id_129_D     integer;
  v_new_group_id_138_OC    integer;
  v_new_group_id_138_D     integer;
  v_new_group_id_146_OC    integer;
  v_new_group_id_146_D     integer;
  v_new_group_id_140_OC    integer;
  v_new_group_id_140_D     integer;
  v_new_group_id_144_OC    integer;
  v_new_group_id_144_D     integer;
  v_new_group_id_142_OC    integer;
  v_new_group_id_142_D     integer;
  v_new_group_id_148_OC    integer;
  v_new_group_id_148_D     integer;
  v_new_group_id_3414_OC   integer;
  v_new_group_id_3414_D    integer;
  v_new_group_id_3362_OC   integer;
  v_new_group_id_3362_D    integer;
  v_new_group_id_134_OC    integer;
  v_new_group_id_134_D     integer;
  v_new_group_id_28_OC     integer;
  v_new_group_id_28_D      integer;
  v_new_group_id_3487_OC   integer;
  v_new_group_id_3487_D    integer;
  v_new_group_id_3409_OC   integer;
  v_new_group_id_3409_D    integer;
  v_new_group_id_54_D      integer;
  v_new_group_id_54_RD     integer;
  v_new_group_id_54_OC     integer;
  v_new_group_id_54_NS     integer;
  v_new_group_id_2838_D    integer;
  v_new_group_id_2838_RD   integer;
  v_new_group_id_2838_OC   integer;
  v_new_group_id_2838_NS   integer;
  v_new_group_id_2841_D    integer;
  v_new_group_id_2841_RD   integer;
  v_new_group_id_2841_OC   integer;
  v_new_group_id_2841_NS   integer;
  v_new_group_id_3091_D    integer;
  v_new_group_id_3480_D    integer;
  v_new_group_id_3441_D    integer;
  v_new_group_id_165_D     integer;
  v_new_group_id_165_RD    integer;
  v_new_group_id_165_OC    integer;
  v_new_group_id_66_D      integer;
  v_new_group_id_66_OC     integer;
  v_new_group_id_3107_D    integer;
  v_new_group_id_3107_OC   integer;
  v_new_group_id_192_D     integer;
  v_new_group_id_192_OC    integer;
  v_new_group_id_192_R     integer;
  v_new_group_id_3103_D    integer;
  v_new_group_id_3103_OC   integer;
  v_new_group_id_3103_R    integer;
  v_new_group_id_3099_D    integer;
  v_new_group_id_3099_OC   integer;
  v_new_group_id_3099_R    integer;
  v_new_group_id_196_D     integer;
  v_new_group_id_196_OC    integer;
  v_new_group_id_196_R     integer;
  v_new_group_id_3359_D    integer;
  v_new_group_id_3359_OC   integer;
  v_new_group_id_3359_NS   integer;
  v_new_group_id_3360_D    integer;
  v_new_group_id_3360_OC   integer;
  v_new_group_id_3360_NS   integer;
  v_new_group_id_44_D      integer;
  v_new_group_id_44_OC     integer;
  v_new_group_id_44_NS     integer;
  v_new_group_id_44_R      integer;
  v_new_group_id_3479_D    integer;
  v_new_group_id_3479_OC   integer;
  v_new_group_id_3479_NS   integer;
  v_new_group_id_3479_R    integer;
  v_new_group_id_222_D     integer;
  v_new_group_id_222_OC    integer;
  v_new_group_id_172_D     integer;
  v_new_group_id_172_OC    integer;
  v_new_group_id_172_R     integer;
  v_new_group_id_3427_D    integer;
  v_new_group_id_3427_SAHJ integer;
  v_new_group_id_3427_OC   integer;
  v_new_group_id_3427_NS   integer;
  v_new_group_id_3427_R    integer;
  v_new_group_id_3427_ID   integer;
  v_new_group_id_3428_D    integer;
  v_new_group_id_3428_OC   integer;
  v_new_group_id_3428_NS   integer;
  v_new_group_id_3428_R    integer;
  v_new_group_id_3397_D    integer;
  v_new_group_id_3397_MDM  integer;
  v_new_group_id_3397_IF   integer;
  v_new_group_id_3397_OC   integer;
  v_new_group_id_3478_CWO  integer;
  v_new_group_id_3478_CWD  integer;
  v_new_group_id_3395_OS   integer;
  v_new_group_id_3395_O    integer;
  v_new_group_id_3399_D    integer;
  v_new_group_id_3399_O    integer;
  v_new_group_id_3471_D    integer;
  v_new_group_id_3471_O    integer;
  v_new_group_id_3471_R    integer;
  v_new_group_id_3459_D    integer;
  v_new_group_id_3459_A    integer;
  v_new_group_id_3459_O    integer;
  v_new_group_id_3459_R    integer;
  v_new_group_id_3470_D    integer;
  v_new_group_id_3470_A    integer;
  v_new_group_id_3470_O    integer;
  v_new_group_id_3470_R    integer;
  v_new_group_id_3473_D    integer;
  v_new_group_id_3473_O    integer;
  v_new_group_id_3473_R    integer;
  v_new_group_id_3472_D    integer;
  v_new_group_id_3472_O    integer;
  v_new_group_id_3472_R    integer;
  v_new_group_id_3474_D    integer;
  v_new_group_id_3474_O    integer;
  v_new_group_id_3474_R    integer;
  v_new_group_id_3391_O    integer;
  v_new_group_id_170_D     integer;
  v_new_group_id_170_SAHJ  integer;
  v_new_group_id_170_O     integer;
  v_new_group_id_170_R     integer;
  v_new_group_id_170_NS    integer;
  v_new_group_id_25_D      integer;
  v_new_group_id_25_O      integer;
  v_new_group_id_25_R      integer;
  v_new_group_id_25_NS     integer;


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
    perform flow.migrate_group_to_event(6656, p_event_type_id, 4);
    perform flow.migrate_group_to_event(6662, p_event_type_id, 5);
    perform flow.migrate_group_to_event(6664, p_event_type_id, 6);
    perform flow.migrate_group_to_event(7056, p_event_type_id, 7);
    perform flow.migrate_group_to_event(6348, p_event_type_id, 8);
    perform flow.migrate_group_to_event(6654, p_event_type_id, 9);
    perform flow.migrate_group_to_event(6358, p_event_type_id, 10);
    perform flow.migrate_group_to_event(6655, p_event_type_id, 11);
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

    perform flow.migrate_fields_to_group(v_new_group_id_2841_NS, 19188, 1);

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
    perform flow.migrate_fields_to_group(v_new_group_id_3091_D, 19018, 1);
  elsif p_process_step_id = 3480 then
    select id
    into v_new_group_id_3480_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_3480_D, 21951, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3480_D, 21952, 2);

  elsif p_process_step_id = 3441 then
    select id
    into v_new_group_id_3441_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    perform flow.migrate_fields_to_group(v_new_group_id_3441_D, 21607, 1);

  elsif p_process_step_id = 165 then
    select id
    into v_new_group_id_165_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;
    select id
    into v_new_group_id_165_RD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_165_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_165_D, 1197, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_165_D, 1201, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_165_D, 1318, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_165_D, 17330, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_165_OC, 641, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_165_OC, 642, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_165_RD, 1394, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_165_RD, 1395, 2);

  elsif p_process_step_id = 66 then
    select id
    into v_new_group_id_66_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_66_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_66_D, 19084, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_66_D, 19104, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_66_D, 1174, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_66_D, 17312, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_66_OC, 134, 1);


  elsif p_process_step_id = 3107 then
    select id
    into v_new_group_id_3107_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3107_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3107_D, 19275, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3107_D, 19271, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3107_D, 19270, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_3107_OC, 19280, 1);

  elsif p_process_step_id = 192 then
    select id
    into v_new_group_id_192_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_192_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_192_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 19072, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 1274, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 812, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 811, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 813, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 809, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 810, 7);
    perform flow.migrate_fields_to_group(v_new_group_id_192_D, 17334, 8);


    perform flow.migrate_fields_to_group(v_new_group_id_192_OC, 826, 1);
   -- perform flow.migrate_fields_to_group(v_new_group_id_192_OC, 18961, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_192_OC, 1364, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_192_R, 1366, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_192_R, 1367, 3);


  elsif p_process_step_id = 3103 then
    select id
    into v_new_group_id_3103_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3103_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3103_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3103_D, 19243, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3103_D, 19247, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3103_D, 19248, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_3103_OC, 19255, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3103_OC, 19256, 2);
   -- perform flow.migrate_fields_to_group(v_new_group_id_3103_OC, 19257, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3103_OC, 19258, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3103_R, 19253, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3103_R, 19254, 2);

  elsif p_process_step_id = 3099 then
    select id
    into v_new_group_id_3099_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3099_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3099_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19199, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19200, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19201, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19202, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19203, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19204, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 19205, 7);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 22450, 8);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_D, 22451, 9);


    perform flow.migrate_fields_to_group(v_new_group_id_3099_OC, 19224, 1);
   -- perform flow.migrate_fields_to_group(v_new_group_id_3099_OC, 19225, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_OC, 19226, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_OC, 22002, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3099_R, 19222, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3099_R, 19223, 2);

  elsif p_process_step_id = 196 then
    select id
    into v_new_group_id_196_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_196_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_196_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_196_D, 1284, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_196_D, 17335, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_196_D, 18966, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_196_OC, 838, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_196_OC, 839, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_196_OC, 1383, 3);
   -- perform flow.migrate_fields_to_group(v_new_group_id_196_OC, 18959, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_196_R, 1381, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_196_R, 1382, 2);

  elsif p_process_step_id = 3359 then
    select id
    into v_new_group_id_3359_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3359_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3359_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3359_D, 19748, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3359_D, 19565, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3359_D, 19596, 3);


    perform flow.migrate_fields_to_group(v_new_group_id_3359_OC, 19566, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3359_NS, 19567, 2);

  elsif p_process_step_id = 3360 then
    select id
    into v_new_group_id_3360_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3360_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3360_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3360_D, 19749, 1);


    perform flow.migrate_fields_to_group(v_new_group_id_3360_OC, 19574, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3360_OC, 19578, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3360_OC, 19577, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_3360_NS, 19575, 1);


  elsif p_process_step_id = 44 then
    select id
    into v_new_group_id_44_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_44_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_44_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_44_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_44_D, 19071, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_44_D, 1325, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_44_D, 17318, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_44_OC, 1000, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_44_OC, 17536, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_44_R, 1413, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_44_R, 1414, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_44_NS, 1001, 1);

  elsif p_process_step_id = 3479 then
    select id
    into v_new_group_id_3479_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3479_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3479_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3479_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3479_D, 21933, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3479_D, 21934, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3479_D, 21935, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3479_D, 21936, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3479_OC, 21937, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3479_NS, 21938, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3479_R, 21939, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3479_R, 21940, 1);


  elsif p_process_step_id = 222 then
    select id
    into v_new_group_id_222_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_222_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_222_D, 19077, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_222_D, 19078, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_222_D, 17336, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_222_OC, 1045, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_222_OC, 1046, 2);


  elsif p_process_step_id = 172 then
    select id
    into v_new_group_id_172_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_172_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_172_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_172_D, 19079, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_172_D, 17333, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_172_D, 18970, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_172_D, 1311, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_172_OC, 666, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_172_OC, 667, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_172_OC, 1376, 3);
   -- perform flow.migrate_fields_to_group(v_new_group_id_172_OC, 18968, 4);


    perform flow.migrate_fields_to_group(v_new_group_id_172_R, 1374, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_172_R, 1375, 2);

  elsif p_process_step_id = 3427 then
    select id
    into v_new_group_id_3427_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3427_SAHJ
    from flow.custom_field_group cfg
    where cfg.group_name = 'Schedule with AHJ'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3427_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3427_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3427_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3427_ID
    from flow.custom_field_group cfg
    where cfg.group_name = 'Inspection Disposition'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3427_D, 21401, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3427_D, 21402, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3427_D, 21400, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_3427_SAHJ, 21406, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3427_OC, 21410, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3427_NS, 21404, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3427_R, 21545, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3427_R, 21403, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3427_ID, 21412, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3427_ID, 21414, 4);

  elsif p_process_step_id = 3428 then
    select id
    into v_new_group_id_3428_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3428_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3428_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3428_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3428_D, 21438, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3428_D, 21437, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3428_OC, 21442, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3428_NS, 21443, 4);


    perform flow.migrate_fields_to_group(v_new_group_id_3428_R, 21507, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3428_R, 21508, 2);

  elsif p_process_step_id = 3397 then
    select id
    into v_new_group_id_3397_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3397_MDM
    from flow.custom_field_group cfg
    where cfg.group_name = 'Material Delivery Materials'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3397_IF
    from flow.custom_field_group cfg
    where cfg.group_name = 'Installer Feedback'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3397_OC
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3397_D, 20926, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_D, 20927, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_D, 20925, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_D, 20928, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20931, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20932, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20933, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20934, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20935, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, 20936, 6);
    -- perform flow.migrate_fields_to_group(v_new_group_id_3397_MDM, , 7);

    perform flow.migrate_fields_to_group(v_new_group_id_3397_IF, 20937, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3397_OC, 20940, 1);

  elsif p_process_step_id = 3478 then
    select id
    into v_new_group_id_3478_CWD
    from flow.custom_field_group cfg
    where cfg.group_name = 'Closeout Work Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3478_CWO
    from flow.custom_field_group cfg
    where cfg.group_name = 'Closeout Work Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3478_CWD, 21901, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3478_CWD, 21902, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3478_CWO, 21908, 1);

  elsif p_process_step_id = 3395 then
    select id
    into v_new_group_id_3395_OS
    from flow.custom_field_group cfg
    where cfg.group_name = 'Online Submission'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3395_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3395_OS, 20918, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3395_OS, 20917, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3395_O, 20919, 1);


  elsif p_process_step_id = 3399 then
    select id
    into v_new_group_id_3399_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3399_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3399_D, 21927, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3399_D, 21928, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3399_O, 20946, 1);

  elsif p_process_step_id = 3471 then
    select id
    into v_new_group_id_3471_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3471_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3471_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3471_D, 21787, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3471_D, 21788, 2);

    perform flow.migrate_fields_to_group(v_new_group_id_3471_O, 21792, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3471_R, 21789, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3471_R, 21790, 2);

  elsif p_process_step_id = 3459 then
    select id
    into v_new_group_id_3459_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3459_A
    from flow.custom_field_group cfg
    where cfg.group_name = 'Audit'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3459_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3459_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3459_D, 21721, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_D, 21722, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3459_A, 21729, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_A, 21730, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_A, 21731, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_A, 21732, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_A, 21733, 5);

    perform flow.migrate_fields_to_group(v_new_group_id_3459_O, 21725, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3459_R, 21726, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3459_R, 21727, 2);


  elsif p_process_step_id = 3470 then
    select id
    into v_new_group_id_3470_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3470_A
    from flow.custom_field_group cfg
    where cfg.group_name = 'Audit'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3470_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3470_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3470_D, 21772, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_D, 21773, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3470_A, 21774, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_A, 21775, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_A, 21777, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_A, 21778, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_A, 21776, 5);

    perform flow.migrate_fields_to_group(v_new_group_id_3470_O, 21779, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3470_R, 21780, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3470_R, 21781, 2);

  elsif p_process_step_id = 3473 then
    select id
    into v_new_group_id_3473_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3473_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3473_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3473_D, 21854, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3473_D, 21855, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3473_O, 21856, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3473_R, 21857, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3473_R, 21858, 2);


  elsif p_process_step_id = 3472 then
    select id
    into v_new_group_id_3472_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3472_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3472_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3472_D, 21838, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3472_D, 21839, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3472_O, 21840, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3472_R, 21841, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3472_R, 21842, 2);

  elsif p_process_step_id = 3474 then
    select id
    into v_new_group_id_3474_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_3474_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_3474_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    perform flow.migrate_fields_to_group(v_new_group_id_3474_D, 21871, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3474_D, 21872, 2);


    perform flow.migrate_fields_to_group(v_new_group_id_3474_O, 21870, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_3474_R, 21868, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3474_R, 21869, 2);


  elsif p_process_step_id = 3391 then


    select id
    into v_new_group_id_3391_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_3391_O, 20900, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_3391_O, 20901, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_3391_O, 20902, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_3391_O, 20903, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_3391_O, 21165, 5);


  elsif p_process_step_id = 170 then

    select id
    into v_new_group_id_170_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_170_SAHJ
    from flow.custom_field_group cfg
    where cfg.group_name = 'Schedule with AHJ'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_170_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_170_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_170_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_170_D, 1196, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_170_D, 1320, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_170_D, 17332, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_170_SAHJ, 19091, 4);

    perform flow.migrate_fields_to_group(v_new_group_id_170_O, 962, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_170_O, 965, 2);
   -- perform flow.migrate_fields_to_group(v_new_group_id_170_O, 1405, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_170_R, 1402, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_170_R, 1403, 3);

    perform flow.migrate_fields_to_group(v_new_group_id_170_NS, 19157, 5);

  elsif p_process_step_id = 25 then

    select id
    into v_new_group_id_25_D
    from flow.custom_field_group cfg
    where cfg.group_name = 'Details'
      and cfg.event_id = p_event_type_id;


    select id
    into v_new_group_id_25_O
    from flow.custom_field_group cfg
    where cfg.group_name = 'Outcome'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_25_R
    from flow.custom_field_group cfg
    where cfg.group_name = 'Reschedule'
      and cfg.event_id = p_event_type_id;

    select id
    into v_new_group_id_25_NS
    from flow.custom_field_group cfg
    where cfg.group_name = 'No-Show'
      and cfg.event_id = p_event_type_id;


    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 19080, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 657, 2);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 22452, 3);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 22453, 4);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 17310, 5);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 1306, 6);
    perform flow.migrate_fields_to_group(v_new_group_id_25_D, 18969, 7);

    perform flow.migrate_fields_to_group(v_new_group_id_25_O, 124, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_25_NS, 1363, 1);

    perform flow.migrate_fields_to_group(v_new_group_id_25_R, 1359, 1);
    perform flow.migrate_fields_to_group(v_new_group_id_25_R, 1360, 2);


    update flow.custom_field_group_assignment set custom_field_id = 9919
    where id = 657;

    with update_data as (
      select date_value,id
      from flow.project_process_step_event_custom_field_value
      where custom_field_group_assignment_id = 657
        and date_value is not null)
    update flow.project_process_step_event_custom_field_value ppsecfv
    set timestamp_value = (ud.date_value::timestamp at time zone 'US/Mountain')::timestamp
    from update_data ud
    where ud.id = ppsecfv.id;

  elsif p_process_step_id = 3494 then
    perform flow.migrate_group_to_event(7037, p_event_type_id, 1);
    perform flow.migrate_group_to_event(7038, p_event_type_id, 2);
    perform flow.migrate_group_to_event(7039, p_event_type_id, 3);

  end if;

END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

