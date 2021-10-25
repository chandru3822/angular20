CREATE OR REPLACE FUNCTION brs.get_tournament_user_score(p_tournament_formula_id integer, p_start_date date,
                                                         p_end_date date, p_user_id integer)
    RETURNS integer
AS
$BODY$
declare
    v_score    integer;
    v_timezone varchar;
BEGIN

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
                     (select (select count(1)*2
                              from brs.project_details pd
                              where ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                and pd.closer_user_id = p_user_id
                                and pd.cancelled_date is null
                                AND ((pd.first_appointment  at time zone 'UTC') at time zone v_timezone)::date >= p_start_date - 10) +
                             ((select count(1)
                               from brs.project_details pd
                                        inner join flow.project p on p.id = pd.project_id
                                        inner join flow.contact c on c.id = p.contact_id
                                        left join flow.contact_custom_field_value ccfv
                                                  on ccfv.contact_id = c.id and ccfv.custom_field_group_assignment_id = 19106
                               where pd.closer_user_id = p_user_id
                                 and pd.cancelled_date is null
                                 and pd.final_design_complete_date between p_start_date and p_end_date
                                 and (ccfv.boolean_value is null or ccfv.boolean_value is false)
                                 and pd.source != 523
                                 AND ((pd.first_appointment  at time zone 'UTC') at time zone v_timezone)::date >= p_start_date - 10) * 4) +
                             ((select count(1)
                               from brs.project_details pd
                                        inner join flow.project p on p.id = pd.project_id
                                        inner join flow.contact c on c.id = p.contact_id
                                        left join flow.contact_custom_field_value ccfv
                                                   on ccfv.contact_id = c.id and ccfv.custom_field_group_assignment_id = 19106
                               where pd.final_design_complete_date is not null
                                 and pd.cancelled_date is null
                                 and pd.closer_user_id = p_user_id
                                 and pd.final_design_complete_date between p_start_date and p_end_date
                                 and (ccfv.boolean_value is true
                                   or pd.source = 523)
                                 AND ((pd.first_appointment  at time zone 'UTC') at time zone v_timezone)::date >= p_start_date - 10) * 5))) as cnt;
            when p_tournament_formula_id = 2 then
                select *
                into v_score
                from (
                         (select (select count(1) * 2
                                  from brs.project_details pd
                                  where ((pd.first_appointment_pitched at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                    and first_appointment_pitched_id is not null
                                    and pd.setter_user_id = p_user_id) +
                                 (select count(1)
                                  from brs.project_details pd
                                  where ((pd.first_appointment_missed at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                    and pd.first_appointment_missed_id is not null
                                    AND pd.first_appointment_pitched is null
                                    and pd.setter_user_id = p_user_id)+
                                 (select count(1) *-1
                                  from brs.project_details pd
                                  where ((pd.first_appointment_not_pitched_or_missed at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                    and pd.first_appointment_not_pitched_or_missed_id in (58,56)
                                    AND pd.first_appointment_pitched is null
                                    AND pd.first_appointment_missed is null
                                    and pd.setter_user_id = p_user_id))) as cnt;

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

