--this is for brs.ahj_name_c which inserts ahj new home data
DO
$do$
    declare
        x                 record;
        v_ahj_id          bigint;
        v_ahj_new_home_id bigint;
        v_submittal_type_c bigint;
        v_electronic_submittal_c bigint;
        v_permit_payment_method_c bigint[];
        v_ahj_preferred_process_c bigint;
        v_mppp_paper_size_c bigint;
        v_mppp_issuance_type_c bigint;
        v_mppp_format_c bigint;
        v_mf_mppp_format_c bigint;
        v_solar_notation_on_home_permit_c bigint;
        v_community_level_revision_responsibility_c bigint;
        v_lot_level_revision_responsibility_c bigint;
        v_ess_preferred_process_c bigint;
        v_ess_permitting_responsibility_c bigint;
        v_builder_permitting_type_c bigint;
        v_mppp_submittal_type_c bigint;
    BEGIN
        for x in select a.id,
                        a.name,
                        a.address_c,
                        a.state_c,
                        a.is_ac_disconnect_required_nh_only_c,
                        a.permit_jurisdiction_website_c,
                        a.city_business_license_number_c,
                        a.city_business_license_expiration_c,
                        a.contact_info_c,
                        a.office_hours_c,
                        a.fire_jurisdiction_c,
                        a.submission_process_c,
                        a.revision_process_c,
                        a.submittal_type_c,
                        a.online_submittal_link_c,
                        a.permit_status_online_c,
                        a.electronic_submittal_c,
                        a.permit_payment_method_c,
                        a.permit_cost_c,
                        a.permit_cost_storage_c,
                        a.resubmittal_cost_c,
                        a.building_permit_required_c,
                        a.electrical_permit_required_c,
                        a.solar_permit_required_c,
                        a.access_permit_required_c,
                        a.fire_permit_required_c,
                        a.zoning_required_c,
                        a.utility_approval_req_before_submission_c,
                        a.letter_of_authorization_required_c,
                        a.homeowner_signature_required_c,
                        a.additional_documentation_needed_c,
                        a.permitting_notes_c,
                        a.ess_permit_requirements_c,
                        a.nh_permitting_turn_around_time_c,
                        a.ahj_preferred_process_c,
                        a.mppp_paper_size_c,
                        a.ess_permitting_process_confirmed_c,
                        a.nh_permit_team_supervisor_c,
                        a.number_of_copies_for_mppp_c,
                        a.mppp_cost_c,
                        a.mppp_issuance_type_c,
                        a.mppp_turnaround_time_c,
                        a.mppp_format_c,
                        a.mf_mppp_format_c,
                        a.pv_rough_wire_inspection_required_c,
                        a.storage_rough_wire_inspection_required_c,
                        a.is_ssp_required_with_mppp_c,
                        a.solar_notation_on_home_permit_c,
                        a.final_permit_collection_c,
                        a.nh_permit_notes_c,
                        a.community_level_revision_responsibility_c,
                        a.lot_level_revision_responsibility_c,
                        a.ess_preferred_process_c,
                        a.ess_permitting_responsibility_c,
                        a.ahj_process_confirmed_date_c,
                        a.builder_permitting_type_c,
                        a.mppp_submittal_type_c,
                        a.contractor_letter_of_auth_required_c,
                        a.builder_letter_of_auth_required_c,
                        st.abbreviation_c as state_abbreviation_c
                 from brs.ahj_name_c a
                          left join brs.ahj_state_c st on st.id = a.state_c
            loop
                v_ahj_id = null;
                v_ahj_new_home_id = null;

                --check if there is an existing ahj by name and new home
                select fa.id, nh.id
                into v_ahj_id, v_ahj_new_home_id
                from brs.feat_db_ahj fa
                         left join brs.feat_db_ahj_new_home nh on nh.ahj_id = fa.id
                where lower(fa.name) = lower(x.name);

                --if there wasn't an existing ahj then add one
                if (v_ahj_id is null) then
                    insert into brs.feat_db_ahj(name, created_by_id, modified_by_id, active, company_state_id)
                    select x.name, 2384850, 2384850, true,
                           (select cs.id
                            from flow.company_state cs
                                     inner join flow.state s on s.id = cs.state_id
                            where cs.company_id = 3
                              and s.abbreviation = x.state_abbreviation_c)
                    returning id into v_ahj_id;
                end if;

                if v_ahj_id is not null then
                    --if there wasn't an existing new home then add one
                    if (v_ahj_new_home_id is null) then
                        insert into brs.feat_db_ahj_new_home(ahj_id, created_by_id, modified_by_id)
                        select v_ahj_id, 2384850, 2384850
                        returning id into v_ahj_new_home_id;
                    end if;

                    if v_ahj_new_home_id is not null then
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1228, x.address_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1230, x.is_ac_disconnect_required_nh_only_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1252, x.permit_jurisdiction_website_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1253, x.city_business_license_number_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1254, x.city_business_license_expiration_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1255, x.contact_info_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1256, x.office_hours_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1257, x.fire_jurisdiction_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1258, x.submission_process_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1259, x.revision_process_c::text, 'AHJ_NEW_HOME');
                        v_submittal_type_c = null;
                        if x.submittal_type_c is not null then
                            select lov.id
                            into v_submittal_type_c
                            from brs.list_of_value lov
                            where lov.name = x.submittal_type_c and lov.parent_id = 13031
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1260, v_submittal_type_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1261, x.online_submittal_link_c::text, 'AHJ_NEW_HOME');
                        --todo add username field here

                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1263, x.permit_status_online_c::text, 'AHJ_NEW_HOME');
                        v_electronic_submittal_c = null;
                        if x.electronic_submittal_c is not null then
                            select lov.id
                            into v_electronic_submittal_c
                            from brs.list_of_value lov
                            where lov.name = x.electronic_submittal_c and lov.parent_id = 13036
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1264, v_electronic_submittal_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_permit_payment_method_c = null;
                        if x.permit_payment_method_c is not null then
                            select array_agg(lov.id)
                            into v_permit_payment_method_c
                            from (
                                     SELECT unnest(string_to_array(aggregated_column, ';')) permit_payment_method_c
                                     FROM (
                                              SELECT STRING_AGG(permit_payment_method_c, ';') AS aggregated_column
                                              from brs.ahj_name_c A2
                                              where id = x.id
                                          ) AS subquery) as foo
                                     inner join brs.list_of_value lov on lov.name = foo.permit_payment_method_c and lov.parent_id = 13041;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1265, v_permit_payment_method_c::text, 'AHJ_NEW_HOME');
                        end if;


                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1266, x.permit_cost_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1267, x.permit_cost_storage_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1268, x.resubmittal_cost_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1231, x.building_permit_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1232, x.electrical_permit_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1233, x.solar_permit_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1234, x.access_permit_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1235, x.fire_permit_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1236, x.zoning_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1237, x.utility_approval_req_before_submission_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1238, x.letter_of_authorization_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1239, x.homeowner_signature_required_c::text, 'AHJ_NEW_HOME');
                        --todo add homeowner signature documents field here
                        --todo add paper size field here
                        --todo add number of copies field here

                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1271, x.additional_documentation_needed_c::text, 'AHJ_NEW_HOME');
                        --todo add nh additional documentation needed field here

                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1272, x.permitting_notes_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1241, x.ess_permit_requirements_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1273, x.nh_permitting_turn_around_time_c::text, 'AHJ_NEW_HOME');
                        v_ahj_preferred_process_c = null;
                        if x.ahj_preferred_process_c is not null then
                            select lov.id
                            into v_ahj_preferred_process_c
                            from brs.list_of_value lov
                            where lov.name = x.ahj_preferred_process_c and lov.parent_id = 13052
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1274, v_ahj_preferred_process_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_mppp_paper_size_c = null;
                        if x.mppp_paper_size_c is not null then
                            select lov.id
                            into v_mppp_paper_size_c
                            from brs.list_of_value lov
                            where lov.name = x.mppp_paper_size_c and lov.parent_id = 13058
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1275, v_mppp_paper_size_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1276, x.ess_permitting_process_confirmed_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1277, x.nh_permit_team_supervisor_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1278, x.number_of_copies_for_mppp_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1279, x.mppp_cost_c::text, 'AHJ_NEW_HOME');
                        v_mppp_issuance_type_c = null;
                        if x.mppp_issuance_type_c is not null then
                            select lov.id
                            into v_mppp_issuance_type_c
                            from brs.list_of_value lov
                            where lov.name = x.mppp_issuance_type_c and lov.parent_id = 13062
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1280, v_mppp_issuance_type_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1281, x.mppp_turnaround_time_c::text, 'AHJ_NEW_HOME');
                        v_mppp_format_c = null;
                        if x.mppp_format_c is not null then
                            select lov.id
                            into v_mppp_format_c
                            from brs.list_of_value lov
                            where lov.name = x.mppp_format_c and lov.parent_id = 13067
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1282, v_mppp_format_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_mf_mppp_format_c = null;
                        if x.mf_mppp_format_c is not null then
                            select lov.id
                            into v_mf_mppp_format_c
                            from brs.list_of_value lov
                            where lov.name = x.mf_mppp_format_c and lov.parent_id = 13070
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1283, v_mf_mppp_format_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1242, x.pv_rough_wire_inspection_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1243, x.storage_rough_wire_inspection_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1244, x.is_ssp_required_with_mppp_c::text, 'AHJ_NEW_HOME');
                        v_solar_notation_on_home_permit_c = null;
                        if x.solar_notation_on_home_permit_c is not null then
                            select lov.id
                            into v_solar_notation_on_home_permit_c
                            from brs.list_of_value lov
                            where lov.name = x.solar_notation_on_home_permit_c and lov.parent_id = 13073
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1284, v_solar_notation_on_home_permit_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1285, x.final_permit_collection_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1286, x.nh_permit_notes_c::text, 'AHJ_NEW_HOME');
                        v_community_level_revision_responsibility_c = null;
                        if x.community_level_revision_responsibility_c is not null then
                            select lov.id
                            into v_community_level_revision_responsibility_c
                            from brs.list_of_value lov
                            where lov.name = x.community_level_revision_responsibility_c and lov.parent_id = 13080
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1287, v_community_level_revision_responsibility_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_lot_level_revision_responsibility_c = null;
                        if x.lot_level_revision_responsibility_c is not null then
                            select lov.id
                            into v_lot_level_revision_responsibility_c
                            from brs.list_of_value lov
                            where lov.name = x.lot_level_revision_responsibility_c and lov.parent_id = 13084
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1288, v_lot_level_revision_responsibility_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_ess_preferred_process_c = null;
                        if x.ess_preferred_process_c is not null then
                            select lov.id
                            into v_ess_preferred_process_c
                            from brs.list_of_value lov
                            where lov.name = x.ess_preferred_process_c and lov.parent_id = 13088
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1289, v_ess_preferred_process_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_ess_permitting_responsibility_c = null;
                        if x.ess_permitting_responsibility_c is not null then
                            select lov.id
                            into v_ess_permitting_responsibility_c
                            from brs.list_of_value lov
                            where lov.name = x.ess_permitting_responsibility_c and lov.parent_id = 13093
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1290, v_ess_permitting_responsibility_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1291, x.ahj_process_confirmed_date_c::text, 'AHJ_NEW_HOME');
                        v_builder_permitting_type_c = null;
                        if x.builder_permitting_type_c is not null then
                            select lov.id
                            into v_builder_permitting_type_c
                            from brs.list_of_value lov
                            where lov.name = x.builder_permitting_type_c and lov.parent_id = 13097
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1292, v_builder_permitting_type_c::text, 'AHJ_NEW_HOME');
                        end if;
                        v_mppp_submittal_type_c = null;
                        if x.mppp_submittal_type_c is not null then
                            select lov.id
                            into v_mppp_submittal_type_c
                            from brs.list_of_value lov
                            where lov.name = x.mppp_submittal_type_c and lov.parent_id = 13101
                              and lov.archived is false;
                            perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1293, v_mppp_submittal_type_c::text, 'AHJ_NEW_HOME');
                        end if;
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1245, x.contractor_letter_of_auth_required_c::text, 'AHJ_NEW_HOME');
                        perform brs.set_feat_db_cfv_no_checks(v_ahj_new_home_id, 2384850, 1246, x.builder_letter_of_auth_required_c::text, 'AHJ_NEW_HOME');

                    end if;
                end if;
            end loop;
    end
