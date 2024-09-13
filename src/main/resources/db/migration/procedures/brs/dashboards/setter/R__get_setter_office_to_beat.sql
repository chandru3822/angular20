-- DROP FUNCTION brs.get_setter_office_to_beat(bigint, date, date);

-- SELECT * FROM brs.get_setter_office_to_beat(723, '2020-06-01', '2020-06-07');
drop function if exists brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date, p_run_by_id bigint);
drop function if exists brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date);
  CREATE OR REPLACE FUNCTION brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date)
    RETURNS table (
                    setter_office_to_beat_id bigint,
                    setter_office_to_beat_name text,
                    pitches_to_go bigint,
                    current_office_rank text
                  ) AS
$BODY$
BEGIN
return query
        select office_to_beat.setter_office_to_beat_id,
               office_to_beat.setter_office_to_beat_name,
               (coalesce(office_to_beat.setter_office_to_beat_pitches,0) - coalesce(office_to_beat.pitches,0) + 1) as pitches_to_go,
               office_to_beat.rank as current_office_rank
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
                       concat(o.org_name, ' (', lov.name, ')') as org,
                       count(1)::bigint as pitches,
                       rank() over (order by count(1) desc) as rank
                from brs.project_details pd
                    inner join flow.user_position up on up.id = pd.setter_user_position_id
                    inner join flow.org o on (o.id = up.org_id or o.id = coalesce( up.sales_org_id,0::bigint))
                    left join flow.organization_custom_field_value ocfv on ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                    left join flow.list_of_value lov on ocfv.int_value = lov.id
                where pd.source in (525, 526) --(Setter Gen, Retargeted)
                    and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone 'US/Mountain') :: date between p_start_date and p_end_date
                  and pd.prioritized_closer_appointment_outcome in (2,3,1139,1140)
                    and o.id != 171 --Setter Call Center
                    and pd.company_id = 3
                group by o.id, concat(o.org_name, ' (', lov.name, ')')
            ) as ranks
        ) as office_to_beat
        where org_id = p_office_id
        order by pitches desc, org_id
        limit 1;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
