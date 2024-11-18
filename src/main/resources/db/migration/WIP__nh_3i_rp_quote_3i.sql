SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
    v_total bigint;
  BEGIN
    v_total = 0;
    raise notice 'Residential Property Quote START = %',clock_timestamp();
    for x in  select q.id as quote_id,
                     q.module_c,
                     --  q.Module_Brand_c,
                     q.module_quantity_c,
                     q.inverter_model_c,
                     q.inverter_quantity_c,
                     q.racking_quantity_c,
                     q.storage_model_c,
                     q.storage_count_c,
                     q.storage_size_k_wh_c,
                     q.storage_backup_type_c,
                     q.finance_charge_c,
                     q.non_ach_interest_rate_c,
                     q.ach_opt_in_c,
                     q.apr_type_c,
                     q.date_sent_to_my_sun_power_c,
                     -- q.total_sales_price_c,
                     -- q.non_ach_total_sales_price_c,
                     q.applied_rebate_rate_c,
                     -- q.Voluntary_Loan_Payment_c,
                     q.external_proposal_url_c,
                     q.selected_quote_in_my_sun_power_c,
                     q.quote_selected_date_c,
                     q.quote_number,
                     -- q.Leesee_Co_Leesee_c,
                     q.lessee_c,
                     q.lessee_2_c,
                     q.lease_number_c,
                     q.consolidated_lease_number_dup_c,
                     q.final_lease_number_c,
                     q.description,
--                      q.Total_Lease_Payments_Pre_NSHP_Rebate_c,
--                      q.RoundOff_First_Monthly_Payment_c,
--                      q.RoundOff_Total_Monthly_Payments_c,
--                      q.RoundOff_First_Monthly_Payment_Base_Amo_c,
--                      q.RoundOff_First_Monthly_Payment_Estimate_c,
--                      q.Final_First_Base_Monthly_Pay_c,
--                      q.Final_Total_Yearly_Page_2_c,
--                      q.Final_Total_Yearly_Page_4_c,
                     q.system_production_year_1_c,
                     q.system_price_c,
                     q.storage_price_c,
--                      q.Installation_Fee_c,
--                      q.Total_of_Payments_c,
--                      q.Monthly_Payments_with_Estimated_Tax_c,
                     q.dealer_fees_c,
                     q.storage_commission_c,
                     q.adder_fee_c,
                     q.discount_c,
                     q.sun_power_discount_c,
                     q.tps_fee_c,
                     q.ip_fee_c,
                     q.system_cost_c,
                     q.lease_doc_created_date_c,
                     q.lease_doc_sent_out_for_signature_c,
                     q.lease_doc_signed_c,
                     q.lease_doc_signed_date_c,
                     --q.Termination_Lease_doc_Date_c,
                     q.total_energy_c,
                     q.proposal_document_link_c,
                     q.power_used_before_solar_k_wh_year_c,
                     q.price_to_customer_c,
                     q.sent_welcome_email_c,
                     q.expiration_date,
                     q.contract_signed_date_c,
                     q.quote_expiration_date_c,
                     q.date_sent_to_customer_c,
                     q.dealer_contractor_license_number_c,
                     q.first_monthly_payment_c,
                     q.first_monthly_payment_base_amount_c,
                     q.first_monthly_payment_estimated_payment_c,
                     q.first_monthly_payment_est_tax_on_payme_c,
                     q.full_prepaid_lease_c,
                     q.full_pre_payment_amount_base_amount_c,
                     q.full_pre_payment_amount_estimated_paymen_c,
                     q.full_pre_payment_amount_estimated_tax_on_c,
                     q.full_prepayment_of_lease_amount_c,
                     q.quote_type_c,
