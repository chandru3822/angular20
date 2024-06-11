drop function if exists brs.get_appointment_count(p_closer_user_id bigint);
drop function if exists brs.get_appointment_count(p_closer_user_id bigint,p_date date);
CREATE OR REPLACE FUNCTION brs.get_appointment_count(p_closer_user_id bigint,p_date date)
  RETURNS table
          (

            closer_user_id    bigint,
            appointment_count bigint
          )
AS
$BODY$
declare
  v_current_day date;
  v_week_start  date;
BEGIN

  raise notice 'p_date %',p_date;

  SELECT date_trunc('week', p_date::date)::date + 6                          AS current_day,
         date_trunc('week', p_date)::date AS week_start
  into v_current_day,
    v_week_start;

  --raise notice 'v_current_day %',v_current_day;
  --raise notice 'v_week_start %',v_week_start;
  return query
    select pd2.closer_user_id::bigint, count(pd2.id)
    from brs.project_details pd2
    where pd2.closer_user_id = p_closer_user_id
      and pd2.first_appointment between v_week_start and v_current_day
      and (first_appointment_id is null or first_appointment_id not in (4, 16685, 15327))
      and round_robin_used = true
      and brs.check_project_zipcode(pd2.project_id) is true
    group by pd2.closer_user_id;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;






