-- SELECT * FROM brs.get_top_setter_offices(10, 30);

CREATE OR REPLACE FUNCTION brs.get_top_setter_offices(p_limit integer, p_days integer DEFAULT 30)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY
    with top_orgs as (
      select o.id as org_id,
             concat(o.org_name, ' (', metro_area.metro_area, ')') as org,
             count(1) pitches,
             rank() over (order by count(1) desc) as rank
      from flow.project p
        inner join brs.project_details pd on pd.project_id = p.id
        inner join flow.contact c on c.id = p.contact_id
        inner join flow.user_positions_vw upv on (upv.user_position_id = c.owner_user_position_id and upv.position_id = 4)
        inner join flow.user u on u.id = upv.user_id
        inner join flow.company_user_status cus on cus.user_id = u.id
        inner join flow.user_status_type ust on ust.id = cus.user_status_type_id
        inner join flow.org o on (o.id = upv.org_id and o.active_flag is true)
        left join lateral (select * from flow.get_value_for_custom_field(5, 185, p.id, 0, false) as metro_area) metro_area on true
      where case when upv.end_date is not null
              then p.date_created::date between upv.start_date and upv.end_date
              else p.date_created::date >= upv.start_date
              end
        and upv.primary_flag is true
        and upv.position_level = 0
        and pd.closer_appointment_start between ((now() at time zone 'US/Mountain')::date) - p_days and ((now() at time zone 'US/Mountain')::date)
        and pd.closer_appointment_outcome in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
        and o.id != 171
      group by o.id, concat(o.org_name, ' (', metro_area.metro_area, ')')
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
