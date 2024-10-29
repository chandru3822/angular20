DO
$do$
  declare
    s                                       record;
    v_count                                 bigint;
    v_total                                 bigint;
    v_project_process_step_pricing_id       bigint;
    v_project_process_step_pricing_event_id bigint;
  BEGIN
    raise notice '3 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for s in select bpc.id                                                                                         as builder_pricing_id,
                    bpc.active_c,
                    bpc.cash_incentive_fee_c,
                    bpc.lease_incentive_fee_c,
                    bpc.nem_3_0_lease_incentives_c,
                    bpc.net_contracted_price_c,
                    bpc.notes_c,
                    case
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytBSAS' then 26002
                      when bpc.storage_configuration_group_c = 'aCv2T000000Kyt6SAC' then 26001
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytfSAC' then 26003
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytGSAS' then 26000
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytkSAC' then 25996
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytpSAC' then 25997
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytuSAC' then 25998
                      when bpc.storage_configuration_group_c = 'aCv2T000000KytzSAC' then 25999
                      else null end as storage_configuration_group,
                    bpc.storage_price_c,
                    bpc.system_wattage_dc_c,
                    bpc.wrap_insurance_percent_c,
                    lov1.id                                                                                        as lov1_code_year_c,
                    lov2.id                                                                                        as lov2_storage_size_c,
                    p.id                                                                                           as project_id,
                    ncc.id                                                                                         as community_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY ncc.id ORDER BY ncc.id) = 1 THEN TRUE
                      ELSE FALSE END                                                                               AS is_first_row
             from brs.builder_pricing_c bpc
                    inner join brs.nh_community_c ncc on bpc.community_c = ncc.id
                    inner join flow.project p on p.nw_migration_id = ncc.id
                    left join flow.list_of_value lov1 on lov1.name = bpc.code_year_c and lov1.parent_id = 25300
                    left join flow.list_of_value lov2 on lov2.name = bpc.storage_size_c and lov2.parent_id = 25562
                    order by ncc.id
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;

        if s.is_first_row is true then
          v_project_process_step_pricing_id = null;
          insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                 company_process_step_status_type_id,
                                                 process_step_complete_date, date_created, date_modified, created_by_id,
                                                 modified_by_id, archived, main, parent_project_process_step_id,
                                                 cancelled_date, parent_project_process_step_event_id, nw_migration_id)
          values (s.project_id, 3789, null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                  s.community_id)
          returning id into v_project_process_step_pricing_id;
        end if;

        v_project_process_step_pricing_event_id = null;
        insert into flow.project_process_step_event(project_process_step_id, process_step_event_id, resource_id,
                                                    company_event_status_type_id, start_time, end_time,
                                                    date_created,
                                                    date_modified, created_by_id, modified_by_id, archived,
                                                    cancelled_date, completed_date, scheduled_date, save_version,
                                                    nw_migration_id)
        values (v_project_process_step_pricing_id, 239, null, 3, null, null, now(), now(), 2384850, 2384850, false,
                null,
                null, null, 1, s.builder_pricing_id)
        returning id into v_project_process_step_pricing_event_id;

        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28732,
                                                 s.active_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28572,
                                                 s.cash_incentive_fee_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28574,
                                                 s.lov1_code_year_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28575,
                                                 s.lease_incentive_fee_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28576,
                                                 s.nem_3_0_lease_incentives_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28585,
                                                 s.net_contracted_price_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28570,
                                                 s.notes_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 29873,
                                                 s.storage_configuration_group::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28580,
                                                 s.storage_price_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28834,
                                                 s.lov2_storage_size_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28582,
                                                 s.system_wattage_dc_c::text, true);
        perform flow.set_pps_event_cfv_no_checks(v_project_process_step_pricing_event_id, 2384850, 28583,
                                                 s.wrap_insurance_percent_c::text, true);
      end loop;
    raise notice '3 END = %',clock_timestamp();
    raise notice '3 END total = %',v_total;
  end
$do$;
