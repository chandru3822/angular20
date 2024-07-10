drop function if exists brs.rpt_closer_funnel_standard_and_cohort_drilldown(p_start_date date, p_end_date date,
                                                                            p_funnel_id bigint,
                                                                            p_user_position_ids bigint[],
                                                                            p_org_ids bigint[],
                                                                            p_is_checked_in_column boolean,
                                                                            p_is_cohort boolean,
                                                                            p_run_by_id bigint);
drop function if exists brs.rpt_closer_funnel_standard_drilldown(p_start_date date, p_end_date date,
                                                                            p_funnel_id bigint,
                                                                            p_user_position_ids bigint[],
                                                                            p_org_ids bigint[],
                                                                            p_is_checked_in_column boolean,
                                                                            p_appointment_type_ids bigint[],
                                                                            p_lead_source_ids bigint[],
                                                                            p_hide_inactive boolean);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard_drilldown(p_start_date date, p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_user_position_ids bigint[],
                                                                               p_is_checked_in_column boolean,
                                                                               p_appointment_type_ids bigint[],
                                                                               p_lead_source_ids bigint[],
                                                                               p_hide_inactive boolean default false)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company              boolean;
  v_outcome_int_values         bigint[];
  v_exclude_values             boolean;
  v_hide_future                boolean;
  v_only_future                boolean;
  v_order_by_closer_appt_start boolean;
  v_funnel_type_id             bigint;
  v_all_sources              boolean;
  v_filter_appointment_types boolean;
  v_is_round_robin           boolean;

BEGIN
  --If p_user_position_ids has a -1 that means get the funnel for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;
  select -1 = any (p_lead_source_ids) into v_all_sources;
  v_filter_appointment_types = true;
  v_is_round_robin = false;
  if (p_appointment_type_ids is null) or p_appointment_type_ids is not null and array_length(p_appointment_type_ids, 1) = 2 then
    v_filter_appointment_types = false;
  elsif 1 = any (p_appointment_type_ids) then
    v_is_round_robin = true;
  end if;

  select hide_future, only_future, exclude_values, funnel_type_id, closer_appt_outcome_int_values
  into v_hide_future, v_only_future, v_exclude_values, v_funnel_type_id, v_outcome_int_values
  from brs.funnel
  where id = p_funnel_id;

  if v_funnel_type_id = 3 then
    --9 = credits run, 3 = credits passed, 4 = bookings complete, 5 = site surveys verified, 6 = final designs sent to homeowner
    --7 = final designs approved, 21 = final designs completed, 8 = installations completed
    RETURN QUERY
      select array_to_json(array_agg(row_to_json(funnel_rows)))
      from (select pd.closer_name                 as  owner_name,
                   o.org_name                         office,
                   pd.project_state_abbreviation      state,
                   pd.metro_area_name             as  metro_area,
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
                   pd.site_survey_completed_date      site_survey_completed_date,
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
                   inner join flow.user u on u.id = pd.closer_user_id
                   inner join flow.company_user_status cus on cus.user_id = u.id
                   inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                   left join flow.user_position up on up.id = pd.closer_user_position_id
                   left join flow.org o on o.id = up.org_id
            where pd.company_id = 3
              and case when p_hide_inactive is true then
                         ust.id = 9 else true end
              and
              -- if not whole company then filter by user
              -- and check/filter by org if needed
              case
                when v_whole_company is false then
                  up.id = any (p_user_position_ids)
                else true end
              and case
                    when v_all_sources is false then
                      pd.source = any (p_lead_source_ids)
                    else true end
              and case
                    when v_filter_appointment_types is true then
                      pd.prioritized_closer_appointment_by_round_robin =
                      v_is_round_robin
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
                      ((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                       'US/Mountain')::DATE between p_start_date and p_end_date, false))
                    when p_funnel_id in (7) then (coalesce(
                      final_design_signed_date :: DATE between p_start_date and p_end_date, false))
                    when p_funnel_id in (21) then (coalesce(
                      final_design_complete_date :: DATE between p_start_date and p_end_date, false))
                    when p_funnel_id in (8) then (coalesce(
                      substantial_completion_date :: DATE between p_start_date and p_end_date, false))
                    else true end
              --credit check bigint value
              and case when p_funnel_id = 3 then pd.credit_check = 82 else true end
              and pd.company_id = 3
            order by owner_name, order_by_date) as funnel_rows;
  else
    RETURN QUERY
      select array_to_json(array_agg(row_to_json(funnel_rows)))
      from (select pd.closer_name as  owner_name,
                   o.org_name as office,
                   pd.project_state_abbreviation      state,
                   pd.metro_area_name             as  metro_area,
                   pd.company_project_status_type as  status_type,
                   pd.project_name,
                   pd.contact_id,
                   pd.project_id,
                   pd.source_name,
                   pd.system_size,
                   pd.primary_financier_name          financier,
                   case when p_is_checked_in_column then pd.prioritized_closer_dashboard_checkin end as checked_in_time,
                   pd.closer_appointment_start        appointment_date,
                   pd.cancelled_date,
                   pd.prioritized_closer_dashboard_outcome,
                   pd.prioritized_closer_dashboard_ppse_id
            from brs.project_details pd
                   inner join flow.user u on u.id = pd.closer_user_id
                   inner join flow.company_user_status cus on cus.user_id = u.id
                   inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                   left join flow.user_position up on up.id = pd.closer_user_position_id
                   left join flow.org o on o.id = up.org_id
                   cross join brs.funnel f
            where pd.company_id = 3
              and case when p_hide_inactive is true then
                         ust.id = 9 else true end
              and f.id = p_funnel_id
              and case
                    when v_whole_company is false then
                      closer_user_position_id = any (p_user_position_ids)
                    else true end
              and case
                    when v_all_sources is false then
                      pd.source = any (p_lead_source_ids)
                    else true end
              and case
                    when v_filter_appointment_types is true then
                      pd.prioritized_closer_appointment_by_round_robin =
                      v_is_round_robin
                    else true end
              and case
                    when f.id = 14 then
                      ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain')::date between p_start_date and p_end_date
                    when f.id = 17 then
                      ((prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                       'US/Mountain')::date between p_start_date and p_end_date and
                      not prioritized_closer_dashboard_outcome_id = any (f.closer_appt_outcome_int_values)
                    when f.id = 23 then
                      ((prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                       'US/Mountain')::date between p_start_date and p_end_date and
                       prioritized_closer_dashboard_outcome_id is null and
                      case
                        when p_is_checked_in_column is true then
                          pd.prioritized_closer_dashboard_checkin is not null
                        else true end
                    when f.id in (15, 16, 25, 18, 19, 20, 22, 24, 11) then
                      ((prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                       'US/Mountain')::date between p_start_date and p_end_date and
                      prioritized_closer_dashboard_outcome_id = any (f.closer_appt_outcome_int_values)
                        and case
                              when p_is_checked_in_column is true and f.id in (18, 19, 20, 22, 24, 11) then
                                pd.prioritized_closer_dashboard_checkin is not null
                              else true end
              end
            order by owner_name) as funnel_rows;
  END IF;
END
$function$

