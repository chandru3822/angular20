CREATE OR REPLACE FUNCTION brs.get_tournament_user_score_drill_down(p_tournament_id integer, p_start_date date,
                                                                    p_end_date date, p_user_id integer)
    RETURNS setof json
AS
$BODY$
declare
    v_timezone              varchar;
    v_tournament_formula_id integer;
BEGIN

    select tf.id
    into v_tournament_formula_id
    from brs.tournament t
             inner join brs.tournament_formula tf on t.tournament_formula_id = tf.id
    where t.id = p_tournament_id;


    select t.timezone
    into v_timezone
    from flow.user_position up
             inner join flow.org o on up.org_id = o.id
             inner join flow.company_timezone ct on ct.id = o.company_timezone_id
             inner join flow.timezone t on ct.timezone_id = t.id
    where up.user_id = p_user_id
      and up.primary_flag is true;

    if v_timezone is not null then

        case when v_tournament_formula_id = 1 then
            RETURN QUERY select (select array_to_json(array_agg(row_to_json(drilldown)))
                                 from (
                                          select project_id,
                                                 p.project_name,
                                                 ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date as complete_date_booking,
                                                 pd.final_design_complete_date,
                                                 count(1) as score
                                          from brs.project_details pd
                                                   inner join flow.project p on pd.project_id = p.id
                                          where ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                            and pd.closer_user_id = p_user_id
                                          group by 1, 2, 3, 4
                                          union
                                          select project_id,
                                                 p.project_name,
                                                 ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date as complete_date_booking,
                                                 pd.final_design_complete_date,
                                                 count(1) * 4 as score
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.contact c on c.id = p.contact_id
                                                   left join flow.contact_custom_field_value ccfv
                                                             on ccfv.contact_id = c.id and ccfv.custom_field_group_assignment_id = 19106
                                          where pd.closer_user_id = p_user_id
                                            and pd.final_design_complete_date between p_start_date and p_end_date
                                            and (ccfv.boolean_value is null or ccfv.boolean_value is false)
                                            and pd.source != 523
                                          group by 1, 2, 3, 4
                                          union
                                          select project_id,
                                                 p.project_name,
                                                 ((pd.complete_date_booking at time zone 'UTC') at time zone v_timezone)::date as complete_date_booking,
                                                 pd.final_design_complete_date,
                                                 count(1) * 5 as score
                                          from brs.project_details pd
                                                   inner join flow.project p on p.id = pd.project_id
                                                   inner join flow.contact c on c.id = p.contact_id
                                                   inner join flow.contact_custom_field_value ccfv
                                                              on ccfv.contact_id = c.id and ccfv.custom_field_group_assignment_id = 19106
                                          where pd.final_design_complete_date is not null
                                            and pd.closer_user_id = p_user_id
                                            and pd.final_design_complete_date between p_start_date and p_end_date
                                            and (ccfv.boolean_value is true
                                              or pd.source = 523)
                                          group by 1, 2, 3, 4
                                          ) as drilldown) as drilldown;
            when v_tournament_formula_id = 2 then
                RETURN QUERY select (select array_to_json(array_agg(row_to_json(drilldown)))
                                     from (
                                              select pd.project_id,
                                                     p.project_name,
                                                     ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date as first_appointment,
                                                     pd.first_appointment_pitched,
                                                     count(1) as score
                                              from brs.project_details pd
                                                       inner join flow.project p on pd.project_id = p.id
                                              where ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                                and first_appointment_pitched_id is not null
                                                and pd.setter_user_id = p_user_id
                                              group by 1, 2, 3, 4
                                              union
                                              select pd.project_id,
                                                     p.project_name,
                                                     ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date as first_appointment,
                                                     pd.first_appointment_missed,
                                                     count(1) as score
                                              from brs.project_details pd
                                                       inner join flow.project p on pd.project_id = p.id
                                              where ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                                and pd.first_appointment_missed_id is not null
                                                and pd.setter_user_id = p_user_id
                                              group by 1, 2, 3, 4
                                              union
                                              select pd.project_id,
                                                     p.project_name,
                                                     ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date as first_appointment,
                                                     pd.first_appointment_not_pitched_or_missed,
                                                     count(1) * -1 as score
                                              from brs.project_details pd
                                                       inner join flow.project p on pd.project_id = p.id
                                              where ((pd.first_appointment at time zone 'UTC') at time zone v_timezone)::date between p_start_date and p_end_date
                                                and pd.first_appointment_not_pitched_or_missed_id is not null
                                                and pd.setter_user_id = p_user_id
                                              group by 1, 2, 3, 4) as drilldown) as drilldown;

            end case;
    end if;

END
$BODY$
    LANGUAGE plpgsql VOLATILE;

