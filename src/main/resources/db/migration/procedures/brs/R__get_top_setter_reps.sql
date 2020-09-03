-- SELECT * FROM brs.get_top_setter_reps(10, 30);

CREATE OR REPLACE FUNCTION brs.get_top_setter_reps(p_limit integer, p_days integer DEFAULT 30)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY
    with top_reps as (
      select u.id as user_id,
             u.first_name || ' ' || u.last_name as name,
             count(1) pitches,
             rank() over (order by count(1) desc) as rank
      from flow.project p
        inner join brs.project_details pd on pd.project_id = p.id
        inner join flow.contact c on c.id = p.contact_id
        inner join flow.user_positions_vw upv on (upv.user_position_id = c.owner_user_position_id and upv.position_id = 4)
        inner join flow.user u on u.id = upv.user_id
        inner join flow.user_status_type ust on ust.user_id = u.id
        inner join flow.company_user_status_type cust on cust.id = ust.company_user_status_type_id
        left join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 2
        left join flow.project_process_step_custom_field_value closer_appointment_outcome on closer_appointment_outcome.project_process_step_id = pps.id and closer_appointment_outcome.custom_field_group_assignment_id = 4
      where cust.user_status_type = 'Active'
        and pd.closer_appointment_start between ((now() at time zone 'US/Mountain')::date) - p_days and ((now() at time zone 'US/Mountain')::date)
        and closer_appointment_outcome.text_value in ('Pitched', 'Missed')
        and u.id not in (2354810, 2390159) --Trizon and Central Solar
      group by u.id, name
    )
    select array_to_json(array_agg(row_to_json(sub_rows)))
    from (
      select top_reps.user_id,
             top_reps.name,
             coalesce(top_reps.pitches, 0) as pitches,
             (case when (
                  top_reps.rank = lag(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank) or
                  top_reps.rank = lead(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank)
                )
                then 'T' || top_reps.rank
                else top_reps.rank::text
                end
             ) as rank
      from top_reps
      order by pitches desc, user_id
      limit p_limit
    ) as sub_rows;

END
$function$
