-- DROP FUNCTION brs.get_setter_to_beat(integer, date, date);

-- SELECT * FROM brs.get_setter_to_beat(2391370, '2020-07-01', '2020-07-07');

CREATE OR REPLACE FUNCTION brs.get_setter_to_beat(p_user_id integer, p_start_date date, p_end_date date)
    RETURNS JSON AS
$BODY$
DECLARE
    v_rank_box_data json;

BEGIN
    SELECT row_to_json(sub_rows)
    INTO v_rank_box_data
    FROM (
        select setter_to_beat_id,
               setter_to_beat_name,
               (setter_to_beat_pitches - pitches) + 1 as pitches_to_go,
               rank as current_user_rank
        from (
            select setter_user_id,
                   pitches,
                   lead(setter_user_id) over (order by pitches, setter_user_id desc) setter_to_beat_id,
                   lead(name) over (order by pitches, setter_user_id desc) setter_to_beat_name,
                   lead(pitches) over (order by pitches, setter_user_id desc) setter_to_beat_pitches,
                   (case when (
                               rank = lag(rank, 1, -1::bigint) over (order by rank) or
                               rank = lead(rank, 1, -1::bigint) over (order by rank)
                       ) then 'T' || rank
                         else rank::text
                       end
                   ) as rank
              from (
                  select pd.setter_user_id,
                         concat(u.first_name, ' ', u.last_name) AS name,
                         count(1)::bigint as pitches,
                         rank() over (order by count(1) desc) as rank
                  from flow.project p
                      inner join brs.project_details pd on pd.project_id = p.id
                      inner join flow.contact c on c.id = p.contact_id
                      inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
                      inner join flow.user u on u.id = pd.setter_user_id
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
                      and pd.company_id = 3
                  group by pd.setter_user_id, name
                  order by pitches desc, pd.setter_user_id
              ) as ranks
        ) user_to_beat
        where setter_user_id = p_user_id
    ) as sub_rows;
RETURN v_rank_box_data;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
