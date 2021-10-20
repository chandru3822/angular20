CREATE OR REPLACE function flow.migrate_events(p_process_step_id integer)
  returns void as
$$
declare

  x               record;
  v_start_date    timestamp;
  v_end_date      timestamp;
  v_resource_id   integer;
  v_event_id      integer;
  v_event_type_id integer;
BEGIN

  for x in select pps.id    project_process_step_id,
                  cfg.group_name,
                  ps.id  as process_step_id,
                  ps.process_step_name,
                  pps.project_id,
                  cfg.id as custom_field_group_id,
                  e.id   as event_type_id,
                  e.event_name
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

      insert into flow.project_process_step_event(project_process_step_id, process_step_event_id,
                                                  resource_id, company_event_status_type_id,
                                                  start_time, end_time, created_by_id)
      values (x.project_process_step_id, (select pse.id
                                          from flow.process_step_event pse
                                                 inner join flow.event e on pse.event_id = e.id
                                          where pse.process_step_id = x.process_step_id
                                            and e.temp_cfg_id = x.custom_field_group_id),
              v_resource_id, 1, v_start_date, v_end_date, 2350555)
      returning id into v_event_id;
--TODO ask what company_event_status_type_id should be

      if x.process_step_id = 1 then
--         update brs.project_details
--         set first_appointment_ppse_id = v_event_id
--         where first_appointment is not null
--           and first_appointment_ppse_id is null
--           and first_appointment_ppse_id = x.project_process_step_id;
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
      end if;

      v_event_type_id = x.event_type_id;
      -- TODO @keller  check on the company_event_status_type_id and the created_by_id

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