--                      q.System_Size_c,
                     -- q.Net_Cost_c,
                     p.id as project_id,
                     lov1.id as lov1_inverter_brand_c,
                     lov2.id as lov2_mounting_description_c,
                     lov3.id as lov3_monitoring_system_c,
                     lov4.id as lov4_non_backup_storage_acknowledged_c,
                     lov5.id as lov5_credit_bureau_c,
                     lov6.id as lov6_lease_doc_reviewed_c,
                     lov7.id as lov7_quote_type_c_id,
                     lpc.id as lp_status_id,
                     lpc.status_c as lp_status,
                     lpc.is_deleted as lpc_is_deleted
              from brs.QUOTE Q
                     inner join brs.lease_payment_c lpc on lpc.quote_c = q.id
                     inner join brs.account A on a.id = q.account_id
                     inner join brs.RESIDENTIAL_PROJECT_C RPC on rpc.ACCOUNT_C = a.id
                     inner join flow.project p on p.nw_migration_id = rpc.id
                     left join flow.list_of_value lov1 on lov1.name = q.inverter_brand_c and lov1.parent_id = 25826
                     left join flow.list_of_value lov2 on lov2.name = q.mounting_description_c and lov2.parent_id = 25828
                     left join flow.list_of_value lov3 on lov3.name = q.monitoring_system_c and lov3.parent_id = 25830
                     left join flow.list_of_value lov4 on lov4.name = q.non_backup_storage_acknowledged_c and lov4.parent_id = 25832
                     left join flow.list_of_value lov5 on lov5.name = q.credit_bureau_c and lov5.parent_id = 25715
                     left join flow.list_of_value lov6 on lov6.name = q.lease_doc_reviewed_c and lov6.parent_id = 25834
                     left join flow.list_of_value lov7 on lov7.name = q.quote_type_c and lov7.parent_id = 26325
              where rpc.QUOTE_C is not null and q.IS_DELETED = false
                and rpc.RECORD_TYPE_ID = '01234000000UQPbAAO'
                and rpc.STATUS_C != 'Cancelled'
                and rpc.IS_DELETED = false
              and rpc.id not in (
                'a6l2T00000089HJQAY',
                'a6l2T00000089LGQAY',
                'a6l2T000000A3fRQAS',
                'a6l2T000001Wn7JQAS',
                'a6l2T000003j7rPQAQ',
                'a6l2T000003jGBcQAM',
                'a6l2T000003jGEqQAM',
                'a6l2T0000055YePQAU',
                'a6l2T00000564LKQAY',
                'a6l2T0000057IGlQAM',
                'a6l2T0000057rnNQAQ',
                'a6l2T0000057rouQAA',
                'a6l34000000Cm6mAAC'
                )
              order by rpc.id,q.lease_doc_signed_date_c,q.created_date
      loop
        v_total = v_total + 1;

        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id,nw_migration_id)
        values (x.project_id, 3798, null, case when x.lp_status_id is not null and
                                                    x.lp_status = 'Active' and x.lp_status != 'Cancelled' and x.lpc_is_deleted is false then 1 else 2 end, null, now(), now(), 2384850, 2384850, false,
                                        case when x.lp_status_id is not null and
                                      x.lp_status = 'Active' and x.lp_status != 'Cancelled' and x.lpc_is_deleted is false then true else false end, null, null, null,x.quote_id) returning id into v_project_process_step_id;
       -- raise notice 'x.project_id %',x.project_id;

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,30076,x.lov7_quote_type_c_id::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29291,x.module_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29292,x.Module_Brand_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29293,x.module_quantity_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29294,x.inverter_model_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29295,x.lov1_inverter_brand_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29296,x.inverter_quantity_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29297,x.lov2_mounting_description_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29298,x.racking_quantity_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29299,x.lov3_monitoring_system_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29300,x.storage_model_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29301,x.storage_count_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29302,x.storage_size_k_wh_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29303,x.storage_backup_type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29304,x.finance_charge_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29305,x.non_ach_interest_rate_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29306,x.ach_opt_in_c::text , true);
 --todo carlin change to drop down in prod      -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29307,x.apr_type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29308,x.date_sent_to_my_sun_power_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29309,x.total_sales_price_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29310,x.non_ach_total_sales_price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29311,x.applied_rebate_rate_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29312,x.Voluntary_Loan_Payment_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29313,x.external_proposal_url_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29314,x.selected_quote_in_my_sun_power_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29315,x.lov4_non_backup_storage_acknowledged_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29316,x.quote_selected_date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29317,x.quote_number::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29318,x.lov5_credit_bureau_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29319,x.Leesee_Co_Leesee_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29320,x.lessee_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29321,x.lessee_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29322,x.lease_number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29323,x.consolidated_lease_number_dup_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29324,x.final_lease_number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29325,x.description::text , true);
        --         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29326,x.Total_Lease_Payments_Pre_NSHP_Rebate_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29327,x.RoundOff_First_Monthly_Payment_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29328,x.RoundOff_Total_Monthly_Payments_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29329,x.RoundOff_First_Monthly_Payment_Base_Amo_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29330,x.RoundOff_First_Monthly_Payment_Estimate_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29331,x.Final_First_Base_Monthly_Pay_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29332,x.Final_Total_Yearly_Page_2_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29333,x.Final_Total_Yearly_Page_4_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29334,x.system_production_year_1_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29335,x.system_price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29336,x.storage_price_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29337,x.Installation_Fee_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29338,x.Total_of_Payments_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29339,x.Monthly_Payments_with_Estimated_Tax_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29340,x.dealer_fees_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29341,x.storage_commission_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29342,x.adder_fee_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29343,x.discount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29344,x.sun_power_discount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29345,x.tps_fee_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29346,x.ip_fee_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29347,x.system_cost_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29348,x.lease_doc_created_date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29349,x.lov6_lease_doc_reviewed_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29350,x.lease_doc_sent_out_for_signature_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29351,x.lease_doc_signed_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29352,x.lease_doc_signed_date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29353,x.Termination_Lease_doc_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29354,x.total_energy_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29355,x.proposal_document_link_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29356,x.power_used_before_solar_k_wh_year_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29357,x.price_to_customer_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29358,x.sent_welcome_email_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29359,x.expiration_date::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29360,x.contract_signed_date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29361,x.quote_expiration_date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29362,x.date_sent_to_customer_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29363,x.dealer_contractor_license_number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29364,x.first_monthly_payment_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29365,x.first_monthly_payment_base_amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29366,x.first_monthly_payment_estimated_payment_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29367,x.first_monthly_payment_est_tax_on_payme_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29368,x.full_prepaid_lease_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29369,x.full_pre_payment_amount_base_amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29370,x.full_pre_payment_amount_estimated_paymen_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29371,x.full_pre_payment_amount_estimated_tax_on_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29372,x.full_prepayment_of_lease_amount_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29373,x.System_Size_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29374,x.Net_Cost_c::text , true);

      end loop;
    raise notice 'Residential Property Quote END = %',clock_timestamp();
    raise notice 'Residential Property Quote Total = %',v_total;
  end
$do$;
