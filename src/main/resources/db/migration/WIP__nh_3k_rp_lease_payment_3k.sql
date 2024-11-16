SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_project_process_step_id bigint;
    v_total bigint;
  BEGIN
    v_total = 0;
    raise notice 'Residential Property Lease Payment START = %',clock_timestamp();
    for x in select

               lpc.US_Cash_Grant_Submission_Date_c,
               lpc.X_1603_Notes_c,
               lpc.X_1603_Placed_In_Service_Submission_Date_c,
               lpc.X_1603_Status_Date_c,
               lpc.Acceptance_Rcvd_c,
               lpc.Acceptance_Apprvd_c,
               lpc.ACH_c,
               lpc.Note_to_Dealer_c,
               lpc.Add_Equipment_Qty_c,
               lpc.Additional_Equipment_c,
               lpc.Addendum_Countersigned_c,
               lpc.Addendum_Sent_c,
               lpc.Addendum_Signed_c,
               lpc.annual_prod_report_yr_1_c,
               lpc.annual_prod_report_yr_2_c,
               lpc.annual_prod_report_yr_3_c,
               lpc.annual_prod_report_yr_4_c,
               lpc.Approved_Install_Docs_c,
               lpc.Auto_Amendment_Hold_c,
               lpc.Award_Amount_c,
               lpc.Batch_01_Date_c,
               lpc.Batch_02_Date_c,
               lpc.Batch_03_Date_c,
               lpc.Batch_04_Date_c,
               lpc.Billing_Notes_c,
               lpc.Booked_Date_c,
               lpc.Booking_Template_Sent_to_LD_c,
               lpc.Bypass_Energy_Start_Date_Update_c,
               lpc.Cash_Grant_Package_Complete_c,
               lpc.Lease_Change_Hold_Applied_c,
               lpc.Lease_Change_Hold_Released_c,
               lpc.Citi_Acceptance_Date_c,
               lpc.Lease_Close_Date_c,
               lpc.Closing_Request_Batch_c,
               lpc.Closing_Request_Date_c,
               lpc.Closing_Request_Resp_c,
               lpc.Cmpltd_ICF_Apprvd_c,
               lpc.CM_Pymnt_Posted_c,
               lpc.CM_Pymnt_Reference_c,
               lpc.CM_Pymnt_Rqustd_c,
               lpc.CM_Pymnt_Submitted_c,
               lpc.Cmsng_Rpt_Apprvd_c,
               lpc.Cnfrmd_ICF_Apprvd_c,
               lpc.Cnfrmd_Mon_Prvsnd_c,
               lpc.Cmsng_Rpt_Rcvd_c,
               lpc.Cmpltd_ICF_Rcvd_c,
               lpc.Cond_Fin_LW_Apprvd_c,
               lpc.Cond_Fin_LW_Rcvd_c,
               lpc.Cond_Prog_LW_Rcvd_c,
               lpc.Cond_Prog_LW_Apprvd_c,
               lpc.Cnfrmd_ICF_Rcvd_c,
               lpc.Cost_Basis_Amount_c,
               lpc.Create_Lease_Summary_c,
               lpc.Current_Stage_Date_c,
               lpc.Customer_Promise_Date_Inverter_c,
               lpc.Customer_Promise_Date_Mounting_c,
               lpc.Customer_Promise_Date_PV_c,
               lpc.Date_Countersigned_old_c,
               lpc.Date_in_PTO_Letter_c,
               lpc.Date_Lease_Document_signed_c,
               lpc.Date_of_Commissioning_c,
               lpc.Note_to_Dealer_Install_c,
               lpc.Dealer_Lease_Contact_Email_c,
               lpc.Dealer_Lease_Contact_Name_c,
               lpc.Dealer_Fee_PO_c,
               lpc.Dealer_Fee_Total_old_c,
               lpc.Dealer_Rebate_Reservation_Confirmation_c,
               lpc.Des_Plan_Apprvd_c,
               lpc.Devco_Batch_1_c,
               lpc.Devco_Batch_2_c,
               lpc.Devco_Batch_3_c,
               lpc.Devco_Batch_4_c,
               lpc.Early_Buyout_Price_c,
               lpc.Energy_Start_Date_c,
               lpc.Expected_Rebate_old_c,
               lpc.Expiration_Date_c,
               lpc.Fair_Market_Value_acctg_c,
              -- lpc.lease_payment_c_Final_Permits_Entered_By_c,
               lpc.Fin_Permits_Rcvd_c,
               lpc.Financier_Change_Date_c,
               lpc.Financing_Completion_Payment_c,
               lpc.Financing_Prepayment_c,
               lpc.Fin_Permits_Apprvd_c,
               lpc.Install_Acculmage_Confirmed_c,
               lpc.FMV_Purchase_Price_c,
               lpc.FMV_Rate_c,
               lpc.Revised_Items_Rcvd_c,
               lpc.Guarantee_Start_Date_c,
               lpc.Hold_Back_Hannon_Mezz_c,
               lpc.Holdback_NTP_B_c,
               lpc.Hold_Back_Sr_Debt_c,
               lpc.Hold_Back_Sunpower_Mezz_c,
               lpc.Hold_Back_TE_Cash_c,
               lpc.Incentive_Interconnect_Date_c,
               lpc.PIS_Estimation_c,
               lpc.Inspection_Waiver_c,
               lpc.Inspection_Waiver_Received_Date_c,
               lpc.Dealer_Fee_90_PO_Receipt_Complete_c,
               lpc.Dealer_Fee_90_PO_Receipt_Number_c,
               lpc.Install_Inv_Apprvd_c,
               lpc.Install_Inv_Amount_c,
               lpc.Install_Inv_Number_c,
               lpc.Install_Inv_Rcvd_c,
               lpc.Install_Pymnt_Apprvd_c,
               lpc.Payment_Date_Installation_c,
               lpc.Install_Pymnt_Sent_c,
               lpc.Integration_History_c,
               lpc.Interconnection_Acculmaged_Confirmed_c,
               lpc.Interconnection_Email_Sent_c,
               lpc.Payment_Date_Interconnect_c,
               lpc.Intrcnct_Pymnt_Sent_c,
               lpc.Dealer_Fee_10_PO_Receipt_Complete_c,
               lpc.Dealer_Fee_10_PO_Receipt_Number_c,
               lpc.Intrcnct_Inv_Apprvd_c,
               lpc.Intrcnct_Inv_Amount_c,
               lpc.Intrcnct_Inv_Number_c,
               lpc.Intrcnct_Inv_Rcvd_c,
               lpc.Intrcnct_Ltr_Apprvd_c,
               lpc.Intrcnct_Ltr_Rcvd_c,
               lpc.Intrcnct_Pymnt_Apprvd_c,
               lpc.Invoice_Admin_c,
               --lpc.lease_payment_c_invoice_admin_2_c,
               lpc.Invoice_Document_Email_c,
               lpc.Last_Install_Doc_Submission_c,
               lpc.Last_Interconnect_Doc_Submission_c,
               lpc.Lease_Change_Notes_c,
               lpc.Lease_Cost_c,
               lpc.Mat_Inv_Amount_c,
               lpc.Mat_Inv_Apprvd_c,
               lpc.Mat_Inv_Lien_Waiver_c,
               lpc.Mat_Inv_LW_Apprvd_c,
               lpc.Mat_Inv_Rcvd_c,
               lpc.Mat_Pymnt_Apprvd_c,
               lpc.Mat_Pymnt_Sent_c,
               lpc.Mat_Pymnt_Submitted_c,
               lpc.Note_to_Dealer_Final_c,
               lpc.Note_to_Dealer_Origination_c,
               lpc.Notice_to_Proceed_Sent_c,
               lpc.LPS_Notes_c,
               lpc.Partner_Oracle_Vendor_Email_c,
               lpc.Payment_Received_c,
               lpc.Payment_Request_Submitted_c,
               lpc.Pending_Interconnection_Email_Sent_c,
               lpc.Performance_Acceptance_Date_c,
               lpc.Install_Pymnt_Submitted_c,
               lpc.Photos_Apprvd_c,
               lpc.Photos_Rcvd_c,
               lpc.PIS_Deadline_Date_c,
               lpc.PIS_Entry_Date_c,
               lpc.Placed_In_Service_c,
               lpc.PO_Created_c,
               lpc.Preflight_Batch_c,
               lpc.Preflight_Batch_Date_c,
               lpc.Preflight_Response_c,
               lpc.Pricing_c,
               lpc.Proj_Admin_Status_c,
               lpc.Projected_Interconnect_Date_c,
               lpc.Proj_Install_Compete_c,
               lpc.PTO_Letter_Issuance_Date_c,
               lpc.PTO_Ltr_Rcvd_c,
               lpc.PTO_Ltr_Apprvd_c,
               lpc.Intrcnct_Pymnt_Submitted_c,
               lpc.Purchase_Hannon_Mezz_c,
               lpc.Purchase_NTP_B_c,
               lpc.Purchase_Price_c,
               lpc.Purchase_Sr_Debt_c,
               lpc.purchase_sun_power_mezz_c,
               lpc.Purchase_TE_Cash_c,
               lpc.Pymnt_Cert_Month_c,
               lpc.Rebate_Reserved_c,
               lpc.rev_rec_entry_date_c,
               lpc.Sales_Tax_c,
               lpc.Settlement_Hannon_Mezz_c,
               lpc.Settlement_NTP_B_c,
               lpc.Settlement_Price_c,
               lpc.Settlement_Sr_Debt_c,
               lpc.settlement_sun_power_mezz_c,
               lpc.Settlement_TE_Cash_c,
               lpc.SMS_ID_c,
               lpc.SMS_Installation_Checklist_Approv_c,
               lpc.SMS_Installation_Checklist_Received_c,
               lpc.SPEB_SO_c,
               lpc.SP_Invoice_c,
               lpc.SP_Invoice_Apprvd_c,
               lpc.SP_Invoice_Rcvd_c,
               lpc.spvt_case_to_sun_power_c,
               lpc.spvt_measurement_date_c,
               lpc.SPVT_Result_Pass_Date_c,
               lpc.SREC_Financier_c,
               lpc.SREC_Financiers_c,
               lpc.Substitute_Report_Submitted_Date_c,
               lpc.Sales_order_number_c,
               lpc.TAN_c,
               lpc.Tranche_Notes_c,
               lpc.id,
               lpc.Uncond_Fin_LW_Approved_c,
               lpc.Uncond_Fin_LW_Rcvd_c,
               lpc.US_Cash_Grant_Received_Date_c,
               lpc.Warr_SNs_Rcvd_c,
               lpc.Warr_SNs_Apprvd_c,
               lpc.Wattage_c,
               lpc.Welcome_Call_Complete_c,
               lpc.With_SH_Inventory_c,
                    case when lpc.lease_payment_c_invoice_admin_2_c is null and lpc.invoice_admin_2_c is not null then
                           2495780::bigint
                         else
                           lpc.lease_payment_c_invoice_admin_2_c end as lease_payment_c_invoice_admin_2_c,
                    case when lpc.lease_payment_c_Final_Permits_Entered_By_c is null and lpc.Final_Permits_Entered_By_c is not null then
                           2495780::bigint
                         else
                           lpc.lease_payment_c_Final_Permits_Entered_By_c end as lease_payment_c_Final_Permits_Entered_By_c,
                    p.id as project_id,
                    lov1.id as lov1_X1603_Financier_c,
                    lov2.id as lov2_X1603_Status_c,
                    lov3.id as lov3_DevCo_c,
                    lov4.id as lov4_Funding_Tranche_c,
                    lov5.id as lov5_Lease_1_or_2_c,
                    lov6.id as lov6_Lease_Change_Hold_Disposition_c,
                    lov7.id as lov7_Mosaic_Status_c,
                    lov8.id as lov8_Oracle_Cancellation_Status_c,
                    lov9.id as lov9_Reason_for_Cancellation_c,
                    lov10.id as lov10_Rebate_Authority_c,
                    lov11.id as lov11_SPVT_Result_c,
                    lov12.id as lov12_Stage_c, --Status_c
                    lov13.id as lov13_Tranche_1_Response_c,
                    lov14.id as lov14_Tranche_2_Response_c,
                    lov15.id as lov15_Tranche_3_Response_c,
                    lov16.id as lov16_Tranching_Status_c,
               concat(su.first_name,' ',su.email) as invoice_admin_2_c_name,
               concat(su1.first_name,' ',su1.email) as Final_Permits_Entered_By_c_name,
                    CASE WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY lpc.created_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
             from brs.LEASE_PAYMENT_C lpc
                    left join brs.sp_user su on su.id = lpc.invoice_admin_2_c
                    left join brs.sp_user su1 on su1.id = lpc.Final_Permits_Entered_By_c
                    inner join brs.account a on a.id = lpc.account_c
                    inner join brs.residential_project_c rpc on rpc.account_c = a.id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name =   lpc.x_1603_financier_c  and lov1.parent_id =25861
                    left join flow.list_of_value lov2 on lov2.name =   lpc.x_1603_status_c  and lov2.parent_id =25863
                    left join flow.list_of_value lov3 on lov3.name =   lpc.dev_co_c  and lov3.parent_id =25865
                    left join flow.list_of_value lov4 on lov4.name =   lpc.Funding_Tranche_c  and lov4.parent_id =25867
                    left join flow.list_of_value lov5 on lov5.name =   lpc.Lease_1_or_2_c  and lov5.parent_id =25869
                    left join flow.list_of_value lov6 on lov6.name =   lpc.Lease_Change_Hold_Disposition_c  and lov6.parent_id =25871
                    left join flow.list_of_value lov7 on lov7.name =   lpc.Mosaic_Status_c  and lov7.parent_id =25873
                    left join flow.list_of_value lov8 on lov8.name =   lpc.Oracle_Cancellation_Status_c  and lov8.parent_id =25875
                    left join flow.list_of_value lov9 on lov9.name =   lpc.Reason_for_Cancellation_c  and lov9.parent_id =25877
                    left join flow.list_of_value lov10 on lov10.name = lpc.Rebate_Authority_c  and lov10.parent_id =25879
                    left join flow.list_of_value lov11 on lov11.name = lpc.SPVT_Result_c  and lov11.parent_id =25881
                    left join flow.list_of_value lov12 on lov12.name = lpc.Stage_c  and lov12.parent_id =25923 --Status_c
                    left join flow.list_of_value lov13 on lov13.name = lpc.Tranche_1_Response_c  and lov13.parent_id =25883
                    left join flow.list_of_value lov14 on lov14.name = lpc.Tranche_2_Response_c  and lov14.parent_id =25885
                    left join flow.list_of_value lov15 on lov15.name = lpc.Tranche_3_Response_c  and lov15.parent_id =25887
                    left join flow.list_of_value lov16 on lov16.name = lpc.Tranching_Status_c  and lov16.parent_id =25889
             where lpc.is_deleted = false
             order by rpc.id,lpc.created_date
      loop
        v_total =v_total + 1;
        v_project_process_step_id = null;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id,nw_migration_id)
        values (x.project_id, 3800, null, case when x.is_last_row is true then 1 else 2 end, null, now(), now(), 2384850, 2384850, false,  --todo carlin to figure out status
                case when x.is_last_row is true then true else false end, null, null, null,x.id) returning id into v_project_process_step_id;

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29956,x.invoice_admin_2_c_name::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29953,x.Final_Permits_Entered_By_c_name::text , true);

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29402,x.lov1_X1603_Financier_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29403,x.US_Cash_Grant_Submission_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29404,x.X_1603_Notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29405,x.X_1603_Placed_In_Service_Submission_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29406,x.lov2_X1603_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29407,x.X_1603_Status_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29408,x.Acceptance_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29409,x.Acceptance_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29410,x.ACH_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29411,x.Note_to_Dealer_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29412,x.Add_Equipment_Qty_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29413,x.Additional_Equipment_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29414,x.Addendum_Countersigned_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29415,x.Addendum_Sent_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29416,x.Addendum_Signed_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29417,x.Annual_Escalation_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29418,x.annual_prod_report_yr_1_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29419,x.annual_prod_report_yr_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29420,x.annual_prod_report_yr_3_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29421,x.annual_prod_report_yr_4_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29422,x.Approved_Install_Docs_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29423,x.Auto_Amendment_Hold_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29424,x.Award_Amount_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29425,x.Base_Mon_Pymnt_Yr1_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29426,x.Base_Monthly_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29427,x.Base_PrePaid_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29428,x.Batch_01_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29429,x.Batch_02_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29430,x.Batch_03_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29431,x.Batch_04_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29432,x.Billing_Notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29433,x.Booked_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29434,x.Booking_Template_Sent_to_LD_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29435,x.Bypass_Energy_Start_Date_Update_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29436,x.Cash_Grant_Package_Complete_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29437,x.Lease_Change_Hold_Applied_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29456,x.Lease_Change_Hold_Released_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29457,x.Citi_Acceptance_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29458,x.Lease_Close_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29459,x.Closing_Request_Batch_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29460,x.Closing_Request_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29462,x.Closing_Request_Resp_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29463,x.Cmpltd_ICF_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29464,x.CM_Pymnt_Posted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29465,x.CM_Pymnt_Reference_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29466,x.CM_Pymnt_Rqustd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29467,x.CM_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29468,x.Cmsng_Rpt_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29469,x.Cnfrmd_ICF_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29470,x.Cnfrmd_Mon_Prvsnd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29471,x.Cmsng_Rpt_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29472,x.Cmpltd_ICF_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29473,x.Cond_Fin_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29475,x.Cond_Fin_LW_Rcvd_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29475,x.Cond_Fin_LW_Rcvd_YN_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29476,x.Cond_Prog_LW_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29477,x.Cond_Prog_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29478,x.Cnfrmd_ICF_Rcvd_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29479,x.Lease_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29480,x.Cost_Basis_Amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29481,x.Create_Lease_Summary_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29482,x.Credit_Check_Date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29483,x.Credit_Check_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29484,x.Current_Stage_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29485,x.Customer_Promise_Date_Inverter_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29486,x.Customer_Promise_Date_Mounting_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29487,x.Customer_Promise_Date_PV_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29488,x.Date_Countersigned_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29489,x.Date_Countersigned_old_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29490,x.Date_in_PTO_Letter_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29491,x.Date_Lease_Document_signed_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29492,x.Date_of_Commissioning_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29493,x.Date_Tranche_1_Submitted_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29494,x.Date_Tranche_2_Submitted_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29495,x.Date_Tranche_3_Submitted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29496,x.Note_to_Dealer_Install_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29497,x.Dealer_Lease_Contact_Email_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29498,x.Dealer_Lease_Contact_Name_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29499,x.Dealer_Fee_PO_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29500,x.Dealer_Fee_Total_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29501,x.Dealer_Fee_Total_old_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29502,x.Dealer_Name_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29503,x.Dealer_Rebate_Reservation_Confirmation_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29504,x.Des_Plan_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29505,x.lov3_DevCo_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29506,x.Devco_Batch_1_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29507,x.Devco_Batch_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29508,x.Devco_Batch_3_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29509,x.Devco_Batch_4_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29510,x.Docs_Gen_Date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29511,x.Down_Payment_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29512,x.Early_Buyout_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29513,x.Early_Buyout_Price_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29514,x.Email_1_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29515,x.Email_2_c::text , true);
       -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29516,x.End_Customer_Account_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29517,x.Energy_Start_Date_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29518,x.EV_Charger_Commission_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29519,x.EV_Charger_Model_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29520,x.EV_Charger_Price_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29521,x.EV_Charger_Quantity_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29522,x.EV_Outlet_Model_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29523,x.EV_Outlet_Price_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29524,x.EV_Outlet_Quantity_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29525,x.Expected_Rebate_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29526,x.Expected_Rebate_old_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29527,x.Expected_Release_of_NTP_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29528,x.Expiration_Date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29529,x.Fair_Market_Value_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29530,x.Fair_Market_Value_acctg_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29531,x.lease_payment_c_Final_Permits_Entered_By_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29532,x.Fin_Permits_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29533,x.lov4_Funding_Tranche_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29534,x.Financier_Change_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29535,x.Financing_Completion_Payment_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29536,x.Financing_Prepayment_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29537,x.FinancingType_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29538,x.Fin_Permits_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29539,x.Install_Acculmage_Confirmed_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29540,x.First_Name_1_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29541,x.First_Name_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29542,x.FMV_Purchase_Price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29543,x.FMV_Rate_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29544,x.Revised_Items_Rcvd_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29545,x.Full_Prepaid_Lease_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29546,x.Full_Prepayment_Amt_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29547,x.Guarantee_Start_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29548,x.Hold_Back_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29549,x.Holdback_NTP_B_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29550,x.Hold_Back_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29551,x.Hold_Back_Sunpower_Mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29552,x.Hold_Back_TE_Cash_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29553,x.Home_Phone_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29554,x.Incentive_Interconnect_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29555,x.PIS_Estimation_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29556,x.Inspection_Waiver_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29557,x.Inspection_Waiver_Received_Date_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29558,x.Install_Doc_Count_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29559,x.Install_Documents_Remaining_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29560,x.Dealer_Fee_90_PO_Receipt_Complete_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29561,x.Dealer_Fee_90_PO_Receipt_Number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29562,x.Install_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29563,x.Install_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29564,x.Install_Inv_Number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29565,x.Install_Inv_Rcvd_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29566,x.Install_URL_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29567,x.Install_Pymnt_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29568,x.Payment_Date_Installation_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29569,x.Install_Pymnt_Sent_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29570,x.Integration_History_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29571,x.Interconnect_Documents_Remaining_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29572,x.Interconnection_Acculmaged_Confirmed_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29573,x.Interconnection_Email_Sent_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29574,x.Interconnect_URL_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29575,x.Payment_Date_Interconnect_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29576,x.Intrcnct_Pymnt_Sent_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29577,x.Intrcnct_Doc_Count_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29578,x.Dealer_Fee_10_PO_Receipt_Complete_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29579,x.Dealer_Fee_10_PO_Receipt_Number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29580,x.Intrcnct_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29581,x.Intrcnct_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29582,x.Intrcnct_Inv_Number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29583,x.Intrcnct_Inv_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29584,x.Intrcnct_Ltr_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29585,x.Intrcnct_Ltr_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29586,x.Intrcnct_Pymnt_Apprvd_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29587,x.Inverter_Brand_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29588,x.Inverter_Brand_2_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29589,x.Inverter_Model_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29590,x.Inverter_Model_2_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29591,x.Inverter_Qty_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29592,x.Inverter_Qty_2_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Inverter_Model_3_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29593,x.Invoice_Admin_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29594,x.lease_payment_c_invoice_admin_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29595,x.Invoice_Document_Email_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29596,x.LastCommaFirst_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29597,x.Last_Install_Doc_Submission_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29598,x.Last_Interconnect_Doc_Submission_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29599,x.Last_Name_1_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29600,x.Last_Name_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29601,x.lov5_Lease_1_or_2_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29602,x.lov6_Lease_Change_Hold_Disposition_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29603,x.Lease_Change_Notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29604,x.Lease_Cost_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29605,x.Lease_Cost_AU_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29606,x.Lease_Phase_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29607,x.Lease_Stage_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29608,x.Lease_Type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29609,x.lov7_Mosaic_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29610,x.Mat_Inv_Amount_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29611,x.Mat_Inv_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29612,x.Mat_Inv_Lien_Waiver_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29613,x.Mat_Inv_LW_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29614,x.Mat_Inv_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29615,x.Mat_Pymnt_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29616,x.Mat_Pymnt_Sent_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29617,x.Mat_Pymnt_Submitted_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29618,x.Module_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29619,x.Module_Qty_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29620,x.Monitoring_Type_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29621,x.Multiple_Meters_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.New_Homeowner_Account_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29622,x.New_Homeowner_Contact_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.New_Homeowner_Primary_Contact_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29623,x.New_Home_Owner_Email_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29624,x.New_Home_Owner_Phone_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29625,x.Note_to_Dealer_Final_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29626,x.Note_to_Dealer_Origination_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29627,x.Notice_to_Proceed_Sent_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Opportunity_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29628,x.lov8_Oracle_Cancellation_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29629,x.LPS_Notes_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29630,x.Partial_prepayment_c::text , true);
       -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29631,x.Partner_Account_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29632,x.Partner_Oracle_Vendor_Email_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29633,x.Payment_Received_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29634,x.Payment_Request_Submitted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29635,x.Pending_Interconnection_Email_Sent_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29636,x.Performance_Acceptance_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29637,x.Install_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29638,x.Photos_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29639,x.Photos_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29640,x.PIS_Deadline_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29641,x.PIS_Entry_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29642,x.Placed_In_Service_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29643,x.PO_Created_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29644,x.Preflight_Batch_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29645,x.Preflight_Batch_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29646,x.Preflight_Response_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29647,x.Presentment_1_Payment_Date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29648,x.Presentment_2_Payment_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29649,x.Pricing_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29650,x.Proj_Admin_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29651,x.Projected_Interconnect_Date_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29652,x.Project_Type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29653,x.Proj_Install_Compete_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29654,x.PSR_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29655,x.PTO_Letter_Issuance_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29656,x.PTO_Ltr_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29657,x.PTO_Ltr_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29658,x.Intrcnct_Pymnt_Submitted_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29659,x.Purchase_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29660,x.Purchase_NTP_B_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29661,x.Purchase_Price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29662,x.Purchase_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29663,x.purchase_sun_power_mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29664,x.Purchase_TE_Cash_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29665,x.Pymnt_Cert_Month_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Quote_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29666,x.Racking_Model_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29667,x.Racking_Qty_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29668,x.lov9_Reason_for_Cancellation_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29669,x.lov10_Rebate_Authority_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29670,x.Rebate_Reserved_c::text , true);
        --perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Residential_Project_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29671,x.rev_rec_entry_date_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29672,x.RSM_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29673,x.Sales_Tax_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29674,x.Sales_Tax_Formula_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29675,x.Settlement_Hannon_Mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29676,x.Settlement_NTP_B_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29677,x.Settlement_Price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29678,x.Settlement_Sr_Debt_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29679,x.settlement_sun_power_mezz_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29680,x.Settlement_TE_Cash_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Size_KW_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Size_Wdc_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29681,x.SLA_Interconnect_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29682,x.SMS_ID_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29683,x.SMS_Installation_Checklist_Approv_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29684,x.SMS_Installation_Checklist_Received_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29685,x.SPEB_SO_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29686,x.SP_Invoice_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29687,x.SP_Invoice_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29688,x.SP_Invoice_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29689,x.spvt_case_to_sun_power_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29690,x.spvt_measurement_date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29691,x.lov11_SPVT_Result_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29692,x.SPVT_Result_Pass_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29693,x.SREC_Financier_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29694,x.SREC_Financiers_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29784,x.lov12_Stage_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,,x.Status_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29695,x.Storage_Model_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29696,x.Storage_Count_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29697,x.Storage_Commission_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29698,x.Storage_Expansion_Model_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29699,x.Storage_Expansion_Quantity_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29700,x.Storage_Price_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29701,x.Storage_Size_c::text , true);
