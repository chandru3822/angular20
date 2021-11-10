CREATE OR REPLACE function flow.migrate_schedule_permit_submission_to_events(p_event_id integer,
                                                                             p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_permit_pack_submission_pps_id integer;
  v_verify_permit_pack_submission_pps_id  integer;
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
BEGIN


  select id
  into v_pending_permit_pack_submission_pps_id
  from flow.project_process_step
  where process_step_id = 94
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_permit_pack_submission_pps_id is not null then
    select id
    into v_verify_permit_pack_submission_pps_id
    from flow.project_process_step
    where process_step_id = 67
      and parent_project_process_step_id = v_pending_permit_pack_submission_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_permit_pack_submission_pps_id is not null then
    select timestamp_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_permit_pack_needed,v_date_created_pending,v_date_modified_pending,v_created_by_id_pending,v_modified_by_id_pending
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 1354
      and project_process_step_id = v_pending_permit_pack_submission_pps_id;
  end if;

  if v_verify_permit_pack_submission_pps_id is not null then
    select timestamp_value, id, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_permit_pack_needed,v_verify_id,v_date_created_verify,v_date_modified_verify,v_created_by_id_verify,v_modified_by_id_verify
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 21983
      and project_process_step_id = v_verify_permit_pack_submission_pps_id;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19085);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19107);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19108);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1268);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     100);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     101);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     103);

  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22000);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     22001);

  if v_pending_permit_pack_submission_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_permit_pack_submission_pps_id,
                                                                       1355);
  end if;
  if v_verify_permit_pack_submission_pps_id is not null then

    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       18956);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       104);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_permit_pack_submission_pps_id,
                                                                       1019);

  end if;


  if v_verify_permit_pack_needed is not null or v_pending_permit_pack_needed is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         21983,
                                                         coalesce(v_verify_permit_pack_needed, v_pending_permit_pack_needed)::timestamp,
                                                         null::text,
                                                         null::integer[],
                                                         null::numeric,
                                                         coalesce(v_date_created_verify, v_date_created_pending),
                                                         coalesce(v_date_modified_verify, v_date_modified_pending),
                                                         coalesce(v_created_by_id_verify, v_created_by_id_pending),
                                                         coalesce(v_modified_by_id_verify, v_modified_by_id_pending));
  end if;


--this update parent to the appropriate parent
  if v_pending_permit_pack_submission_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_permit_pack_submission_pps_id
      and case
            when v_verify_permit_pack_submission_pps_id is not null then
              id != v_verify_permit_pack_submission_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_permit_pack_submission_pps_id;
  end if;

  if v_verify_permit_pack_submission_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_permit_pack_submission_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_permit_pack_submission_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

