drop function if exists brs.get_below_the_line_state_rebates(p_version_id bigint, p_state_id bigint,
                                                             p_system_size numeric,
                                                             p_total_system_cost numeric);
CREATE OR REPLACE FUNCTION brs.get_below_the_line_state_rebates(p_version_id bigint, p_state_id bigint,
                                                                p_system_size numeric,
                                                                p_total_system_cost numeric)
  returns table
          (
            below_the_line_state_rebate_amount                numeric,
            below_the_line_state_rebate_first_year_cap_amount numeric,
            rebates                                           jsonb
          )
AS
$BODY$
declare
  v_state_rebate_amount                        numeric;
  v_below_the_line_state_rebate_amount         numeric;
  v_rebates                                    jsonb;
  x                                            record;
  v_below_the_line_state_rebate_first_year_cap numeric;
BEGIN

  for x in
    select rebate_amount,
           unit_type_id,
           rebate_cap_amount,
           rebate_cap_percent_of_total,
           max_amount_captured_first_year,
           first_year_cap_on_rebate,
           rebate
    from brs.get_proposal_rebates(p_version_id)
    where state_id = p_state_id
      and rebate_type_id = 454
      and rebate_applied_at = 1763
    loop
      v_state_rebate_amount = 0::numeric;

      select brs.get_amount_by_unit_type(p_system_size, 'PROPOSAL_REBATE',
                                         x.rebate_amount::numeric, x.unit_type_id::bigint,
                                         (coalesce(p_total_system_cost, 0)),
                                         null,
                                         null)
      into v_state_rebate_amount;

      if x.rebate_cap_amount is not null then
        v_state_rebate_amount = least(v_state_rebate_amount::numeric, x.rebate_cap_amount::numeric);
      elsif x.rebate_cap_percent_of_total is not null then
        v_state_rebate_amount =
          least(v_state_rebate_amount, x.rebate_cap_percent_of_total * p_total_system_cost);
      end if;


      if x.first_year_cap_on_rebate is not null and x.first_year_cap_on_rebate = 462 then
        v_below_the_line_state_rebate_first_year_cap =
            coalesce(v_below_the_line_state_rebate_first_year_cap, 0) +
            least(coalesce(v_state_rebate_amount, 0), x.max_amount_captured_first_year);
      end if;
      v_below_the_line_state_rebate_amount =
          coalesce(v_below_the_line_state_rebate_amount, 0) + coalesce(v_state_rebate_amount, 0);
      v_rebates = COALESCE(v_rebates, '{}'::jsonb) || jsonb_build_object(x.rebate, round(v_state_rebate_amount,2));
    end loop;
  return query select coalesce(round(v_below_the_line_state_rebate_amount,2), 0),
                      coalesce(round(v_below_the_line_state_rebate_first_year_cap,2), 0),
                      COALESCE(v_rebates, '{}'::jsonb);
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;




