-- drop function if exists brs.rpt_setter_funnel_standard(date, date, numeric, bigint[], bigint[]);
-- drop function if exists brs.rpt_setter_funnel_standard(date, date, numeric, bigint[], bigint[], boolean);
drop function if exists brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                       p_base_expectation numeric,
                                                       p_user_position_ids bigint[],
                                                       p_org_ids bigint[],
                                                       p_is_cohort boolean);
drop function if exists brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                       p_user_position_ids bigint[],
                                                       p_org_ids bigint[],
                                                       p_is_cohort boolean);
drop function if exists brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                       p_trend_start_date date, p_trend_end_date date,
                                                       p_user_position_ids bigint[],
                                                       p_org_ids bigint[],
                                                       p_hide_inactive boolean);
CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                           p_trend_start_date date, p_trend_end_date date,
                                                           p_user_position_ids bigint[],
                                                           p_org_ids bigint[],
                                                           p_hide_inactive boolean)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
BEGIN

  select -1 = any (p_user_position_ids) into v_whole_company;
  if p_trend_start_date is null then
    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                 from (with appointment_data as (select pd.project_id,
                                                        final_design_complete_date,
                                                        first_time_appointment_created,
                                                        prioritized_closer_appointment_outcome_date,
                                                        prioritized_closer_appointment_outcome,
                                                        installation_agreement_signed_date,
                                                        first_appointment_pitched,
                                                        first_appointment_missed,
                                                        first_appointment_id,
                                                        first_appointment
                                                 from brs.project_details pd
                                                        inner join flow.user_position up
                                                                   on up.id = pd.setter_user_position_id
                                                   --the list of reps is filtered to only show users in these statuses so we have to filter the funnel data the same way
                                                        inner join flow.company_user_status cus
                                                                   on cus.user_id = up.user_id
                                                        inner join flow.user_status_type ust
                                                                   on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                        inner join flow.org o on o.id = up.org_id
                                                 where pd.company_id = 3
                                                   and  pd.archived is false
                                                   and case
                                                         when p_hide_inactive is true then
                                                           ust.id in (9, 11, 14)
                                                         else true end
                                                   and pd.source in (525, 526)
                                                   and pd.archived is false
                                                   and case
                                                         when v_whole_company is false then
                                                           (up.id = any (p_user_position_ids)
--                                                              and (case
--                                                                     when array_length(p_org_ids, 1) > 0
--                                                                       then org_id = any (p_org_ids)
--                                                                     else 1 = 1 end)
                                                             )
                                                         else true end
                                                   and (
                                                   ((pd.first_time_appointment_created at time zone 'UTC' at time zone
                                                     'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or ((pd.prioritized_closer_appointment_outcome_date at time zone
                                                          'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or
                                                   ((pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or (pd.installation_agreement_signed_date::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or (pd.final_design_complete_date::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or
                                                   ((pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date))),
                            funnel_data as (select f.id,
                                                   count(1) filter (where
                                                     case
                                                       when f.id = 27 then
                                                         (pd.first_time_appointment_created at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 28 then
                                                         prioritized_closer_appointment_outcome = 3 and
                                                         (pd.prioritized_closer_appointment_outcome_date at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 33 then
                                                         (first_appointment_id is null or
                                                          (first_appointment_id is not null and first_appointment_id != 4)) and
                                                         (pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date

                                                       when f.id = 29 then
                                                         (pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 31 then
                                                         installation_agreement_signed_date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 32 then
                                                         final_design_complete_date between p_custom_start_date and p_custom_end_date
                                                       end
                                                     )          as count_count,
                                                   null::bigint as custom_date_range_trend_count
                                            from brs.funnel f
                                                   cross join appointment_data pd
                                            where f.archived is false
                                              and f.funnel_type_id = 4
                                              and f.unique_behavior is false
                                            group by 1),
                            all_funnel_data as (select *
                                                from funnel_data fd
                                                union
                                                select f2.id,
                                                       case
                                                         when
                                                             (select count_count::numeric from funnel_data f1 where f1.id = 27)::numeric <
                                                             1 then
                                                           0
                                                         else
                                                           round(
                                                               (select count_count::numeric from funnel_data f1 where f1.id = 29)::numeric /
                                                               (select count_count::numeric from funnel_data f1 where f1.id = 27)::numeric *
                                                               100) end,
                                                       null::bigint as custom_date_range_trend_count
                                                from brs.funnel f2
                                                where f2.id = 30)
                       select f.id,
                              f.name,
                              f.display_order,
                              f.funnel_type_id,
                              fd.count_count
                       from brs.funnel f
                              left join all_funnel_data fd on fd.id = f.id
                       where f.archived is false
                         and f.funnel_type_id = 4
                       order by f.display_order) as funnel_rows;

  else
    RETURN QUERY select array_to_json(array_agg(row_to_json(funnel_rows)))
                 from (with appointment_data as (select pd.project_id,
                                                        final_design_complete_date,
                                                        first_time_appointment_created,
                                                        prioritized_closer_appointment_outcome_date,
                                                        prioritized_closer_appointment_outcome,
                                                        installation_agreement_signed_date,
                                                        first_appointment_pitched,
                                                        first_appointment_missed,
                                                        first_appointment_id,
                                                        first_appointment
                                                 from brs.project_details pd
                                                        inner join flow.user_position up
                                                                   on up.id = pd.setter_user_position_id
                                                   --the list of reps is filtered to only show users in these statuses so we have to filter the funnel data the same way
                                                        inner join flow.company_user_status cus
                                                                   on cus.user_id = up.user_id
                                                        inner join flow.user_status_type ust
                                                                   on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                        inner join flow.org o on o.id = up.org_id
                                                 where pd.company_id = 3
                                                   and  pd.archived is false
                                                   and case
                                                         when p_hide_inactive is true then
                                                           ust.id in (9, 11, 14)
                                                         else true end
                                                   and pd.source in (525, 526)
                                                   and pd.archived is false
                                                   and case
                                                         when v_whole_company is false then
                                                           (up.id = any (p_user_position_ids)
--                                                              and (case
--                                                                     when array_length(p_org_ids, 1) > 0
--                                                                       then org_id = any (p_org_ids)
--                                                                     else 1 = 1 end)
                                                             )
                                                         else true end
                                                   and (
                                                   ((pd.first_time_appointment_created at time zone 'UTC' at time zone
                                                     'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or ((pd.prioritized_closer_appointment_outcome_date at time zone
                                                          'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or
                                                   ((pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or (pd.installation_agreement_signed_date::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or (pd.final_design_complete_date::date
                                                     between p_custom_start_date and p_custom_end_date)
                                                     or
                                                   ((pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                     between p_custom_start_date and p_custom_end_date))),
                            appointment_trend_data as (select pd.project_id,
                                                              final_design_complete_date,
                                                              first_time_appointment_created,
                                                              prioritized_closer_appointment_outcome_date,
                                                              prioritized_closer_appointment_outcome,
                                                              installation_agreement_signed_date,
                                                              first_appointment_pitched,
                                                              first_appointment_missed,
                                                              first_appointment_id,
                                                              first_appointment
                                                       from brs.project_details pd
                                                              inner join flow.user_position up
                                                                         on up.id = pd.setter_user_position_id
                                                         --the list of reps is filtered to only show users in these statuses so we have to filter the funnel data the same way
                                                              inner join flow.company_user_status cus
                                                                         on cus.user_id = up.user_id
                                                              inner join flow.user_status_type ust
                                                                         on ust.id = cus.user_status_type_id and ust.company_id = 3
                                                              inner join flow.org o on o.id = up.org_id
                                                       where pd.company_id = 3
                                                         and  pd.archived is false
                                                         and case
                                                               when p_hide_inactive is true then
                                                                 ust.id in (9, 11, 14)
                                                               else true end
                                                         and pd.source in (525, 526)
                                                         and pd.archived is false
                                                         and case
                                                               when v_whole_company is false then
                                                                 (up.id = any (p_user_position_ids)
--                                                                    and (case
--                                                                           when array_length(p_org_ids, 1) > 0
--                                                                             then org_id = any (p_org_ids)
--                                                                           else 1 = 1 end)
                                                                   )
                                                               else true end
                                                         and (
                                                         ((pd.first_time_appointment_created at time zone
                                                           'UTC' at time zone
                                                           'US/Mountain')::date
                                                           between p_trend_start_date and p_trend_end_date)
                                                           or
                                                         ((pd.prioritized_closer_appointment_outcome_date at time zone
                                                           'UTC' at time zone 'US/Mountain')::date
                                                           between p_trend_start_date and p_trend_end_date)
                                                           or
                                                         ((pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date
                                                           between p_trend_start_date and p_trend_end_date)
                                                           or (pd.installation_agreement_signed_date::date
                                                           between p_trend_start_date and p_trend_end_date)
                                                           or (pd.final_design_complete_date::date
                                                           between p_trend_start_date and p_trend_end_date)
                                                           or
                                                         ((pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                           between p_trend_start_date and p_trend_end_date))),
                            funnel_data as (select f.id,
                                                   count(1) filter (where
                                                     case
                                                       when f.id = 27 then
                                                         (pd.first_time_appointment_created at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 28 then
                                                         pd.prioritized_closer_appointment_outcome = 3 and
                                                         (pd.prioritized_closer_appointment_outcome_date at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 33 then
                                                         (pd.first_appointment_id is null or
                                                          (pd.first_appointment_id is not null and pd.first_appointment_id != 4)) and
                                                         (pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date

                                                       when f.id = 29 then
                                                         (pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 31 then
                                                         pd.installation_agreement_signed_date between p_custom_start_date and p_custom_end_date
                                                       when f.id = 32 then
                                                         pd.final_design_complete_date between p_custom_start_date and p_custom_end_date
                                                       end
                                                     ) as count_count,
                                                   (select count(1) filter (where
                                                     case
                                                       when f1.id = 27 then
                                                         (atd.first_time_appointment_created at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_trend_start_date and p_trend_end_date
                                                       when f1.id = 28 then
                                                         atd.prioritized_closer_appointment_outcome = 3 and
                                                         (atd.prioritized_closer_appointment_outcome_date at time zone
                                                          'UTC' at time zone
                                                          'US/Mountain')::date between p_trend_start_date and p_trend_end_date
                                                       when f1.id = 33 then
                                                         (atd.first_appointment_id is null or
                                                          (atd.first_appointment_id is not null and atd.first_appointment_id != 4)) and
                                                         (atd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date between p_trend_start_date and p_trend_end_date

                                                       when f1.id = 29 then
                                                         (atd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date between p_trend_start_date and p_trend_end_date
                                                       when f1.id = 31 then
                                                         atd.installation_agreement_signed_date between p_trend_start_date and p_trend_end_date
                                                       when f1.id = 32 then
                                                         atd.final_design_complete_date between p_trend_start_date and p_trend_end_date
                                                       end
                                                     ) as trend_count
                                                    from brs.funnel f1
                                                           cross join appointment_trend_data atd
                                                    where f1.archived is false
                                                      and f1.funnel_type_id = 4
                                                      and f1.unique_behavior is false
                                                      and f1.id = f.id)
                                            from brs.funnel f
                                                   cross join appointment_data pd
                                            where f.archived is false
                                              and f.funnel_type_id = 4
                                              and f.unique_behavior is false
                                            group by 1),
                            all_funnel_data as (select *
                                                from funnel_data fd
                                                union
                                                select f2.id,
                                                       case
                                                         when
                                                             (select count_count::numeric from funnel_data f1 where f1.id = 33)::numeric <
                                                             1 then
                                                           0
                                                         else
                                                           round(
                                                               (select count_count::numeric from funnel_data f1 where f1.id = 29)::numeric /
                                                               (select count_count::numeric from funnel_data f1 where f1.id = 33)::numeric *
                                                               100) end,
                                                       null::bigint as custom_date_range_trend_count
                                                from brs.funnel f2
                                                where f2.id = 30)
                       select f.id,
                              f.name,
                              f.display_order,
                              f.funnel_type_id,
                              coalesce(fd.count_count,0) as count_count,
                              case
                                when fd.trend_count is not null or fd.trend_count > 0
                                  then
                                  round((fd.count_count::numeric - fd.trend_count::numeric) /
                                        greatest(fd.trend_count::numeric, 1) *
                                        100)::numeric
                                else 0::numeric end as trend_count
                       from brs.funnel f
                              left join all_funnel_data fd on fd.id = f.id
                       where f.archived is false
                         and f.funnel_type_id = 4
                       order by f.display_order) as funnel_rows;


  end if;
END
$function$
