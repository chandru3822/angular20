drop function if exists brs.get_rebate_for_standard_low_income(p_aurora_design_summary jsonb,
                                                               p_system_size numeric,
                                                               p_rebate_cap_dollar_amount numeric,
                                                               p_rebate_cap_percentage_of_total numeric,
                                                               p_total_system_cost_before_rebates numeric,
                                                               p_panel_wattage numeric,
                                                               p_rebate_rate numeric,
                                                               p_system_size_cutoff numeric,
                                                               p_number_of_batteries numeric,
                                                               p_battery_rebate_cap_percent_of_total numeric,
                                                               p_battery_rebate_cap_amount numeric,
                                                               p_battery_rebate_amount numeric,
                                                               p_cash_price_storage numeric);
CREATE OR REPLACE FUNCTION brs.get_rebate_for_standard_low_income(p_aurora_design_summary jsonb,
                                                                  p_system_size numeric,
                                                                  p_rebate_cap_dollar_amount numeric,
                                                                  p_rebate_cap_percentage_of_total numeric,
                                                                  p_total_system_cost_before_rebates numeric,
                                                                  p_panel_wattage numeric,
                                                                  p_rebate_rate numeric,
                                                                  p_system_size_cutoff numeric,
                                                                  p_number_of_batteries numeric,
                                                                  p_battery_rebate_cap_percent_of_total numeric,
                                                                  p_battery_rebate_cap_amount numeric,
                                                                  p_battery_rebate_amount numeric,
                                                                  p_cash_price_storage numeric)
  returns numeric AS
$BODY$
declare
  x                               jsonb;
  v_panel_count                   bigint;
  v_total_solar_resource_fraction numeric;
  v_value                         numeric;
  v_plane_rebate_amount           numeric;
BEGIN
  if p_system_size > p_system_size_cutoff then
    v_value = 0.00::numeric;
    for x in SELECT jsonb_array_elements::jsonb FROM jsonb_array_elements(p_aurora_design_summary -> 'arrays')
      loop
        v_total_solar_resource_fraction = (x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual');
        --raise notice 'v_total_solar_resource_fraction = %',x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual';
          v_panel_count = (x::jsonb -> 'module' -> 'count')::bigint;
          --raise notice 'v_count = %',x::jsonb -> 'module' -> 'count';
        if v_total_solar_resource_fraction > 80 then
          v_plane_rebate_amount = coalesce(v_plane_rebate_amount,0) + (v_panel_count * p_panel_wattage * p_rebate_rate);
        end if;

      end loop;
    if v_plane_rebate_amount is not null then
    v_value = least(p_rebate_cap_dollar_amount,
                    (p_total_system_cost_before_rebates * p_rebate_cap_percentage_of_total),
                    v_plane_rebate_amount);
    else
      v_value = 0.00::numeric;
    end if;

    if p_number_of_batteries > 0 then
      v_value = coalesce(v_value, 0) +
                least(p_battery_rebate_cap_amount, (p_cash_price_storage * p_battery_rebate_cap_percent_of_total),
                      (p_system_size * 1000) * p_battery_rebate_amount);
    end if;
  end if;
  return coalesce(v_value, 0);

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




