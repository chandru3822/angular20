CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard_and_cohort_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id integer,
                                                                               p_user_position_ids integer[],
                                                                               p_org_ids integer[],
                                                                               p_is_checked_in_column boolean,
                                                                               p_is_cohort boolean)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company              boolean;
  v_outcome_int_values         int[];
  v_exclude_values             boolean;
  v_hide_future                boolean;
  v_only_future                boolean;
  v_order_by_closer_appt_start boolean;
  v_funnel_type_id             int;

BEGIN
  --If p_user_position_ids has a -1 that means get the funnel for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;

  select case when p_funnel_id = 11 then true else false end into v_order_by_closer_appt_start; --pitched

  select hide_future, only_future, exclude_values, funnel_type_id, closer_appt_outcome_int_values
  into v_hide_future, v_only_future, v_exclude_values, v_funnel_type_id, v_outcome_int_values
  from brs.funnel
  where id = p_funnel_id;

  if v_funnel_type_id = 3 then
    --9 = credits run, 3 = credits passed, 4 = bookings complete, 5 = site surveys verified, 6 = final designs sent to homeowner
    --7 = final designs approved, 21 = final designs completed, 8 = installations completed
    if p_is_cohort then
      RETURN QUERY
        select array_to_json(array_agg(row_to_json(funnel_rows)))
        from (
               select pd.closer_name                 as  owner_name,
                      o.org_name                         office,
                      pd.project_state_abbreviation      state,
                      pd.company_project_status_type as  status_type,
                      pd.contact_name                as  customer_name,
                      pd.contact_id,
                      pd.project_id,
                      pd.source_name,
                      pd.system_size,
                      pd.primary_financier_name          financier,
                      pd.closer_appointment_start        appointment_date,
                      pd.cancelled_date,
                      pd.closer_appointment_outcome_name appointment_outcome,
                      pd.credit_decision_date,
                      pd.credit_check_name               credit_check,
                      pd.installation_agreement_signed_date,
                      pd.site_survey_verified_date,
                      pd.final_design_sent_to_homeowner_date,
                      pd.final_design_signed_date,
                      pd.final_design_signed_date,
                      pd.final_design_complete_date,
                      pd.financial_agreement_signed_date,
                      pd.substantial_completion_date,
                      pd.proof_of_homeowners_insurance_obtained_date,
                      pd.first_cash_payment_paid_date    cash_down_payment,
                      pd.utility_bill_verified_date,
                      pd.site_survey_end_time            site_survey_completed_date,
                      case
                        when p_funnel_id in (9, 3) then pd.credit_decision_date
                        when p_funnel_id = 4 then pd.installation_agreement_signed_date
                        when p_funnel_id = 5 then pd.site_survey_verified_date
                        when p_funnel_id = 6 then pd.final_design_sent_to_homeowner_date
                        when p_funnel_id = 7 then pd.final_design_signed_date
                        when p_funnel_id = 21 then pd.final_design_complete_date
                        when p_funnel_id = 8 then pd.substantial_completion_date
                        end                          as  order_by_date
               from brs.project_details pd
                      --we dont have to do this join for the where clause but other numbers do an inner join so we do it here to limit the results
                      inner join flow.user_position up on up.id = pd.closer_user_position_id
                      inner join flow.org o on o.id = up.org_id
                      inner join flow.project_process_step pps
                                 on pps.project_id = pd.project_id and pps.process_step_id = 1
                      inner join flow.project_process_step_event ppse
                                 on pps.id = ppse.project_process_step_id and
                                    ppse.process_step_event_id = 14 and ppse.archived is false
                      inner join flow.project_process_step_event_custom_field_value ppsecfv
                                 on ppse.id = ppsecfv.project_process_step_event_id and
                                    ppsecfv.custom_field_group_assignment_id =
                                    4 --closer appt outcome
               where
                 -- if not whole company then filter by user
                 -- and check/filter by org if needed
                 case
                   when v_whole_company is false then
                     (up.id = any (p_user_position_ids)
                       and case when array_length(p_org_ids, 1) > 0 then org_id = any (p_org_ids) else 1 = 1 end)
                   else true end
                 and pd.archived is false
                 and (ppse.start_time :: DATE between p_start_date and p_end_date)
                 and ppsecfv.int_value in (select unnest(string_to_array(value, ',')::int[])
                                           from flow.company_configuration_value
                                           where code = 'OUTCOME_PITCHED')
                 and pd.company_id = 3
                 --credit check int value
                 and case when p_funnel_id = 3 then pd.credit_check = 82 else true end
                 and case
                       when p_funnel_id in (9, 3) then credit_decision_date is not null
                       when p_funnel_id in (4) then installation_agreement_signed_date is not null
                       when p_funnel_id in (5) then site_survey_verified_date is not null
                       when p_funnel_id in (6) then final_design_sent_to_homeowner_date is not null
                       when p_funnel_id in (7) then final_design_signed_date is not null
                       when p_funnel_id in (21) then final_design_complete_date is not null
                       when p_funnel_id in (8) then substantial_completion_date is not null
                       else true end
               group by pd.closer_name, o.org_name, pd.project_state_abbreviation, pd.company_project_status_type,
                        pd.contact_name, pd.contact_id, pd.project_id, pd.source_name, pd.system_size,
                        pd.primary_financier_name, pd.closer_appointment_start, pd.cancelled_date,
                        pd.closer_appointment_outcome_name, pd.credit_decision_date, pd.credit_check_name,
                        pd.installation_agreement_signed_date, pd.site_survey_verified_date,
                        pd.final_design_sent_to_homeowner_date, pd.final_design_signed_date,
                        pd.final_design_signed_date, pd.final_design_complete_date, pd.financial_agreement_signed_date,
                        pd.substantial_completion_date, pd.proof_of_homeowners_insurance_obtained_date,
                        pd.first_cash_payment_paid_date, pd.utility_bill_verified_date, pd.site_survey_end_time,
                        order_by_date
               order by owner_name, order_by_date
             ) as funnel_rows;
    else
      RETURN QUERY
        select array_to_json(array_agg(row_to_json(funnel_rows)))
        from (
               select pd.closer_name                 as  owner_name,
                      o.org_name                         office,
                      pd.project_state_abbreviation      state,
                      pd.company_project_status_type as  status_type,
                      pd.contact_name                as  customer_name,
                      pd.contact_id,
                      pd.project_id,
                      pd.source_name,
                      pd.system_size,
                      pd.primary_financier_name          financier,
                      pd.closer_appointment_start        appointment_date,
                      pd.cancelled_date,
                      pd.closer_appointment_outcome_name appointment_outcome,
                      pd.credit_decision_date,
                      pd.credit_check_name               credit_check,
                      pd.installation_agreement_signed_date,
                      pd.site_survey_verified_date,
                      pd.final_design_sent_to_homeowner_date,
                      pd.final_design_signed_date,
                      pd.final_design_signed_date,
                      pd.final_design_complete_date,
                      pd.financial_agreement_signed_date,
                      pd.substantial_completion_date,
                      pd.proof_of_homeowners_insurance_obtained_date,
                      pd.first_cash_payment_paid_date    cash_down_payment,
                      pd.utility_bill_verified_date,
                      pd.site_survey_end_time            site_survey_completed_date,
                      case
                        when p_funnel_id in (9, 3) then pd.credit_decision_date
                        when p_funnel_id = 4 then pd.installation_agreement_signed_date
                        when p_funnel_id = 5 then pd.site_survey_verified_date
                        when p_funnel_id = 6 then pd.final_design_sent_to_homeowner_date
                        when p_funnel_id = 7 then pd.final_design_signed_date
                        when p_funnel_id = 21 then pd.final_design_complete_date
                        when p_funnel_id = 8 then pd.substantial_completion_date
                        end                          as  order_by_date
               from brs.project_details pd
                      inner join flow.user_position up on up.id = pd.closer_user_position_id
                      inner join flow.org o on o.id = up.org_id
               where
                 -- if not whole company then filter by user
                 -- and check/filter by org if needed
                 case
                   when v_whole_company is false then
                     (up.id = any (p_user_position_ids)
                       and case when array_length(p_org_ids, 1) > 0 then org_id = any (p_org_ids) else 1 = 1 end)
                   else true end
                 --date checks (same as `date between start and end AND date is not null) ..i think
                 and case
                       when p_funnel_id in (9, 3) then (coalesce(
                         credit_decision_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (4) then (coalesce(
                         installation_agreement_signed_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (5) then (coalesce(
                         site_survey_verified_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (6) then (coalesce(
                         final_design_sent_to_homeowner_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (7) then (coalesce(
                         final_design_signed_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (21) then (coalesce(
                         final_design_complete_date :: DATE between p_start_date and p_end_date, false))
                       when p_funnel_id in (8) then (coalesce(
                         substantial_completion_date :: DATE between p_start_date and p_end_date, false))
                       else true end
                 --credit check int value
                 and case when p_funnel_id = 3 then pd.credit_check = 82 else true end
                 and pd.company_id = 3
               order by owner_name, order_by_date
             ) as funnel_rows;
    end if;
  else
    RETURN QUERY
      select array_to_json(array_agg(row_to_json(funnel_rows)))
      from (
             select owner_name,
                    office,
                    state,
                    status_type,
                    customer_name,
                    contact_id,
                    project_id,
                    source_name,
                    system_size,
                    financier,
                    case when p_is_checked_in_column then checked_in_time end as checked_in_time,
                    appointment_date, -- appointment_date === ppse.start_time (from the view)
                    cancelled_date,
                    appointment_outcome
             from brs.closer_dashboard_drilldown_vw
             where ((appointment_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
               -- if not whole company then filter by user
               -- and check/filter by org if needed
               and case
                     when v_whole_company is false then
                       (closer_user_position_id = any (p_user_position_ids)
                         and case when array_length(p_org_ids, 1) > 0 then org_id = any (p_org_ids) else 1 = 1 end)
                     else true end

               -- 24 = Non-dispositioned appointments and there is a special rule:
               and case
                     when p_funnel_id = 24 then (closer_appt_outcome_int_value = any (v_outcome_int_values) or
                                                 (closer_appt_outcome_int_value is null and
                                                  ((appointment_date at time zone 'UTC') at time zone 'US/Mountain') <
                                                  (now() at time zone 'US/Mountain'))
                       )
               -- if included values then do in()
                     when v_exclude_values is false and array_length(v_outcome_int_values::int[], 1) > 0
                       then closer_appt_outcome_int_value = any (v_outcome_int_values)
               --these will not run/be populated if the special case above is true so we dont need to have an additional check
               -- if excluded values then do not in()

                     when v_exclude_values is true and array_length(v_outcome_int_values::int[], 1) > 0
                       then (closer_appt_outcome_int_value is null OR
                             closer_appt_outcome_int_value not in (select unnest(v_outcome_int_values)))
                     else true end
               -- if dont show anything at a future time
               and case
                     when v_hide_future then
                         ((appointment_date at time zone 'UTC') at time zone 'US/Mountain') <
                         (now() AT TIME ZONE 'US/Mountain')
                     else true end
               -- if only show future
               and case
                     when v_only_future then
                         ((appointment_date at time zone 'UTC') at time zone 'US/Mountain') >
                         (now() at time zone 'US/Mountain')
                     else true end
               -- if checked_in_column is true then filter to those only
               and case when p_is_checked_in_column then checked_in_time is not null else true end
             order by owner_name,
                      case when v_order_by_closer_appt_start then closer_appointment_start else appointment_date end
           ) as funnel_rows;
  END IF;

END
$function$
