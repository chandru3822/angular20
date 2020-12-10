-- SELECT * FROM brs.get_top_setter_offices(10, 30);

CREATE OR REPLACE FUNCTION brs.get_top_setter_offices(p_limit integer, p_days integer DEFAULT 30)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY
    with top_orgs as (
      select o.id as org_id,
             concat(o.org_name, ' (', lov.name, ')') as org,
             count(1) pitches,
             rank() over (order by count(1) desc) as rank
      from flow.project p
        inner join brs.project_details pd on pd.project_id = p.id
        inner join flow.contact c on c.id = p.contact_id
        inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id = 4)
        inner join flow.org o on (o.id = up.org_id and o.active_flag is true)
        left join flow.organization_custom_field_value ocfv on ocfv.org_id = o.id
        left join flow.list_of_value lov on ocfv.int_value = lov.id
      where pd.source in (525, 526) --(Setter Gen, Retargeted)
            and case when up.end_date is not null
              then ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date between up.start_date and up.end_date
              else ((p.date_created at time zone 'UTC') at time zone 'US/Mountain') :: date >= up.start_date
              end
        and (((pd.closer_appointment_start at time zone 'UTC') at time zone 'US/Mountain') :: date) between ((now() at time zone 'US/Mountain')::date - p_days) and ((now() at time zone 'US/Mountain')::date)
        and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
        and o.id != 171 --Setter Call Center
        and pd.company_id = 3
      group by o.id, concat(o.org_name, ' (', lov.name, ')')
    )
    select array_to_json(array_agg(row_to_json(sub_rows)))
    from (
      select top_orgs.org_id,
             top_orgs.org as name,
             coalesce(top_orgs.pitches, 0) as pitches,
             (case when (
                  top_orgs.rank = lag(top_orgs.rank, 1, -1::bigint) over (order by top_orgs.rank) or
                  top_orgs.rank = lead(top_orgs.rank, 1, -1::bigint) over (order by top_orgs.rank)
                )
                then 'T' || top_orgs.rank
                else top_orgs.rank::text
                end
             ) as rank
             from top_orgs
             order by pitches desc, org_id
             limit p_limit
    ) as sub_rows;

END
$function$
