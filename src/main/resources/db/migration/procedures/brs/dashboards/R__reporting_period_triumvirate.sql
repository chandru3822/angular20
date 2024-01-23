drop function if exists brs.reporting_period_triumvirate(p_today_date date);
CREATE OR REPLACE FUNCTION brs.reporting_period_triumvirate(p_today_date date)
    RETURNS TABLE
            (
                current_period_start date,
                current_period_end date,
                last_period_start date,
                last_period_end date,
                penultimate_period_start date,
                penultimate_period_end date,
                current_quarter_start date,
                current_quarter_end date,
                last_quarter_start date,
                last_quarter_end date,
                penultimate_quarter_start date,
                penultimate_quarter_end date
            )
  LANGUAGE plpgsql
AS
$function$
declare
  v_current_period_start date;
  v_current_period_end date;
  v_last_period_start date;
  v_last_period_end date;
  v_penultimate_period_start date;
  v_penultimate_period_end date;

  v_current_quarter_start date;
  v_current_quarter_end date;
  v_last_quarter_start date;
  v_last_quarter_end date;
  v_penultimate_quarter_start date;
  v_penultimate_quarter_end date;

  x record;
  v_count int = 1;
BEGIN

--populate the periods
    for x in
        select min(start_date) AS start_date,
               max(end_date) AS end_date
        from brs.reporting_period
        where start_date >= p_today_date::date - '6 months'::interval
          AND start_date <= p_today_date::date
        GROUP BY year, period
        ORDER BY start_date desc
        limit 3
    loop
        if(v_count = 1) then
            v_current_period_start = x.start_date;
            v_current_period_end = x.end_date;
        elsif(v_count = 2) then
            v_last_period_start = x.start_date;
            v_last_period_end = x.end_date;
        elsif(v_count = 3) then
            v_penultimate_period_start = x.start_date;
            v_penultimate_period_end = x.end_date;
        end if;

        v_count = v_count + 1;

    end loop;

--populate quarter data
    v_count = 1;

for x in
    select min(start_date) AS start_date,
           max(end_date) AS end_date
    from brs.reporting_period
    where start_date >= p_today_date::date - '12 months'::interval
      AND start_date <= p_today_date::date
    GROUP BY year, quarter
    ORDER BY start_date desc
    limit 3
    loop
        if(v_count = 1) then
            v_current_quarter_start = x.start_date;
            v_current_quarter_end = x.end_date;
        elsif(v_count = 2) then
            v_last_quarter_start = x.start_date;
            v_last_quarter_end = x.end_date;
        elsif(v_count = 3) then
            v_penultimate_quarter_start = x.start_date;
            v_penultimate_quarter_end = x.end_date;
        end if;

        v_count = v_count + 1;

    end loop;

    return query
        select
            v_current_period_start,
            v_current_period_end,
            v_last_period_start,
            v_last_period_end,
            v_penultimate_period_start,
            v_penultimate_period_end,
            v_current_quarter_start,
            v_current_quarter_end,
            v_last_quarter_start,
            v_last_quarter_end,
            v_penultimate_quarter_start,
            v_penultimate_quarter_end;


END
$function$
