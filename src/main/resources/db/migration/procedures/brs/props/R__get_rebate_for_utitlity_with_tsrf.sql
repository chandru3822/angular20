drop function if exists brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary jsonb,
                                                             p_system_size numeric,
                                                             p_rebate_cap_dollar_amount numeric,
                                                             p_rebate_rate numeric,
                                                             p_minimum_tsrf bigint);
CREATE OR REPLACE FUNCTION brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary jsonb,
                                                                p_system_size numeric,
                                                                p_rebate_cap_dollar_amount numeric,
                                                                p_rebate_rate numeric,
                                                                p_minimum_tsrf bigint)
  returns numeric AS
$BODY$
declare
  x                               jsonb;
  v_total_solar_resource_fraction numeric;
  v_value                         numeric;
  v_found_tsrf                    boolean default false;
BEGIN
  v_found_tsrf = false;
  v_value = 0;
  for x in SELECT jsonb_array_elements::jsonb FROM jsonb_array_elements(p_aurora_design_summary -> 'arrays')
    loop
      v_total_solar_resource_fraction = (x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual');
      if v_total_solar_resource_fraction > p_minimum_tsrf and v_found_tsrf = false then
        v_found_tsrf = true;
      end if;

    end loop;
  if v_found_tsrf = true then
    v_value = least(p_rebate_cap_dollar_amount, p_system_size * p_rebate_rate * 1000);
  end if;

  return v_value;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




