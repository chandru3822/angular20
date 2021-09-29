CREATE OR REPLACE function flow.migrate_schedule_ahj_reinspection_wc_to_events(p_event_id integer,
                                                                               p_project_process_step_id integer)
  returns void as
$$

declare
  v_schedule_reinspection_with_ahj_id        integer;
  v_pending_ahj_reinspection_id            integer;
  v_need_ahj_verification_pps_id           integer;
  v_ahj_reinspection_wc_event_id           integer;
  v_reinspection_pending_reschedule_needed timestamp;
  v_reinspection_pending_reschedule_reason text;
  v_reinspection_need_reschedule_needed    timestamp;
  v_reinspection_need_reschedule_reason    text;
  v_need_id                                integer;
  v_need_reason_id                         integer;
  v_project_id                             integer;
  v_date_created_pending_needed            timestamp;
  v_date_created_pending_reason            timestamp;
  v_date_created_need_needed               timestamp;
  v_date_created_need_reason               timestamp;
  v_date_modified_pending_needed           timestamp;
  v_date_modified_pending_reason           timestamp;
  v_date_modified_need_needed              timestamp;
  v_date_modified_need_reason              timestamp;
  v_created_by_id_pending_needed           integer;
  v_created_by_id_pending_reason           integer;
  v_created_by_id_need_needed              integer;
  v_created_by_id_need_reason              integer;
  v_modified_by_id_pending_needed          integer;
  v_modified_by_id_pending_reason          integer;
  v_modified_by_id_need_needed             integer;
  v_modified_by_id_need_reason             integer;
BEGIN

  select project_id
  into v_project_id
  from flow.project_process_step
  where id = p_project_process_step_id;

  select id
  into v_schedule_reinspection_with_ahj_id
  from flow.project_process_step
  where process_step_id = 205
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  select id
  into v_pending_ahj_reinspection_id
  from flow.project_process_step
  where process_step_id = 154
    and parent_project_process_step_id = v_schedule_reinspection_with_ahj_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_ahj_reinspection_id is not null then
    select id
    into v_need_ahj_verification_pps_id
    from flow.project_process_step
    where process_step_id = 46
      and parent_project_process_step_id = v_pending_ahj_reinspection_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_ahj_reinspection_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_pending_reschedule_needed,v_date_created_pending_needed,
      v_date_modified_pending_needed,v_created_by_id_pending_needed,v_modified_by_id_pending_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1409
      and project_process_step_id = v_pending_ahj_reinspection_id;
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_pending_reschedule_reason,v_date_created_pending_reason,
      v_date_modified_pending_reason,v_created_by_id_pending_reason,v_modified_by_id_pending_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1410
      and project_process_step_id = v_pending_ahj_reinspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_need_reschedule_needed,v_need_id,
      v_date_created_need_needed,v_date_modified_need_needed,v_created_by_id_need_needed,
      v_modified_by_id_need_needed
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19027
      and project_process_step_id = v_need_ahj_verification_pps_id;
    select text_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_reinspection_need_reschedule_reason,v_need_reason_id,
      v_date_created_need_reason,v_date_modified_need_reason,
      v_created_by_id_need_reason,v_modified_by_id_need_reason
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 19028
      and project_process_step_id = v_need_ahj_verification_pps_id;
  end if;

  select id
  into v_ahj_reinspection_wc_event_id
  from flow.event
  where temp_cfg_id = 5644;
  -- this migrates scheduling complete

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     338,
                                                                     p_project_process_step_id,
                                                                     null);


  if v_need_ahj_verification_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       153, true, v_ahj_reinspection_wc_event_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       152, true, v_ahj_reinspection_wc_event_id);

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       998, true, v_ahj_reinspection_wc_event_id);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id, null, v_need_ahj_verification_pps_id,
                                                                       21609, true, v_ahj_reinspection_wc_event_id);


  end if;
  if v_reinspection_need_reschedule_needed is not null or v_reinspection_pending_reschedule_needed is not null then
  perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                       19027,
                                                       coalesce(v_reinspection_need_reschedule_needed,
                                                                v_reinspection_pending_reschedule_needed),
                                                       null::text,
                                                       null::integer[],
                                                       coalesce(v_date_created_need_needed, v_date_created_pending_needed),
                                                       coalesce(v_date_modified_need_needed, v_date_modified_pending_needed),
                                                       coalesce(v_created_by_id_need_needed, v_created_by_id_pending_needed),
                                                       coalesce(v_modified_by_id_need_needed,
                                                                v_modified_by_id_pending_needed),
                                                       true, v_ahj_reinspection_wc_event_id);
  end if;
  if v_reinspection_need_reschedule_reason is not null or v_reinspection_pending_reschedule_reason is not null then
  perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                       19028,
                                                       null::timestamp,
                                                       coalesce(v_reinspection_need_reschedule_reason,
                                                                v_reinspection_pending_reschedule_reason)::text,
                                                       null::integer[],
                                                       coalesce(v_date_created_need_reason, v_date_created_pending_reason),
                                                       coalesce(v_date_modified_need_reason, v_date_modified_pending_reason),
                                                       coalesce(v_created_by_id_need_reason, v_created_by_id_pending_reason),
                                                       coalesce(v_modified_by_id_need_reason,
                                                                v_modified_by_id_pending_reason)
                                                            , true, v_ahj_reinspection_wc_event_id);
  end if;
--this update parent to the appropriate parent

  if v_schedule_reinspection_with_ahj_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_schedule_reinspection_with_ahj_id
      and case
            when v_pending_ahj_reinspection_id is not null then
                id != v_pending_ahj_reinspection_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_schedule_reinspection_with_ahj_id;
  end if;

  if v_pending_ahj_reinspection_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_ahj_reinspection_id
      and case
            when v_need_ahj_verification_pps_id is not null then
              id != v_need_ahj_verification_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_ahj_reinspection_id;
  end if;

  if v_need_ahj_verification_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_need_ahj_verification_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_need_ahj_verification_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

