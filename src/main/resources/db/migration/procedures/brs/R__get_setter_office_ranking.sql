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
               total_pitches,
               (case when total_appointments = 0 then 0
                    else ((total_pitches::numeric(10,2) / total_appointments) * 100)::integer
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
                concat(o.org_name, ' (', lov.name, ')') as org,
                (select count(1)::bigint
                 from flow.project p2
                     inner join brs.project_details pd2 on pd2.project_id = p2.id
                     inner join flow.contact c2 on c2.id = p2.contact_id
                     inner join flow.user_position up2 on (up2.user_id = pd2.setter_user_id and up2.primary_flag is true and up2.position_id in (select unnest(string_to_array(value, ',')::int[])
                                                                                                        from flow.company_configuration_value
                                                                                                        where code = 'SETTER_POSITION_IDS'))
                     inner join flow.org o2 on (o2.id = up2.org_id and o2.active_flag is true)
                 where pd2.source in (525, 526) --(Setter Gen, Retargeted)
                     and case when up2.end_date is not null
                         then ((p2.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between up2.start_date and up2.end_date
                         else ((p2.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= up2.start_date
                         end
                     and (((case when pd2.first_appointment_pitched is not null
                                     then pd2.first_appointment_pitched
                                 when pd2.first_appointment_pitched is null
                                     and pd2.first_appointment_missed is not null
                                     then pd2.first_appointment_missed
                                 when pd2.first_appointment_pitched is null
                                     and pd2.first_appointment_missed is null
                                     and pd2.first_appointment_not_pitched_or_missed is not null
                                     then pd2.first_appointment_not_pitched_or_missed
                                 when pd2.first_appointment_pitched is null
                                     and pd2.first_appointment_missed is null
                                     and pd2.first_appointment_not_pitched_or_missed is null
                                     and pd2.first_appointment is not null
                                     then pd2.first_appointment
                                 else pd2.closer_appointment_start
                                 end) at time zone 'UTC') at time zone 'US/Mountain') :: date between ((now() at time zone 'US/Mountain')::date - p_days) and ((now() at time zone 'US/Mountain')::date)
                     and ((pd2.cancelled_date is null) or (pd2.cancelled_date is not null and pd2.cancelled_date > (now() at time zone 'US/Mountain')::date))
                     and o2.id = o.id
                     and pd2.company_id = 3
                ) as total_appointments,
                count(1)::bigint as total_pitches,
                rank() over (order by count(1) desc) as rank
            from flow.project p
                inner join brs.project_details pd on pd.project_id = p.id
                inner join flow.contact c on c.id = p.contact_id
                inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id in (select unnest(string_to_array(value, ',')::int[])
                                                                                                        from flow.company_configuration_value
                                                                                                        where code = 'SETTER_POSITION_IDS') and up.archived is not true)
                inner join flow.org o on (o.id = up.org_id and o.active_flag is true)
                left join flow.organization_custom_field_value ocfv on ocfv.org_id = o.id
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
                            end) at time zone 'UTC') at time zone 'US/Mountain') :: date between ((now() at time zone 'US/Mountain')::date - p_days) and ((now() at time zone 'US/Mountain')::date)
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
            limit p_limit
        ) as t
        order by total_pitches desc, org_id
    ) as sub_rows;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