--         perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29702,x.Storage_System_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29703,x.Substitute_Report_Submitted_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29704,x.Sales_order_number_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29705,x.System_Price_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29706,x.TAN_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29707,x.Tot_Monthly_Payments_c::text , true);
       -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29708,x.Tranche_1_Batch_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29709,x.lov13_Tranche_1_Response_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29710,x.Tranche_1_Response_Date_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29711,x.Tranche_1_Type_c::text , true);
       -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29712,x.Tranche_2_Batch_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29713,x.lov14_Tranche_2_Response_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29714,x.Tranche_2_Response_Date_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29715,x.Tranche_2_Type_c::text , true);
       -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29716,x.Tranche_3_Batch_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29717,x.lov15_Tranche_3_Response_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29718,x.Tranche_3_Response_Date_c::text , true);
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29719,x.Tranche_3_Type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29720,x.Tranche_Notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29721,x.lov16_Tranching_Status_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29722,x.Uncond_Fin_LW_Approved_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29723,x.Uncond_Fin_LW_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29724,x.US_Cash_Grant_Received_Date_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29725,x.Warr_SNs_Rcvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29726,x.Warr_SNs_Apprvd_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29727,x.Wattage_c::text , true);
        -- perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29728,x.Watts_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29729,x.Welcome_Call_Complete_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29730,x.With_SH_Inventory_c::text , true);

      end loop;
    raise notice 'Residential Property Lease Payment END = %',clock_timestamp();
    raise notice 'Residential Property Lease Payment Total = %',v_total;
  end
$do$;
