drop function if exists brs.get_tournament_user_score(p_tournament_id bigint, p_tournament_formula_id bigint,
                                                      p_start_date date,
                                                      p_end_date date, p_user_id bigint);
CREATE OR REPLACE FUNCTION brs.get_tournament_user_score(p_tournament_id bigint, p_tournament_formula_id bigint,
                                                         p_start_date date,
                                                         p_end_date date, p_user_id bigint)
  RETURNS bigint
AS
$BODY$
declare
  v_score                 bigint;
  v_timezone              varchar;
  v_tournament_start_date date;
BEGIN

  select start_date
  into v_tournament_start_date
  from brs.tournament
  where id = p_tournament_id;


  select t.timezone
  into v_timezone
  from flow.user_position up
         inner join flow.org o on up.org_id = o.id
         inner join flow.company_timezone ct on ct.id = o.company_timezone_id
         inner join flow.timezone t on ct.timezone_id = t.id
  where up.user_id = p_user_id
    and up.primary_flag is true;

  if v_timezone is not null then
    case when p_tournament_formula_id = 1 then
      select *
      into v_score
      from (
             (select (select count(1) * (select field_value
                                          from brs.tournament_formula_field_value tffv
                                                 inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                          where tff.tournament_formula_id = p_tournament_formula_id
                                            and tffv.tournament_id = p_tournament_id
                                            and tff.field_code = 'BOOKING_SCORE_VALUE')::int
                      from brs.project_details pd
                      where ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                        and pd.closer_user_id = p_user_id
                        and pd.cancelled_date is null
                        AND ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date >=
                            (select field_value
                             from brs.tournament_formula_field_value tffv
                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                             where tff.tournament_formula_id = p_tournament_formula_id
                               and tffv.tournament_id = p_tournament_id
                               and tff.field_code = 'APPOINTMENT_DATE')::date) +
                     ((select count(1) * (select field_value
                                          from brs.tournament_formula_field_value tffv
                                                   inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                          where tff.tournament_formula_id = p_tournament_formula_id
                                            and tffv.tournament_id = p_tournament_id
                                            and tff.field_code = 'FDC_SCORE_VALUE')::int  --- this is the FDC count
                       from brs.project_details pd
                              left join flow.contact_custom_field_value ccfv
                                        on ccfv.contact_id = pd.contact_id and ccfv.custom_field_group_assignment_id = 19106
                       where pd.closer_user_id = p_user_id
                         and pd.cancelled_date is null
                         and pd.final_design_complete_date between p_start_date and p_end_date
                         and (ccfv.boolean_value is null or ccfv.boolean_value is false)
                         and pd.source not in (select unnest(string_to_array(value, ',')::bigint[])
                                    from flow.company_configuration_value
                                    where code = 'CLOSER_GEN_SOURCE_IDS')
                         AND ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date >=
                             (select field_value
                              from brs.tournament_formula_field_value tffv
                                     inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                              where tff.tournament_formula_id = p_tournament_formula_id
                                and tffv.tournament_id = p_tournament_id
                                and tff.field_code = 'APPOINTMENT_DATE')::date)) +
                     ((select count(1) * (select field_value
                                          from brs.tournament_formula_field_value tffv
                                                   inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                          where tff.tournament_formula_id = p_tournament_formula_id
                                            and tffv.tournament_id = p_tournament_id
                                            and tff.field_code = 'SELF_GEN_FDC_SCORE_VALUE')::int
                       from brs.project_details pd
                              left join flow.contact_custom_field_value ccfv
                                        on ccfv.contact_id = pd.contact_id and ccfv.custom_field_group_assignment_id = 19106
                       where pd.final_design_complete_date is not null
                         and pd.cancelled_date is null
                         and pd.closer_user_id = p_user_id
                         and pd.final_design_complete_date between p_start_date and p_end_date
                         and (ccfv.boolean_value is true
                           or pd.source in (select unnest(string_to_array(value, ',')::bigint[])
                                                 from flow.company_configuration_value
                                                 where code = 'CLOSER_GEN_SOURCE_IDS')
                             )
                         AND ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date >=
                             (select field_value
                              from brs.tournament_formula_field_value tffv
                                     inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                              where tff.tournament_formula_id = p_tournament_formula_id
                                and tffv.tournament_id = p_tournament_id
                                and tff.field_code = 'APPOINTMENT_DATE')::date)))) as cnt;
      when p_tournament_formula_id = 2 then
        select *
        into v_score
        from (
               (select (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'PITCHED_SCORE_VALUE')::int --pitched
                        from brs.project_details pd
                        where ((pd.first_appointment_pitched at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                          and first_appointment_pitched_id is not null
                          and pd.setter_user_id = p_user_id) +
                       (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'MISSED_SCORE_VALUE')::int --missed
                        from brs.project_details pd
                        where ((pd.first_appointment_missed at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                          and pd.first_appointment_missed_id is not null
                          AND pd.first_appointment_pitched is null
                          and pd.setter_user_id = p_user_id) +
                       (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'NOT_PITCHED_SCORE_VALUE')::int --not pitch: other & no show
                        from brs.project_details pd
                        where ((pd.first_appointment_not_pitched_or_missed at time zone 'UTC') at time zone
                               v_timezone)::date between p_start_date and p_end_date
                          and pd.first_appointment_not_pitched_or_missed_id in (58, 56)
                          AND pd.first_appointment_pitched is null
                          AND pd.first_appointment_missed is null
                          and pd.setter_user_id = p_user_id))) as cnt;
        when p_tournament_formula_id = 3 then
        select *
        into v_score
        from (
               (select (select count(1) * (select field_value
                                          from brs.tournament_formula_field_value tffv
                                                 inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                          where tff.tournament_formula_id = p_tournament_formula_id
                                            and tffv.tournament_id = p_tournament_id
                                            and tff.field_code = 'PITCHED_SCORE_VALUE')::int --pitched
                        from brs.project_details pd
                        where ((pd.first_appointment_pitched at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                          and first_appointment_pitched_id is not null
                          and pd.setter_user_id = p_user_id) +
                       (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'MISSED_SCORE_VALUE')::int --missed
                        from brs.project_details pd
                        where ((pd.first_appointment_missed at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                          and pd.first_appointment_missed_id is not null
                          AND pd.first_appointment_pitched is null
                          and pd.setter_user_id = p_user_id) +
                       (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                    inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'NOT_PITCHED_SCORE_VALUE')::int --not pitch: other & no show
                        from brs.project_details pd
                        where ((pd.first_appointment_not_pitched_or_missed at time zone 'UTC') at time zone
                               v_timezone)::date between p_start_date and p_end_date
                          and pd.first_appointment_not_pitched_or_missed_id in (58, 56)
                          AND pd.first_appointment_pitched is null
                          AND pd.first_appointment_missed is null
                          and pd.setter_user_id = p_user_id) +
                       ((select count(1) * (select field_value
                                             from brs.tournament_formula_field_value tffv
                                                      inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                             where tff.tournament_formula_id = p_tournament_formula_id
                                               and tffv.tournament_id = p_tournament_id
                                               and tff.field_code = 'FDC_SCORE_VALUE')::int --- this is the FDC count
                         from brs.project_details pd
                         where pd.setter_user_id = p_user_id
                           and pd.cancelled_date is null
                           and pd.final_design_complete_date between p_start_date and p_end_date
                           AND ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date >=
                               (select field_value
                                from brs.tournament_formula_field_value tffv
                                         inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                where tff.tournament_formula_id = p_tournament_formula_id
                                  and tffv.tournament_id = p_tournament_id
                                  and tff.field_code = 'APPOINTMENT_DATE')::date)) +
                       (select count(1) * (select field_value
                                           from brs.tournament_formula_field_value tffv
                                                  inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                                           where tff.tournament_formula_id = p_tournament_formula_id
                                             and tffv.tournament_id = p_tournament_id
                                             and tff.field_code = 'BOOKING_SCORE_VALUE_SETTERS')::int
                        from brs.project_details pd
                        where pd.installation_agreement_signed_date::date between p_start_date and p_end_date
                          and pd.setter_user_id = p_user_id

                          --carlin to find out if this part is necessary
                          AND ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date >=
                              (select field_value
                               from brs.tournament_formula_field_value tffv
                                        inner join brs.tournament_formula_field tff on tff.id = tffv.tournament_formula_field_id
                               where tff.tournament_formula_id = p_tournament_formula_id
                                 and tffv.tournament_id = p_tournament_id
                                 and tff.field_code = 'APPOINTMENT_DATE')::date
                        ))) as cnt;

      else
        v_score = null;
      end case;
  else
    v_score = null;
  end if;


  return v_score;
END
$BODY$
  LANGUAGE plpgsql VOLATILE;

