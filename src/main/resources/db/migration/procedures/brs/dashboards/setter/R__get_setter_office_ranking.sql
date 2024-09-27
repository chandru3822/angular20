drop function if exists brs.get_setter_office_ranking(p_limit bigint, p_time_interval character varying, p_days bigint,
                                                      p_run_by_id bigint);
drop function if exists brs.get_setter_office_ranking(p_start_date date, p_end_date date, p_limit bigint);
CREATE OR REPLACE FUNCTION brs.get_setter_office_ranking(p_start_date date, p_end_date date, p_limit bigint)
  RETURNS table
          (
            org_id             bigint,
            org                character varying,
            total_appointments bigint,
            total_pitches      bigint,
            pitch_percentage   bigint,
            rank               text
          )
AS
$BODY$
declare
BEGIN
  RETURN QUERY
    select t.org_id,
           t.org,
           coalesce(t.total_appointments, 0) as total_appointments,
           coalesce(t.total_pitches, 0)      as total_pitches,
           (case
              when t.total_appointments = 0 then 0
              else ((coalesce(t.total_pitches, 0)::numeric(10, 2) / t.total_appointments) * 100)::bigint
             end
             )                               as pitch_percentage,
           (case
              when (
                t.rank = lag(t.rank, 1, -1::bigint) over (order by t.rank) or
                t.rank = lead(t.rank, 1, -1::bigint) over (order by t.rank)
                ) then 'T' || t.rank
              else t.rank::text
             end
             )                               as rank
    from (select o.id                                    as org_id,
                 case when lov.name is not null then
                 concat(o.org_name, ' (', lov.name, ')')
                   else o.org_name end as org,
                 (select count(1)::bigint
                  from brs.project_details pd2
                         inner join flow.user_position up2 on up2.id = pd2.setter_user_position_id
                         inner join flow.org o2
                                    on (o2.id = up2.org_id or o2.id = coalesce(up2.sales_org_id, 0::bigint))
                  where pd2.source in (525, 526)
                    and ((pd2.first_time_appointment_created at time zone 'UTC') at time zone
                         'US/Mountain') :: date between p_start_date and p_end_date
                    and o2.id = o.id
                    and pd2.company_id = 3)              as total_appointments,
                 count(1)::bigint                        as total_pitches,
                 rank() over (order by count(1) desc)    as rank
          from brs.project_details pd
                 inner join flow.user_position up on up.id = pd.setter_user_position_id
                 inner join flow.org o
                            on (o.id = up.org_id or o.id = coalesce(up.sales_org_id, 0::bigint))
                 left join flow.organization_custom_field_value ocfv
                           on ocfv.org_id = o.id and ocfv.custom_field_group_assignment_id = 19097
                 left join flow.list_of_value lov on ocfv.int_value = lov.id
          where pd.source in (525, 526)
            and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone
                 'US/Mountain') :: date between p_start_date and p_end_date
            and pd.prioritized_closer_appointment_outcome in (2, 3, 1139, 1140)
            and o.id != 171 --Setter Call Center
            and pd.company_id = 3
          group by o.id, case when lov.name is not null then
                                concat(o.org_name, ' (', lov.name, ')')
                              else o.org_name end
          limit p_limit) as t
    order by total_pitches desc, org_id;


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
