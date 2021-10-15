CREATE OR REPLACE function flow.migrate_schedule_structural_upgrade_non_standard_to_events(p_event_id integer,
                                                                                           p_project_process_step_id integer)
  returns void as
$$
declare
  v_structural_upgrade_holding_id integer;
  v_verify_structural_upgrade_id  integer;
BEGIN
  select id
  into v_structural_upgrade_holding_id
  from flow.project_process_step
  where process_step_id = 210
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_structural_upgrade_holding_id is not null then
    select id
    into v_verify_structural_upgrade_id
    from flow.project_process_step
    where process_step_id = 139
      and parent_project_process_step_id = v_structural_upgrade_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;


  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19088);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17500);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17323);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19514);

  if v_verify_structural_upgrade_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_structural_upgrade_id,
                                                                       547);
  end if;


  --this update parent to the appropriate parent
  if v_structural_upgrade_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_structural_upgrade_holding_id
      and case
            when v_verify_structural_upgrade_id is not null then
              id != v_verify_structural_upgrade_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_structural_upgrade_holding_id;
  end if;

  if v_verify_structural_upgrade_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_structural_upgrade_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_structural_upgrade_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

