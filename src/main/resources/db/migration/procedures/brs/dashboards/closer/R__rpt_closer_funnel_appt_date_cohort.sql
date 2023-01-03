drop function if exists brs.rpt_closer_funnel_appt_date_cohort(p_custom_start_date date,
                                                               p_custom_end_date date,
                                                               p_user_position_ids bigint[], p_org_ids bigint[], p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.rpt_closer_funnel_appt_date_cohort(p_custom_start_date date,
                                                                  p_custom_end_date date,
                                                                  p_user_position_ids bigint[], p_org_ids bigint[], p_run_by_id bigint)
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
                                                                            p_user_position_ids, p_org_ids, p_run_by_id) rpt
                      union all
                      (
                        --this subset has to have everything in it that you might need later (prevents from having to query project_details table more than once)
                        with project_data as (
                          select pd.project_id,
                                 array_agg(ppse.start_time::date) as start_time_dates, --the counts currently only check these as dates
                                 pd.credit_decision_date,
                                 pd.installation_agreement_signed_date,
                                 pd.site_survey_verified_date,
                                 pd.final_design_sent_to_homeowner_date,
                                 pd.final_design_signed_date,
                                 pd.final_design_complete_date,
                                 pd.substantial_completion_date,
                                 pd.credit_check
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
                          where pd.company_id = 3
                            and case
                                  when v_whole_company is false then
                                    (up.id = any (p_user_position_ids)
                                      and case
                                            when array_length(p_org_ids, 1) > 0 then up.org_id = any (p_org_ids)
                                            else 1 = 1 end)
                                  else true end
                            and pd.archived is false
                            and ppsecfv.int_value in (select unnest(string_to_array(value, ',')::bigint[])
                                                      from flow.company_configuration_value
                                                      where code = 'OUTCOME_PITCHED')
--                             and (ppse.start_time :: DATE between p_custom_start_date and p_custom_end_date)
                            and ((ppse.start_time :: DATE between p_custom_start_date and p_custom_end_date)
                            OR
                                 (ppse.start_time::DATE between ((date_trunc('week', now() at time zone 'US/Mountain')) :: DATE) and (now() at time zone 'US/Mountain') :: DATE))
                            --we check these cuz it limits the results...one of these has to be not null to return a value to the counts
                            and (
                              pd.credit_decision_date is not null or
                              pd.installation_agreement_signed_date is not null or
                              pd.site_survey_verified_date is not null or
                              pd.final_design_sent_to_homeowner_date is not null or
                              pd.final_design_signed_date is not null or
                              pd.final_design_complete_date is not null or
                              pd.substantial_completion_date is not null
                            )
                          group by pd.project_id,
                                   pd.credit_decision_date,
                                   pd.installation_agreement_signed_date,
                                   pd.site_survey_verified_date,
                                   pd.final_design_sent_to_homeowner_date,
                                   pd.final_design_signed_date,
                                   pd.final_design_complete_date,
                                   pd.substantial_completion_date,
                                   pd.credit_check
                        )
                        select f.id,
                               f.name,
                               f.display_order,
                               (select count(1)
                                from project_data
                                where (now() at time zone 'US/Mountain') :: DATE = any (start_time_dates)
                                  and case
                                        when f.id in (9, 3) then credit_decision_date is not null
                                        when f.id in (4) then installation_agreement_signed_date is not null
                                        when f.id in (5) then site_survey_verified_date is not null
                                        when f.id in (6) then final_design_sent_to_homeowner_date is not null
                                        when f.id in (7) then final_design_signed_date is not null
                                        when f.id in (21) then final_design_complete_date is not null
                                        when f.id in (8) then substantial_completion_date is not null
                                        else true end
                                  --credit check bigint value
                                  and case when f.id = 3 then credit_check = 82 else true end
                               )         as today_count,
                               null::bigint as checked_in_today_count,
                               (select count(1)
                                from project_data
                                where
                                  --i think this is a date checker for checking if any time is between two dates
                                    daterange((date_trunc('week', now() at time zone 'US/Mountain'))::date,
                                              (now() at time zone 'US/Mountain') :: DATE) @> any (start_time_dates)
                                  and case
                                        when f.id in (9, 3) then credit_decision_date is not null
                                        when f.id in (4) then installation_agreement_signed_date is not null
                                        when f.id in (5) then site_survey_verified_date is not null
                                        when f.id in (6) then final_design_sent_to_homeowner_date is not null
                                        when f.id in (7) then final_design_signed_date is not null
                                        when f.id in (21) then final_design_complete_date is not null
                                        when f.id in (8) then substantial_completion_date is not null
                                        else true end
                                  --credit check bigint value
                                  and case when f.id = 3 then credit_check = 82 else true end
                               )         as week_to_date_count,
--
                               null::bigint as checked_in_week_to_date_count,
                               (select count(1)
                                from project_data
                                where
                                  --i think this is a date checker for checking if any time is between two dates
--                                     daterange( p_custom_start_date, p_custom_end_date) @> any(start_time_dates)
                                    daterange(p_custom_start_date::date, p_custom_end_date::date) @> any
                                    (start_time_dates)
                                  and case
                                        when f.id in (9, 3) then credit_decision_date is not null
                                        when f.id in (4) then installation_agreement_signed_date is not null
                                        when f.id in (5) then site_survey_verified_date is not null
                                        when f.id in (6) then final_design_sent_to_homeowner_date is not null
                                        when f.id in (7) then final_design_signed_date is not null
                                        when f.id in (21) then final_design_complete_date is not null
                                        when f.id in (8) then substantial_completion_date is not null
                                        else true end
                                  --credit check bigint value
                                  and case when f.id = 3 then credit_check = 82 else true end
                               )         as custom_date_range_count,
                               null::bigint as checked_in_custom_date_range_count
                        from brs.funnel f
                        where f.archived is false
                          and f.funnel_type_id = 3
                        group by f.id, f.name, f.display_order
                        order by display_order
                      )
                    )
                      as funnel_rows;

    insert into flow.company_function_log(function_name, parameters, run_by_id)
    values ('Closer Funnel Appointment Date Cohort', 'p_custom_start_date: ' || p_custom_start_date ||
                                                     ' p_custom_end_date: ' || p_custom_end_date ||
                                                     ' p_user_position_ids: ' || p_user_position_ids::text ||
                                                     ' p_org_ids: ' || p_org_ids::text ||
                                                     ' p_run_by_id: ' || p_run_by_id,
            p_run_by_id);

END
$function$
