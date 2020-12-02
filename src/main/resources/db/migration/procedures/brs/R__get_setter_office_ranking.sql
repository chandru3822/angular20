-- DROP FUNCTION brs.get_setter_office_ranking(integer, integer);

-- SELECT * FROM brs.get_setter_office_ranking(13, 30);

CREATE OR REPLACE FUNCTION brs.get_setter_office_ranking(p_limit integer, p_days integer DEFAULT 30)
    RETURNS SETOF JSON AS
$BODY$
BEGIN

    RETURN QUERY SELECT array_to_json(array_agg(row_to_json(sub_rows)))
    FROM (
        select org_id,
               org,
               total_appointments,
               pitches,
               (case when total_appointments = 0 then 0
                    else ((pitches::numeric(10,2) / total_appointments) * 100)::integer
                    end
               ) as pitch_percentage,
               (case when (
                         rank = lag(rank, 1, -1::bigint) over (order by rank) or
                         rank = lead(rank, 1, -1::bigint) over (order by rank)
                     ) then 'T' || rank
                     else rank::text
                     end
               ) as rank
        from (
            select
                o.id as org_id,
                concat(o.org_name, ' (', metro_area.metro_area, ')') as org,
                (select count(1)::bigint
                 from flow.project p2
                     inner join brs.project_details pd2 on pd2.project_id = p2.id
                     inner join flow.contact c2 on c2.id = p2.contact_id
                     inner join flow.user_positions_vw upv2 on (upv2.user_position_id = c2.owner_user_position_id and upv2.position_id = 4)
                     inner join flow.user u2 on u2.id = upv2.user_id
                     inner join flow.org o2 on (o2.id = upv2.org_id and o2.active_flag is true)
                 where pd2.source in (525, 526) --(Setter Gen, Retargeted)
                     and case when upv2.end_date is not null
                         then p2.date_created::date between upv2.start_date and upv2.end_date
                         else p2.date_created::date >= upv2.start_date
                         end
                     and upv2.position_level = 0
                     and pd2.closer_appointment_start between ((now() at time zone 'US/Mountain')::date - p_days) and ((now() at time zone 'US/Mountain')::date)
                     and ((pd2.cancelled_date is null) or (pd2.cancelled_date is not null and pd2.cancelled_date > (now() at time zone 'US/Mountain')::date))
                     and o2.id = o.id
                ) as total_appointments,
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
                and upv.position_level = 0
                and pd.closer_appointment_start between ((now() at time zone 'US/Mountain')::date - p_days) and ((now() at time zone 'US/Mountain')::date)
                and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed)
                and o.id != 171
            group by o.id, concat(o.org_name, ' (', metro_area.metro_area, ')')
            limit p_limit
        ) as t
        order by pitches desc, org_id
    ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
