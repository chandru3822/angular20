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
  v_kwh_rate numeric;
  v_grid_reliance numeric;
  v_annual_cost numeric;
  v_monthly_cost numeric;
  v_average_monthly_cost numeric;

BEGIN
--   insert into flow.company_function_log(function_name, parameters)
--   values ('Get Year Average Remaining Monthly Electric Bill', 'p_khw_rate: ' || p_khw_rate ||
--                                                               ' p_utility_cost_escalator: ' || p_utility_cost_escalator ||
--                                                               ' p_adjusted_annual_consumption: ' || p_adjusted_annual_consumption ||
--                                                               ' p_first_year_annual_production: ' || p_first_year_annual_production ||
--                                                               ' p_panel_degradation_factor: ' || p_panel_degradation_factor ||
--                                                               ' p_years: ' || p_years);
  v_amount = 0;
--   raise notice 'p_khw_rate ******** %',p_khw_rate;
--   raise notice 'p_utility_cost_escalator ******** %',p_utility_cost_escalator;
--   raise notice 'p_adjusted_annual_consumption ******** %',p_adjusted_annual_consumption;
--   raise notice 'p_first_year_annual_production ******** %',p_first_year_annual_production;
--   raise notice 'p_panel_degradation_factor ******** %',p_panel_degradation_factor;
--   raise notice 'p_years ******** %',p_years;
  FOR i IN 1..p_years LOOP

      v_kwh_rate = p_khw_rate * power((1 + p_utility_cost_escalator),i-1);
      v_grid_reliance = p_adjusted_annual_consumption  - (p_first_year_annual_production *
                                                                     (power(1-p_panel_degradation_factor,i-1)));

   --   raise notice 'kwh_rate ******** %',v_kwh_rate;
   --   raise notice 'grid_reliance ******** %',v_grid_reliance;
      v_annual_cost = v_kwh_rate*v_grid_reliance;

   --   raise notice 'v_annual_cost ******** %',v_annual_cost;

      v_monthly_cost = v_annual_cost /12;
   --   raise notice 'v_monthly_cost ******** %',v_monthly_cost;

      v_average_monthly_cost = v_monthly_cost/p_years;
   --   raise notice 'v_average ******** %',v_average_monthly_cost;

      v_amount = coalesce(v_amount,0) +v_average_monthly_cost;
      --raise notice 'v_amount ******** %',v_amount;
    end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


