CREATE OR REPLACE function flow.migrate_events(p_process_step_id integer)
  returns void as
$$
declare

  x                          record;
  v_start_date               timestamp;
  v_end_date                 timestamp;
  v_resource_id              integer;
  v_event_id                 integer;
  v_event_type_id            integer;
  v_event_status_type_id     integer;
  y                          integer;
  p                          integer[];
  v_first_row                boolean default false;
  v_project_process_step_ids integer[];
  v_online_timestamp_value   timestamp;
  v_created_start_time       timestamp;
  v_cancelled_date timestamp;
  v_completed_date timestamp;
  v_scheduled_timestamp timestamp;
BEGIN
  select process_step_ids into p from flow.migration_child_process_step where project_process_id = p_process_step_id;

  for x in select pps.id    project_process_step_id,
                  cfg.group_name,
                  ps.id  as process_step_id,
                  ps.process_step_name,
                  pps.project_id,
                  cfg.id as custom_field_group_id,
                  e.id   as event_type_id,
                  e.event_name,
                  pps.date_created
           from flow.custom_field_group cfg
                  inner join flow.process_step ps on ps.id = cfg.process_step_id
                  inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
                  inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
                  inner join flow.event e on e.temp_cfg_id = cfg.id
           where cfg.event_type_id is not null
             and cfg.archived is false
             and cot.company_id = 3
             and ps.id = p_process_step_id
             -- and pps.id = 3263673
           order by pps.project_id, pps.date_created

    loop
      -- raise notice 'the record count = %, the pps_id = %',v_record_count,x.project_process_step_id;
      select ppscfv.timestamp_value as event_start_date
      into v_start_date
      from flow.custom_field_group cfg
             inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
             inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
             inner join flow.project_process_step_custom_field_value ppscfv
                        on pps.id = ppscfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga
                        on ppscfv.custom_field_group_assignment_id = cfga.id and
                           cfga.schedule_field_type_id in (1)
      where cfg.event_type_id is not null
        and cfg.archived is false
        and cot.company_id = 3
        and pps.id = x.project_process_step_id;


      select ppscfv.timestamp_value as event_end_date
      into v_end_date
      from flow.custom_field_group cfg
             inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
             inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
             inner join flow.project_process_step_custom_field_value ppscfv
                        on pps.id = ppscfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga
                        on ppscfv.custom_field_group_assignment_id = cfga.id and
                           cfga.schedule_field_type_id in (2)
      where cfg.event_type_id is not null
        and cfg.archived is false
        and cot.company_id = 3
        and pps.id = x.project_process_step_id;


      select ppscfv.int_value as event_resource
      into v_resource_id
      from flow.custom_field_group cfg
             inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
             inner join flow.project_process_step pps on pps.process_step_id = cfg.process_step_id
             inner join flow.project_process_step_custom_field_value ppscfv
                        on pps.id = ppscfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga
                        on ppscfv.custom_field_group_assignment_id = cfga.id and
                           cfga.schedule_field_type_id in (3)
      where cfg.event_type_id is not null
        and cfg.archived is false
        and cot.company_id = 3
        and pps.id = x.project_process_step_id;

      --                 raise notice 'this is the start time = %',v_start_date;
