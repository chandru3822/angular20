CREATE OR REPLACE function flow.migrate_schedule_ac_compressor_relocation_to_events(p_event_id integer,
                                                                                           p_project_process_step_id integer)
  returns void as
$$
declare
  v_ac_compressor_holding_id integer;
  v_verify_ac_compressor_id  integer;
BEGIN
  select id
  into v_ac_compressor_holding_id
  from flow.project_process_step
  where process_step_id = 214
    and parent_project_process_step_id = p_project_process_step_id
  order by project_process_step.date_created desc
  limit 1;

  if v_ac_compressor_holding_id is not null then
    select id
    into v_verify_ac_compressor_id
    from flow.project_process_step
    where process_step_id = 147
      and parent_project_process_step_id = v_ac_compressor_holding_id
    order by project_process_step.date_created desc
    limit 1;
  end if;





  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19070);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17504);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     17327);
  perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                     null,
                                                                     p_project_process_step_id,
                                                                     19509);

  if v_verify_ac_compressor_id is not null then
    perform flow.migrate_project_process_step_event_custom_field_value(p_event_id,
                                                                       null,
                                                                       v_verify_ac_compressor_id,
                                                                       552);
  end if;


  --this update parent to the appropriate parent
  if v_ac_compressor_holding_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_ac_compressor_holding_id
      and case
            when v_verify_ac_compressor_id is not null then
              id != v_verify_ac_compressor_id
            else 1 = 1 end;

    ---archives site_survey
    update flow.project_process_step
    set archived = true
    where id = v_ac_compressor_holding_id;
  end if;

  if v_verify_ac_compressor_id is not null then
    update flow.project_process_step
    set parent_project_process_step_id = p_project_process_step_id
    where parent_project_process_step_id = v_verify_ac_compressor_id;

    ---archives site_survey_verification
    update flow.project_process_step
    set archived = true
    where id = v_verify_ac_compressor_id;
  end if;


END
$$
  LANGUAGE plpgsql VOLATILE
                   COST 100;

