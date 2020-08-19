-- DROP FUNCTION brs.get_setter_performance_report(integer, date, date);

-- SELECT * FROM brs.get_setter_performance_report(2395038, '2020-07-01', '2020-07-09');

CREATE OR REPLACE FUNCTION brs.get_setter_performance_report(p_user_id integer, p_start_date date, p_end_date date)
    RETURNS JSON AS
$BODY$
DECLARE
    v_setter_performance_report json;

BEGIN
    SELECT row_to_json(sub_rows)
    INTO v_setter_performance_report
    FROM (
        select rpt.total_appointments,
               rpt.total_pitches,
               (case when rpt.total_appointments = 0 then 0
                    else ((rpt.total_pitches::numeric(10,2) / rpt.total_appointments) * 100)::integer
                    end
               ) as pitch_percentage
        from (select
            (select count(1)::bigint
             from flow.project p
                 inner join brs.project_details pd on pd.project_id = p.id
                 inner join flow.contact c on c.id = p.contact_id
                 inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                 inner join flow.user u on u.id = upv.user_id
             where pd.source in (6,493)
                 and pd.closer_appointment_start between p_start_date and p_end_date
                 and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > p_end_date))
                 and u.id is not null
                 and u.id not in (2354810, 2390159)
                 and u.id = p_user_id
            ) as total_appointments,
            (select count(1)::bigint
             from flow.project p
                 inner join brs.project_details pd on pd.project_id = p.id
                 inner join flow.contact c on c.id = p.contact_id
                 inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                 inner join flow.user u on u.id = upv.user_id
                 left join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 2
                 left join flow.project_process_step_custom_field_value closer_appointment_outcome on closer_appointment_outcome.project_process_step_id = pps.id and closer_appointment_outcome.custom_field_group_assignment_id = 4
             where pd.source in (6,493)
                 and pd.closer_appointment_start between p_start_date and p_end_date
                 and closer_appointment_outcome.text_value in ('Pitched', 'Missed')
                 and u.id is not null
                 and u.id not in (2354810, 2390159)
                 and u.id = p_user_id
            ) as total_pitches
        ) rpt
    ) as sub_rows;
RETURN v_setter_performance_report;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