--                 raise notice 'this is the end time = %',v_end_date;
--                 raise notice 'this is the resource id = %',v_resource_id;

      if (p_process_step_id = 1 and v_start_date is not null and v_end_date is not null and
          v_resource_id is not null) or
         p_process_step_id != 1 then
        v_online_timestamp_value = null;
        if p_process_step_id in (13, 3099, 3395) then
          select timestamp_value
          into v_online_timestamp_value
          from flow.project_process_step_custom_field_value
          where project_process_step_id = x.project_process_step_id
            and custom_field_group_assignment_id in (20917, 19108, 19201)
          limit 1;

        end if;
        if x.process_step_id = 1 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         1, 0,
                                         0,
                                         0);

        elsif x.process_step_id = 5 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         5, 60,
                                         3346,
                                         0);
        elsif x.process_step_id = 98 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         98, 99,
                                         3346,
                                         0);
        elsif x.process_step_id = 168 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         168, 204,
                                         152,
                                         46);
        elsif x.process_step_id = 40 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         40, 204,
                                         152,
                                         46);
        elsif x.process_step_id = 153 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         153, 205,
                                         154,
                                         46);
        elsif x.process_step_id = 3365 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3365, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3383 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3383, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 16 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         16, 233,
                                         17,
                                         0);
        elsif x.process_step_id = 13 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, coalesce(v_start_date,v_online_timestamp_value),
                                         v_end_date,
                                         13, 94,
                                         67,
                                         0);
        elsif x.process_step_id = 85 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         85, 96,
                                         97,
                                         0);
        elsif x.process_step_id = 3431 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3431, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 129 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         129, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 138 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         138, 210,
                                         139,
                                         0);
        elsif x.process_step_id = 146 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         146, 214,
                                         147,
                                         0);
        elsif x.process_step_id = 140 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         140, 211,
                                         141,
                                         0);
        elsif x.process_step_id = 144 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         144, 213,
                                         145,
                                         0);
        elsif x.process_step_id = 142 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         142, 212,
                                         143,
                                         0);
        elsif x.process_step_id = 148 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         148, 149,
                                         0,
                                         0);
        elsif x.process_step_id = 3414 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3414, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3362 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3362, 3363,
                                         3364,
                                         0);
        elsif x.process_step_id = 134 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         134, 208,
                                         135,
                                         0);
        elsif x.process_step_id = 28 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         28, 239,
                                         134,
                                         0);
        elsif x.process_step_id = 3487 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3487, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3409 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3409, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 54 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         54, 104,
                                         55,
                                         0);
        elsif x.process_step_id = 2838 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         2838, 2839,
                                         2840,
                                         0);
        elsif x.process_step_id = 2841 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         2841, 2842,
                                         2843,
                                         0);
        elsif x.process_step_id = 3091 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3091, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3480 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3480, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3441 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3441, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 165 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         165, 166,
                                         167,
                                         0);
        elsif x.process_step_id = 66 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         66, 228,
                                         71,
                                         0);
        elsif x.process_step_id = 3107 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3107, 3108,
                                         3109,
                                         0);
        elsif x.process_step_id = 192 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         192, 193,
                                         194,
                                         0);
        elsif x.process_step_id = 3103 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3103, 3104,
                                         3105,
                                         0);
        elsif x.process_step_id = 3099 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, coalesce(v_start_date,v_online_timestamp_value),
                                         v_end_date,
                                         3099, 3100,
                                         3101,
                                         0);
        elsif x.process_step_id = 196 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         196, 234,
                                         197,
                                         0);
        elsif x.process_step_id = 3359 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3359, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3360 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3360, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 44 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         44, 156,
                                         157,
                                         0);
        elsif x.process_step_id = 3479 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3479, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 222 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         222, 223,
                                         0,
                                         0);
        elsif x.process_step_id = 172 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         172, 236,
                                         173,
                                         0);
        elsif x.process_step_id = 3427 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3427, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3428 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3428, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3397 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3397, 3398,
                                         0,
                                         0);

        elsif x.process_step_id = 3478 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3478, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3395 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, coalesce(v_start_date,v_online_timestamp_value),
                                         v_end_date,
                                         3395, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3399 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3399, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3471 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3471, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3459 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3459, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3470 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3470, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3473 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3473, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3472 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3472, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3474 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3474, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 3391 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         3391, 0,
                                         0,
                                         0);
        elsif x.process_step_id = 170 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         170, 206,
                                         207,
                                         171);
        elsif x.process_step_id = 25 then
          select process_event_status_id,cancel_timestamp,complete_timestamp,scheduled_timestamp
          into v_event_status_type_id,v_cancelled_date,v_completed_date,v_scheduled_timestamp
          from flow.migrate_event_status(x.project_process_step_id, x.project_id, v_start_date,
                                         v_end_date,
                                         25, 235,
                                         26,
                                         0);
        end if;
        v_created_start_time = null;
        if v_start_date is null and v_end_date is not null then
          v_created_start_time = v_end_date - interval '1 hour';
        end if;
        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id,
                                                    resource_id, company_event_status_type_id,
                                                    start_time, end_time, created_by_id,cancelled_date,completed_date,scheduled_date)
        values (x.project_process_step_id, (select pse.id
                                            from flow.process_step_event pse
                                                   inner join flow.event e on pse.event_id = e.id
                                            where pse.process_step_id = x.process_step_id
                                              and e.temp_cfg_id = x.custom_field_group_id),
                v_resource_id, coalesce(v_event_status_type_id, 5), coalesce(
                  coalesce(coalesce(v_start_date, v_online_timestamp_value), v_created_start_time), x.date_created),
                v_end_date, 2350555,v_cancelled_date,v_completed_date,v_scheduled_timestamp)
        returning id into v_event_id;
        v_project_process_step_ids = null;
        v_first_row = true;
        foreach y in array p
          loop
            if v_project_process_step_ids is null then
              v_project_process_step_ids = array_agg(x.project_process_step_id);
            else
              select array_agg(id)
              into v_project_process_step_ids
              from flow.project_process_step
              where parent_project_process_step_id = any (v_project_process_step_ids)
                and process_step_id = y;
            end if;

            if v_project_process_step_ids is not null or array_length(v_project_process_step_ids, 1) > 0 then
              insert into flow.project_process_step_event_attachment(attachment_id, project_process_step_event_id,
                                                                     date_created, date_modified, created_by_id,
                                                                     modified_by_id, archived)
                (select ppsa.attachment_id,
                        v_event_id,
                        ppsa.date_created,
                        ppsa.date_modified,
                        ppsa.created_by_id,
                        ppsa.modified_by_id,
                        ppsa.archived
                 from flow.project_process_step_attachment ppsa
                        inner join flow.project_process_step pps on pps.id = ppsa.project_process_step_id
                 where ppsa.project_process_step_id = any (v_project_process_step_ids)
                   and pps.process_step_id = y);

              if v_first_row is false then
                insert into flow.project_process_step_attachment(attachment_id, project_process_step_id, date_created,
                                                                 date_modified, created_by_id, modified_by_id, archived)
                  (select ppsa.attachment_id,
                          x.project_process_step_id,
                          ppsa.date_created,
                          ppsa.date_modified,
                          ppsa.created_by_id,
                          ppsa.modified_by_id,
                          ppsa.archived
                   from flow.project_process_step_attachment ppsa
                          inner join flow.project_process_step pps on pps.id = ppsa.project_process_step_id
                   where ppsa.project_process_step_id = any (v_project_process_step_ids)
                     and pps.process_step_id = y);

                update flow.project_process_step_attachment
                set archived = true
                where project_process_step_id = any (v_project_process_step_ids);
              end if;

            end if;

            v_first_row = false;
          end loop;


        --       update flow.project_process_step_attachment
