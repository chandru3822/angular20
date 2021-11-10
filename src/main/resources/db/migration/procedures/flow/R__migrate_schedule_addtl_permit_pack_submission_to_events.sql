CREATE OR REPLACE function flow.migrate_schedule_addtl_permit_pack_submission_to_events(p_event_id integer,
                                                                                        p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_addtl_pps_pps_id integer;
  v_verify_addtl_pps_pps_id  integer;
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
  into v_pending_addtl_pps_pps_id
  from flow.project_process_step
  where process_step_id = 3100
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_addtl_pps_pps_id is not null then
    select id
    into v_verify_addtl_pps_pps_id
    from flow.project_process_step
    where process_step_id = 3101
      and parent_project_process_step_id = v_pending_addtl_pps_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  select numeric_value, date_created, date_modified, created_by_id, modified_by_id
  into v_permit_fee_main,v_date_created_fee_main,v_date_modified_fee_main,v_created_by_id_fee_main,v_modified_by_id_fee_main
  from flow.project_process_step_custom_field_value
  where custom_field_group_assignment_id =19203
    and project_process_step_id = p_project_process_step_id;

  if v_verify_addtl_pps_pps_id is not null then
    select numeric_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_permit_fee,v_date_created_verify_permit_fee,v_date_modified_verify_permit_fee,v_created_by_id_verify_permit_fee,v_modified_by_id_verify_permit_fee
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id =19225
      and project_process_step_id = v_verify_addtl_pps_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19199);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19200);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19201);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19202);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19204);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19205);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22450);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22451);


  if v_pending_addtl_pps_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_pps_pps_id,
                                                                       19222);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_addtl_pps_pps_id,
                                                                       19223);
  end if;
  if v_verify_addtl_pps_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       19224);

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       19226);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_addtl_pps_pps_id,
                                                                       22002);


  end if;

  if v_permit_fee_main is not null or v_verify_permit_fee is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19203,
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
  end if;

--this update parent to the appropriate parent
  if v_pending_addtl_pps_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_addtl_pps_pps_id
      and case
            when v_verify_addtl_pps_pps_id is not null then
              id != v_verify_addtl_pps_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_addtl_pps_pps_id;
  end if;

  if v_verify_addtl_pps_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_addtl_pps_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_addtl_pps_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

