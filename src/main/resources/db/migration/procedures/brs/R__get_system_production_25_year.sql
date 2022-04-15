 drop function if exists  brs.get_system_production_25_year(
   p_first_year_annual_production numeric,
   p_panel_degradation_factor numeric,
   p_years integer);
CREATE OR REPLACE FUNCTION brs.get_system_production_25_year(
  p_first_year_annual_production numeric,
  p_panel_degradation_factor numeric,
  p_years integer)
  returns numeric
AS
$BODY$
declare
  v_amount       numeric;
BEGIN
  v_amount = 0;
  FOR i IN 1..p_years LOOP
      v_amount = v_amount + (p_first_year_annual_production * power((1- p_panel_degradation_factor),i-1));
  end loop;

  return coalesce(v_amount, 0);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
--ROWS 1000;


