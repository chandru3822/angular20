drop function if exists brs.get_monthly_cost_25_year_average_without_solar(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_estimated_annual_consumption numeric);
CREATE OR REPLACE FUNCTION brs.get_monthly_cost_25_year_average_without_solar(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_estimated_annual_consumption numeric)
  returns numeric
AS
$BODY$
declare
  v_amount       numeric;
BEGIN
  v_amount = 0;
  FOR i IN 1..25 LOOP
      v_amount = v_amount + (p_khw_rate * power((1+ p_utility_cost_escalator),i-1) * p_estimated_annual_consumption)/300;
  end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


