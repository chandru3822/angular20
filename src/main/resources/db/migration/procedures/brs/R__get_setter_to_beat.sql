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
                  select u.id as setter_user_id,
                         concat(u.first_name, ' ', u.last_name) AS name,
                         count(1)::bigint as pitches,
                         rank() over (order by count(1) desc) as rank
                  from flow.project p
                      inner join brs.project_details pd on pd.project_id = p.id
                      inner join flow.contact c on c.id = p.contact_id
                      inner join flow.user_positions_vw upv on upv.user_position_id = c.owner_user_position_id
                      inner join flow.user u on u.id = upv.user_id
                      inner join flow.company_user_status cus on cus.user_id = u.id
                      inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
                  where ust.user_status_type = 'Active'
                      and pd.source in (6,493) -- ('Setter Gen', 'Retargeted')
                      and pd.closer_appointment_start between p_start_date and p_end_date
                      and pd.closer_appointment_outcome in (2,3) -- ('Pitched', 'Missed')
                      and u.id is not null
                      and u.id not in (2354810, 2390159)
                  group by setter_user_id, name
                  order by pitches desc, setter_user_id
              ) as ranks
        ) user_to_beat
        where setter_user_id = p_user_id
    ) as sub_rows;
RETURN v_rank_box_data;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
