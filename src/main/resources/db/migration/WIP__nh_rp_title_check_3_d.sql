SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_count bigint;
    v_total bigint;
    v_project_process_step_id bigint;
  BEGIN
    raise notice '7 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select p.id as project_id,
                    tcc.id as title_check_id,
                    tcc.alternate_apn_c,
                    tcc.apn_c,
                    tcc.census_block_c,
                    tcc.census_block_group_c,
                    tcc.census_tract_c,
                    tcc.comments_c,
                    tcc.external_property_id_c,
                    tcc.county_c,
                    tcc.county_use_c,
                    tcc.county_use_code_c,
                    tcc.land_use_c,
                    tcc.land_use_code_c,
                    tcc.legal_block_c,
                    tcc.legal_description_c,
                    tcc.legal_lot_c,
                    tcc.mailing_city_state_c,
                    tcc.mailing_street_c,
                    tcc.mailing_zip_c,
                    tcc.map_reference_c,
                    tcc.map_reference_2_c,
                    tcc.municipality_c,
                    tcc.owner_first_name_c,
                    tcc.owner_last_name_c,
                    tcc.owner_name_c,
                    tcc.property_city_c,
                    tcc.property_state_c,
                    tcc.property_street_c,
                    tcc.property_zip_c,
                    tcc.recording_date_c,
                    tcc.sale_date_c,
                    tcc.secondary_owner_c,
                    tcc.seller_name_c,
                    tcc.state_use_c,
                    tcc.state_use_code_c,
                    tcc.subdivision_c,
                    tcc.township_c,
                    tcc.township_range_section_c,
                    tcc.vesting_code_c,
                    lov1.id as lov1_action_taken_c_id,
                    CASE WHEN row_number() OVER (PARTITION BY tcc.account_c ORDER BY tcc.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
             from brs.title_check_c tcc
                    inner join flow.contact c on c.nw_migration_id = tcc.account_c
                    inner join flow.project p on p.contact_id = c.id
                    left join flow.list_of_value lov1 on lov1.name = tcc.action_taken_c and lov1.parent_id = 25729
             where tcc.is_deleted = false
             order by tcc.account_c,tcc.created_date

      loop
        v_project_process_step_id = null;
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id,nw_migration_id)
        values (x.project_id, 3794, null, case when x.is_last_row is true then 1 else 2 end,
                null, now(), now(), 2384850, 2384850, false, case when x.is_last_row is true then true else false end, null, null, null,x.title_check_id)
        returning id into v_project_process_step_id;

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28838,x.lov1_action_taken_c_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28839,x.alternate_apn_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28840,x.apn_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28841,x.census_block_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28842,x.census_block_group_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28843,x.census_tract_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28844,x.comments_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28845,x.external_property_id_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28846,x.county_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28847,x.county_use_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28848,x.county_use_code_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28849,x.land_use_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28850,x.land_use_code_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28851,x.legal_block_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28852,x.legal_description_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28853,x.legal_lot_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28855,x.mailing_city_state_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28856,x.mailing_street_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28857,x.mailing_zip_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28858,x.map_reference_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28859,x.map_reference_2_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28860,x.municipality_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28861,x.owner_first_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28862,x.owner_last_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28863,x.owner_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28864,x.property_city_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28865,x.property_state_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28866,x.property_street_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28867,x.property_zip_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28868,x.recording_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28869,x.sale_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28870,x.secondary_owner_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28871,x.seller_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28872,x.state_use_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28873,x.state_use_code_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28885,x.subdivision_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28874,x.township_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28875,x.township_range_section_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,28876,x.vesting_code_c::text, true);
      end loop;
    raise notice '7 END = %',clock_timestamp();
    raise notice '7 END total = %',v_total;
  end
$do$;
