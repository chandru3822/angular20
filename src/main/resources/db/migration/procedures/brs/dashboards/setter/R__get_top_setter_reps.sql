-- SELECT * FROM brs.get_top_setter_reps(10, 30);
drop function if exists brs.get_top_setter_reps(p_limit bigint, p_time_interval character varying, p_days bigint, p_run_by_id bigint);
  CREATE OR REPLACE FUNCTION brs.get_top_setter_reps(p_limit bigint, p_time_interval character varying, p_days bigint DEFAULT 3, p_run_by_id bigint default 99999999)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS $function$
BEGIN

  RETURN QUERY
    with top_reps as (
      select pd.setter_user_id as user_id,
             concat(u.first_name, ' ', u.last_name) AS name,
             count(1) pitches,
             rank() over (order by count(1) desc) as rank
      from flow.project p
        inner join brs.project_details pd on pd.project_id = p.id
        inner join flow.contact c on c.id = p.contact_id
        inner join flow.user_position up on (up.user_id = pd.setter_user_id and up.primary_flag is true and up.position_id in (select unnest(string_to_array(value, ',')::bigint[])
                                                                                                                               from flow.company_configuration_value
                                                                                                                               where code = 'SETTER_POSITION_IDS') and up.archived is not true)
        inner join flow.user u on u.id = pd.setter_user_id
      where (((case when pd.first_appointment_pitched is not null
                        then pd.first_appointment_pitched
                    when pd.first_appointment_pitched is null
                        and pd.first_appointment_missed is not null
                        then pd.first_appointment_missed
                    else pd.closer_appointment_start
--                     end) at time zone 'UTC') at time zone 'US/Mountain') :: date between ((now() at time zone 'US/Mountain')::date) - p_days and ((now() at time zone 'US/Mountain')::date)
                                                                                                                                    --this is weird but it says "If they want to see counts from YESTERDAY (aka p_days = 1) then dont include today/now)
                       end) at time zone 'UTC') at time zone 'US/Mountain') :: date between ((now() at time zone 'US/Mountain')::date) - p_days::integer and (case when p_time_interval = 'Yesterday' then ((now() at time zone 'US/Mountain')::date) - p_days::integer else (now() at time zone 'US/Mountain')::date end)
        and (case when pd.first_appointment_pitched is not null
                      then pd.first_appointment_pitched_id in (2,3,1139,1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                  when pd.first_appointment_pitched is null
                      and pd.first_appointment_missed is not null
                      then pd.first_appointment_missed_id in (2,3,1139,1140)
                  else pd.closer_appointment_outcome in (2,3,1139,1140)
                  end)
        and pd.setter_user_id not in (2354810, 2390159) --Trizon and Central Solar
        and pd.company_id = 3
      group by pd.setter_user_id, name
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

insert into flow.company_function_log(function_name, parameters, run_by_id)
values ('Get Top Setter Reps', 'p_limit: ' || p_limit ||
                               ' p_time_interval: ' || p_time_interval ||
                               ' p_days: ' || p_days ||
                               ' p_run_by_id: ' || p_run_by_id,
        p_run_by_id);

END
$function$
