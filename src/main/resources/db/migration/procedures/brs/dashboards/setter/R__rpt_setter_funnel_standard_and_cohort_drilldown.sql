drop function if exists brs.rpt_setter_funnel_standard_drilldown(date, date, bigint, bigint[], bigint[]);
drop function if exists brs.rpt_setter_funnel_standard_and_cohort_drilldown(p_start_date date,
                                                                               p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_user_position_ids bigint[],
                                                                               p_org_ids bigint[],
                                                                               p_is_cohort boolean);
CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard_and_cohort_drilldown(p_start_date date,
                                                                               p_end_date date,
                                                                               p_funnel_id bigint,
                                                                               p_user_position_ids bigint[],
                                                                               p_org_ids bigint[],
                                                                               p_is_cohort boolean default false)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
BEGIN

  --If p_user_position_ids has a -1 that means get the funnel for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;
  --

  --3 = appt created - now 27
  --2 = appts pitched - now 29
  --1 = appts occurred - now 28
  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (select pd.setter_name,
--                              concat(su.first_name, ' ', su.last_name) as setter_name,
                            pd.contact_name                                            as customer_name,
                            pd.project_id,
                            coalesce(pd.prioritized_closer_appointment_outcome_date,
                                     pd.closer_appointment_start)                      as appointment_date,
                            pd.closer_name                                             as owner_name,
                            pd.verified_setter_lead,
                            pd.verified_usage,
                            (select name
                             from flow.list_of_value lov
                             where lov.id = pd.prioritized_closer_appointment_outcome) as appointment_outcome,
                            pd.project_created_date                                    as date_created,
                            pd.project_state_abbreviation                              as state,
                            o.org_name                                                 as office,
                            pd.first_time_appointment_created                                       as checked_in_time,
                            pd.installation_agreement_signed_date,
                            pd.final_design_complete_date,
                            pd.cancelled_date
                     from brs.project_details pd
                            inner join flow.user_position up
                                       on up.id = pd.setter_user_position_id
                       --the list of reps is filtered to only show users in these statuses so we have to filter the funnel data the same way
                            inner join flow.company_user_status cus
                                       on cus.user_id = up.user_id and cus.user_status_type_id in (9, 11, 14)
                            inner join flow.org o on o.id = up.org_id
                     where pd.company_id = 3
                       and pd.source in (525, 526)
                       and pd.archived is false
                       and case
                             when v_whole_company is false then
                               (up.id = any (p_user_position_ids)
                                 -- if this part is enabled it should probably be enabled for whole company as well or numbers dont match when select all reps vs click all reps
--                                     and (case
--                                            when up.end_date is not null then
--                                              pd.project_created_date between up.start_date and up.end_date
--                                            else pd.project_created_date >= up.start_date end)
                                 and (case
                                        when array_length(p_org_ids, 1) > 0
                                          then org_id = any (p_org_ids)
                                        else 1 = 1 end)
                                 )
                             else true end
                       and case
                             when p_funnel_id = 27 then
                               ((pd.first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                 between p_start_date and p_end_date)
                             when p_funnel_id = 28 then
                               case
                                 when p_is_cohort is true then
                                   prioritized_closer_appointment_outcome = 3 and
                                   (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 else
                                   prioritized_closer_appointment_outcome = 3 and
                                   (prioritized_closer_appointment_outcome_date at time zone
                                    'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 end
                             when p_funnel_id = 29 then
                               case
                                 when p_is_cohort is true then
                                   first_appointment_pitched is not null and
                                   (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 else
                                   least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                         (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                     between p_start_date and p_end_date
                                 end
                             when p_funnel_id = 31 then
                               case
                                 when p_is_cohort is true then
                                   installation_agreement_signed_date is not null and
                                   (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 else
                                   (installation_agreement_signed_date at time zone
                                    'UTC' at time zone
                                    'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 end
                             when p_funnel_id = 32 then
                               case
                                 when p_is_cohort is true then
                                   final_design_complete_date is not null and
                                   (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 else
                                   (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 end
                             when p_funnel_id = 33 then
                               case
                                 when p_is_cohort is true then
                                   first_appointment is not null and
                                   (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4))
                                  and
                                   (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 else
                                   (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                   (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                     between p_start_date and p_end_date
                                 end
                       end
                     order by setter_name, contact_name
--                       order by setter_name, coalesce(pd.prioritized_closer_appointment_outcome_date,pd.closer_appointment_start)
                    ) as funnel_rows;


END
$function$
