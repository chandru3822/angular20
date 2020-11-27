-- DROP FUNCTION brs.get_setter_mgr_performance_report(integer, date, date);

-- SELECT * FROM brs.get_setter_mgr_performance_report(717, '2020-07-01', '2020-07-09');

CREATE OR REPLACE FUNCTION brs.get_setter_mgr_performance_report(p_office_id integer, p_start_date date, p_end_date date)
    RETURNS JSON AS
$BODY$
DECLARE
    v_setter_ids integer[];
    v_setter_performance_report json;

BEGIN
    SELECT * FROM brs.get_setters_by_setter_mgr_office(p_office_id) INTO v_setter_ids;

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
                 inner join flow.user_positions_vw upv on (upv.user_position_id = c.owner_user_position_id and upv.position_id = 4)
                 inner join flow.user u on u.id = upv.user_id
             where pd.source in (525, 526) --(Setter Gen, Retargeted)
                 and case when upv.end_date is not null
                     then p.date_created::date between upv.start_date and upv.end_date
                     else p.date_created::date >= upv.start_date
                     end
                 and upv.position_level = 0
                 and pd.closer_appointment_start between p_start_date and p_end_date
                 and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > p_end_date))
                 and u.id = any(v_setter_ids)
            ) as total_appointments,
            (select count(1)::bigint
             from flow.project p
                 inner join brs.project_details pd on pd.project_id = p.id
                 inner join flow.contact c on c.id = p.contact_id
                 inner join flow.user_positions_vw upv on (upv.user_position_id = c.owner_user_position_id and upv.position_id = 4)
                 inner join flow.user u on u.id = upv.user_id
             where pd.source in (525, 526) --(Setter Gen, Retargeted)
                 and case when upv.end_date is not null
                     then p.date_created::date between upv.start_date and upv.end_date
                     else p.date_created::date >= upv.start_date
                     end
                 and upv.position_level = 0
                 and pd.closer_appointment_start between p_start_date and p_end_date
                 and pd.closer_appointment_outcome in (2, 3) --(Pitched, Missed)
                 and u.id = any(v_setter_ids)
            ) as total_pitches
        ) rpt
    ) as sub_rows;
RETURN v_setter_performance_report;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
