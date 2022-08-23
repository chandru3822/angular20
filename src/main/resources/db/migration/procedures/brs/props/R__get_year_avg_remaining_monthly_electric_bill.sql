drop function if exists brs.get_year_avg_remaining_monthly_electric_bill(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_adjusted_annual_consumption numeric,
  p_first_year_annual_production numeric,
  p_panel_degradation_factor numeric,
  p_years bigint);
CREATE OR REPLACE FUNCTION brs.get_year_avg_remaining_monthly_electric_bill(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_adjusted_annual_consumption numeric,
  p_first_year_annual_production numeric,
  p_panel_degradation_factor numeric,
  p_years bigint)
  returns numeric
AS
$BODY$
declare
  v_amount       numeric;
BEGIN
  v_amount = 0;
--   raise notice 'p_khw_rate ******** %',p_khw_rate;
--   raise notice 'p_utility_cost_escalator ******** %',p_utility_cost_escalator;
--   raise notice 'p_adjusted_annual_consumption ******** %',p_adjusted_annual_consumption;
--   raise notice 'p_first_year_annual_production ******** %',p_first_year_annual_production;
--   raise notice 'p_panel_degradation_factor ******** %',p_panel_degradation_factor;
--   raise notice 'p_years ******** %',p_years;
  FOR i IN 1..p_years LOOP
      v_amount = v_amount + ((p_khw_rate * power((1 + p_utility_cost_escalator),i-1) *
                              greatest(p_adjusted_annual_consumption - (p_first_year_annual_production *
                                                              (power(1-p_panel_degradation_factor,i-1))),0))/case when p_years = 25 then 300 else 360 end);
--      raise notice 'v_amount ******** %',v_amount;
    end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


