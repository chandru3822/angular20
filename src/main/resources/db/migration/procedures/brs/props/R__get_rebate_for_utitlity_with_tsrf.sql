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
  v_size                          numeric;
  v_panel_count                   bigint;
  v_face                          bigint;
  v_multiple_plane_rebate_amount  numeric;
  v_single_plane_rebate_amount    numeric;
BEGIN
  create temp table calculations
  (
    panel_count                   integer,
    total_solar_resource_fraction numeric,
    face                          integer,
    size                          numeric
  ) ;
  v_value = 0;
  for x in SELECT jsonb_array_elements::jsonb FROM jsonb_array_elements(p_aurora_design_summary -> 'arrays')
    loop
      v_total_solar_resource_fraction = (x::jsonb -> 'shading' -> 'total_solar_resource_fraction' -> 'annual');
      v_size = (x::jsonb -> 'size');
      v_panel_count = (x::jsonb -> 'module' -> 'count')::bigint;
      v_face = x::jsonb -> 'face';
      insert into calculations(panel_count, total_solar_resource_fraction, face, size)
      values (v_panel_count, round(v_total_solar_resource_fraction,1), v_face, v_size);
    end loop;

  with multiple_faces as (select face
                          from calculations
                          group by face
                          having count(1) > 1)
  select sum(size) * p_rebate_rate
  into v_multiple_plane_rebate_amount
  from (select fraction / count as total_solar_resource_fraction, count as panel_count, size as size
        from (select sum(panel_count * total_solar_resource_fraction) fraction,
                     sum(panel_count)                                 count,
                     sum(size) as                                     size
              from calculations mc
                     inner join multiple_faces mf on mf.face = mc.face group by mc.face) as foo) as foo1
  where foo1.total_solar_resource_fraction > p_minimum_tsrf;

  with single_faces as (select face
                        from calculations
                        group by face
                        having count(1) = 1)
  select sum(size) * p_rebate_rate
  into v_single_plane_rebate_amount
  from (select sum(panel_count) as panel_count, sum(size) as size
        from calculations mc
               inner join single_faces mf on mf.face = mc.face
        where total_solar_resource_fraction > p_minimum_tsrf
        group by mc.face) as foo;
  v_value = coalesce(v_multiple_plane_rebate_amount, 0) + coalesce(v_single_plane_rebate_amount, 0);

  --   if v_total_solar_resource_fraction > p_minimum_tsrf then
--     v_value = v_value + (v_size * p_rebate_rate);
--   end if;

  v_value = least(v_value, p_rebate_cap_dollar_amount);

  drop table if exists calculations;
  return v_value;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




