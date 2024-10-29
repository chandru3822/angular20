--2 END total = 21189
-- 2 minutes 40 seconds
DO
$do$
  declare
    x                      record;
    v_object_category_id   bigint;
    v_project_id           bigint;
    v_community_adder_c    bigint[];
    v_financial_offering_c bigint[];
    v_roof_attachment_c    bigint[];
    v_count bigint;
    v_total bigint;
    v_contact_id bigint;
  BEGIN
    select id
    into v_contact_id
    from flow.contact c3
    where c3.nw_migration_id = '0012T00001r4xVhQAI';

    v_count = 0;
    v_total = 0;
    raise notice '2 START = %',clock_timestamp();
    select oc.id
    into v_object_category_id
    from flow.object_category oc
    where object_category_code = 'COMMUNITY' and object_type_id = 1;
    for x in select c2.id as contact_id,
                    c.community_id_c,
                    c.number_of_homes_reserved_c,
                    c.sr_community_account_manager_c,
                    c.proposal_link_c,
                    c.account_manager_c,
                    c.expected_community_construction_start_c,
                    c.grand_opening_date_c,
                    c.number_of_homes_in_community_c,
                    c.field_manager_c,
                    c.sr_builder_operation_manager_c,
                    c.utility_c,
                    c.ahj_c,
                    c.builder_initial_submitter_c,
                    c.tract_number_c,
                    c.model_discount_c,
                    c.lease_escalator_c,
                    c.flat_lease_community_c,
                    c.my_sun_power_c,
                    c.bulk_rp_creation_c,
                    c.builder_purchasing_contact_c,
                    c.builder_utility_rep_c,
                    c.community_adder_c,
                    c.distance_adder_c,
                    c.phase_cutover_c,
                    c.prevailing_wage_c,
                    c.prevailing_wage_details_c,
                    c.transition_notes_c,
                    c.utility_considerations_c,
                    c.region_c,
                    c.financial_offering_c,
                    c.preferred_pv_partner_c,
                    c.preferred_storage_partner_c,
                    c.community_superintendent_name_c,
                    c.community_superintendent_email_c,
                    c.community_superintendent_phone_number_c,
                    c.activation_coordinator_c,
                    c.tracking_number_c,
                    c.builder_delivery_info_c,
                    c.permit_ahj_fees_c,
                    c.permitting_notes_c,
                    c.master_permit_c,
                    c.builder_permitting_complete_c,
                    c.cash_pv_module_qty_c,
                    c.right_sized_c,
                    c.sheet_size_c,
                    c.roof_attachment_c,
                    c.multi_family_steep_roof_c,
                    c.custom_community_adder_c,
                    c.custom_adder_description_c,
                    c.storage_c,
                    c.climate_zone_c,
                    c.t_24_code_reserved_c,
                    c.rebate_reservation_expiry_date_c,
                    c.rebate_reservation_confirmation_number_c,
                    c.reservation_amount_per_project_c,
                    c.reserved_kw_c,
                    c.reservation_notes_c,
                    c.reserved_incentive_level_c,
                    c.registry_notes_c,
                    c.builder_hers_rater_c,
                    c.load_application_c,
                    c.load_application_received_c,
                    c.address_list_c,
                    c.address_list_info_complete_c,
                    c.architecture_files_c,
                    c.architecture_files_info_complete_c,
                    c.community_documents_folder_c,
                    c.document_notes_c,
                    c.electrical_diagram_c,
                    c.sequence_sheet_c,
                    c.sequence_sheet_info_complete_c,
                    c.site_plan_c,
                    c.site_plan_info_complete_c,cs.id as company_state_id,lov.id as lov_lease_term_c_id,
                    l.id as l_weeks_prior_to_rough_install_for_cut_off_c_id,
                    l1.id as l1_builder_architect_c_id,
                    l2.id as l1_builder_project_manager_c_id,
                    l3.id as l3_competitor_c_id,
                    l4.id as l4_distribution_type_c_id,
                    l5.id as l5_home_energy_source_c_id,
                    l6.id as l6_multi_family_interconnection_c_id,
                    l7.id as l7_pre_plumb_c_id,
                    l8.id as l8_reason_won_lost_c_id,
                    l9.id as l9_rough_wire_c_id,
                    l10.id as l10_type_of_release_c_id,
                    l11.id as l11_stage_c_id,
                    l12.id as l12_building_type_c_id,
                    l13.id as l13_OWNERSHIP_TYPE_C_id,
                    l15.id as l15_permit_pack_type_c_id,
                    l16.id as l16_PERMITTING_RESPONSIBILITY_C_id,
                    l17.id as l17_ssp_required_c_id,
                    l18.id as l18_ess_permit_pack_type_c_id,
                    l19.id as l19_ess_permitting_responsibility_c_id,
                    l20.id as l20_mounting_type_c_id,
                    l22.id as l22_multi_family_array_c_id,
                    l23.id as l23_roof_type_c_id,
                    l24.id as l24_installation_type_c_id,
                    l25.id as l25_inverter_type_c_id,
                    l26.id as l26_structural_options_enhancements_c_id,
                    l27.id as l27_evse_offering_c_id,
                    l28.id as l28_builder_file_validation_c_id,
                    l29.id as l29_storage_type_c_id,
                    l30.id as l30_storage_backup_type_c_id,
                    l31.id as l31_rebate_program_c_id,
                    l32.id as l32_rebate_payable_to_c_id,
                    l33.id as l33_community_type_c_id,
                    c.community_status_c,
                    c.name,
                    c.id,
                    c.zip_code_c,
                    c.city_location_c,
                    c.IS_DELETED,
                    c.builder_preferred_roofer_c,
                    case when c.nh_community_c_field_manager_c is null and c.field_manager_c is not null then
                           2495780::bigint
                         else
                           c.nh_community_c_field_manager_c end as nh_community_c_field_manager_c,
                    c.iplot_design_notes_c,
                    c.builder_specific_requirements_c,
                    c.ahjname_c,
                    case when c.nh_community_c_account_manager_c is null and c.account_manager_c is not null then
                           2495780::bigint
                         else
                           c.nh_community_c_account_manager_c end as nh_community_c_account_manager_c,
                    case when c.nh_community_c_sr_builder_operation_manager_c is null and c.sr_builder_operation_manager_c is not null then
                           2495780::bigint
                         else
                           c.nh_community_c_sr_builder_operation_manager_c end as nh_community_c_sr_builder_operation_manager_c
             from brs.NH_COMMUNITY_C c
                    left join brs.account a on a.id = c.builder_c
                    left join flow.contact c2 on c2.nw_migration_id = a.id
                    left join flow.state s on s.abbreviation = c.state_c
                    left join flow.company_state cs on cs.state_id = s.id and cs.company_id = 3
                    left join flow.list_of_value lov on lov.name = c.lease_term_c and lov.parent_id = 25216
                    left join flow.list_of_value l on l.name = c.weeks_prior_to_rough_install_for_cut_off_c and l.parent_id = 25214
                    left join flow.list_of_value l1 on l1.name = c.builder_architect_c and l1.parent_id = 25180
                    left join flow.list_of_value l2 on l2.name = c.builder_project_manager_c and l2.parent_id = 25180
                    left join flow.list_of_value l3 on l3.name = c.competitor_c and l3.parent_id =25232
                    left join flow.list_of_value l4 on l4.name = c.distribution_type_c and l4.parent_id =25222
                    left join flow.list_of_value l5 on l5.name = c.home_energy_source_c and l5.parent_id =25242
                    left join flow.list_of_value l6 on l6.name = c.multi_family_interconnection_c and l6.parent_id =25244
                    left join flow.list_of_value l7 on l7.name = c.pre_plumb_c and l7.parent_id =25234
                    left join flow.list_of_value l8 on l8.name = c.reason_won_lost_c and l8.parent_id =25231
                    left join flow.list_of_value l9 on l9.name = c.rough_wire_c and l9.parent_id =25238
                    left join flow.list_of_value l10 on l10.name = c.type_of_release_c and l10.parent_id =25240
                    left join flow.list_of_value l11 on l11.name = c.stage_c and l11.parent_id =25224
                    left join flow.list_of_value l12 on l12.name = c.building_type_c and l12.parent_id =25176
                    left join flow.list_of_value l13 on l13.name = c.OWNERSHIP_TYPE_C and l13.parent_id =25180
                    left join flow.list_of_value l15 on l15.name = c.permit_pack_type_c and l15.parent_id =25246
                    left join flow.list_of_value l16 on l16.name = c.PERMITTING_RESPONSIBILITY_C and l16.parent_id =25248
                    left join flow.list_of_value l17 on l17.name = c.ssp_required_c and l17.parent_id =25250
                    left join flow.list_of_value l18 on l18.name = c.ess_permit_pack_type_c and l18.parent_id =25252
                    left join flow.list_of_value l19 on l19.name = c.ess_permitting_responsibility_c and l19.parent_id =25254
                    left join flow.list_of_value l20 on l20.name = c.mounting_type_c and l20.parent_id =25258
                    left join flow.list_of_value l22 on l22.name = c.multi_family_array_c and l22.parent_id =25262
                    left join flow.list_of_value l23 on l23.name = c.roof_type_c and l23.parent_id =25264
                    left join flow.list_of_value l24 on l24.name = c.installation_type_c and l24.parent_id =25266
                    left join flow.list_of_value l25 on l25.name = c.inverter_type_c and l25.parent_id =25268
                    left join flow.list_of_value l26 on l26.name = c.structural_options_enhancements_c and l26.parent_id =25270
                    left join flow.list_of_value l27 on l27.name = c.evse_offering_c and l27.parent_id =25272
                    left join flow.list_of_value l28 on l28.name = c.builder_file_validation_c and l28.parent_id =25274
                    left join flow.list_of_value l29 on l29.name = c.storage_type_c and l29.parent_id =25171
                    left join flow.list_of_value l30 on l30.name = c.storage_backup_type_c and l30.parent_id =25208
                    left join flow.list_of_value l31 on l31.name = c.rebate_program_c and l31.parent_id =25276
                    left join flow.list_of_value l32 on l32.name = c.rebate_payable_to_c and l32.parent_id =25278
                    left join flow.list_of_value l33 on l33.name = c.community_type_c and l33.parent_id =25162
                    where c.is_deleted is false
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          --commit;
          v_count = 0;
        end if;
        v_project_id = null;
        v_community_adder_c = null;
        v_financial_offering_c = null;
        v_roof_attachment_c = null;
        insert into flow.project( contact_id, company_process_id, project_name, date_created, date_modified,
                                  created_by_id, modified_by_id, company_project_status_type_id,
                                  company_state_id,city,postal_code,
                                  company_country_id, archived,object_category_id,nw_migration_id)
        values(coalesce(x.contact_id,v_contact_id),26,x.name,now(),now(),
               2384850,2384850,case when x.IS_DELETED is true and x.community_status_c is null then 225
                                    when x.community_status_c is null then 223
                                    when x.community_status_c = 'Hold' then 224
                                    when x.community_status_c = 'Active' then 223
                                    when x.community_status_c = 'Cancelled' then 225
                                    when x.community_status_c = 'Construction Complete' then 226
                                    when x.community_status_c = 'Closed' then 227  end,x.company_state_id,x.city_location_c,x.zip_code_c,1,false,v_object_category_id,x.id) returning id into v_project_id;

        if v_project_id is not null then
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27998,x.community_id_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27999,x.number_of_homes_reserved_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28011,x.proposal_link_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27979,x.l33_community_type_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27980,x.nh_community_c_account_manager_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27981,x.expected_community_construction_start_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27982,x.grand_opening_date_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27983,x.number_of_homes_in_community_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27988,x.nh_community_c_field_manager_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27989,x.nh_community_c_sr_builder_operation_manager_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28006,x.utility_c::text , true);
      --todo create insert for brs    perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1049,x.ahj_utility_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29868,x.sr_community_account_manager_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28007,x.ahj_c::text , true);
          --todo create insert for brs  perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1048,x.ahjname_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28010,x.builder_initial_submitter_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28008,x.tract_number_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28000,x.model_discount_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28001,x.lov_lease_term_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28002,x.lease_escalator_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28003,x.flat_lease_community_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27996,x.my_sun_power_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28004,x.bulk_rp_creation_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28009,x.l_weeks_prior_to_rough_install_for_cut_off_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28030,x.l1_builder_architect_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28031,x.l1_builder_project_manager_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28029,x.builder_purchasing_contact_c::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28034,x.builder_utility_rep_c::text , true);
          v_community_adder_c = null;
          if x.community_adder_c is not null then
            select array_agg(lov.id)
            into v_community_adder_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) community_adder_c
                   FROM (
                          SELECT STRING_AGG(community_adder_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.community_adder_c and lov.parent_id = 25236;
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28025,v_community_adder_c::text, true);
          end if;

          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28015,x.l3_competitor_c_id::text , true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28027,x.distance_adder_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28016,x.l4_distribution_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28035,x.l5_home_energy_source_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28036,x.l6_multi_family_interconnection_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28033,x.phase_cutover_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28024,x.l7_pre_plumb_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28037,x.prevailing_wage_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28038,x.prevailing_wage_details_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28014,x.l8_reason_won_lost_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28026,x.l9_rough_wire_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28032,x.transition_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28028,x.l10_type_of_release_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28013,x.l11_stage_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27984,x.utility_considerations_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27986,x.l12_building_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27987,x.l13_OWNERSHIP_TYPE_C_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28017,x.region_c::text, true);
          v_financial_offering_c = null;
          if x.financial_offering_c is not null then
            select array_agg(lov.id)
            into v_financial_offering_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) financial_offering_c
                   FROM (
                          SELECT STRING_AGG(financial_offering_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.financial_offering_c and lov.parent_id = 25184;
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27990,v_financial_offering_c::text, true);
          end if;

          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28018,x.builder_preferred_roofer_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28019,x.preferred_pv_partner_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28020,x.preferred_storage_partner_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28021,x.community_superintendent_name_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28022,x.community_superintendent_email_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28023,x.community_superintendent_phone_number_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28040,x.tracking_number_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28039,x.l15_permit_pack_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28041,x.l16_PERMITTING_RESPONSIBILITY_C_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28042,x.builder_delivery_info_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28043,x.l17_ssp_required_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28044,x.permit_ahj_fees_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28093,x.permitting_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28045,x.master_permit_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28046,x.builder_permitting_complete_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28047,x.l18_ess_permit_pack_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28048,x.l19_ess_permitting_responsibility_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28049,x.cash_pv_module_qty_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28051,x.right_sized_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28052,x.l20_mounting_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28053,x.sheet_size_c::text, true);
          v_roof_attachment_c = null;
          if x.roof_attachment_c is not null then
            select array_agg(lov.id)
            into v_roof_attachment_c
            from (
                   SELECT unnest(string_to_array(aggregated_column, ';')) roof_attachment_c
                   FROM (
                          SELECT STRING_AGG(roof_attachment_c, ';') AS aggregated_column
                          from brs.nh_community_c ncc
                          where id = x.id
                        ) AS subquery) as foo
                   inner join flow.list_of_value lov on lov.name = foo.roof_attachment_c and lov.parent_id = 25260;
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28054,v_roof_attachment_c::text, true);
          end if;
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28057,x.l22_multi_family_array_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28055,x.l23_roof_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28058,x.multi_family_steep_roof_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28056,x.l24_installation_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28059,x.custom_community_adder_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28060,x.custom_adder_description_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28062,x.l25_inverter_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28063,x.l26_structural_options_enhancements_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28064,x.l27_evse_offering_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28065,x.l28_builder_file_validation_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27985,x.l29_storage_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,27995,x.l30_storage_backup_type_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28061,x.storage_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29866,x.iplot_design_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,29867,x.builder_specific_requirements_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28066,x.l31_rebate_program_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28067,x.climate_zone_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28068,x.l32_rebate_payable_to_c_id::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28073,x.t_24_code_reserved_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28071,x.rebate_reservation_expiry_date_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28072,x.rebate_reservation_confirmation_number_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28075,x.reservation_amount_per_project_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28076,x.reserved_kw_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28077,x.reservation_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28078,x.reserved_incentive_level_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28079,x.registry_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28080,x.builder_hers_rater_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28435,x.load_application_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28436,x.load_application_received_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28082,x.address_list_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28083,x.address_list_info_complete_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28089,x.architecture_files_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28090,x.architecture_files_info_complete_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28086,x.community_documents_folder_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28092,x.document_notes_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28091,x.electrical_diagram_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28084,x.sequence_sheet_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28085,x.sequence_sheet_info_complete_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28087,x.site_plan_c::text, true);
          perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28088,x.site_plan_info_complete_c::text, true);
        end if;

      end loop;
    raise notice '2 END = %',clock_timestamp();
    raise notice '2 END total = %',v_total;
  end
$do$;
