drop function if exists brs.rpt_closer_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                       p_user_position_ids bigint[], p_org_ids bigint[],
                                                       p_run_by_id bigint);
drop function if exists brs.rpt_closer_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                       p_trend_start_date date, p_trend_end_date date,
                                                       p_user_position_ids bigint[],
                                                       p_appointment_type_ids bigint[],
                                                       p_lead_source_ids bigint[],
                                                        p_hide_inactive boolean);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                           p_trend_start_date date, p_trend_end_date date,
                                                           p_user_position_ids bigint[],
                                                           p_appointment_type_ids bigint[],
                                                           p_lead_source_ids bigint[],
                                                           p_hide_inactive boolean default false)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company            boolean;
  v_all_sources              boolean;
  v_filter_appointment_types boolean;
  v_is_round_robin           boolean;
BEGIN
  --If p_user_position_ids has a -1 that means get data for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;
  select -1 = any (p_lead_source_ids) into v_all_sources;
  v_filter_appointment_types = false;
  if p_appointment_type_ids is not null and array_length(p_appointment_type_ids, 1) = 1 then
    v_filter_appointment_types = true;
    v_is_round_robin = false;
    if 1 = any (p_appointment_type_ids) then
      v_is_round_robin = true;
    end if;
  end if;
--   raise notice 'v_whole_company %',v_whole_company;
--   raise notice 'v_all_sources %',v_all_sources;
--   raise notice 'v_filter_appointment_types %',v_filter_appointment_types;
--   raise notice 'v_is_round_robin %',v_is_round_robin;
  if p_trend_start_date is null then
    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                 from (
                        --this subset has to have everything in it that you might need later (prevents from having to query project_details table more than once)
                        with project_data as (select credit_decision_date,
                                                     credit_check_name,
                                                     installation_agreement_signed_date,
                                                     site_survey_verified_date,
                                                     ((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                      'US/Mountain')::date as final_design_sent_to_homeowner_date,
                                                     final_design_signed_date,
                                                     final_design_complete_date,
                                                     substantial_completion_date,
                                                     credit_check,
                                                     pd.project_id
                                              from brs.project_details pd
                                              inner join flow.user u on u.id = pd.closer_user_id
                                              inner join flow.company_user_status cus on cus.user_id = u.id
                                              inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                              where pd.company_id = 3
                                                and case when p_hide_inactive is true then
                                                    ust.id = 9 else true end
                                                and case
                                                      when v_whole_company is false then
                                                        pd.closer_user_position_id = any (p_user_position_ids)
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
                                                and (
                                                (credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (installation_agreement_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (site_survey_verified_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                  'US/Mountain')::date between p_custom_start_date and p_custom_end_date) OR
                                                (final_design_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (final_design_complete_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (substantial_completion_date :: DATE between p_custom_start_date and p_custom_end_date)
                                                )),
                             project_outcome_data as (select pd.prioritized_closer_dashboard_outcome_id,
                                                             pd.prioritized_closer_dashboard_outcome,
                                                             pd.prioritized_closer_dashboard_start_time,
                                                             pd.prioritized_closer_dashboard_checkin,
                                                             pd.prioritized_closer_dashboard_ppse_id,
                                                             pd.project_id
                                                      from brs.project_details pd
                                                             inner join flow.user u on u.id = pd.closer_user_id
                                                             inner join flow.company_user_status cus on cus.user_id = u.id
                                                             inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                      where pd.company_id = 3
                                                        and case when p_hide_inactive is true then
                                                                   ust.id = 9 else true end

                                                        and case
                                                              when v_whole_company is false then
                                                                pd.closer_user_position_id = any (p_user_position_ids)
                                                              else true end
                                                        and case
                                                              when v_all_sources is false then
                                                                pd.source = any (p_lead_source_ids)
                                                              else true end
                                                        and case
                                                              when v_filter_appointment_types is true then
                                                                pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                              else true end
                                                        and (
                                                        (prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                                                        'US/Mountain')::date between p_custom_start_date and p_custom_end_date),
                             total_appointmnents as (select pd.project_id, pd.first_appointment
                                                     from brs.project_details pd
                                                            inner join flow.user u on u.id = pd.closer_user_id
                                                            inner join flow.company_user_status cus on cus.user_id = u.id
                                                            inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                     where pd.company_id = 3
                                                       and case when p_hide_inactive is true then
                                                                  ust.id = 9 else true end

                                                       and case
                                                             when v_whole_company is false then
                                                               pd.closer_user_position_id = any (p_user_position_ids)
                                                             else true end
                                                       and case
                                                             when v_all_sources is false then
                                                               pd.source = any (p_lead_source_ids)
                                                             else true end
                                                       and case
                                                             when v_filter_appointment_types is true then
                                                               pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                             else true end
                                                       and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date)
                        select f.id,
                               f.name,
                               f.display_order,
                               f.funnel_type_id,
                               (select count(1)
                                from project_data
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (9) then (coalesce(
                                      credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (3) then (coalesce(
                                      credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                      and credit_check_name = 'Pass'
                                    when f.id in (4) then (coalesce(
                                      installation_agreement_signed_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (5) then (coalesce(
                                      site_survey_verified_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (6) then (coalesce(
                                      final_design_sent_to_homeowner_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (7) then (coalesce(
                                      final_design_signed_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (21) then (coalesce(
                                      final_design_complete_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    when f.id in (8) then (coalesce(
                                      substantial_completion_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
                                    else true end) as custom_date_range_count,
                               null::bigint        as custom_date_range_trend_count,
                               null::bigint        as checked_in_custom_date_range_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 3
                        group by f.id, f.name, f.display_order
                        union
                        select f.id,
                               f.name,
                               f.display_order,
                               f.funnel_type_id,
                               (select count(1)
                                from project_outcome_data pod
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (15) then
                                      pod.prioritized_closer_dashboard_outcome_id = any (
                                        (f.closer_appt_outcome_int_values))
                                    when f.id in (19) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (18) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (16) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (22) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (24) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (11) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (25) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (17) then not pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (20) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values))
                                    when f.id in (23) then pod.prioritized_closer_dashboard_outcome_id is null
                                    else true end) as custom_date_range_count,
                               null::bigint        as custom_date_range_trend_count,
                               (select count(1)
                                from project_outcome_data pod
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (19) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (18) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (22) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (24) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (11) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (25) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (20) then pod.prioritized_closer_dashboard_outcome_id = any (
                                      (f.closer_appt_outcome_int_values)) and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    when f.id in (23) then pod.prioritized_closer_dashboard_outcome_id is null and
                                                           pod.prioritized_closer_dashboard_checkin is not null
                                    else true end) as checked_in_custom_date_range_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 1
                          and f.id != 14
                        group by f.id, f.name, f.display_order
                        union
                        select f.id,
                               f.name,
                               f.display_order,
                               f.funnel_type_id,
                               (select count(1)
                                from total_appointmnents) as custom_date_range_count,
                               null::bigint               as custom_date_range_trend_count,
                               null::bigint               as checked_in_custom_date_range_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 1
                          and f.id = 14
                        group by f.id, f.name, f.display_order
                        order by 3) as funnel_rows;
  else
    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                 from (
                        --this subset has to have everything in it that you might need later (prevents from having to query project_details table more than once)
                        with project_data as (select credit_decision_date,
                                                     credit_check_name,
                                                     installation_agreement_signed_date,
                                                     site_survey_verified_date,
                                                     ((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                      'US/Mountain')::date as final_design_sent_to_homeowner_date,
                                                     final_design_signed_date,
                                                     final_design_complete_date,
                                                     substantial_completion_date,
                                                     credit_check,
                                                     pd.project_id
                                              from brs.project_details pd
                                                     inner join flow.user u on u.id = pd.closer_user_id
                                                     inner join flow.company_user_status cus on cus.user_id = u.id
                                                     inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                              where pd.company_id = 3
                                                and case when p_hide_inactive is true then
                                                           ust.id = 9 else true end

                                                and case
                                                      when v_whole_company is false then
                                                        pd.closer_user_position_id = any (p_user_position_ids)
                                                      else true end
                                                and case
                                                      when v_all_sources is false then
                                                        pd.source = any (p_lead_source_ids)
                                                      else true end
                                                and case
                                                      when v_filter_appointment_types is true then
                                                        pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                      else true end
                                                and (
                                                (credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (installation_agreement_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (site_survey_verified_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                  'US/Mountain')::date between p_custom_start_date and p_custom_end_date) OR
                                                (final_design_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (final_design_complete_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                                                (substantial_completion_date :: DATE between p_custom_start_date and p_custom_end_date)
                                                )),
                             project_trend_data as (select credit_decision_date,
                                                           credit_check_name,
                                                           installation_agreement_signed_date,
                                                           site_survey_verified_date,
                                                           ((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                            'US/Mountain')::date as final_design_sent_to_homeowner_date,
                                                           final_design_signed_date,
                                                           final_design_complete_date,
                                                           substantial_completion_date,
                                                           credit_check,
                                                           pd.project_id
                                                    from brs.project_details pd
                                                           inner join flow.user u on u.id = pd.closer_user_id
                                                           inner join flow.company_user_status cus on cus.user_id = u.id
                                                           inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                    where pd.company_id = 3
                                                      and case when p_hide_inactive is true then
                                                                 ust.id = 9 else true end

                                                      and case
                                                            when v_whole_company is false then
                                                              pd.closer_user_position_id = any (p_user_position_ids)
                                                            else true end
                                                      and case
                                                            when v_all_sources is false then
                                                              pd.source = any (p_lead_source_ids)
                                                            else true end
                                                      and case
                                                            when v_filter_appointment_types is true then
                                                              pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                            else true end
                                                      and (
                                                      (credit_decision_date :: DATE between p_trend_start_date and p_trend_end_date) OR
                                                      (installation_agreement_signed_date :: DATE between p_trend_start_date and p_trend_end_date) OR
                                                      (site_survey_verified_date :: DATE between p_trend_start_date and p_trend_end_date) OR
                                                      (((final_design_sent_to_homeowner_date at time zone 'UTC') at time zone
                                                        'US/Mountain')::date between p_trend_start_date and p_trend_end_date) OR
                                                      (final_design_signed_date :: DATE between p_trend_start_date and p_trend_end_date) OR
                                                      (final_design_complete_date :: DATE between p_trend_start_date and p_trend_end_date) OR
                                                      (substantial_completion_date :: DATE between p_trend_start_date and p_trend_end_date)
                                                      )),
                             project_outcome_data as (select pd.prioritized_closer_dashboard_outcome_id,
                                                             pd.prioritized_closer_dashboard_outcome,
                                                             pd.prioritized_closer_dashboard_start_time,
                                                             pd.prioritized_closer_dashboard_checkin,
                                                             pd.prioritized_closer_dashboard_ppse_id,
                                                             pd.project_id
                                                      from brs.project_details pd
                                                             inner join flow.user u on u.id = pd.closer_user_id
                                                             inner join flow.company_user_status cus on cus.user_id = u.id
                                                             inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                      where pd.company_id = 3
                                                        and case when p_hide_inactive is true then
                                                                   ust.id = 9 else true end
                                                        and case
                                                              when v_whole_company is false then
                                                                pd.closer_user_position_id = any (p_user_position_ids)
                                                              else true end
                                                        and case
                                                              when v_all_sources is false then
                                                                pd.source = any (p_lead_source_ids)
                                                              else true end
                                                        and case
                                                              when v_filter_appointment_types is true then
                                                                pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                              else true end
                                                        and (
                                                        (prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                                                        'US/Mountain')::date between p_custom_start_date and p_custom_end_date),
                             project_outcome_trend_data as (select pd.prioritized_closer_dashboard_outcome_id,
                                                                   pd.prioritized_closer_dashboard_outcome,
                                                                   pd.prioritized_closer_dashboard_start_time,
                                                                   pd.prioritized_closer_dashboard_checkin,
                                                                   pd.prioritized_closer_dashboard_ppse_id,
                                                                   pd.project_id
                                                            from brs.project_details pd
                                                                   inner join flow.user u on u.id = pd.closer_user_id
                                                                   inner join flow.company_user_status cus on cus.user_id = u.id
                                                                   inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                            where pd.company_id = 3
                                                              and case when p_hide_inactive is true then
                                                                         ust.id = 9 else true end
                                                              and case
                                                                    when v_whole_company is false then
                                                                      pd.closer_user_position_id = any (p_user_position_ids)
                                                                    else true end
                                                              and case
                                                                    when v_all_sources is false then
                                                                      pd.source = any (p_lead_source_ids)
                                                                    else true end
                                                              and case
                                                                    when v_filter_appointment_types is true then
                                                                      pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                                    else true end
                                                              and (
                                                              (prioritized_closer_dashboard_start_time at time zone 'UTC') at time zone
                                                              'US/Mountain')::date between p_trend_start_date and p_trend_end_date),
                             total_appointmnents as (select pd.project_id, pd.first_appointment
                                                     from brs.project_details pd
                                                            inner join flow.user u on u.id = pd.closer_user_id
                                                            inner join flow.company_user_status cus on cus.user_id = u.id
                                                            inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                     where pd.company_id = 3
                                                       and case when p_hide_inactive is true then
                                                                  ust.id = 9 else true end
                                                       and case
                                                             when v_whole_company is false then
                                                               pd.closer_user_position_id = any (p_user_position_ids)
                                                             else true end
                                                       and case
                                                             when v_all_sources is false then
                                                               pd.source = any (p_lead_source_ids)
                                                             else true end
                                                       and case
                                                             when v_filter_appointment_types is true then
                                                               pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                             else true end
                                                       and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date),
                             total_trend_appointmnents as (select pd.project_id, pd.first_appointment
                                                           from brs.project_details pd
                                                                  inner join flow.user u on u.id = pd.closer_user_id
                                                                  inner join flow.company_user_status cus on cus.user_id = u.id
                                                                  inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                           where pd.company_id = 3
                                                             and case when p_hide_inactive is true then
                                                                        ust.id = 9 else true end
                                                             and case
                                                                   when v_whole_company is false then
                                                                     pd.closer_user_position_id = any (p_user_position_ids)
                                                                   else true end
                                                             and case
                                                                   when v_all_sources is false then
                                                                     pd.source = any (p_lead_source_ids)
                                                                   else true end
                                                             and case
                                                                   when v_filter_appointment_types is true then
                                                                     pd.prioritized_closer_appointment_by_round_robin = v_is_round_robin
                                                                   else true end
                                                             and ((pd.first_appointment at time zone 'UTC') at time zone 'US/Mountain')::date between p_trend_start_date and p_trend_end_date)
                        select foo.id,
                               foo.name,
                               foo.display_order,
                               foo.funnel_type_id,
                               foo.custom_date_range_count,
                               foo.custom_date_range_trend_count,
                               foo.checked_in_custom_date_range_count,
                               case
                                 when custom_date_range_trend_count is not null or custom_date_range_trend_count > 0
                                   then
                                   round((checked_in_custom_date_range_count::numeric -
                                          custom_date_range_trend_count::numeric) /
                                         greatest(custom_date_range_trend_count::numeric, 1) *
                                         100)::numeric end as trend_count
                        from (select f.id,
                                     f.name,
                                     f.display_order,
                                     f.funnel_type_id,
                                     (select count(1)
                                      from project_data pd2
                                      where
                                        --date checks (same as `date between start and end AND date is not null) ..i think
                                        case
                                          when f.id in (9) then (coalesce(
                                            pd2.credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (3) then (coalesce(
                                            pd2.credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                            and pd2.credit_check_name = 'Pass'
                                          when f.id in (4) then (coalesce(
                                            pd2.installation_agreement_signed_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (5) then (coalesce(
                                            pd2.site_survey_verified_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (6) then (coalesce(
                                            pd2.final_design_sent_to_homeowner_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (7) then (coalesce(
                                            pd2.final_design_signed_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (21) then (coalesce(
                                            pd2.final_design_complete_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          when f.id in (8) then (coalesce(
                                            pd2.substantial_completion_date :: DATE between p_custom_start_date and p_custom_end_date,
                                            false))
                                          else true end) as custom_date_range_count,
                                     (select count(1)
                                      from project_trend_data ptd
                                      where
                                        --date checks (same as `date between start and end AND date is not null) ..i think
                                        case
                                          when f.id in (9) then (coalesce(
                                            ptd.credit_decision_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (3) then (coalesce(
                                            ptd.credit_decision_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                            and ptd.credit_check_name = 'Pass'
                                          when f.id in (4) then (coalesce(
                                            ptd.installation_agreement_signed_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (5) then (coalesce(
                                            ptd.site_survey_verified_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (6) then (coalesce(
                                            ptd.final_design_sent_to_homeowner_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (7) then (coalesce(
                                            ptd.final_design_signed_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (21) then (coalesce(
                                            ptd.final_design_complete_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          when f.id in (8) then (coalesce(
                                            ptd.substantial_completion_date :: DATE between p_trend_start_date and p_trend_end_date,
                                            false))
                                          else true end) as custom_date_range_trend_count,
                                     null::bigint        as checked_in_custom_date_range_count
                              from brs.funnel f
                              where f.archived is false
                                and f.funnel_type_id = 3
                              group by f.id, f.name, f.display_order) as foo
                        union
                        select foo1.id,
                               foo1.name,
                               foo1.display_order,
                               foo1.funnel_type_id,
                               foo1.custom_date_range_count,
                               foo1.custom_date_range_trend_count,
                               foo1.checked_in_custom_date_range_count,
                               case
                                 when custom_date_range_trend_count is not null or custom_date_range_trend_count > 0
                                   then
                                   round((custom_date_range_count::numeric - custom_date_range_trend_count::numeric) /
                                         greatest(custom_date_range_trend_count::numeric, 1) *
                                         100)::numeric end as trend_count
                        from (select f.id,
                                     f.name,
                                     f.display_order,
                                     f.funnel_type_id,
                                     (select count(1)
                                      from project_outcome_data pod
                                      where
                                        --date checks (same as `date between start and end AND date is not null) ..i think
                                        case
                                          when f.id in (15) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (19) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (18) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (16) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (22) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (24) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (11) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (25) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (17) then not pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (20) then pod.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (23) then pod.prioritized_closer_dashboard_outcome_id is null
                                          else true end) as custom_date_range_count,
                                     (select count(1)
                                      from project_outcome_trend_data pod1
                                      where
                                        --date checks (same as `date between start and end AND date is not null) ..i think
                                        case
                                          when f.id in (15) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (19) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (18) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (16) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (22) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (24) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (11) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (25) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (17) then not pod1.prioritized_closer_dashboard_outcome_id = any
                                                                     (
                                                                       (f.closer_appt_outcome_int_values))
                                          when f.id in (20) then pod1.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values))
                                          when f.id in (23) then pod1.prioritized_closer_dashboard_outcome_id is null
                                          else true end) as custom_date_range_trend_count,
                                     (select count(1)
                                      from project_outcome_data pod2
                                      where
                                        --date checks (same as `date between start and end AND date is not null) ..i think
                                        case
                                          when f.id in (19) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (18) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (22) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (24) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (11) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (25) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (20) then pod2.prioritized_closer_dashboard_outcome_id = any (
                                            (f.closer_appt_outcome_int_values)) and
                                                                 pod2.prioritized_closer_dashboard_checkin is not null
                                          when f.id in (23) then
                                            pod2.prioritized_closer_dashboard_outcome_id is null and
                                            pod2.prioritized_closer_dashboard_checkin is not null
                                          else true end) as checked_in_custom_date_range_count
                              from brs.funnel f
                              where f.archived is false
                                and f.funnel_type_id = 1
                                and f.id != 14
                              group by f.id, f.name, f.display_order) as foo1
                        union
                        select f.id,
                               f.name,
                               f.display_order,
                               f.funnel_type_id,
                               (select count(1)
                                from total_appointmnents)       as custom_date_range_count,
                               (select count(1)
                                from total_trend_appointmnents) as custom_date_range_trend_count,
                               null::bigint                     as checked_in_custom_date_range_count,
                               null::bigint                     as trend_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 1
                          and f.id = 14
                        group by f.id, f.name, f.display_order
                        order by 3) as funnel_rows;
  end if;

END
$function$
