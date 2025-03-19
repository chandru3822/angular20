SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    y record;
    z record;
    v_contact_id bigint;
    v_project_id bigint;
    v_lot_project_id bigint;
    v_project_process_step_opportunity_id bigint;
  v_carports_1_c bigint[];
  BEGIN

    update brs.temp_multifamily tm
    set sif_utility_lookup = '668'::text
    where sif_utility_lookup::integer = 870;

    update brs.temp_multifamily tm
    set sif_utility_lookup = '871'::text
    where sif_utility_lookup::integer = 873;

    insert into flow.object_category(object_category, object_category_code, object_type_id, created_by_id, modified_by_id, archived, is_default)
    values ('Multi Family Community', 'MULTI_FAMILY_COMMUNITY', 1, 2417170, 2417170, false, false);
    update flow.object_category
    set object_category = 'Multi Family Project'
    where object_category_code = 'MULTI_FAMILY';

    insert into flow.object_category_child_object_category(object_category_id, child_object_category_id, created_by_id, modified_by_id)
    values (7, 12, 2417170, 2417170); --7 = builder contact. 12 = multi family community
    insert into flow.object_category_child_object_category(object_category_id, child_object_category_id, created_by_id, modified_by_id)
    values (12, 10, 2417170, 2417170); --12 = multi family community, 10 = multi family project

