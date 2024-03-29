drop function if exists brs.get_above_the_line_utility_rebates(p_version_id bigint, p_utility_company_id bigint,
                                                               p_aurora_design_summary jsonb, p_system_size numeric,
                                                               p_total_system_cost_before_rebates numeric,
                                                               p_state_id bigint);
drop function if exists brs.get_above_the_line_utility_rebates(p_version_id bigint, p_utility_company_id bigint,
                                                               p_aurora_design_summary jsonb, p_system_size numeric,
                                                               p_total_system_cost_before_rebates numeric,
                                                               p_state_id bigint,
                                                               p_storage_capacity numeric);
drop function if exists brs.get_above_the_line_utility_rebates(p_version_id bigint, p_utility_company_id bigint,
                                                               p_aurora_design_summary jsonb, p_system_size numeric,
                                                               p_total_system_cost_before_rebates numeric,
                                                               p_state_id bigint, p_rebate_id bigint[],
                                                               p_storage_capacity numeric);
CREATE OR REPLACE FUNCTION brs.get_above_the_line_utility_rebates(p_version_id bigint, p_utility_company_id bigint,
                                                                  p_aurora_design_summary jsonb, p_system_size numeric,
                                                                  p_total_system_cost_before_rebates numeric,
                                                                  p_state_id bigint, p_rebate_id bigint[],
                                                                  p_storage_capacity numeric)
  returns table
          (
            above_the_line_utility_rebate_amount numeric,
            rebates                              jsonb,
            eto_rebate_amount                    numeric
          )
AS
$BODY$
declare
  v_rebates                      jsonb;
  x                              record;
  v_utility_rebate_amount        numeric;
  v_above_the_line_rebate_amount numeric;
  v_eto_rebate_amount            numeric;
BEGIN
  for x in select rebate_amount,
                  unit_type_id,
                  rebate_cap_amount,
                  rebate_cap_percent_of_total,
                  minimum_tsrf_for_qualification,
                  rebate,
                  rebate_id,
                  odoe_battery_rebate_amount,
                  odoe_battery_rebate_cap_amount
           from brs.get_proposal_rebates(p_version_id)
           where rebate_type_id = 455
             and rebate_applied_at = 1762
             and ((p_rebate_id is not null and
                   selectable_by_user is true and
                   rebate_id = any (p_rebate_id)
             and utility_company_id = p_utility_company_id
             and case
                   when state_id is not null then
                     state_id = p_state_id
                   else 1 = 1 end) or
                  (utility_company_id = p_utility_company_id
                    and (selectable_by_user is null or selectable_by_user is false)
                    and case
                          when state_id is not null then
                            state_id = p_state_id
                          else 1 = 1 end))

    loop
      v_utility_rebate_amount = 0::numeric;
      --       raise notice 'above the line minimum_tsrf_for_qualification = %',x.minimum_tsrf_for_qualification;
--       raise notice 'above the line rebate_amount = % ',x.rebate_amount;
--       raise notice 'above the line rebate_cap_amount = % ',x.rebate_cap_amount;
--       raise notice 'above the line rebate_cap_percent_of_total = % ',x.rebate_cap_percent_of_total;
--       raise notice ' above the lin erebate = % ',x.rebate;

      if x.minimum_tsrf_for_qualification is not null then
        select *
        into v_utility_rebate_amount
        from brs.get_rebate_for_utility_with_tsrf(p_aurora_design_summary,
                                                  x.rebate_cap_amount,
                                                  x.rebate_amount,
                                                  x.minimum_tsrf_for_qualification,
                                                  x.unit_type_id);
      else
        select brs.get_amount_by_unit_type(p_system_size, 'PROPOSAL_REBATE',
                                           x.rebate_amount::numeric, x.unit_type_id::bigint,
                                           (coalesce(p_total_system_cost_before_rebates, 0)),
                                           null,
                                           null)
        into v_utility_rebate_amount;

        if x.rebate_cap_amount is not null then
          v_utility_rebate_amount = least(v_utility_rebate_amount::numeric, x.rebate_cap_amount::numeric);
        elsif x.rebate_cap_percent_of_total is not null then
          v_utility_rebate_amount =
            least(v_utility_rebate_amount, x.rebate_cap_percent_of_total * p_total_system_cost_before_rebates);
        end if;
      end if;
      if x.odoe_battery_rebate_amount is not null and x.odoe_battery_rebate_amount > 0 then
        v_utility_rebate_amount = v_utility_rebate_amount +
                                  least(
                                    (coalesce(p_storage_capacity, 0) * x.odoe_battery_rebate_amount * 1000)::numeric,
                                    x.odoe_battery_rebate_cap_amount);
      end if;
      --raise notice 'above the line v_utility_rebate_amount = %',v_utility_rebate_amount;
      v_above_the_line_rebate_amount =
        coalesce(v_above_the_line_rebate_amount, 0) + coalesce(v_utility_rebate_amount, 0);
      v_rebates = COALESCE(v_rebates, '{}'::jsonb) || jsonb_build_object(x.rebate, round(v_utility_rebate_amount, 2));
      if x.rebate_id = 451 then
        v_eto_rebate_amount = coalesce(v_eto_rebate_amount, 0) + coalesce(v_utility_rebate_amount, 0);
      end if;

    end loop;
  return query select coalesce(v_above_the_line_rebate_amount, 0),
                      COALESCE(v_rebates, '{}'::jsonb),
                      v_eto_rebate_amount;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
