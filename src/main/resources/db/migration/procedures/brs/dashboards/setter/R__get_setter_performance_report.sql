-- DROP FUNCTION brs.get_setter_performance_report(bigint, date, date);

-- SELECT * FROM brs.get_setter_performance_report(2395038, '2020-07-01', '2020-07-09');
drop function if exists brs.get_setter_performance_report(p_user_id bigint, p_start_date date, p_end_date date);
CREATE OR REPLACE FUNCTION brs.get_setter_performance_report(p_user_id bigint, p_start_date date, p_end_date date)
  RETURNS table
          (
            total_appointments  bigint,
            total_pitches       bigint,
            pitch_percentage    bigint,
            to_beat_id   integer,
            to_beat_name text,
            pitches_to_go       bigint,
            current_rank   text
          )
AS
$BODY$
BEGIN
  return query
    with data as (
      select coalesce(rpt.total_appointments, 0) as total_appointments,
         coalesce(rpt.total_pitches, 0)      as total_pitches,
         (case
            when rpt.total_appointments = 0 then 0
            else ((coalesce(rpt.total_pitches, 0)::numeric(10, 2) / rpt.total_appointments) * 100)::bigint
           end
           )                                 as pitch_percentage,
         stb.setter_to_beat_id,
         stb.setter_to_beat_name,
         stb.pitches_to_go,
         stb.current_user_rank
  from (select (select count(1)::bigint
                from brs.project_details pd
                where pd.source in (525, 526) --(Setter Gen, Retargeted)
                  and ((pd.first_time_appointment_created at time zone 'UTC') at time zone
                       'US/Mountain') :: date between p_start_date and p_end_date
                  and pd.setter_user_id = p_user_id
                  and pd.company_id = 3) as total_appointments,
               (select count(1)::bigint
                from brs.project_details pd
                where pd.source in (525, 526) --(Setter Gen, Retargeted)
                  and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone
                       'US/Mountain') :: date between p_start_date and p_end_date
                  and pd.prioritized_closer_appointment_outcome in (2, 3, 1139, 1140)
                  and pd.setter_user_id = p_user_id
                  and pd.company_id = 3) as total_pitches) rpt
         join lateral brs.get_setter_to_beat(p_user_id, p_start_date, p_end_date) stb on true)
    SELECT
      d.total_appointments AS total_appointments,
      d.total_pitches AS total_pitches,
      d.pitch_percentage AS pitch_percentage,
      d.setter_to_beat_id AS setter_to_beat_id,
      d.setter_to_beat_name AS setter_to_beat_name,
      d.pitches_to_go AS pitches_to_go,
      d.current_user_rank AS current_user_rank
    FROM data d
    UNION ALL
    SELECT 0::bigint AS total_appointments,
           0::bigint AS total_pitches,
           0::bigint AS pitch_percentage,
           null::integer AS setter_to_beat_id,
           'TBD'::text AS setter_to_beat_name,
           0::bigint AS pitches_to_go,
           'TBD'::text AS current_user_rank
    WHERE NOT EXISTS (SELECT 1 FROM data);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
