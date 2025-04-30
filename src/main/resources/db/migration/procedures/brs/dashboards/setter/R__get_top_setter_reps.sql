drop function if exists brs.get_top_setter_reps(p_limit bigint, p_time_interval character varying, p_days bigint,
                                                p_run_by_id bigint);
drop function if exists brs.get_top_setter_reps(p_start_date date, p_end_date date, p_limit bigint);
drop function if exists brs.get_top_setter_reps(p_user_id bigint, p_start_date date, p_end_date date, p_limit bigint);
CREATE OR REPLACE FUNCTION brs.get_top_setter_reps(p_user_id bigint, p_start_date date, p_end_date date, p_limit bigint)
  RETURNS table
          (
            user_id    integer,
            name       text,
            pitches    bigint,
            rank       text,
            show_first boolean
          )
  LANGUAGE plpgsql
AS
$function$
BEGIN

  return query
    with top_reps as (select pd.setter_user_id                      as user_id,
                             concat(u.first_name, ' ', u.last_name) AS name,
                             count(1)                                  pitches,
                             rank() over (order by count(1) desc)   as rank
                      from brs.project_details pd
                             inner join flow.user u on u.id = pd.setter_user_id
                      where pd.source in (525, 526)
                        and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone
                             'US/Mountain') :: date between p_start_date and p_end_date
                        and pd.prioritized_closer_appointment_outcome in (2, 3, 1139, 1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                        and pd.setter_user_id not in (2354810, 2390159)                     --Trizon and Central Solar
                        and pd.company_id = 3
                      group by 1, 2)
    select *
    from (select top_reps.user_id,
                 top_reps.name,
                 coalesce(top_reps.pitches, 0) as pitches,
                 (case
                    when (
                      top_reps.rank = lag(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank) or
                      top_reps.rank = lead(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank)
                      )
                      then 'T' || top_reps.rank
                    else top_reps.rank::text
                   end
                   )                           as rank,
                 true
          from top_reps
          order by pitches desc, user_id) as foo
    where foo.user_id = p_user_id;

  RETURN QUERY
    with top_reps as (select pd.setter_user_id                      as user_id,
                             concat(u.first_name, ' ', u.last_name) AS name,
                             count(1)                                  pitches,
                             rank() over (order by count(1) desc)   as rank
                      from brs.project_details pd
                             inner join flow.user u on u.id = pd.setter_user_id
                             INNER JOIN flow.company_user_status cus on cus.user_id = u.id
                             INNER JOIN flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                      where pd.source in (525, 526)
                        and ((prioritized_closer_appointment_outcome_date at time zone 'UTC') at time zone
                             'US/Mountain') :: date between p_start_date and p_end_date
                        and pd.prioritized_closer_appointment_outcome in (2, 3, 1139, 1140) --(Pitched, Missed, Pitched - Proposal Not Shown, Pitched - Proposal Shown)
                        and pd.setter_user_id not in (2354810, 2390159)                     --Trizon and Central Solar
                        and pd.company_id = 3
                        and ust.user_status_type = 'Active'
                      group by 1, 2)
    select top_reps.user_id,
           top_reps.name,
           coalesce(top_reps.pitches, 0) as pitches,
           (case
              when (
                top_reps.rank = lag(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank) or
                top_reps.rank = lead(top_reps.rank, 1, -1::bigint) over (order by top_reps.rank)
                )
                then 'T' || top_reps.rank
              else top_reps.rank::text
             end
             )                           as rank,
           false
    from top_reps
    order by pitches desc, user_id
    limit p_limit;


END
$function$
