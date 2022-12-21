drop function if exists brs.get_year_savings_by_years(p_khw_rate numeric, p_utility_cost_escalator numeric, p_estimated_annual_consumption numeric, p_first_year_annual_production numeric, p_panel_degradation_factor numeric, p_monthly_solar_payment numeric, p_loan_term numeric, p_cash_down_payment numeric, p_years integer);
create or replace function brs.get_year_savings_by_years(p_khw_rate numeric, p_utility_cost_escalator numeric, p_estimated_annual_consumption numeric, p_first_year_annual_production numeric, p_panel_degradation_factor numeric, p_monthly_solar_payment numeric, p_loan_term numeric, p_cash_down_payment numeric, p_years integer) returns numeric
  language plpgsql
as
$$
declare
  v_amount       numeric;
BEGIN
  v_amount = 0;
  FOR i IN 1..p_years LOOP
      v_amount = v_amount +(((p_khw_rate * power((1 + p_utility_cost_escalator),i-1)) * p_estimated_annual_consumption) -
                            ((p_khw_rate * power((1 + p_utility_cost_escalator),i-1)) *
                             greatest(p_estimated_annual_consumption- (p_first_year_annual_production *
                                                                       (power(1-p_panel_degradation_factor,i-1))),0)));

    end loop;

  insert into flow.company_function_log(function_name, parameters)
  values ('Get Year Savings for Years', 'p_khw_rate: ' || p_khw_rate ||
                                        ' p_utility_cost_escalator: ' || p_utility_cost_escalator ||
                                        ' p_estimated_annual_consumption: ' || p_estimated_annual_consumption ||
                                        ' p_first_year_annual_production: ' || p_first_year_annual_production ||
                                        ' p_panel_degradation_factor: ' || p_panel_degradation_factor ||
                                        ' p_monthly_solar_payment: ' || p_monthly_solar_payment ||
                                        ' p_loan_term: ' || p_loan_term ||
                                        ' p_cash_down_payment: ' || p_cash_down_payment ||
                                        ' p_years: ' || p_years);

  return coalesce(v_amount  + (p_monthly_solar_payment * 12 * p_loan_term) -p_cash_down_payment, 0);
END
$$;


