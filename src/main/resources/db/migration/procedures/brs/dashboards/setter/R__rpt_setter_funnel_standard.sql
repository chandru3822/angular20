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
CREATE OR REPLACE FUNCTION brs.rpt_setter_funnel_standard(p_custom_start_date date, p_custom_end_date date,
                                                          p_user_position_ids bigint[],
                                                          p_org_ids bigint[],
                                                          p_is_cohort boolean)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_whole_company boolean;
  v_date_diff     integer;
BEGIN

  select greatest(p_custom_end_date - p_custom_start_date, 60)
  into v_date_diff;
  select -1 = any (p_user_position_ids) into v_whole_company;

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
                                                 and (
                                                 ((pd.first_time_appointment_created at time zone 'UTC' at time zone
                                                   'US/Mountain')::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date)
                                                   or ((pd.prioritized_closer_appointment_outcome_date at time zone
                                                        'UTC' at time zone 'US/Mountain')::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date)
                                                   or
                                                 ((pd.first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date)
                                                   or (pd.installation_agreement_signed_date::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date)
                                                   or (pd.final_design_complete_date::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date)
                                                   or
                                                 ((pd.first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                   between (now() at time zone 'US/Mountain')::date - v_date_diff and (now() at time zone 'US/Mountain')::date))),
                          funnel_data as (select f.id,
                                                 count(1) filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         = (now() at time zone 'US/Mountain') :: DATE
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             = (now() at time zone 'US/Mountain') :: DATE end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE end
                                                     end
                                                   ) as today_day_count,
                                                 count(1) filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         = (now() at time zone 'US/Mountain') :: DATE - 1
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1 end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE -1
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE -1 end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1 end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1 end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             = (now() at time zone 'US/Mountain') :: DATE - 1 end
                                                     end
                                                   )
                                                     as yesterday_day_count,
                                                 count(1)
                                                 filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 7 and (now() at time zone 'US/Mountain')::date end
                                                     end
                                                   ) as seven_day_count,
                                                 count(1)
                                                 filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7 end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7 end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7 end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7 end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 14 and (now() at time zone 'US/Mountain')::date - 7 end
                                                     end
                                                   ) as prev_seven_day_count,
                                                 count(1)
                                                 filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     end
                                                   ) as thirty_day_count,
                                                 count(1)
                                                 filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30 end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30 end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30 end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30 end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 60 and (now() at time zone 'US/Mountain')::date - 30
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between (now() at time zone 'US/Mountain')::date - 30 and (now() at time zone 'US/Mountain')::date end
                                                     end
                                                   ) as prev_thirty_day_count,
                                                 count(1)
                                                 filter (where
                                                   case
                                                     when f.id = 27 then
                                                       (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                         between p_custom_start_date and p_custom_end_date
                                                     when f.id = 28 then
                                                       case
                                                         when p_is_cohort is true then
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date
                                                         else
                                                           prioritized_closer_appointment_outcome = 3 and
                                                           (prioritized_closer_appointment_outcome_date at time zone
                                                            'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date end
                                                     when f.id = 33 then
                                                       case
                                                         when p_is_cohort is true then
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date
                                                         else
                                                           (first_appointment_id is null or (first_appointment_id is not null and first_appointment_id != 4)) and
                                                           (first_appointment at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date end
                                                     when f.id = 29 then
                                                       case
                                                         when p_is_cohort is true then
                                                           first_appointment_pitched is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date
                                                         else
                                                           least((first_appointment_pitched at time zone 'UTC' at time zone 'US/Mountain')::date,
                                                                 (first_appointment_missed at time zone 'UTC' at time zone 'US/Mountain')::date)
                                                             between p_custom_start_date and p_custom_end_date end
                                                     when f.id = 31 then
                                                       case
                                                         when p_is_cohort is true then
                                                           installation_agreement_signed_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date
                                                         else
                                                           (installation_agreement_signed_date at time zone
                                                            'UTC' at time zone
                                                            'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date end
                                                     when f.id = 32 then
                                                       case
                                                         when p_is_cohort is true then
                                                           final_design_complete_date is not null and
                                                           (first_time_appointment_created at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date
                                                         else
                                                           (final_design_complete_date at time zone 'UTC' at time zone 'US/Mountain')::date
                                                             between p_custom_start_date and p_custom_end_date end
                                                     end
                                                   ) as custom_date_range_count
                                          from brs.funnel f
                                                 cross join appointment_data pd
                                          where f.archived is false
                                            and f.funnel_type_id = 4
                                            and f.unique_behavior is false
                                          group by 1),
                          funnel_stats as (select *,
                                                  case
                                                    when yesterday_day_count = 0 then 0
                                                    else cast(
                                                           cast(today_day_count - yesterday_day_count as numeric(10, 2)) /
                                                           yesterday_day_count as numeric(10, 2)) *
                                                         100 end as today_percent,
                                                  case
                                                    when prev_seven_day_count = 0 then 0
                                                    else cast(
                                                           cast(seven_day_count - prev_seven_day_count as numeric(10, 2)) /
                                                           prev_seven_day_count as numeric(10, 2)) *
                                                         100 end as seven_percent,
                                                  case
                                                    when prev_thirty_day_count = 0 then 0
                                                    else cast(
                                                           cast(thirty_day_count - prev_thirty_day_count as numeric(10, 2)) /
                                                           prev_thirty_day_count as numeric(10, 2)) *
                                                         100 end as thirty_day_percent
                                           from funnel_data fd),
                          all_funnel_stats as (select *
                                               from funnel_stats
                                               union
                                               select f2.id,
                                                      case when (select today_day_count::numeric from funnel_stats f1 where f1.id = 27)::numeric < 1 then
                                                        0 else
                                                      round(
                                                          (select today_day_count::numeric from funnel_stats f1 where f1.id = 29)::numeric /
                                                          (select today_day_count::numeric from funnel_stats f1 where f1.id = 27)::numeric *
                                                          100) end,
                                                      null,
                                                      case when (select seven_day_count::numeric from funnel_stats f1 where f1.id = 27)::numeric < 1 then
                                                             0 else
                                                      round(
                                                          (select seven_day_count::numeric from funnel_stats f1 where f1.id = 29)::numeric /
                                                          (select seven_day_count::numeric from funnel_stats f1 where f1.id = 27)::numeric *
                                                          100) end,
                                                      null,
                                                      case when (select thirty_day_count::numeric from funnel_stats f1 where f1.id = 27)::numeric < 1 then
                                                             0 else
                                                      round((select thirty_day_count::numeric
                                                             from funnel_stats f1
                                                             where f1.id = 29)::numeric /
                                                            (select thirty_day_count::numeric
                                                             from funnel_stats f1
                                                             where f1.id = 27)::numeric * 100) end,
                                                      null,
                                                      case when (select custom_date_range_count::numeric from funnel_stats f1 where f1.id = 27)::numeric < 1 then
                                                             0 else
                                                             round((select custom_date_range_count::numeric
                                                                    from funnel_stats f1
                                                                    where f1.id = 29)::numeric /
                                                                   (select custom_date_range_count::numeric
                                                                    from funnel_stats f1
                                                                    where f1.id = 27)::numeric * 100) end,
                                                      null,
                                                      null,
                                                      null
                                               from brs.funnel f2
                                               where f2.id = 30)
                     select f.id,
                            f.name,
                            f.display_order,
                            f.funnel_type_id,
                            fs.prev_seven_day_count    as prev_seven_day_count,
                            fs.prev_thirty_day_count   as prev_thirty_day_count,
                            fs.today_day_count         as today_day_count,
                            fs.seven_day_count         as seven_day_count,
                            fs.thirty_day_count        as thirty_day_count,
                            fs.custom_date_range_count as custom_date_range_count,
                            fs.seven_percent           as seven_percent,
                            fs.thirty_day_percent      as thirty_day_percent,
                            fs.today_percent           as today_percent,
                            fs.yesterday_day_count
                     from brs.funnel f
                            left join all_funnel_stats fs on fs.id = f.id
                     where f.archived is false
                       and f.funnel_type_id = 4
                     order by f.display_order) as funnel_rows;
END
$function$
