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
                                                               p_cash_price_storage numeric,
                                                               p_minimum_tsrf bigint);
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
                                                                   p_cash_price_storage numeric,
                                                                   p_minimum_tsrf bigint)
  returns numeric AS
$BODY$
declare
  x                               jsonb;
  v_panel_count                   bigint;
  v_total_solar_resource_fraction numeric;
  v_value                         numeric;
  v_plane_rebate_amount           numeric;
  v_face                          integer;
  v_multiple_plane_rebate_amount  numeric;
  v_single_plane_rebate_amount    numeric;
BEGIN
  create temp table calculations
  (
    panel_count                   integer,
    total_solar_resource_fraction numeric,
    face                          integer
  );

  if p_system_size > p_system_size_cutoff then
    v_value = 0.00::numeric;
    v_single_plane_rebate_amount = 0.00::numeric;
    v_multiple_plane_rebate_amount = 0.00::numeric;
    for x in SELECT jsonb_array_elements::jsonb
             FROM jsonb_array_elements(p_aurora_design_summary -> 'arrays')
             order by jsonb_array_elements -> 'face'
      loop
        v_face = x::jsonb -> 'face';
        --raise notice 'this is the face %',v_face;
        v_total_solar_resource_fraction = (x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual');
        --raise notice 'v_total_solar_resource_fraction = %',x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual';
        v_panel_count = (x::jsonb -> 'module' -> 'count')::bigint;
        -- raise notice 'v_count = %',x::jsonb -> 'module' -> 'count';
        insert into calculations(panel_count, total_solar_resource_fraction, face)
        values (v_panel_count,round(v_total_solar_resource_fraction,0), v_face);
      end loop;

    with multiple_faces as (select face
                            from calculations
                            group by face
                            having count(1) > 1)
    select sum(panel_count) * p_panel_wattage * p_rebate_rate
    into v_multiple_plane_rebate_amount
    from (select fraction / count as total_solar_resource_fraction, count as panel_count
          from (select sum(panel_count * total_solar_resource_fraction) fraction, sum(panel_count) count
                from calculations mc
                       inner join multiple_faces mf on mf.face = mc.face group by mc.face) as foo) as foo1
    where foo1.total_solar_resource_fraction >= p_minimum_tsrf;

    with single_faces as (select face
                          from calculations
                          group by face
                          having count(1) = 1)
    select sum(panel_count) * p_panel_wattage * p_rebate_rate
    into v_single_plane_rebate_amount
    from (select sum(panel_count) as panel_count
          from calculations mc
                 inner join single_faces mf on mf.face = mc.face
          where total_solar_resource_fraction >= p_minimum_tsrf group by mc.face) as foo;
    v_plane_rebate_amount = coalesce(v_multiple_plane_rebate_amount, 0) + coalesce(v_single_plane_rebate_amount, 0);

   -- raise notice 'v_plane_rebate_amount %',v_plane_rebate_amount;

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
  drop table if exists calculations;
  return coalesce(v_value, 0);


END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




