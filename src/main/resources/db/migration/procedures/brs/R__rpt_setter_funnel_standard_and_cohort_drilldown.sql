-- drop function if exists brs.rpt_setter_funnel_standard_drilldown(date, date, integer, integer[], integer[]);
CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard_and_cohort_drilldown(p_start_date date,
                                                                          p_end_date date,
                                                                          p_funnel_id integer,
                                                                          p_user_position_ids integer[],
                                                                          p_org_ids integer[])
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company                 boolean;
  v_outcome_int_values            int[];
BEGIN

  --If p_user_position_ids has a -1 that means get the funnel for the whole company
  select -1 = any (p_user_position_ids) into v_whole_company;
--
  select closer_appt_outcome_int_values
  into v_outcome_int_values
  from brs.funnel
  where id = p_funnel_id;

  --3 = appt created - now 27
  --2 = appts pitched - now 29
  --1 = appts occurred - now 28
  RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
               from (
                      select
                             pd.setter_name,
--                              concat(su.first_name, ' ', su.last_name) as setter_name,
                             pd.contact_name                                            as customer_name,
                             pd.project_id,
                             coalesce(pd.prioritized_closer_appointment_outcome_date,pd.closer_appointment_start)             as appointment_date,
                             pd.closer_name                                             as owner_name,
                             pd.verified_setter_lead,
                             pd.verified_usage,
                             (select name
                              from flow.list_of_value lov
                              where lov.id = pd.prioritized_closer_appointment_outcome) as appointment_outcome,
                             pd.project_created_date                                    as date_created,
                             pd.project_state_abbreviation                              as state,
                             o.org_name                                                 as office
                      from brs.project_details pd
                             inner join flow.user_position up on up.id = pd.setter_user_position_id
                             inner join flow.org o on o.id = up.org_id
                            --the list of reps is filtered to only show users in these statuses so we have to filter the funnel data the same way
                             inner join flow.company_user_status cus on cus.user_id = up.user_id and cus.user_status_type_id  in (9, 11, 14)
                      where pd.company_id = 3
                        and pd.archived is false
                        and case
                              when v_whole_company is false then
                                (up.id = any (p_user_position_ids)
--                                   and (case
--                                          when up.end_date is not null then
--                                            pd.project_created_date between up.start_date and up.end_date
--                                          else pd.project_created_date >= up.start_date end)
                                  and (case
                                         when array_length(p_org_ids, 1) > 0 then org_id = any (p_org_ids)
                                         else 1 = 1 end))
                              else true end

                        and pd.source = 525 --setter gen only
                        --pretty sure all of them have this check
                        and (pd.prioritized_closer_appointment_outcome_date is not null or (pd.prioritized_closer_appointment_outcome_date is null and pd.closer_appointment_start is not null))
                        and case
                              when p_funnel_id = 27 then -- old = 3
                                ((pd.project_created_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                              when p_funnel_id = 28 then --old = 1
                                  (((coalesce(pd.prioritized_closer_appointment_outcome_date, pd.closer_appointment_start)) at time zone 'UTC') at time zone
                                   'US/Mountain') :: date between p_start_date and p_end_date
                                  and (pd.prioritized_closer_appointment_outcome is null or pd.prioritized_closer_appointment_outcome != 4)
                              when p_funnel_id = 29 then -- old = 2
                                (((coalesce(pd.prioritized_closer_appointment_outcome_date, pd.closer_appointment_start)) at time zone 'UTC') at time zone
                                 'US/Mountain') :: date between p_start_date and p_end_date
                                  and pd.prioritized_closer_appointment_outcome = any (v_outcome_int_values)
                      end
                      order by setter_name, contact_name
--                       order by setter_name, coalesce(pd.prioritized_closer_appointment_outcome_date,pd.closer_appointment_start)
                    ) as funnel_rows;
END
$function$
