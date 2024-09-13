-- DROP FUNCTION brs.get_setter_to_beat(bigint, date, date);

-- SELECT * FROM brs.get_setter_to_beat(2391370, '2020-07-01', '2020-07-07');
drop function if exists brs.get_setter_to_beat(p_user_id bigint, p_start_date date, p_end_date date);
  CREATE OR REPLACE FUNCTION brs.get_setter_to_beat(p_user_id bigint, p_start_date date, p_end_date date)
    RETURNS table (
      setter_to_beat_id integer,
      setter_to_beat_name text,
      pitches_to_go bigint,
      current_user_rank text
      ) AS
$BODY$
BEGIN
return query
        select user_to_beat.setter_to_beat_id,
               user_to_beat.setter_to_beat_name,
               (setter_to_beat_pitches - pitches) + 1 as pitches_to_go,
               rank as current_user_rank
        from (
            select setter_user_id,
                   coalesce(pitches,0) as pitches,
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
                  from brs.project_details pd
                      inner join flow.user u on u.id = pd.setter_user_id
                  where pd.source in (525, 526) --(Setter Gen, Retargeted)
                      and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                      and pd.prioritized_closer_appointment_outcome in (2,3,1139,1140)
                      and pd.setter_user_id not in (2354810, 2390159)
                      and pd.company_id = 3
                  group by pd.setter_user_id, name
                  order by pitches desc, pd.setter_user_id
              ) as ranks
        ) user_to_beat
        where setter_user_id = p_user_id
        limit 1;
END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
