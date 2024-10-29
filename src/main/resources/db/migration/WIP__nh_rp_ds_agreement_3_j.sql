SET session_replication_role = replica;
DO
$do$
  declare
    x record;
    v_on_hold_reason_s_c bigint[];
    v_sub_category_c bigint[];
    v_project_process_step_id bigint;
    v_count bigint;
    v_total bigint;
  BEGIN
    raise notice '18 START = %',clock_timestamp();
    v_count = 0;
    v_total = 0;
    for x in select
               dac.name,
               dac.docu_sign_envelope_c,
               dac.docu_sign_status_c,
               dac.contract_type_c,
               dac.document_url_c,
               dac.ready_to_sign_c,
               dac.owner_id,
               dac.reviewer_c,
               dac.record_type_id,
               dac.adhoc_create_lda_requested_c,
               dac.migrated_from_adobe_c,
               dac.on_hold_reason_s_c,
               dac.sub_category_c,
               dac.notes_c,
               dac.countersignatory_notes_c,
               case when dac.ds_agreement_c_owner_id is null and dac.owner_id is not null then
                      2495780::bigint
                    else
                      ds_agreement_c_owner_id end as ds_agreement_c_owner_id,
               case when dac.ds_agreement_c_reviewer_c is null and dac.reviewer_c is not null then
                      2495780::bigint
                    else
                      ds_agreement_c_reviewer_c end as ds_agreement_c_reviewer_c,
               dac.cancellation_reason_c,
               dac.hold_notes_c,
               dac.id,
               dac.ENVELOPE_STATUS_C,
               p.id as project_id,
               lov1.id as lov1_cancellation_reason_c,
               lov2.id as lov2_contract_type_c,
               CASE WHEN row_number() OVER (PARTITION BY rpc.id ORDER BY dac.last_modified_date desc) = 1 THEN TRUE ELSE FALSE END AS is_last_row
             from brs.ds_agreement_c dac
                    inner join brs.account a on a.id = dac.account_c
                    inner join brs.residential_project_c rpc on rpc.account_c = a.id
                    inner join flow.project p on p.nw_migration_id = rpc.id
                    left join flow.list_of_value lov1 on lov1.name = dac.cancellation_reason_c and lov1.parent_id =25850
                    left join flow.list_of_value lov2 on lov2.name = dac.contract_type_c and lov2.parent_id = 25842
             order by rpc.id,dac.last_modified_date
      loop
        v_count = v_count + 1;
        v_total = v_total + 1;
        if v_count = 5000 then
          raise notice 'v_count = %',v_count;
          raise notice 'v_total = %',v_total;
          --commit;
          v_count = 0;
        end if;
        v_project_process_step_id = null;
        insert into flow.project_process_step (project_id, process_step_id, user_position_id,
                                               company_process_step_status_type_id,
                                               process_step_complete_date, date_created, date_modified, created_by_id,
                                               modified_by_id, archived, main, parent_project_process_step_id,
                                               cancelled_date, parent_project_process_step_event_id,nw_migration_id)
        values (x.project_id, 3799, null, case when x.ENVELOPE_STATUS_C = 'Waiting for Co-Signer' then 1779
                                               when x.ENVELOPE_STATUS_C = 'Waiting for Countersignature' then 1780
                                               when x.ENVELOPE_STATUS_C = 'In Review' then 1775
                                               when x.ENVELOPE_STATUS_C = 'Loan App Submitted' then 1785
                                               when x.ENVELOPE_STATUS_C = 'Draft' then 1777
                                               when x.ENVELOPE_STATUS_C = 'Expired' then 1784
                                               when x.ENVELOPE_STATUS_C = 'Waiting for Counter-Signature' then 1780
                                               when x.ENVELOPE_STATUS_C = 'Signed' then 1782
                                               when x.ENVELOPE_STATUS_C = 'On Hold' then 1781
                                               when x.ENVELOPE_STATUS_C = 'Out for Signature' then 1778
                                               when x.ENVELOPE_STATUS_C = 'Loan App Signed' then 1782
                                               when x.ENVELOPE_STATUS_C = 'Cancelled' then 3
                                               when x.ENVELOPE_STATUS_C = 'Cancelled / Declined' then 3
                                               else 3 end
                 , null, now(), now(), 2384850, 2384850, false,
                case when x.is_last_row is true then true else false end, null, null, null,x.id) returning id into v_project_process_step_id;
        --  perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29379,x.contract_number_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29380,x.docu_sign_envelope_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29381,x.docu_sign_status_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29382,x.lender_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29383,x.lov2_contract_type_c::text , true);
        --    perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29384,x.finance_type_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29385,x.document_url_c::text , true);
        --   perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29386,x.storage_only_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29387,x.ready_to_sign_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29388,x.ds_agreement_c_owner_id::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29389,x.ds_agreement_c_reviewer_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29390,x.record_type_id::text , true);
        --    perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29391,x.Date_Sent_Formula_c::text , true);
        --    perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29392,x.Date_Completed_Formula_c::text , true);
        --    perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29393,x.Last_Status_Update_Formula_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29394,x.adhoc_create_lda_requested_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29395,x.migrated_from_adobe_c::text , true);
        v_on_hold_reason_s_c = null;
        if x.on_hold_reason_s_c is not null then
          select array_agg(lov.id)
          into v_on_hold_reason_s_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) on_hold_reason_s_c
                 FROM (
                        SELECT STRING_AGG(on_hold_reason_s_c, ';') AS aggregated_column
                        from brs.ds_agreement_c d
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.on_hold_reason_s_c and lov.parent_id =25846 ;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29396,v_on_hold_reason_s_c::text , true);
        end if;
        v_sub_category_c = null;
        if x.sub_category_c is not null then
          select array_agg(lov.id)
          into v_sub_category_c
          from (
                 SELECT unnest(string_to_array(aggregated_column, ';')) sub_category_c
                 FROM (
                        SELECT STRING_AGG(sub_category_c, ';') AS aggregated_column
                        from brs.ds_agreement_c d
                        where id = x.id
                      ) AS subquery) as foo
                 inner join flow.list_of_value lov on lov.name = foo.sub_category_c and lov.parent_id = 25848;
          perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29397,v_sub_category_c::text , true);
        end if;
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29398,x.notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29399,x.countersignatory_notes_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29400,x.lov1_cancellation_reason_c::text , true);
        perform flow.set_pps_cfv_no_checks(v_project_process_step_id , 2384850,29401,x.hold_notes_c::text , true);

      end loop;
    raise notice '18 END = %',clock_timestamp();
    raise notice '18 END total  = %',v_total;
  end
$do$;
