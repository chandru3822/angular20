drop function if exists brs.get_top_setter_reps(p_limit bigint, p_time_interval character varying, p_days bigint,
                                                p_run_by_id bigint);
drop function if exists brs.get_top_setter_reps(p_start_date date, p_end_date date, p_limit bigint);
drop function if exists brs.get_top_setter_reps(p_user_id bigint, p_start_date date, p_end_date date, p_limit bigint);
-- DROP FUNCTION brs.get_top_setter_reps(int8, date, date, int8);

CREATE OR REPLACE FUNCTION brs.get_top_setter_reps(
  p_user_id bigint,
  p_start_date date,
  p_end_date date,
  p_limit bigint
)
RETURNS TABLE (
  user_id integer,
  name text,
  pitches bigint,
  rank text,
  show_first boolean
)
LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  WITH top_reps AS (
      SELECT
          pd.setter_user_id AS user_id,
          CONCAT(u.first_name, ' ', u.last_name) AS name,
          COUNT(*) AS pitches,
          RANK() OVER (ORDER BY COUNT(*) DESC) AS rank
      FROM brs.project_details pd
      INNER JOIN flow.user u ON u.id = pd.setter_user_id
      WHERE pd.source IN (525, 526)
        AND ((pd.prioritized_closer_appointment_outcome_date AT TIME ZONE 'UTC') AT TIME ZONE 'US/Mountain')::date
            BETWEEN p_start_date AND p_end_date
        AND pd.prioritized_closer_appointment_outcome IN (2, 3, 1139, 1140)
        AND pd.setter_user_id NOT IN (2354810, 2390159)
        AND pd.company_id = 3
      GROUP BY pd.setter_user_id, u.first_name, u.last_name
  ),
  ranked_reps AS (
      SELECT
          tr.user_id,
          tr.name,
          tr.pitches,
          CASE
              WHEN tr.rank = LAG(tr.rank) OVER (ORDER BY tr.rank)
                OR tr.rank = LEAD(tr.rank) OVER (ORDER BY tr.rank)
              THEN 'T' || tr.rank
              ELSE tr.rank::text
          END AS rank,
          tr.rank AS raw_rank
      FROM top_reps tr
  ),
  top_n AS (
      SELECT * FROM ranked_reps
      ORDER BY raw_rank
      LIMIT p_limit
  ),
  top_n_with_flag AS (
      SELECT
          tn.user_id,
          tn.name,
          tn.pitches,
          tn.rank,
          tn.raw_rank,
          CASE WHEN tn.user_id = p_user_id THEN true ELSE false END AS show_first
      FROM top_n tn
  ),
  user_not_in_top AS (
      SELECT
          rr.user_id,
          rr.name,
          rr.pitches,
          rr.rank,
          rr.raw_rank,
          true AS show_first
      FROM ranked_reps rr
      WHERE rr.user_id = p_user_id
        AND rr.user_id NOT IN (SELECT user_id FROM top_n)
  )
  SELECT
      result.user_id,
      result.name,
      result.pitches,
      result.rank,
      result.show_first
  FROM (
      SELECT * FROM user_not_in_top
      UNION ALL
      SELECT * FROM top_n_with_flag
  ) result


END;
$function$;
