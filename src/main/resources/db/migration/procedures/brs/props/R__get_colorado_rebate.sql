drop function if exists brs.get_colorado_rebate(p_aurora_design_summary jsonb,p_rebate_amount numeric,p_inverter_efficiency numeric);
CREATE OR REPLACE FUNCTION brs.get_colorado_rebate(p_aurora_design_summary jsonb,p_rebate_amount numeric,p_inverter_efficiency numeric)
    returns numeric AS
$BODY$
declare
  x jsonb;
  v_tilt bigint;
  v_azimuth bigint;
  v_percent_value numeric;
  v_size numeric;
  v_annual numeric;
  v_col_springs_rebate numeric;
BEGIN
      insert into flow.company_function_log(function_name, parameters)
      values ('Get Colorado Rebate', 'p_aurora_design_summary: ' || p_aurora_design_summary ||
                                     ' p_rebate_amount: ' || p_rebate_amount ||
                                     ' p_inverter_efficiency: ' || p_inverter_efficiency);
      raise notice 'p_rebate_amount %',p_rebate_amount;
      raise notice 'p_inverter_efficiency %',p_inverter_efficiency;
      v_col_springs_rebate = 0.00;
        for x  in SELECT jsonb_array_elements::jsonb FROM jsonb_array_elements(p_aurora_design_summary->'arrays')
          loop
            v_tilt = null;
            v_azimuth = null;
            v_tilt = (x::jsonb->'pitch')::bigint;
            v_azimuth = (x::jsonb->'azimuth')::bigint;
            v_size = (x::jsonb->'size')::bigint;
            v_annual = (x::jsonb->'shading'->'solar_access'->'annual')::numeric;
            select percent_value
            into v_percent_value
            from brs.colorado_springs_rebate_factor
              where azimuth = v_azimuth and tilt = v_tilt;

            raise notice 'v_percent_value = %',v_percent_value;
            raise notice 'pitch = %',x::jsonb->'pitch';
            raise notice 'azimuth = %',x::jsonb->'azimuth';
            raise notice 'size = %',x::jsonb->'size';
            raise notice 'annual = %',x::jsonb->'shading'->'solar_access'->'annual';

            v_col_springs_rebate = v_col_springs_rebate + (v_size * v_annual * v_percent_value * p_inverter_efficiency * p_rebate_amount);
            raise notice 'v_col_springs_rebate inside loop = %',v_col_springs_rebate;
          end loop;
      raise notice 'v_col_springs_rebate outside loop = %',v_col_springs_rebate;
  return v_col_springs_rebate;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
