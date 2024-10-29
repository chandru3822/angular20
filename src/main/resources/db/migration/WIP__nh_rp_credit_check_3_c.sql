SET session_replication_role = replica;
DO
$do$
  declare
    x       record;
    v_count bigint;
    v_total bigint;
    v_project_process_step_id bigint;
  BEGIN
    raise notice '6 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select p.id             as project_id,
                    ccrc.id as credit_check_request_id,
                    ccrc.auth_token_c,
                    ccrc.comments_c,
                    ccrc.credit_application_url_c,
                    ccrc.credit_check_approval_date_c,
                    ccrc.credit_check_decision_date_c,
                    ccrc.credit_check_expiration_date_c,
                    ccrc.credit_check_message_c,
                    ccrc.credit_check_submission_date_c,
                    ccrc.decision_reason_c,
                    ccrc.error_message_c,
                    ccrc.external_id_c,
                    ccrc.first_name_c,
                    ccrc.govt_id_upload_time_c,
                    ccrc.last_name_c,
                    ccrc.mortgage_pre_approval_letter_upload_time_c,
                    ccrc.mortgage_pre_approval_letter_url_c,
                    ccrc.offer_id_c,
                    ccrc.phone_c,
                    ccrc.send_lease_credit_check_failure_email_c,
                    ccrc.share_id_c,
                    ccrc.status_c,
                    ccrc.successful_invite_c,
                    lov1.id          as lov1_application_type_c_id,
                    lov2.id          as lov2_bureau_c_id,
                    lov3.id          as lov3_credit_beureu_c_id,
                    lov4.id          as lov4_lender_c_id,
                    CASE
                      WHEN row_number() OVER (PARTITION BY account_c ORDER BY ccrc.credit_check_expiration_date_c desc) = 1 THEN TRUE --todo check nulls
                      ELSE FALSE END AS is_last_row
             from brs.CREDIT_CHECK_REQUEST_C ccrc
                    inner join flow.contact c on c.nw_migration_id = ccrc.account_c
                    inner join flow.project p on p.contact_id = c.id
                    left join flow.list_of_value lov1 on lov1.name = ccrc.application_type_c and lov1.parent_id = 25709
                    left join flow.list_of_value lov2 on lov2.name = ccrc.bureau_c and lov2.parent_id = 25711
                    left join flow.list_of_value lov3 on lov3.name = ccrc.credit_beureu_c and lov3.parent_id = 25713
                    left join flow.list_of_value lov4 on lov4.name = ccrc.lender_c and lov4.parent_id = 25715
             order by ccrc.account_c,ccrc.credit_check_expiration_date_c
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
        values (x.project_id, 3792, null, case when x.is_last_row is true then 1 else 2 end, null, now(), now(),
                2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null,x.credit_check_request_id) returning id into v_project_process_step_id;

        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28786, x.auth_token_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28788, x.comments_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28789, x.credit_application_url_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28791, x.credit_check_approval_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28792, x.credit_check_decision_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28793, x.credit_check_expiration_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28794, x.credit_check_message_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28796, x.credit_check_submission_date_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28797, x.decision_reason_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28798, x.error_message_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28799, x.external_id_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28800, x.first_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28801, x.govt_id_upload_time_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28802, x.last_name_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28804, x.mortgage_pre_approval_letter_upload_time_c::text,true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28805, x.mortgage_pre_approval_letter_url_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28806, x.offer_id_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28807, x.phone_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28808, x.send_lease_credit_check_failure_email_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28809, x.share_id_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28810, x.status_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28811, x.successful_invite_c::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28785, x.lov1_application_type_c_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28790, x.lov2_bureau_c_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28795, x.lov3_credit_beureu_c_id::text, true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id, 2384850, 28803, x.lov4_lender_c_id::text, true);
      end loop;
    raise notice '6 END = %',clock_timestamp();
    raise notice '6 END total = %',v_total;
  end
$do$;
