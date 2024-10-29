SET session_replication_role = replica;
DO
$do$
  declare
    y                                      record;
    v_project_process_step_plan_id              bigint;
    v_project_process_step_plan_event_id        bigint;
    v_count bigint;
    v_total bigint;
    v_system_wattage numeric;
  BEGIN
    raise notice '3 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for y in select ptc.id as plan_type_id,
                    ptc.NAME,
                    ptc.created_by_id,
                    ptc.ADDITIONAL_COST_FOR_STORAGE_C,
                    ptc.BASE_SQUARE_FOOTAGE_C,
                    ptc.flat_monthly_tpo_rate_c,
                    ptc.min_system_size_watts_c,
                    ptc.modules_c,
                    ptc.retail_value_c,
                    ptc.solar_access_c,
                    case when ptc.plan_type_c_created_by_id is null and ptc.created_by_id is not null then
                           2495780::bigint
                         else
                           ptc.plan_type_c_created_by_id end as plan_type_c_created_by_id,
                    ptc.sun_vault_retail_value_c,
                    mcc.name as mcc_name,
                    mcc.wattage_c,
                    mcc.id as MODULE_CONFIGURATION_C_id ,
                    ic.manufacturer_c,
                    lov1.id as lov1_CFI_C_id,
                    lov2.id as lov2_code_level_c_id,
                    lov3.id as lov3_manufacturer_c_id,
                    p.id             as project_id,
                    co.id            as community_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY co.id ORDER BY co.id) = 1 THEN TRUE
                      ELSE FALSE END AS is_first_row
             from brs.plan_type_c ptc
                    left join brs.MODULE_CONFIGURATION_C mcc on mcc.id = ptc.module_configuration_1_c
                    left join brs.item_c ic on ic.id = mcc.item_c
                    inner join brs.NH_COMMUNITY_C co on co.id = ptc.community_c
                    inner join flow.project p on p.nw_migration_id = co.id
                    left join flow.list_of_value lov1 on lov1.name = ptc.CFI_C and lov1.parent_id = 25293
                    left join flow.list_of_value lov2 on lov2.name = ptc.code_level_c and lov2.parent_id = 25300
                    left join flow.list_of_value lov3 on lov3.name = ic.manufacturer_c and lov3.parent_id = 25824
             where ptc.is_deleted = false
             order by co.id
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;

        if y.is_first_row is true then
          v_project_process_step_plan_id = null;
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (y.project_id, 3756, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                  y.community_id)
          returning id into v_project_process_step_plan_id;
        end if;



            v_project_process_step_plan_event_id = null;
            insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                        company_event_status_type_id, start_time, end_time,
                                                        date_created,
                                                        date_modified, created_by_id, modified_by_id, archived,
                                                        cancelled_date, completed_date, scheduled_date, save_version,nw_migration_id)
            values (v_project_process_step_plan_id, 236, null, 3, null, null, now(), now(), 2384850, 2384850, false, null,
                    null, null, 1,y.plan_type_id)
            returning id into v_project_process_step_plan_event_id;

            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28099, y.plan_type_c_created_by_id::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28098, y.NAME::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28100, y.ADDITIONAL_COST_FOR_STORAGE_C::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28101, y.BASE_SQUARE_FOOTAGE_C::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28102, y.lov1_CFI_C_id::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28103, y.lov2_code_level_c_id::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28104, y.flat_monthly_tpo_rate_c::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28105, y.min_system_size_watts_c::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 29845, y.mcc_name::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 29846, y.wattage_c::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 29850, y.lov3_manufacturer_c_id::text,true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28107, y.modules_c::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28108, y.retail_value_c::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28109, y.solar_access_c::text, true);
            perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28110, y.sun_vault_retail_value_c::text,true);

            if y.MODULE_CONFIGURATION_C_id is not null and y.modules_c is not null and y.modules_c > 0 and
               y.wattage_c is not null and y.wattage_c > 0 then
              v_system_wattage = y.modules_c::numeric * y.wattage_c::numeric;
              perform flow.set_pps_event_cfv_no_checks(v_project_process_step_plan_event_id, 2384850, 28111, v_system_wattage::text,true);
            end if;
          end loop;

    raise notice '3 END = %',clock_timestamp();
    raise notice '3 END total = %',v_total;
  end
$do$;