--         set archived = true
--       where project_process_step_id = x.project_process_step_id;

        if x.process_step_id = 1 then
          perform flow.migrate_schedule_closer_appointment_to_events(v_event_id,
                                                                     x.project_process_step_id);

        elsif x.process_step_id = 5 then
          perform flow.migrate_schedule_site_survey_to_events(v_event_id,
                                                              x.project_process_step_id);
        elsif x.process_step_id = 98 then
          perform flow.migrate_schedule_resurvey_to_events(v_event_id,
                                                           x.project_process_step_id);
        elsif x.process_step_id = 168 then
          perform flow.migrate_schedule_ahj_inspection_sc_to_events(v_event_id,
                                                                    x.project_process_step_id);
        elsif x.process_step_id = 40 then
          perform flow.migrate_schedule_ahj_inspection_nsc_to_events(v_event_id,
                                                                     x.project_process_step_id);
        elsif x.process_step_id = 153 then
          perform flow.migrate_schedule_ahj_reinspection_wc_to_events(v_event_id,
                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3365 then
          perform flow.migrate_schedule_installation_to_events(v_event_id,
                                                               x.project_process_step_id);
        elsif x.process_step_id = 3383 then
          perform flow.migrate_schedule_installation_closeout_to_events(v_event_id,
                                                                        x.project_process_step_id);
        elsif x.process_step_id = 16 then
          perform flow.migrate_schedule_permit_pickup_delivery_to_events(v_event_id,
                                                                         x.project_process_step_id);
        elsif x.process_step_id = 13 then
          perform flow.migrate_schedule_permit_submission_to_events(v_event_id,
                                                                    x.project_process_step_id);
        elsif x.process_step_id = 85 then
          perform flow.migrate_schedule_energization_to_events(v_event_id,
                                                               x.project_process_step_id);
        elsif x.process_step_id = 3431 then
          perform flow.migrate_schedule_retrofit_energization_to_events(v_event_id,
                                                                        x.project_process_step_id);
        elsif x.process_step_id = 129 then
          perform flow.migrate_schedule_eto_rebate_inspection_to_events(v_event_id,
                                                                        x.project_process_step_id);
        elsif x.process_step_id = 138 then
          perform flow.migrate_schedule_structural_upgrade_non_standard_to_events(v_event_id,
                                                                                  x.project_process_step_id);
        elsif x.process_step_id = 146 then
          perform flow.migrate_schedule_ac_compressor_relocation_to_events(v_event_id,
                                                                           x.project_process_step_id);
        elsif x.process_step_id = 140 then
          perform flow.migrate_schedule_reroof_to_events(v_event_id,
                                                         x.project_process_step_id);
        elsif x.process_step_id = 144 then
          perform flow.migrate_schedule_tree_trimming_to_events(v_event_id,
                                                                x.project_process_step_id);
        elsif x.process_step_id = 142 then
          perform flow.migrate_schedule_trenching_to_events(v_event_id,
                                                            x.project_process_step_id);
        elsif x.process_step_id = 148 then
          perform flow.migrate_schedule_deadfront_to_events(v_event_id,
                                                            x.project_process_step_id);
        elsif x.process_step_id = 3414 then
          perform flow.migrate_schedule_non_standard_visit_to_events(v_event_id,
                                                                     x.project_process_step_id);
        elsif x.process_step_id = 3362 then
          perform flow.migrate_schedule_meter_pull_to_events(v_event_id,
                                                             x.project_process_step_id);
        elsif x.process_step_id = 134 then
          perform flow.migrate_schedule_outsource_mpu_to_events(v_event_id,
                                                                x.project_process_step_id);
        elsif x.process_step_id = 28 then
          perform flow.migrate_schedule_inhouse_mpu_to_events(v_event_id,
                                                              x.project_process_step_id);
        elsif x.process_step_id = 3487 then
          perform flow.migrate_schedule_rma_work_order_to_events(v_event_id,
                                                                 x.project_process_step_id);
        elsif x.process_step_id = 3409 then
          perform flow.migrate_schedule_roof_leak_repair_to_events(v_event_id,
                                                                   x.project_process_step_id);
        elsif x.process_step_id = 54 then
          perform flow.migrate_schedule_in_person_work_order_to_events(v_event_id,
                                                                       x.project_process_step_id);
        elsif x.process_step_id = 2838 then
          perform flow.migrate_schedule_in_person_work_order2_to_events(v_event_id,
                                                                        x.project_process_step_id);
        elsif x.process_step_id = 2841 then
          perform flow.migrate_schedule_in_person_work_order3_to_events(v_event_id,
                                                                        x.project_process_step_id);
        elsif x.process_step_id = 3091 then
          perform flow.migrate_schedule_add_additional_resource_to_install_to_events(v_event_id,
                                                                                     x.project_process_step_id);
        elsif x.process_step_id = 3480 then
          perform flow.migrate_schedule_add_additional_resource_to_wo_to_events(v_event_id,
                                                                                x.project_process_step_id);
        elsif x.process_step_id = 3441 then
          perform flow.migrate_schedule_add_retro_addtln_resource_install_to_events(v_event_id,
                                                                                    x.project_process_step_id);
        elsif x.process_step_id = 165 then
          perform flow.migrate_schedule_midpoint_inspection_to_events(v_event_id,
                                                                      x.project_process_step_id);
        elsif x.process_step_id = 66 then
          perform flow.migrate_schedule_permit_signature_to_events(v_event_id,
                                                                   x.project_process_step_id);
        elsif x.process_step_id = 3107 then
          perform flow.migrate_schedule_additional_permit_signature_to_events(v_event_id,
                                                                              x.project_process_step_id);
        elsif x.process_step_id = 192 then
          perform flow.migrate_schedule_asbuilt_permit_signature_to_events(v_event_id,
                                                                           x.project_process_step_id);
        elsif x.process_step_id = 3103 then
          perform flow.migrate_schedule_addtl_permit_pickup_delivery_to_events(v_event_id,
                                                                               x.project_process_step_id);
        elsif x.process_step_id = 3099 then
          perform flow.migrate_schedule_addtl_permit_pack_submission_to_events(v_event_id,
                                                                               x.project_process_step_id);
        elsif x.process_step_id = 196 then
          perform flow.migrate_schedule_asbuilt_permit_pack_delivery_to_events(v_event_id,
                                                                               x.project_process_step_id);
        elsif x.process_step_id = 3359 then
          perform flow.migrate_schedule_panel_removal_to_events(v_event_id,
                                                                x.project_process_step_id);
        elsif x.process_step_id = 3360 then
          perform flow.migrate_schedule_panel_reinstallation_to_events(v_event_id,
                                                                       x.project_process_step_id);
        elsif x.process_step_id = 44 then
          perform flow.migrate_schedule_ahj_inspection_work_to_events(v_event_id,
                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3479 then
          perform flow.migrate_schedule_critter_guard_to_events(v_event_id,
                                                                x.project_process_step_id);
        elsif x.process_step_id = 222 then
          perform flow.migrate_schedule_inhouse_mpu_inspection_to_events(v_event_id,
                                                                         x.project_process_step_id);
        elsif x.process_step_id = 172 then
          perform flow.migrate_schedule_inhouse_mpu_permit_pickup_to_events(v_event_id,
                                                                            x.project_process_step_id);
        elsif x.process_step_id = 3427 then
          perform flow.migrate_schedule_retrofit_inspection_to_events(v_event_id,
                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3428 then
          perform flow.migrate_schedule_retrofit_inspection_correction_work_to_events(v_event_id,
                                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3397 then
          perform flow.migrate_schedule_retrofit_installation_to_events(v_event_id,
                                                                        x.project_process_step_id);

        elsif x.process_step_id = 3478 then
          perform flow.migrate_schedule_retrofit_installation_closeout_work_to_events(v_event_id,
                                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3395 then
          perform flow.migrate_schedule_retrofit_permit_submission_to_events(v_event_id,
                                                                             x.project_process_step_id);
        elsif x.process_step_id = 3399 then
          perform flow.migrate_schedule_retrofit_permit_pickup_delivery_to_events(v_event_id,
                                                                                  x.project_process_step_id);
        elsif x.process_step_id = 3471 then
          perform flow.migrate_schedule_retrofit_meter_pull_to_events(v_event_id,
                                                                      x.project_process_step_id);
        elsif x.process_step_id = 3459 then
          perform flow.migrate_schedule_retrofit_inhouse_mpu_to_events(v_event_id,
                                                                       x.project_process_step_id);
        elsif x.process_step_id = 3470 then
          perform flow.migrate_schedule_retrofit_outsource_mpu_to_events(v_event_id,
                                                                         x.project_process_step_id);
        elsif x.process_step_id = 3473 then
          perform flow.migrate_schedule_retrofit_trenching_to_events(v_event_id,
                                                                     x.project_process_step_id);
        elsif x.process_step_id = 3472 then
          perform flow.migrate_schedule_retrofit_tree_trimming_to_events(v_event_id,
                                                                         x.project_process_step_id);
        elsif x.process_step_id = 3474 then
          perform flow.migrate_schedule_retrofit_structural_upgrade_to_events(v_event_id,
                                                                              x.project_process_step_id);
        elsif x.process_step_id = 3391 then
          perform flow.migrate_schedule_retrofit_site_survey_to_events(v_event_id,
                                                                       x.project_process_step_id);
        elsif x.process_step_id = 170 then
          perform flow.migrate_schedule_additional_inspection_customer_to_events(v_event_id,
                                                                                 x.project_process_step_id);
        elsif x.process_step_id = 25 then
          perform flow.migrate_schedule_inhouse_mpu_permit_submission_to_events(v_event_id,
                                                                                x.project_process_step_id);
        end if;

        v_event_type_id = x.event_type_id;
        -- TODO @keller  check on the company_event_status_type_id and the created_by_id
      end if;
    end loop;


  perform flow.migrate_all_groups(v_event_type_id, p_process_step_id);


  with update_data as (
    select cfg.id
    from flow.custom_field_group cfg
           inner join flow.process_step ps on ps.id = cfg.process_step_id and ps.archived is false
    where ps.id = p_process_step_id
      and cfg.archived is false
      and cfg.event_type_id is not null)
  update flow.custom_field_group cfg
  set archived = true
  from update_data ud
  where ud.id = cfg.id;
end

$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

