CREATE OR REPLACE function flow.migrate_schedule_asbuilt_permit_signature_to_events(p_event_id integer,
                                                                                 p_project_process_step_id integer)
  returns void as
$$

declare
  v_pending_asbuilt_permit_signature_pps_id integer;
  v_verify_asbuilt_permit_signature_pps_id  integer;
  v_pending_bn                              text;
  v_verify_bn                               text;
  v_pending_en                              text;
  v_verify_en                               text;
  v_date_created_pending_bn            timestamp;
  v_date_modified_pending_bn            timestamp;
  v_created_by_id_pending_bn            integer;
  v_modified_by_id_pending_bn           integer;
  v_date_created_verify_bn              timestamp;
  v_date_modified_verify_bn             timestamp;
  v_created_by_id_verify_bn            integer;
  v_modified_by_id_verify_bn            integer;
  v_date_created_pending_en             timestamp;
  v_date_modified_pending_en            timestamp;
  v_created_by_id_pending_en            integer;
  v_modified_by_id_pending_en           integer;
  v_date_created_verify_en              timestamp;
  v_date_modified_verify_en             timestamp;
  v_created_by_id_verify_en             integer;
  v_modified_by_id_verify_en            integer;
BEGIN


  select id
  into v_pending_asbuilt_permit_signature_pps_id
  from flow.project_process_step
  where process_step_id = 193
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select id
    into v_verify_asbuilt_permit_signature_pps_id
    from flow.project_process_step
    where process_step_id = 194
      and parent_project_process_step_id = v_pending_asbuilt_permit_signature_pps_id
    order by project_process_step.date_created desc
    limit 1;
  end if;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_bn,v_date_created_pending_bn,v_date_modified_pending_bn,v_created_by_id_pending_bn,v_modified_by_id_pending_bn
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 809
      and project_process_step_id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_bn,v_date_created_verify_bn,v_date_modified_verify_bn,v_created_by_id_verify_bn,v_modified_by_id_verify_bn
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 823
      and project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;
  end if;

  if v_pending_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_pending_en,v_date_created_pending_en,v_date_modified_pending_en,v_created_by_id_pending_en,v_modified_by_id_pending_en
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 810
      and project_process_step_id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    select text_value, date_created, date_modified, created_by_id, modified_by_id
    into v_verify_en,v_date_created_verify_en,v_date_modified_verify_en,v_created_by_id_verify_en,v_modified_by_id_verify_en
    from flow.project_process_step_custom_field_value
    where custom_field_group_assignment_id = 824
      and project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;
  end if;



  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19072);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     1274);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     812);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     811);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     813);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17334);


  if v_pending_asbuilt_permit_signature_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_asbuilt_permit_signature_pps_id,
                                                                       1366);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_pending_asbuilt_permit_signature_pps_id,
                                                                       1367);
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       826);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       18961);
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_asbuilt_permit_signature_pps_id,
                                                                       1364);



  end if;


  if v_verify_bn is not null or v_pending_bn is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         809,
                                                         null::timestamp,
                                                         coalesce(v_verify_bn, v_pending_bn)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_bn, v_date_created_pending_bn),
                                                         coalesce(v_date_modified_verify_bn,
                                                                  v_date_modified_pending_bn),
                                                         coalesce(v_created_by_id_verify_bn,
                                                                  v_created_by_id_pending_bn),
                                                         coalesce(v_modified_by_id_verify_bn,
                                                                  v_modified_by_id_pending_bn));
  end if;

  if v_verify_en is not null or v_pending_en is not null then
    perform flow.migrate_insert_event_custom_field_value(p_event_id,
                                                         810,
                                                         null::timestamp,
                                                         coalesce(v_verify_en, v_pending_en)::text,
                                                         null::integer[],
                                                         coalesce(v_date_created_verify_en, v_date_created_pending_en),
                                                         coalesce(v_date_modified_verify_en,
                                                                  v_date_modified_pending_en),
                                                         coalesce(v_created_by_id_verify_en,
                                                                  v_created_by_id_pending_en),
                                                         coalesce(v_modified_by_id_verify_en,
                                                                  v_modified_by_id_pending_en));
  end if;


--this update parent to the appropriate parent
  if v_pending_asbuilt_permit_signature_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_pending_asbuilt_permit_signature_pps_id
      and case
            when v_verify_asbuilt_permit_signature_pps_id is not null then
              id != v_verify_asbuilt_permit_signature_pps_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_pending_asbuilt_permit_signature_pps_id;
  end if;

  if v_verify_asbuilt_permit_signature_pps_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_asbuilt_permit_signature_pps_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_asbuilt_permit_signature_pps_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

