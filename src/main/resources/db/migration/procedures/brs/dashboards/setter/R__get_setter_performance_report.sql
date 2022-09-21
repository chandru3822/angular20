-- DROP FUNCTION brs.get_setter_performance_report(bigint, date, date);

-- SELECT * FROM brs.get_setter_performance_report(2395038, '2020-07-01', '2020-07-09');
drop function if exists brs.get_setter_performance_report(p_user_id bigint, p_start_date date, p_end_date date);
  CREATE OR REPLACE FUNCTION brs.get_setter_performance_report(p_user_id bigint, p_start_date date, p_end_date date)
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
                    else ((rpt.total_pitches::numeric(10,2) / rpt.total_appointments) * 100)::bigint
                    end
               ) as pitch_percentage
        from (select
            (select count(1)::bigint
             from flow.project p
                 inner join brs.project_details pd on pd.project_id = p.id
                 inner join flow.contact c on c.id = p.contact_id
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4 and up.archived is not true)
             where pd.source in (525, 526) --(Setter Gen, Retargeted)
                 and (((case when pd.first_appointment_pitched is not null
                                 then pd.first_appointment_pitched
                             when pd.first_appointment_pitched is null
                                 and pd.first_appointment_missed is not null
                                 then pd.first_appointment_missed
                             when pd.first_appointment_pitched is null
                                 and pd.first_appointment_missed is null
                                 and pd.first_appointment_not_pitched_or_missed is not null
                                 then pd.first_appointment_not_pitched_or_missed
                             when pd.first_appointment_pitched is null
                                 and pd.first_appointment_missed is null
                                 and pd.first_appointment_not_pitched_or_missed is null
                                 and pd.first_appointment is not null
                                 then pd.first_appointment
                             else pd.closer_appointment_start
                             end) at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                 and ((pd.cancelled_date is null) or (pd.cancelled_date is not null and pd.cancelled_date > p_end_date))
                 and pd.setter_user_id not in (2354810, 2390159)
                 and pd.setter_user_id = p_user_id
                 and pd.company_id = 3
            ) as total_appointments,
            (select count(1)::bigint
             from flow.project p
                 inner join brs.project_details pd on pd.project_id = p.id
                 inner join flow.contact c on c.id = p.contact_id
                 inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4 and up.archived is not true)
             where pd.source in (525, 526) --(Setter Gen, Retargeted)
                 and (((case when pd.first_appointment_pitched is not null
                                 then pd.first_appointment_pitched
                             when pd.first_appointment_pitched is null
                                 and pd.first_appointment_missed is not null
                                 then pd.first_appointment_missed
                             else pd.closer_appointment_start
                             end) at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                 and (case when pd.first_appointment_pitched is not null
                               then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                           when pd.first_appointment_pitched is null
                               and pd.first_appointment_missed is not null
                               then pd.first_appointment_missed_id in (2,3,1139,1140)
                           else pd.closer_appointment_outcome in (2,3,1139,1140)
                           end)
                 and pd.setter_user_id not in (2354810, 2390159)
                 and pd.setter_user_id = p_user_id
                 and pd.company_id = 3
            ) as total_pitches
        ) rpt
    ) as sub_rows;
RETURN v_setter_performance_report;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
