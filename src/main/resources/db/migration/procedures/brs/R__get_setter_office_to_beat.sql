-- DROP FUNCTION brs.get_setter_office_to_beat(integer, date, date);

-- SELECT * FROM brs.get_setter_office_to_beat(723, '2020-06-01', '2020-06-07');

CREATE OR REPLACE FUNCTION brs.get_setter_office_to_beat(p_office_id integer, p_start_date date, p_end_date date)
    RETURNS JSON AS
$BODY$
DECLARE
    v_rank_box_data json;

BEGIN

    SELECT row_to_json(sub_rows)
    INTO v_rank_box_data
    FROM (
        select setter_office_to_beat_id,
               setter_office_to_beat_name,
               (setter_office_to_beat_pitches - pitches + 1) as pitches_to_go,
               rank as current_office_rank
        from (
            select org_id,
                   pitches,
                   lead(org_id) over (order by pitches, org_id desc) setter_office_to_beat_id,
                   lead(org) over (order by pitches, org_id desc) setter_office_to_beat_name,
                   lead(pitches) over (order by pitches, org_id desc) setter_office_to_beat_pitches,
                   (case when (
                             rank = lag(rank, 1, -1::bigint) over (order by rank) or
                             rank = lead(rank, 1, -1::bigint) over (order by rank)
                         ) then 'T' || rank
                         else rank::text
                         end
                   ) as rank
            from (
                select o.id as org_id,
                       concat(o.org_name, ' (', metro_area.metro_area, ')') as org,
                       count(1)::bigint as pitches,
                       rank() over (order by count(1) desc) as rank
                from flow.project p
                    inner join brs.project_details pd on pd.project_id = p.id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user_positions_vw upv on (upv.user_position_id = c.owner_user_position_id and upv.position_id = 4)
                    inner join flow.user u on u.id = upv.user_id
                    inner join flow.org o on (o.id = upv.org_id and o.active_flag is true)
                    left join lateral (select * from flow.get_value_for_custom_field(5, 185, p.id, 0, false) as metro_area) metro_area on true
                where pd.source in (525, 526) --(Setter Gen, Retargeted)
                    and case when upv.end_date is not null
                        then p.date_created::date between upv.start_date and upv.end_date
                        else p.date_created::date >= upv.start_date
                        end
                    and upv.primary_flag is true
                    and upv.position_level = 0
                    and upv.position_id = 4
                    and pd.closer_appointment_start between p_start_date and p_end_date
                    and pd.closer_appointment_outcome in (2,1139,1140)
                    and o.id != 171
                group by o.id, concat(o.org_name, ' (', metro_area.metro_area, ')')
            ) as ranks
        ) as office_to_beat
        where org_id = p_office_id
        order by pitches desc, org_id
    ) as sub_rows;
RETURN v_rank_box_data;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
