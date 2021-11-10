CREATE OR REPLACE function flow.migrate_schedule_inhouse_mpu_permit_pickup_to_events(p_event_id integer,
                                                                             p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_inhouse_mpu_permit_pickup_pps_id integer;
  v_verify_inhouse_mpu_permit_pickup_pps_id  integer;
  v_pending_permit_pack_needed            timestamp;
  v_verify_permit_pack_needed             timestamp;
  v_verify_id                             integer;
  v_date_created_pending                  timestamp;
  v_date_modified_pending                 timestamp;
  v_created_by_id_pending                 integer;
  v_modified_by_id_pending                integer;
  v_date_created_verify                   timestamp;
  v_date_modified_verify                  timestamp;
  v_created_by_id_verify                  integer;
  v_modified_by_id_verify                 integer;
  v_permit_fee_main                         numeric;
  v_verify_permit_fee                       numeric;
  v_date_created_fee_main                   timestamp;
  v_date_modified_fee_main                  timestamp;
  v_created_by_id_fee_main                  integer;
  v_modified_by_id_fee_main                 integer;
  v_date_created_verify_permit_fee          timestamp;
  v_date_modified_verify_permit_fee         timestamp;
  v_created_by_id_verify_permit_fee         integer;
  v_modified_by_id_verify_permit_fee        integer;
BEGIN


  select id
  into v_pending_inhouse_mpu_permit_pickup_pps_id
  from flow.project_process_step
  where process_step_id = 236
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_inhouse_mpu_permit_pickup_pps_id is not null then
    select id
    into v_verify_inhouse_mpu_permit_pickup_pps_id
    from flow.project_process_step
    where process_step_id = 173
      and parent_project_process_step_id = v_pending_inhouse_mpu_permit_pickup_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_inhouse_mpu_permit_pickup_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_permit_pack_needed,v_date_created_pending,v_date_modified_pending,v_created_by_id_pending,v_modified_by_id_pending
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1374
      and project_process_step_id = v_pending_inhouse_mpu_permit_pickup_pps_id;
  end if;

  if v_verify_inhouse_mpu_permit_pickup_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_permit_pack_needed,v_verify_id,v_date_created_verify,v_date_modified_verify,v_created_by_id_verify,v_modified_by_id_verify
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21986
      and project_process_step_id = v_verify_inhouse_mpu_permit_pickup_pps_id;
  end if;

  select numeric_value, date_created, date_modified, created_by_id, modified_by_id
  into v_permit_fee_main,v_date_created_fee_main,v_date_modified_fee_main,v_created_by_id_fee_main,v_modified_by_id_fee_main
  from flow.project_process_step_custom_field_value
  where custom_field_group_assignment_id =18970
    and project_process_step_id = p_project_process_step_id;

  if v_verify_inhouse_mpu_permit_pickup_pps_id is not null then
    select numeric_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_permit_fee,v_date_created_verify_permit_fee,v_date_modified_verify_permit_fee,v_created_by_id_verify_permit_fee,v_modified_by_id_verify_permit_fee
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =18968
      and project_process_step_id = v_verify_inhouse_mpu_permit_pickup_pps_id;
  end if;




  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19079);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17333);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1311);


  if v_pending_inhouse_mpu_permit_pickup_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_inhouse_mpu_permit_pickup_pps_id,
                                                                       1375);
  end if;
  if v_verify_inhouse_mpu_permit_pickup_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_permit_pickup_pps_id,
                                                                       666);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_permit_pickup_pps_id,
                                                                       667);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_inhouse_mpu_permit_pickup_pps_id,
                                                                       1376);


  end if;


  if v_verify_permit_pack_needed is not null or v_pending_permit_pack_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         1374,
                                                         coalesce(v_verify_permit_pack_needed, v_pending_permit_pack_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         null::numeric,
                                                         coalesce(v_date_created_verify, v_date_created_pending),
                                                         coalesce(v_date_modified_verify, v_date_modified_pending),
                                                         coalesce(v_created_by_id_verify, v_created_by_id_pending),
                                                         coalesce(v_modified_by_id_verify, v_modified_by_id_pending));
  end if;

  if v_permit_fee_main is not null or v_verify_permit_fee is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         18970,
                                                         null::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         coalesce(v_verify_permit_fee, v_permit_fee_main)::numeric,
                                                         coalesce(v_date_created_verify_permit_fee, v_date_created_fee_main),
                                                         coalesce(v_date_modified_verify_permit_fee,
                                                                  v_date_modified_fee_main),
                                                         coalesce(v_created_by_id_verify_permit_fee,
                                                                  v_created_by_id_fee_main),
                                                         coalesce(v_modified_by_id_verify_permit_fee,
                                                                  v_modified_by_id_fee_main));


--this update parent to the appropriate parent
  if v_pending_inhouse_mpu_permit_pickup_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_inhouse_mpu_permit_pickup_pps_id
      and case
            when v_verify_inhouse_mpu_permit_pickup_pps_id is not null then
              id != v_verify_inhouse_mpu_permit_pickup_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_inhouse_mpu_permit_pickup_pps_id;
  end if;

  if v_verify_inhouse_mpu_permit_pickup_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_inhouse_mpu_permit_pickup_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_inhouse_mpu_permit_pickup_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

