-- DROP FUNCTION brs.get_setter_office_to_beat(bigint, date, date);

-- SELECT * FROM brs.get_setter_office_to_beat(723, '2020-06-01', '2020-06-07');
drop function if exists brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date);
  CREATE OR REPLACE FUNCTION brs.get_setter_office_to_beat(p_office_id bigint, p_start_date date, p_end_date date)
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
                       concat(o.org_name, ' (', lov.name, ')') as org,
                       count(1)::bigint as pitches,
                       rank() over (order by count(1) desc) as rank
                from flow.project p
                    inner join brs.project_details pd on pd.project_id = p.id
                    inner join flow.contact c on c.id = p.contact_id
                    inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id in (select unnest(string_to_array(value, ',')::bigint[])
                                                                                                        from flow.company_configuration_value
                                                                                                        where code = 'SETTER_POSITION_IDS') and up.archived is not true)
                    inner join flow.user u on u.id = pd.setter_user_id
                    inner join flow.org o on (o.id = up.org_id and o.active_flag is true)
                    left join flow.organization_custom_field_value ocfv on ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                    left join flow.list_of_value lov on ocfv.int_value = lov.id
                where pd.source in (525, 526) --(Setter Gen, Retargeted)
                    and case when up.end_date is not null
                        then ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between up.start_date and up.end_date
                        else ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= up.start_date
                        end
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
                    and o.id != 171 --Setter Call Center
                    and pd.company_id = 3
                group by o.id, concat(o.org_name, ' (', lov.name, ')')
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
