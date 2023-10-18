drop function if exists brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary jsonb,
                                                             p_system_size numeric,
                                                             p_rebate_cap_dollar_amount numeric,
                                                             p_rebate_rate numeric,
                                                             p_minimum_tsrf bigint);
drop function if exists brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary jsonb,
                                                             p_rebate_cap_dollar_amount numeric,
                                                             p_rebate_rate numeric,
                                                             p_minimum_tsrf bigint);
CREATE OR REPLACE FUNCTION brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary jsonb,
                                                                p_rebate_cap_dollar_amount numeric,
                                                                p_rebate_rate numeric,
                                                                p_minimum_tsrf bigint)
  returns numeric AS
$BODY$
declare
  x                               jsonb;
  v_total_solar_resource_fraction numeric;
  v_value                         numeric;
  v_size numeric;
BEGIN

  v_value = 0;
  for x in SELECT jsonb_array_elements::jsonb FROM jsonb_array_elements(p_aurora_design_summary -> 'arrays')
    loop
      v_total_solar_resource_fraction = (x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual');
      v_size  = (x::jsonb -> 'size');
      if v_total_solar_resource_fraction > p_minimum_tsrf then
        v_value = v_value + (v_size * p_rebate_rate);
      end if;

    end loop;

    v_value = least(v_value,p_rebate_cap_dollar_amount);


  return v_value;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




