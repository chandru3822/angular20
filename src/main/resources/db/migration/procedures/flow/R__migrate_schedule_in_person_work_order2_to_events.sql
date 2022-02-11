CREATE OR REPLACE function flow.migrate_schedule_in_person_work_order2_to_events(p_event_id integer,
                                                                                p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_work_order_pps_id       integer;
  v_verify_verify_work_order_pps_id integer;
  v_pending_work_order_needed       timestamp;
  v_verify_work_order_needed        timestamp;
  v_pending_work_order_reason       text;
  v_verify_work_order_reason        text;
  v_date_created_pending_needed     timestamp;
  v_date_modified_pending_needed    timestamp;
  v_created_by_id_pending_needed    integer;
  v_modified_by_id_pending_needed   integer;
  v_date_created_verify_needed      timestamp;
  v_date_modified_verify_needed     timestamp;
  v_created_by_id_verify_needed     integer;
  v_modified_by_id_verify_needed    integer;
  v_date_created_pending_reason     timestamp;
  v_date_modified_pending_reason    timestamp;
  v_created_by_id_pending_reason    integer;
  v_modified_by_id_pending_reason   integer;
  v_date_created_verify_reason      timestamp;
  v_date_modified_verify_reason     timestamp;
  v_created_by_id_verify_reason     integer;
  v_modified_by_id_verify_reason    integer;
BEGIN


  select id
  into v_pending_work_order_pps_id
  from flow.project_process_step
  where process_step_id = 2839
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_work_order_pps_id is not null then
    select id
    into v_verify_verify_work_order_pps_id
    from flow.project_process_step
    where process_step_id = 2840
      and parent_project_process_step_id = v_pending_work_order_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_needed,v_date_created_pending_needed,v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17472
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_needed,v_date_created_verify_needed,v_date_modified_verify_needed,v_created_by_id_verify_needed,v_modified_by_id_verify_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19189
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;

  if v_pending_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_work_order_reason,v_date_created_pending_reason,v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17473
      and project_process_step_id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_work_order_reason,v_date_created_verify_reason,v_date_modified_verify_reason,v_created_by_id_verify_reason,v_modified_by_id_verify_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 17476
      and project_process_step_id = v_verify_verify_work_order_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19082);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18774);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17466);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17467);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     18772);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     20961);



  if v_verify_verify_work_order_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       17475);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_verify_work_order_pps_id,
                                                                       17474);

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
    and custom_field_group_assignment_id = 19161 and int_value is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 19173 and text_value  is not null;

    update flow.project_process_step_custom_field_value
    set project_process_step_id = p_project_process_step_id
    where project_process_step_id = v_verify_verify_work_order_pps_id
      and custom_field_group_assignment_id = 22330 and int_value is not null;

  end if;


  if v_verify_work_order_needed is not null or v_pending_work_order_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         19189,
                                                         coalesce(v_verify_work_order_needed, v_pending_work_order_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         null::numeric,
                                                         coalesce(v_date_created_verify_needed, v_date_created_pending_needed),
                                                         coalesce(v_date_modified_verify_needed, v_date_modified_pending_needed),
                                                         coalesce(v_created_by_id_verify_needed, v_created_by_id_pending_needed),
                                                         coalesce(v_modified_by_id_verify_needed, v_modified_by_id_pending_needed));
  end if;

  if v_verify_work_order_reason is not null or v_pending_work_order_reason is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         17476,
                                                         null::timestamp,
                                                         coalesce(v_verify_work_order_reason, v_pending_work_order_reason)::text,
                                                         null::integer[],
                                                         null::numeric,
                                                         coalesce(v_date_created_verify_reason, v_date_created_pending_reason),
                                                         coalesce(v_date_modified_verify_reason, v_date_modified_pending_reason),
                                                         coalesce(v_created_by_id_verify_reason, v_created_by_id_pending_reason),
                                                         coalesce(v_modified_by_id_verify_reason, v_modified_by_id_pending_reason));
  end if;


--this update parent to the appropriate parent
  if v_pending_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_work_order_pps_id
      and case
            when v_verify_verify_work_order_pps_id is not null then
              id != v_verify_verify_work_order_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_work_order_pps_id;
  end if;

  if v_verify_verify_work_order_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_verify_work_order_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_verify_work_order_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

