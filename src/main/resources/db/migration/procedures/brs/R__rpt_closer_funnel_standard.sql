CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                          p_user_position_ids integer[], p_org_ids integer[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
BEGIN
  --If p_user_position_ids has a -1 that means get data for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;

  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select rpt.id,
                             rpt.name,
                             rpt.display_order,
                             rpt.today_count,
                             rpt.checked_in_today_count,
                             rpt.week_to_date_count,
                             rpt.checked_in_week_to_date_count,
                             rpt.custom_date_range_count,
                             rpt.checked_in_custom_date_range_count
                      from brs.rpt_closer_funnel_standard_event_based(p_custom_start_date, p_custom_end_date,
                                                                            p_user_position_ids, p_org_ids) rpt
                      union all
                      (
                        --this subset has to have everything in it that you might need later (prevents from having to query project_details table more than once)
                        with project_data as (
                          select credit_decision_date,
                                 installation_agreement_signed_date,
                                 site_survey_verified_date,
                                 final_design_sent_to_homeowner_date,
                                 final_design_signed_date,
                                 final_design_complete_date,
                                 substantial_completion_date,
                                 credit_check
                          from brs.project_details pd
                                 --we dont have to do this join for the where clause but other numbers do an inner join so we do it here to limit the results
                                 inner join flow.user_position up on up.id = pd.closer_user_position_id
                                 inner join flow.org o on o.id = up.org_id
                          where pd.company_id = 3
                            and case
                                  when v_whole_company is false then
                                    (up.id = any (p_user_position_ids)
                                      and case
                                            when array_length(p_org_ids, 1) > 0 then up.org_id = any (p_org_ids)
                                            else 1 = 1 end)
                                  else true end
                            and (
                              (credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (credit_decision_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (installation_agreement_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (installation_agreement_signed_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (site_survey_verified_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (site_survey_verified_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (final_design_sent_to_homeowner_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (final_design_sent_to_homeowner_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (final_design_signed_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (final_design_signed_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (final_design_complete_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (final_design_complete_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE) OR
                              (substantial_completion_date :: DATE between p_custom_start_date and p_custom_end_date) OR
                              (substantial_completion_date::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE)
                            )
                        )
                        select f.id,
                               f.name,
                               f.display_order,
                               (select count(1)
                                from project_data
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (9, 3)
                                      then credit_decision_date :: DATE = (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (4) then installation_agreement_signed_date :: DATE =
                                                          (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (5) then site_survey_verified_date :: DATE =
                                                          (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (6) then final_design_sent_to_homeowner_date :: DATE =
                                                          (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (7) then final_design_signed_date :: DATE =
                                                          (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (21) then final_design_complete_date :: DATE =
                                                           (now() at time zone 'US/Mountain') :: DATE
                                    when f.id in (8) then substantial_completion_date :: DATE =
                                                          (now() at time zone 'US/Mountain') :: DATE
                                    else true end
                                  --credit check int value
                                  and case when f.id = 3 then credit_check = 82 else true end
                               )         as today_count,
                               null::int as checked_in_today_count,
                               (select count(1)
                                from project_data
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (9, 3) then (coalesce(
                                      credit_decision_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (4) then (coalesce(
                                      installation_agreement_signed_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (5) then (coalesce(
                                      site_survey_verified_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (6) then (coalesce(
                                      final_design_sent_to_homeowner_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (7) then (coalesce(
                                      final_design_signed_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (21) then (coalesce(
                                      final_design_complete_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    when f.id in (8) then (coalesce(
                                      substantial_completion_date :: DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE,
                                      false))
                                    else true end
                               )         as week_to_date_count,
                               null::int as checked_in_week_to_date_count,
                               (select count(1)
                                from project_data
                                where
                                  --date checks (same as `date between start and end AND date is not null) ..i think
                                  case
                                    when f.id in (9, 3) then (coalesce(
                                      credit_decision_date :: DATE between p_custom_start_date and p_custom_end_date,
                                      false))
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
                                    else true end
                               )         as custom_date_range_count,
                               null::int as checked_in_custom_date_range_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 3
                        group by f.id, f.name, f.display_order
                        order by display_order
                      )
                    )
                      as funnel_rows;

END
$function$
