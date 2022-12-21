drop function if exists brs.get_monthly_cost_average_without_solar(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_estimated_annual_consumption numeric,
  p_number_of_months bigint,
  p_years bigint);
CREATE OR REPLACE FUNCTION brs.get_monthly_cost_average_without_solar(
  p_khw_rate numeric,
  p_utility_cost_escalator numeric,
  p_estimated_annual_consumption numeric,
  p_number_of_months bigint,
  p_years bigint)
  returns numeric
AS
$BODY$
declare
  v_amount       numeric;
BEGIN
  v_amount = 0;
  FOR i IN 1..p_years LOOP
      v_amount = v_amount + (p_khw_rate * power((1+ p_utility_cost_escalator),i-1) * p_estimated_annual_consumption)/p_number_of_months;
  end loop;

  insert into flow.company_function_log(function_name, parameters)
  values ('Get Monthly Cost Average Without Solar', 'p_khw_rate: ' || p_khw_rate ||
                                                    ' p_utility_cost_escalator: ' || p_utility_cost_escalator ||
                                                    ' p_estimated_annual_consumption: ' || p_estimated_annual_consumption ||
                                                    ' p_number_of_months: ' || p_number_of_months ||
                                                    ' p_years: ' || p_years);

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


