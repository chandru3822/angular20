SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_object_category_id bigint;
    v_contact_id bigint;
    v_project_id bigint;
    v_object_category_project_id bigint;
    v_system_adders_c bigint[];
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '4 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    select oc.id
    into v_object_category_project_id
    from flow.object_category oc
    where object_category_code = 'NEW_HOME' and object_type_id = 1;
    for x in select a2.homeowner_preferred_name_c,a2.id as homeowner_id,
                    a2.billing_street,
                    a2.billing_city,
                    a2.billing_postal_code,
                    a2.phone,
                    a2.email_c,
                    a2.name as account_name,
                    a.homeowner_preferred_name_c as builder_homeowner_preferred_name_c,
                    a.billing_street as builder_billing_street,
                    a.billing_city as builder_billing_city,
                    a.billing_postal_code as builder_billing_postal_code,
                    a.phone as builder_phone,
                    a.email_c as builder_email_c,
                    cs.id as company_state_id,
                    rpc.record_type_id,
                    rpc.project_number_c,
                    rpc.lot_number_c,
                    rpc.elevation_c,
                    rpc.enhancements_c,
                    rpc.structural_option_c,
                    rpc.pto_date_c,
                    rpc.ntp_date_c,
                    rpc.esd_date_c,
                    rpc.sales_order_complete_date_c,
                    rpc.phase_c,
                    rpc.closed_won_date_nh_c,
                    rpc.est_escrow_date_c,
                    rpc.lines_ready_to_submit_c,
                    rpc.sales_order_number_c,
                    rpc.escrow_date_ho_c,
                    rpc.auto_booked_c,
                    rpc.ho_provided_escrow_response_c,
                    rpc.historical_sales_order_number_c,
                    rpc.scheduled_installation_date_c,
                    rpc.oracle_order_header_id_c,
                    rpc.first_scheduled_installation_date_c,
                    rpc.amendment_reconciled_c,
                    rpc.unblock_quote_amendment_c,
                    rpc.solar_access_c,
                    rpc.scheduled_ahj_inspection_c,
                    rpc.milestone_c,
                    rpc.rev_rec_date_c,
                    rpc.misc_notes_c,
                    rpc.forecasted_unblock_date_c,
                    rpc.hoa_submission_date_c,
                    rpc.escrow_date_c,
                    rpc.number_of_panels_c,
                    rpc.inverter_quantity_c,
                    rpc.system_wattage_ac_c,
                    rpc.system_wattage_dc_c,
                    rpc.requested_delivery_date_c,
                    rpc.scheduled_arrival_date_c,
                    rpc.material_shipped_date_c,
                    rpc.builder_wo_storage_price_c,
                    rpc.material_delivery_date_c,
                    rpc.storage_system_c,
                    rpc.roof_1_system_orientation_c,
                    rpc.design_required_c,
                    rpc.roof_1_no_of_modules_c,
                    rpc.actual_time_hours_c,
                    rpc.roof_2_system_orientation_c,
                    rpc.roof_2_no_of_modules_c,
                    rpc.further_discount_percent_c,
                    rpc.total_number_of_sets_proj_c,
                    rpc.roof_3_system_orientation_c,
                    rpc.number_of_split_arrays_c,
                    rpc.roof_3_no_of_modules_c,
                    rpc.design_notes_c,
                    rpc.roof_4_system_orientation_c,
                    rpc.permit_execution_fees_c,
                    rpc.roof_4_no_of_modules_c,
                    rpc.permit_eta_c,
                    rpc.previous_permit_eta_c,
                    rpc.sun_power_permit_override_c,
                    rpc.builder_wo_c,
                    rpc.builder_wo_date_of_receipt_c,
                    rpc.storage_size_discrepancy_c,
                    rpc.wo_price_c,
                    rpc.wo_system_size_w_c,
                    rpc.storage_price_discrepancy_c,
                    rpc.wo_storage_price_c,
                    rpc.module_count_discrepancy_c,
                    rpc.builder_wo_value_c,
                    --rpc.builder_wo_value_c,
                    rpc.additional_builder_services_wo_c,
                    rpc.wrap_insurance_amount_c,
                    rpc.addtl_builder_services_wodateof_receipt_c,
                    rpc.total_sovalue_c,
                    rpc.additional_builder_services_wo_value_c,
                    rpc.further_discount_amount_c,
                    rpc.builder_incentive_value_c,
                    rpc.further_discount_rationale_c,
                    rpc.model_discount_percent_c,
                    rpc.model_discount_amount_c,
                    rpc.sunvault_model_discount_c,
                    rpc.sunvault_model_discount_amount_c,
                    rpc.trim_labor_pricing_c,
                    rpc.pv_trim_po_c,
                    rpc.rough_wire_wo_c,
                    rpc.trench_date_promised_c,
                    rpc.rough_wire_wo_date_receipt_c,
                    rpc.trench_started_c,
                    rpc.customer_street_text_c,
                    ncc.state_c,
                    ncc.city_location_c,
                    ncc.zip_code_c,
                    rpc.rough_wire_wo_value_c,
                    rpc.trench_date_c,
                    rpc.rough_labor_pricing_c,
                    rpc.pv_rough_po_c,
                    rpc.rough_wire_promised_c,
                    rpc.roofer_labor_pricing_c,
                    rpc.pv_install_promised_c,
                    rpc.roofer_inset_po_c,
                    rpc.trim_promised_c,
                    rpc.ready_for_rough_wire_checkbox_c,
                    rpc.ready_for_install_checkbox_c,
                    rpc.ready_for_rough_wire_c,
                    rpc.ready_for_install_c,
                    rpc.roughwire_complete_c,
                    rpc.pv_install_complete_c,
                    rpc.pv_install_completed_c,
                    rpc.rough_wire_completed_c,
                    rpc.rough_wire_pull_date_c,
                    rpc.trim_install_complete_c,
                    rpc.pre_coe_commissioning_pricing_c,
                    rpc.trim_install_completed_c,
                    rpc.trim_install_pull_date_c,
                    rpc.install_complete_c,
                    rpc.install_completed_c,
                    rpc.pre_coe_comm_notes_c,
                    rpc.storage_rw_c,
                    rpc.install_pull_date_c,
                    rpc.utility_meter_confirmation_date_c,
                    rpc.inspection_price_c,
                    rpc.serial_number_c,
                    rpc.permit_cost_actual_c,
                    rpc.wi_fi_connected_c,
                    rpc.adders_value_c,
                    rpc.follow_up_date_c,
                    rpc.commitment_date_c,
                    rpc.storage_rough_po_c,
                    rpc.site_id_c,
                    rpc.storage_trim_po_c,
                    rpc.storage_rough_wire_promised_c,
                    rpc.storage_install_promised_c,
                    rpc.storage_rough_complete_c,
                    rpc.storage_rough_complete_date_c,
                    rpc.storage_rough_complete_pull_date_c,
                    rpc.storage_install_complete_c,
                    rpc.storage_install_complete_date_c,
                    rpc.storage_install_complete_pull_date_c,
                    rpc.rebate_reservation_expiry_date_lot_c,
                    rpc.hers_inspection_notes_c,
                    rpc.solar_rebate_actual_c,
                    rpc.pv_id_c,
                    rpc.solar_rebate_expected_c,
                    rpc.rebate_reservation_confirmation_lot_c,
                    rpc.rebate_claim_notes_c,
                    rpc.cf_2_r_c,
                    rpc.energy_efficiency_code_c,
                    rpc.rebate_claim_submitted_c,
                    rpc.hers_inspection_completed_c,
                    rpc.storage_install_c,
                    rpc.rebate_claim_approved_c,
                    rpc.utility_application_id_c,
                    rpc.t_24_notes_c,
                    rpc.utility_account_number_c,
                    rpc.utility_meter_number_c,
                    rpc.hers_certificate_received_c,
                    rpc.interconnection_notes_c,
                    rpc.adders_value_quote_c,
                    rpc.rebate_claim_expiry_date_c,
                    rpc.gate_code_c,
                    rpc.roof_material_c,
                    rpc.hoa_name_c,
                    rpc.hoa_contact_phone_email_c,
                    rpc.age_of_roof_c,
                    rpc.intake_notes_c,
                    rpc.age_of_home_c,
                    rpc.storage_install_completed_by_c,
                    -- rpc.storage_rough_completed_c,
                    rpc.install_completed_by_c,
                    rpc.trim_install_completed_by_c,
                    rpc.pv_install_completed_by_c,
                    rpc.rough_wire_completed_by_c,
                    rpc.trench_completed_by_c,
                    rpc.activation_coordinator_c,
                    rpc.storage_rough_completed_by_c,
                    c2.id as builder_contact_id,
                    p.id as community_project_id,
                    p.contact_id as community_contact_id,
                    lov1.id as  lov1_priority_c,
                    lov2.id as  lov2_cancellation_justification_c,
                    lov3.id as  lov3_sun_power_deal_type_c,
                    lov4.id as  lov4_sun_vault_deal_type_c,
                    lov5.id as  lov5_rescheduled_reason_code_c,
                    lov6.id as  lov6_rp_fields_and_builder_files_validated_c,
                    lov7.id as  lov7_block_reason_c,
                    lov8.id as  lov8_monitoring_c,
                    lov9.id as  lov9_roof_attachment_c,
                    lov10.id as lov10_smart_thermostat_c,
                    lov11.id as lov11_thermostat_manufacturer_c,
                    lov12.id as lov12_thermostat_model_c,
                    lov13.id as lov13_installation_type_c,
                    lov14.id as lov14_roof_type_c,
                    lov15.id as lov15_type_of_design_c,
                    lov16.id as lov16_roof_1_pitch_c,
                    lov17.id as lov17_proposed_solar_breaker_installed_in_msp_c,
                    lov18.id as lov18_pdf_copy_only_c,
                    lov19.id as lov19_roof_2_pitch_c,
                    lov20.id as lov20_roof_3_pitch_c,
                    lov21.id as lov21_roof_4_pitch_c,
                    lov22.id as lov22_further_discount_status_c,
                    lov23.id as lov23_microinverter_status_c,
                    lov24.id as lov24_pre_coe_comm_failure_reason_c,
                    lov25.id as lov25_utility_meter_installed_c,
                    lov26.id as lov26_system_activation_status_c,
                    lov27.id as lov27_rse_outcome_c,
                    lov28.id as lov28_pv_hers_certification_type_c,
                    lov29.id as lov29_nem_applicability_c,
                    lov30.id as lov30_internet_access_c,
                    lov31.id as lov31_preferred_communication_c,
                    lov32.id as lov32_tree_trim_c,
                    lov33.id as lov33_attic_crawl_space_c,
                    lov34.id as lov34_dog_on_site_c,
                    lov35.id as lov35_customer_construction_project_c,
                    lov36.id as lov36_complexity_indicator_c,
                    lov44.id as lov44_manufacturer_c_id,
                    lov46.id as lov46_hers_c_id,
                    lov47.id as lov47_mounting_type_c_id,
                    lov48.id as lov48_evse_count_c_id,
                    rpc.ev_charger_retail_amount_c,
                    rpc.scheduled_ev_installation_date_c,
                    rpc.status_c,
                    pcfv1.int_value as utility_id,
                    pcfv.int_value as ahj_id,
                    rpc.name,
                    rpc.system_adders_c,
                    rpc.id,
                    case when rpc.residential_project_c_activation_coordinator_c is null and rpc.activation_coordinator_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_activation_coordinator_c end as residential_project_c_activation_coordinator_c,
                    case when rpc.residential_project_c_trim_install_completed_by_c is null and rpc.trim_install_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_trim_install_completed_by_c end as residential_project_c_trim_install_completed_by_c,
                    case when rpc.residential_project_c_install_completed_by_c is null and rpc.install_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_install_completed_by_c end as residential_project_c_install_completed_by_c,

                    mcc.name mcc_name,
                    mcc.wattage_c,
                    ic.manufacturer_c,
                    rpc.module_configuration_c,
                    case when rpc.residential_project_c_trench_completed_by_c is null and rpc.trench_completed_by_c is not null then
                           2495780::bigint
                    else
                    rpc.residential_project_c_trench_completed_by_c end as residential_project_c_trench_completed_by_c,
                    case when rpc.residential_project_c_rough_wire_completed_by_c is null and rpc.rough_wire_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_rough_wire_completed_by_c end as residential_project_c_rough_wire_completed_by_c,
                    case when rpc.residential_project_c_pv_install_completed_by_c is null and rpc.pv_install_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_pv_install_completed_by_c end as residential_project_c_pv_install_completed_by_c,
                    case when rpc.residential_project_c_storage_rough_completed_by_c is null and rpc.storage_rough_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_storage_rough_completed_by_c end as residential_project_c_storage_rough_completed_by_c,
                    case when rpc.residential_project_c_storage_install_completed_by_c is null and rpc.storage_install_completed_by_c is not null then
                           2495780::bigint
                         else
                           rpc.residential_project_c_storage_install_completed_by_c end as residential_project_c_storage_install_completed_by_c,
                    case
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytBSAS' then 26002::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000Kyt6SAC' then 26001::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytfSAC' then 26003::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytGSAS' then 26000::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytkSAC' then 25996::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytpSAC' then 25997::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytuSAC' then 25998::text
                      when rpc.storage_configuration_group_c = 'aCv2T000000KytzSAC' then 25999::text
                      else null end as storage_configuration_group,
               lov45.id as lov45_microinverter_status_c_id,
                    concat(su.first_name,' ',su.email) as   install_completed_by_c_name,
                    concat(su1.first_name,' ',su1.email) as pv_install_completed_by_c_name,
                    concat(su2.first_name,' ',su2.email) as rough_wire_completed_by_c_name,
                    concat(su3.first_name,' ',su3.email) as storage_install_completed_by_c_name,
                    concat(su4.first_name,' ',su4.email) as storage_rough_completed_by_c_name,
                    concat(su5.first_name,' ',su5.email) as trench_completed_by_c_name,
                    concat(su6.first_name,' ',su6.email) as trim_install_completed_by_c_name,
                    concat(su7.first_name,' ',su7.email) as activation_coordinator_c_name,
                    pt.name as plan_type_name
             from brs.residential_project_c rpc
                    left join brs.plan_type_c pt on pt.id = rpc.PLAN_TYPE_C
                    left join brs.sp_user su on su.id =   rpc.install_completed_by_c
                    left join brs.sp_user su1 on su1.id = rpc.pv_install_completed_by_c
                    left join brs.sp_user su2 on su2.id = rpc.rough_wire_completed_by_c
                    left join brs.sp_user su3 on su3.id = rpc.storage_install_completed_by_c
                    left join brs.sp_user su4 on su4.id = rpc.storage_rough_completed_by_c
                    left join brs.sp_user su5 on su5.id = rpc.trench_completed_by_c
                    left join brs.sp_user su6 on su6.id = rpc.trim_install_completed_by_c
                    left join brs.sp_user su7 on su7.id = rpc.activation_coordinator_c
                    inner join brs.nh_community_c ncc on ncc.id = rpc.community_c
                    left join brs.MODULE_CONFIGURATION_C mcc on mcc.id = rpc.module_configuration_c
                    left join brs.item_c ic on ic.id = mcc.item_c
                    left join flow.project p on p.nw_migration_id = ncc.id
                    left join flow.project_custom_field_value pcfv on pcfv.project_id = p.id and pcfv.custom_field_group_assignment_id = 1048
                    left join flow.project_custom_field_value pcfv1 on pcfv1.project_id = p.id and pcfv1.custom_field_group_assignment_id = 1049
                    left join brs.account a on a.id = ncc.builder_c
                    left join flow.contact c2 on c2.nw_migration_id = a.id
                    left join brs.account a2 on a2.id = rpc.account_c and a2.type in ('Home Owner – SSE','Home Owner','Homeowner')
                    left join flow.state s on s.abbreviation = ncc.state_c
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov1 on lov1.name =   rpc.priority_c and lov1.parent_id =25516
                    left join flow.list_of_value lov2 on lov2.name =   rpc.cancellation_justification_c and lov2.parent_id =25520
                    left join flow.list_of_value lov3 on lov3.name =   rpc.sun_power_deal_type_c and lov3.parent_id =25524
                    left join flow.list_of_value lov4 on lov4.name =   rpc.sun_vault_deal_type_c and lov4.parent_id =25528
                    left join flow.list_of_value lov5 on lov5.name =   rpc.rescheduled_reason_code_c and lov5.parent_id =25544
                    left join flow.list_of_value lov6 on lov6.name =   rpc.rp_fields_and_builder_files_validated_c and lov6.parent_id =25542
                    left join flow.list_of_value lov7 on lov7.name =   rpc.block_reason_c and lov7.parent_id =25540
                    left join flow.list_of_value lov8 on lov8.name =   rpc.monitoring_c and lov8.parent_id =25538
                    left join flow.list_of_value lov9 on lov9.name =   rpc.roof_attachment_c and lov9.parent_id =25538
                    left join flow.list_of_value lov10 on lov10.name = rpc.smart_thermostat_c and lov10.parent_id =25532
                    left join flow.list_of_value lov11 on lov11.name = rpc.thermostat_manufacturer_c and lov11.parent_id =25522
                    left join flow.list_of_value lov12 on lov12.name = rpc.thermostat_model_c and lov12.parent_id =25518
                    left join flow.list_of_value lov13 on lov13.name = rpc.installation_type_c and lov13.parent_id =25266
                    left join flow.list_of_value lov14 on lov14.name = rpc.roof_type_c and lov14.parent_id =25264
                    left join flow.list_of_value lov15 on lov15.name = rpc.type_of_design_c and lov15.parent_id =25510
                    left join flow.list_of_value lov16 on lov16.name = rpc.roof_1_pitch_c and lov16.parent_id =25508
                    left join flow.list_of_value lov17 on lov17.name = rpc.proposed_solar_breaker_installed_in_msp_c and lov17.parent_id =25506
                    left join flow.list_of_value lov18 on lov18.name = rpc.pdf_copy_only_c and lov18.parent_id =25504
                    left join flow.list_of_value lov19 on lov19.name = rpc.roof_2_pitch_c and lov19.parent_id =25502
                    left join flow.list_of_value lov20 on lov20.name = rpc.roof_3_pitch_c and lov20.parent_id =25430
                    left join flow.list_of_value lov21 on lov21.name = rpc.roof_4_pitch_c and lov21.parent_id =25436
                    left join flow.list_of_value lov22 on lov22.name = rpc.further_discount_status_c and lov22.parent_id =25485
                    left join flow.list_of_value lov23 on lov23.name = rpc.microinverter_status_c and lov23.parent_id =25500
                    left join flow.list_of_value lov24 on lov24.name = rpc.pre_coe_comm_failure_reason_c and lov24.parent_id =25487
                    left join flow.list_of_value lov25 on lov25.name = rpc.utility_meter_installed_c and lov25.parent_id =25482
                    left join flow.list_of_value lov26 on lov26.name = rpc.system_activation_status_c and lov26.parent_id =25444
                    left join flow.list_of_value lov27 on lov27.name = rpc.rse_outcome_c and lov27.parent_id =25438
                    left join flow.list_of_value lov28 on lov28.name = rpc.pv_hers_certification_type_c and lov28.parent_id =25432
                    left join flow.list_of_value lov29 on lov29.name = rpc.nem_applicability_c and lov29.parent_id =25427
                    left join flow.list_of_value lov30 on lov30.name = rpc.internet_access_c and lov30.parent_id =25425
                    left join flow.list_of_value lov31 on lov31.name = rpc.preferred_communication_c and lov31.parent_id =25423
                    left join flow.list_of_value lov32 on lov32.name = rpc.tree_trim_c and lov32.parent_id =25421
                    left join flow.list_of_value lov33 on lov33.name = rpc.attic_crawl_space_c and lov33.parent_id =25419
                    left join flow.list_of_value lov34 on lov34.name = rpc.dog_on_site_c and lov34.parent_id =25417
                    left join flow.list_of_value lov35 on lov35.name = rpc.customer_construction_project_c and lov35.parent_id =25415
                    left join flow.list_of_value lov36 on lov36.name = rpc.complexity_indicator_c and lov36.parent_id =25413
                    left join flow.list_of_value lov44 on lov44.name = ic.manufacturer_c and lov44.parent_id = 25824
                    left join flow.list_of_value lov45 on lov45.name = rpc.microinverter_status_c and lov45.parent_id = 25498
                    left join flow.list_of_value lov46 on lov46.name = rpc.hers_c and lov46.parent_id = 25434
                    left join flow.list_of_value lov47 on lov47.name = rpc.mounting_type_c and lov47.parent_id = 25258
                    left join flow.list_of_value lov48 on lov48.name = rpc.evse_count_c and lov48.parent_id = 26283
      where rpc.is_deleted = false
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          raise notice 'v_total = %',v_total;
          --commit;
          v_count = 0;
        end if;
        v_contact_id = null;
        v_object_category_id = null;
        if x.homeowner_id is not null then
          select oc.id
          into v_object_category_id
          from flow.object_category oc
          where object_category_code = 'LOT_OWNER'
            and object_type_id = 2;
          insert into flow.contact(contact_type_id, first_name, last_name, street1, street2, city, postal_code,
                                   phone, email, mobile, date_created, date_modified,
                                   created_by_id, modified_by_id, company_id, archived,
                                   company_state_id,
                                   company_country_id, nw_migration_id, object_category_id)
          values (1, x.account_name, null, x.customer_street_text_c, null, x.city_location_c, substr(x.zip_code_c,1,10), x.phone, x.email_c,
                  x.phone, now(), now(), 2384850, 2384850, 3, false,
                  x.company_state_id, 1, x.homeowner_id,v_object_category_id) returning id into v_contact_id;
        end if;
        insert into flow.project(contact_id, company_process_id, project_name, date_created, date_modified,
                                 created_by_id, modified_by_id, company_project_status_type_id,
                                 street1, street2, city, postal_code,
                                 company_state_id, company_country_id,
                                 archived, cancelled_date, nw_migration_id,object_category_id,parent_id)
        values(coalesce(v_contact_id,x.community_contact_id),27,x.name,now(),now(),2384850,2384850,
               case when x.status_c is null then 223
                    when x.status_c = 'Hold' then 224
                    when x.status_c = 'On Hold' then 224
                    when x.status_c = 'Active' then 223
                    when x.status_c = 'At Risk' then 230
                    when x.status_c = 'Pending Cancellation' then 229
                    when x.status_c = 'Cancelled' then 225
                    when x.status_c = 'Completed' then 228 end,
              x.customer_street_text_c,null,x.city_location_c,
               x.zip_code_c,x.company_state_id,1,false,null,x.id,
               v_object_category_project_id,x.community_project_id
              ) returning id into v_project_id;
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29874,x.plan_type_name::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1048,x.ahj_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1049,x.utility_id::text , true);

        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28122,x.record_type_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28675,x.project_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28127,x.lot_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28128,x.elevation_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28129,x.enhancements_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28130,x.structural_option_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28131,x.residential_project_c_activation_coordinator_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28132,x.pto_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28133,x.ntp_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28134,x.esd_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28135,x.sales_order_complete_date_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28136,x.phase_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28138,x.closed_won_date_nh_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28139,x.est_escrow_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28141,x.lines_ready_to_submit_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28142,x.sales_order_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28144,x.escrow_date_ho_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28146,x.auto_booked_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28148,x.ho_provided_escrow_response_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28149,x.historical_sales_order_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28151,x.scheduled_installation_date_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28169,x.oracle_order_header_id_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28153,x.first_scheduled_installation_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28159,x.amendment_reconciled_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28161,x.unblock_quote_amendment_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28174,x.solar_access_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28176,x.scheduled_ahj_inspection_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28185,x.milestone_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28186,x.rev_rec_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28188,x.misc_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28191,x.forecasted_unblock_date_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28192,x.hoa_submission_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28835,x.escrow_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29875,x.module_configuration_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29847,x.mcc_name::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29848,x.wattage_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29849,x.lov44_manufacturer_c_id::text, true);



        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28218,x.number_of_panels_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28220,x.inverter_quantity_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28221,x.system_wattage_ac_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28224,x.system_wattage_dc_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28231,x.requested_delivery_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28234,x.scheduled_arrival_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28237,x.material_shipped_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28243,x.material_delivery_date_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28244,x.storage_system_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28252,x.roof_1_system_orientation_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28253,x.design_required_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28255,x.roof_1_no_of_modules_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28257,x.actual_time_hours_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28260,x.roof_2_system_orientation_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28263,x.roof_2_no_of_modules_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28265,x.total_number_of_sets_proj_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28267,x.roof_3_system_orientation_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28268,x.number_of_split_arrays_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28269,x.roof_3_no_of_modules_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28270,x.design_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28272,x.roof_4_system_orientation_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28273,x.permit_execution_fees_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28274,x.roof_4_no_of_modules_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28275,x.permit_eta_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28277,x.previous_permit_eta_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28278,x.sun_power_permit_override_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28279,x.builder_wo_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28280,x.builder_wo_date_of_receipt_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28281,x.storage_size_discrepancy_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28282,x.wo_price_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28283,x.wo_system_size_w_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28284,x.storage_price_discrepancy_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28285,x.wo_storage_price_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28286,x.module_count_discrepancy_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28287,x.builder_wo_value_c::text, true);

        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28288,x.builder_wo_storage_price_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28289,x.additional_builder_services_wo_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28291,x.wrap_insurance_amount_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28292,x.addtl_builder_services_wodateof_receipt_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28293,x.total_sovalue_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28294,x.additional_builder_services_wo_value_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28295,x.further_discount_amount_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28296,x.builder_incentive_value_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28297,x.further_discount_rationale_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28298,x.model_discount_percent_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28301,x.model_discount_amount_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28303,x.sunvault_model_discount_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28304,x.sunvault_model_discount_amount_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28837,x.further_discount_percent_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28213,x.trim_labor_pricing_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28215,x.pv_trim_po_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28216,x.rough_wire_wo_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28217,x.trench_date_promised_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28219,x.rough_wire_wo_date_receipt_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28222,x.trench_started_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28225,x.rough_wire_wo_value_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28227,x.trench_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28230,x.rough_labor_pricing_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28232,x.residential_project_c_trench_completed_by_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28235,x.pv_rough_po_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28238,x.rough_wire_promised_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28240,x.roofer_labor_pricing_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28241,x.pv_install_promised_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28242,x.roofer_inset_po_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28246,x.trim_promised_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28248,x.ready_for_rough_wire_checkbox_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28251,x.ready_for_install_checkbox_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28254,x.ready_for_rough_wire_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28256,x.ready_for_install_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28290,x.roughwire_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28266,x.pv_install_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28299,x.residential_project_c_rough_wire_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28302,x.pv_install_completed_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28261,x.rough_wire_completed_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28306,x.residential_project_c_pv_install_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28307,x.rough_wire_pull_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28308,x.trim_install_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28309,x.pre_coe_commissioning_pricing_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28310,x.trim_install_completed_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28312,x.trim_install_pull_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28314,x.residential_project_c_trim_install_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28316,x.install_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28318,x.residential_project_c_install_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28320,x.install_completed_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28321,x.pre_coe_comm_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28322,x.install_pull_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28323,x.utility_meter_confirmation_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28324,x.inspection_price_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28325,x.serial_number_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28326,x.permit_cost_actual_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28329,x.wi_fi_connected_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28330,x.adders_value_quote_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28332,x.adders_value_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28333,x.follow_up_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28334,x.storage_rw_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28335,x.commitment_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28336,x.storage_rough_po_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28337,x.site_id_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28338,x.storage_install_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28339,x.storage_trim_po_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28340,x.storage_rough_wire_promised_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28341,x.storage_install_promised_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28342,x.storage_rough_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28343,x.storage_rough_complete_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28344,x.residential_project_c_storage_rough_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28345,x.storage_rough_complete_pull_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28346,x.storage_install_complete_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28347,x.storage_install_complete_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28348,x.residential_project_c_storage_install_completed_by_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28349,x.storage_install_complete_pull_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28165,x.rebate_reservation_expiry_date_lot_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28166,x.hers_inspection_notes_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28167,x.solar_rebate_actual_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28168,x.pv_id_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28170,x.solar_rebate_expected_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28171,x.rebate_reservation_confirmation_lot_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28173,x.rebate_claim_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28175,x.cf_2_r_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28178,x.energy_efficiency_code_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28180,x.rebate_claim_submitted_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28181,x.hers_inspection_completed_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28184,x.rebate_claim_approved_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28187,x.utility_application_id_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28190,x.t_24_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28193,x.utility_account_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28195,x.utility_meter_number_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28201,x.hers_certificate_received_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28204,x.interconnection_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28208,x.rebate_claim_expiry_date_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28137,x.gate_code_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28147,x.roof_material_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28150,x.hoa_name_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28734,x.hoa_contact_phone_email_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28156,x.age_of_roof_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28158,x.intake_notes_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28160,x.age_of_home_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28123,x.lov1_priority_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28124,x.lov2_cancellation_justification_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28125,x.lov3_sun_power_deal_type_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28126,x.lov4_sun_vault_deal_type_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28164,x.lov5_rescheduled_reason_code_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28177,x.lov6_rp_fields_and_builder_files_validated_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29189,x.lov7_block_reason_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28223,x.lov8_monitoring_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28228,x.lov9_roof_attachment_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28229,x.lov10_smart_thermostat_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28233,x.lov11_thermostat_manufacturer_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28236,x.lov12_thermostat_model_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28056,x.lov13_installation_type_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28055,x.lov14_roof_type_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28250,x.lov15_type_of_design_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28258,x.lov16_roof_1_pitch_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28259,x.lov17_proposed_solar_breaker_installed_in_msp_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28262,x.lov18_pdf_copy_only_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28264,x.lov19_roof_2_pitch_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28271,x.lov20_roof_3_pitch_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28276,x.lov21_roof_4_pitch_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28300,x.lov22_further_discount_status_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28311,x.lov23_microinverter_status_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28317,x.lov24_pre_coe_comm_failure_reason_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28319,x.lov25_utility_meter_installed_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28327,x.lov26_system_activation_status_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28331,x.lov27_rse_outcome_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28179,x.lov28_pv_hers_certification_type_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28198,x.lov29_nem_applicability_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28140,x.lov30_internet_access_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28143,x.lov31_preferred_communication_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28145,x.lov32_tree_trim_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28733,x.lov33_attic_crawl_space_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28152,x.lov34_dog_on_site_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28154,x.lov35_customer_construction_project_c::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28162,x.lov36_complexity_indicator_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29876,x.storage_configuration_group::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28313,x.lov45_microinverter_status_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28163,x.lov46_hers_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28052,x.lov47_mounting_type_c_id::text , true);


        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29919,x.install_completed_by_c_name::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29920,x.pv_install_completed_by_c_name::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29921,x.rough_wire_completed_by_c_name::text, true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29922,x.storage_install_completed_by_c_name::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29923,x.storage_rough_completed_by_c_name::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29924,x.trench_completed_by_c_name::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29925,x.trim_install_completed_by_c_name::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29918,x.activation_coordinator_c_name::text , true);

        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30023,x.lov48_evse_count_c_id::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30024,x.ev_charger_retail_amount_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30025,x.scheduled_ev_installation_date_c::text , true);
        perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30021,case when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPEQAY' then 26020::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hP9QAI' then 26021::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPOQAY' then 26021::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPJQAY' then 26022::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000001ObZQAU' then 26023::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T000000RSg0QAG' then 26024::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T000000NQCIQA4' then 26025::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T000000NQCSQA4' then 26025::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T000000NQCXQA4' then 26026::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T000000N9IyQAK' then 26027::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPYQAY' then 26028::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPsQAI' then 26028::text
                                                                                 when x.scheduled_ev_installation_date_c::text = 'a772T0000008hPnQAI' then 26029::text else null end, true);


        v_system_adders_c = null;
        if x.system_adders_c is not null then
          select array_agg(lov.id)
          into v_system_adders_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) system_adders_c
                 FROM (
                        SELECT STRING_AGG(system_adders_c, ';') AS aggregated_column
                        from brs.residential_project_c r
                        where r.id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.system_adders_c and lov.parent_id = 25442;
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28328,v_system_adders_c::text, true);
        end if;
       end loop;
    raise notice '4 END = %',clock_timestamp();
    raise notice '4 END total = %',v_total;
  end
$do$;
