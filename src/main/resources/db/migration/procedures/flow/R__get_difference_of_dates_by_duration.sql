CREATE OR REPLACE FUNCTION flow.get_difference_of_dates_by_duration(p_end_date timestamp, p_start_date timestamp,
                                                                   p_duration_type_id integer)
  RETURNS NUMERIC AS
$BODY$
declare
  v_numeric_value numeric;
BEGIN

  if p_duration_type_id = 2 then

    select EXTRACT(EPOCH FROM ((p_end_date - p_start_date))) / 3600
    into v_numeric_value;
  elsif p_duration_type_id = 1 then
    select date_part('Days',
                     (p_end_date - p_start_date))
    into v_numeric_value;
  elsif p_duration_type_id = 3 then
    select date_part('Days',
                     (p_end_date - p_start_date)) / 7
    into v_numeric_value;
  elsif p_duration_type_id = 4 then
    select EXTRACT(EPOCH FROM ((p_end_date - p_start_date)))
    into v_numeric_value;
  end if;

  return v_numeric_value;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