$do$;


--this is for brs.ahj_utility_c
DO
$do$
    declare
        x                 record;
        v_utility_id bigint;
        v_submittal_c bigint;
        v_payment_type_c bigint;
        v_buyer_vs_builder_submittals_c bigint;
    BEGIN
        for x in select a.id,
                        a.name,
                        a.state_c,
                        a.utility_url_c,
                        a.utility_poc_c,
                        a.layout_required_c,
                        a.line_diagram_required_c,
                        a.panel_inverter_spec_sheet_required_c,
                        a.prod_meter_required_c,
                        a.production_meter_notes_c,
                        a.design_folder_c,
                        a.ac_disconnect_required_c,
                        a.ac_disco_spec_sheet_required_c,
                        a.ac_disconnect_requirement_notes_c,
                        a.oversizing_allowance_and_requirement_c,
                        a.utility_place_card_requirement_c,
                        a.side_elevation_required_c,
                        a.additional_utility_notes_c,
                        a.additional_permit_ic_notes_c,
                        a.last_utility_process_review_c,
                        a.utility_pre_comm_notes_c,
                        a.final_permit_collection_c,
                        a.final_permit_requirements_c,
                        a.application_portal_url_c,
                        a.submittal_c,
                        a.interconnect_fees_c,
                        a.payment_type_c,
                        a.pre_approval_required_c,
                        a.pre_approval_process_c,
                        a.ic_requirements_documented_c,
                        a.gbfs_handoff_c,
                        a.gbfs_process_link_c,
                        a.buyer_vs_builder_submittals_c,
                        a.pto_timeline_c,
                        a.additional_documents_c
                 from brs.ahj_utility_c a
            loop
                v_utility_id = null;

                --check if there is an existing utility by name
                select fa.id
                into v_utility_id
                from brs.feat_db_utility fa
                where lower(fa.name) = lower(x.name);

                --if there wasn't an existing ahj then add one
                if (v_utility_id is null) then
                    insert into brs.feat_db_utility(name, created_by_id, modified_by_id, company_state_id, active)
                    select x.name, 2384850, 2384850,
                           --in ahj_utility_c, state_c is the state abbreviation, use that to match to the company state id for company_id = 3
                           (select cs.id
                            from flow.company_state cs
                                     inner join flow.state s on s.id = cs.state_id
                            where cs.company_id = 3
                              and s.abbreviation = x.state_c),
                           true
                    returning id into v_utility_id;
                end if;

                if v_utility_id is not null then
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1177, x.utility_url_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1178, x.utility_poc_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1181, x.layout_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1182, x.line_diagram_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1183, x.panel_inverter_spec_sheet_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1184, x.prod_meter_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1185, x.production_meter_notes_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1186, x.design_folder_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1187, x.ac_disconnect_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1188, x.ac_disco_spec_sheet_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1189, x.ac_disconnect_requirement_notes_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1190, x.oversizing_allowance_and_requirement_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1191, x.utility_place_card_requirement_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1192, x.side_elevation_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1193, x.additional_utility_notes_c::text, 'AHJ_UTILITY');
                    --todo add utility formatting notes here
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1202, x.additional_permit_ic_notes_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1203, x.last_utility_process_review_c::text, 'AHJ_UTILITY');
                    --todo add backfeed pre-comm allowed field here
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1205, x.utility_pre_comm_notes_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1206, x.final_permit_collection_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1207, x.final_permit_requirements_c::text, 'AHJ_UTILITY');
                    --todo add pre approval required for permit field here
                    --todo add utility required grid profile field here
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1210, x.application_portal_url_c::text, 'AHJ_UTILITY');
                    v_submittal_c = null;
                    if x.submittal_c is not null then
                        select lov.id
                        into v_submittal_c
                        from brs.list_of_value lov
                        where lov.name = x.submittal_c and lov.parent_id = 13018
                          and lov.archived is false;
                        perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1211, v_submittal_c::text, 'AHJ_UTILITY');
                    end if;
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1212, x.interconnect_fees_c::text, 'AHJ_UTILITY');
                    v_payment_type_c = null;
                    if x.payment_type_c is not null then
                        select lov.id
                        into v_payment_type_c
                        from brs.list_of_value lov
                        where lov.name = x.payment_type_c and lov.parent_id = 13022
                          and lov.archived is false;
                        perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1212, v_payment_type_c::text, 'AHJ_UTILITY');
                    end if;
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1214, x.pre_approval_required_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1215, x.pre_approval_process_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1216, x.ic_requirements_documented_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1217, x.gbfs_handoff_c::text, 'AHJ_UTILITY');
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1218, x.gbfs_process_link_c::text, 'AHJ_UTILITY');
                    v_buyer_vs_builder_submittals_c = null;
                    if x.buyer_vs_builder_submittals_c is not null then
                        select lov.id
                        into v_buyer_vs_builder_submittals_c
                        from brs.list_of_value lov
                        where lov.name = x.buyer_vs_builder_submittals_c and lov.parent_id = 13027
                          and lov.archived is false;
                        perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1212, v_buyer_vs_builder_submittals_c::text, 'AHJ_UTILITY');
                    end if;
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1220, x.pto_timeline_c::text, 'AHJ_UTILITY');
                    --todo add Grid Capacity Last Review field here
                    --todo add Grid Capacity Map URL field here
                    --todo add Grid Capacity Response / Notes field here
                    perform brs.set_feat_db_cfv_no_checks(v_utility_id, 2384850, 1224, x.additional_documents_c::text, 'AHJ_UTILITY');
                    --todo add Required Photos field here
                    --todo add In-Person Utility Inspection field here


                end if;
            end loop;
    end
$do$;