--carlin needs to add the new processes then:
    update flow.process
    set object_category_id = 12 --community
    where id = 29; --the id for the multi family community process
    update flow.process
    set object_category_id = 10 --project
    where id = 30; --the id for the multi family project process


    for x in select distinct on (builder_migration_id) tm.* from brs.temp_multifamily tm

      loop
        v_contact_id = null;

        select id
        into v_contact_id
        from flow.contact c2
        where c2.nw_migration_id = x.BUILDER_MIGRATION_ID;

        if v_contact_id is null then
          insert into flow.contact(contact_type_id, first_name, street1,
                                   city, postal_code, phone, mobile,
                                   date_created, date_modified, created_by_id, modified_by_id,
                                   company_id, archived,
                                   company_state_id,
                                   company_country_id,
                                   object_category_id, nw_migration_id)
          values (1,x.BUILDER_NAME,x.BILLING_STREET,x.BILLING_CITY,substr(x.BILLING_POSTAL_CODE,1,5),
                  x.phone,x.phone,now(),now(),2384850,2384850,3,false,case when x.BILLING_STATE = 'CA' then 1877
                                                                           when x.BILLING_STATE = 'NE' then 1858
                                                                           when x.BILLING_STATE = 'WA' then 13
                                                                           when x.BILLING_STATE = 'ID' then 4 end,1,7,x.BUILDER_MIGRATION_ID) returning id into v_contact_id;
        end if;
        perform flow.set_contact_cfv(v_contact_id, 2384850, 30256, x.FAX::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 28829, x.WEBSITE::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 28820, x.DESCRIPTION::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 29911, x.ACCOUNT_OWNER::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 29860, x.Builder_LEAD_QUALIFICATION_NOTES_C::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 30352, x.NUMBER_OF_ACTIVE_SITES_C::text, true);
        perform flow.set_contact_cfv(v_contact_id, 2384850, 30353, x.NUMBER_OF_INACTIVE_SITES_C::text, true);

        for y in select distinct on (tm.site_migration_id) tm.*,
                        lov1.id as lov1_stage_name,
                        lov2.id as lov2_INTERCONNECTION_TYPE_C,
                        lov3.id as lov3_STORAGE_C,
                        lov4.id as lov4_FINANCING_2_C,
                        lov5.id as lov5_ROOF_TYPE_C
                 from brs.temp_multifamily tm
                 left join flow.list_of_value lov1 on lov1.name = tm.stage_name and lov1.parent_id = 25746
                 left join flow.list_of_value lov2 on lov2.name = tm.INTERCONNECTION_TYPE_C and lov2.parent_id = 25779
                 left join flow.list_of_value lov3 on lov3.name = tm.STORAGE_C and lov3.parent_id =  25783
                 left join flow.list_of_value lov4 on lov4.name = tm.FINANCING_2_C and lov4.parent_id =  13914
                 left join flow.list_of_value lov5 on lov5.name = tm.ROOF_TYPE_C and lov5.parent_id = 25512
                 where tm.BUILDER_MIGRATION_ID = x.BUILDER_MIGRATION_ID
          loop
            v_project_id = null;
            insert into flow.project( contact_id, company_process_id, project_name, date_created, date_modified,
                                      created_by_id, modified_by_id, company_project_status_type_id,
                                      company_state_id,city,postal_code,street1,
                                      company_country_id, archived,object_category_id,nw_migration_id)
            values(v_contact_id,29,y.COMMUNITY_NAME,now(),now(),
                   2384850,2384850,case when x.SITE_STATUS_C = 'Active' then 223
                                        when x.SITE_STATUS_C  = 'Placed in Service' then 232
                                        else 223
                     end,case when x.BILLING_STATE = 'CA' then 1877
                              when x.BILLING_STATE = 'NE' then 1858
                              when x.BILLING_STATE = 'WA' then 13
                              when x.BILLING_STATE = 'ID' then 4 else null end,x.SITE_CITY_C,substr(x.SITE_ZIP_POSTAL_CODE_C,1,5),x.SITE_ADDRESS_C,1,false,12,x.SITE_MIGRATION_ID)
                        returning id into v_project_id;

            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1048,x.SIF_AHJ_LOOKUP::text , true);
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,1049,x.SIF_UTILITY_LOOKUP::text , true);
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30390,x.PERMIT_COORDINATOR::text , true);
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,28086,x.project_documents_c::text , true);
            perform flow.set_project_cfv_no_checks(v_project_id , 2384850,30389,x.job_number_c::text , true);


            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id, nw_migration_id)
            values (v_project_id,3834 , null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                    null);


            v_project_process_step_opportunity_id = null;
            insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                   company_process_step_status_type_id,
                                                   process_step_complete_date, date_created, date_modified, created_by_id,
                                                   modified_by_id, archived, main, parent_project_process_step_id,
                                                   cancelled_date, parent_project_process_step_event_id, nw_migration_id)
            values (v_project_id,3832 , null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                    y.OPPORTUNITY_MIGRATION_ID)
            returning id into v_project_process_step_opportunity_id;


            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30364 , y.O_OWNER::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30365, y.lov1_stage_name::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30366 , y.NUMBER_OF_SITES_TO_INSTALL_SOLAR_NUMBER_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30367, y.NUMBER_OF_BUILDINGS_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30368 , y.NUMBER_OF_STORIES_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30369 , y.NUMBER_OF_UNITS_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30370, y.lov2_INTERCONNECTION_TYPE_C::text, true);
            if y.CARPORTS_1_C is not null then
              select array_agg(lov.id)
              into v_carports_1_c
              from (
                     SELECT unnest(string_to_array(aggregated_column, ';')) carports_1_c
                     FROM (
                            SELECT STRING_AGG(CARPORTS_1_C, ';') AS aggregated_column
                            from brs.temp_multifamily tm1
                            where tm1.id = y.id
                          ) AS subquery) as foo
                     inner join flow.list_of_value lov on lov.name = foo.carports_1_c and lov.parent_id = 28367;
              perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30388 , v_carports_1_c::text, true);
            end if;


            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30372, y.NUMBER_OF_CARPORT_CANOPIES_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30373, y.lov3_STORAGE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30374 , y.lov4_FINANCING_2_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30375, case when y.PREVAILING_WAGE_C = 'Yes' then 'true'::text
                                                                                                                                                            when y.PREVAILING_WAGE_C = 'No' then 'false'::text else null end, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30376 , y.T_24_INFORMATION_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30377, y.lov5_ROOF_TYPE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30378, y.ROOF_MATERIAL_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30379 , y.ROOF_TYPE_NOTES_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30380 , y.TOTAL_K_W_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30381 , y.TOTAL_SYSTEM_PRICE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30383 , y.CLOSE_DATE::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850,30384 , y.EXPECTED_PROJECT_START_DATE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30385, y.DSA_SIGNATURE_DATE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30386, y.EPC_CONTRACT_BOOKED_DATE_C::text, true);
           -- perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30622, y.DSA_COMPLETION_DATE_C::text, true);
            perform flow.set_pps_cfv_no_checks(v_project_process_step_opportunity_id, 2384850, 30387, y.LEAD_QUALIFICATION_NOTES_C::text, true);
            for z in select distinct on (tm.IA_MIGRATION_ID) tm.* ,
                            lov1.id as lov1_type_of_interconnection_c,
                            lov2.id as lov2_application_fee_required_c,
                            lov3.id as lov3_ia_status_c,
                            lov4.id as lov4_supplemental_review_c
                     from brs.temp_multifamily tm
                            left join flow.list_of_value lov1 on lov1.name = tm.type_of_interconnection_c and lov1.parent_id = 25652
                            left join flow.list_of_value lov2 on lov2.name = tm.application_fee_required_c and lov2.parent_id = 25662
                            left join flow.list_of_value lov3 on lov3.name = tm.ia_status_c and lov3.parent_id =  25665
                            left join flow.list_of_value lov4 on lov4.name = tm.supplemental_review_c and lov4.parent_id =  25677
                     where tm.SITE_MIGRATION_ID = y.SITE_MIGRATION_ID
              loop
                v_lot_project_id = null;
                insert into flow.project( contact_id, company_process_id, project_name, date_created, date_modified,
                                          created_by_id, modified_by_id, company_project_status_type_id,
                                          company_state_id,city,postal_code,street1,
                                          company_country_id, archived,object_category_id,nw_migration_id,parent_id)
                values(v_contact_id,30,z.PROJECT_NAME,now(),now(),
                       2384850,2384850, 223
                        ,case when z.METER_ADDRESS_STATE_C = 'CA' then 1877
                              else null end,z.METER_ADDRESS_CITY_C,substr(z.METER_ADDRESS_POSTAL_CODE_C,1,5),z.METER_ADDRESS_STREET_C,1,false,10,z.IA_MIGRATION_ID,v_project_id)returning id into v_lot_project_id;


                insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                       company_process_step_status_type_id,
                                                       process_step_complete_date, date_created, date_modified, created_by_id,
                                                       modified_by_id, archived, main, parent_project_process_step_id,
                                                       cancelled_date, parent_project_process_step_event_id, nw_migration_id)
                values (v_lot_project_id,3835 , null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                        null);

                insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                                       company_process_step_status_type_id,
                                                       process_step_complete_date, date_created, date_modified, created_by_id,
                                                       modified_by_id, archived, main, parent_project_process_step_id,
                                                       cancelled_date, parent_project_process_step_event_id, nw_migration_id)
                values (v_lot_project_id,3759 , null, 1, null, now(), now(), 2384850, 2384850, false, true, null, null, null,
                        null);

                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30394,z.IA_ASSIGNED_TO::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,1049,z.sif_utility_lookup::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30389,z.job_number_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,1048,z.sif_ahj_lookup::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28270,z.GENERAL_INFORMATION_COMMENT_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30395,z.lov1_type_of_interconnection_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28187,z.UTILITY_REFERENCE_NUMBER_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30396,z.REQUIRED_INFORMATION_SHEET_RECEIVED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30397,z.REQUIRED_INFORMATION_SHEET_COMPLETE_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30448,z.APPLICATION_SUBMITTED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30398,z.lov2_application_fee_required_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30399,z.APPLICATION_FEE_AMOUNT_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30400,z.APPLICATION_FEE_SUBMITTED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30401,z.INITIAL_REVIEW_ENTERED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30402,z.INITIAL_REVIEW_COMPLETED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30403,z.DRAWING_RESUBMISSIONS_TO_UTILITY_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30404,z.PRELIMINARY_APPROVAL_DATE_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30405,z.AHJ_SIGN_OFF_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30406,z.AHJ_SIGN_OFF_TO_UTILITY_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30407,z.REQUEST_INSPECTION_PTO_FROM_UTILITY_C::text , true);
          --      perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30621,z.PTO_RECEIVED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28204,z.MESSAGE_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30408,z.lov3_ia_status_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28221,z.SYSTEM_SIZE_K_W_AC_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30410,z.lov4_supplemental_review_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30411,z.SUPPLEMENTAL_REVIEW_ENTERED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30412,z.SUPPLEMENTAL_REVIEW_COMPLETED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30420,z.UTILITY_INSPECTION_PASSED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30426,z.PULSE_METER_REQUIRED_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28193,z.utility_customer_account_c::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,28195,z.METER_NUMBER_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30427,z.CUSTOMER_NAME_ON_UTILITY_BILL_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30428,z.CURRENT_ANNUAL_CONSUMPTION_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30430,z.APPLICATION_DEEMED_COMPLETE_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30431,z.ESTIMATED_DATE_OF_ENGINEERING_APPROVAL_C::text , true);
                perform flow.set_project_cfv_no_checks(v_lot_project_id , 2384850,30429,z.UTILITY_BILL_RECEIVED_C::text , true);
              end loop;
          end loop;
      end loop;


  end
$do$;
SET session_replication_role = default;



