DROP FUNCTION IF EXISTS brs.get_proposal_commission_details(p_financial_product_id bigint,
                                                            p_source_id bigint,
                                                            p_system_size numeric,
                                                            p_unapproved_zip_code_adder numeric,
                                                            p_red_line_funding_amount numeric,
                                                            p_closer_gen_discount numeric,
                                                            p_equipment_panel_adder numeric,
                                                            p_equipment_inverter_adder numeric,
                                                            p_zone_adder numeric,
                                                            p_misc_adders numeric,
                                                            p_small_system_size_adder_amount numeric,
                                                            p_dealer_fee numeric,
                                                            p_initial_payment_factor numeric,
                                                            p_above_line_rebate numeric);
CREATE OR REPLACE FUNCTION brs.get_proposal_commission_details(p_financial_product_id bigint,
                                                               p_source_id bigint,
                                                               p_system_size numeric,
                                                               p_unapproved_zip_code_adder numeric,
                                                               p_red_line_funding_amount numeric,
                                                               p_closer_gen_discount numeric,
                                                               p_equipment_panel_adder numeric,
                                                               p_equipment_inverter_adder numeric,
                                                               p_zone_adder numeric,
                                                               p_misc_adders numeric,
                                                               p_small_system_size_adder_amount numeric,
                                                               p_dealer_fee numeric,
                                                               p_initial_payment_factor numeric,
                                                               p_above_line_rebate numeric)
  returns table
          (
            redline_amount           numeric,
            source_discount          numeric,
            adders_dollar_watts      numeric,
            base_price               numeric,
            commissions_dollar_watts numeric,
            total_ppw                numeric,
            system_size              numeric,
            cash_price               numeric,
            loan_amount              numeric,
            monthly_payment          numeric,
            commission_kw            numeric,
            total_commissions        numeric,
            above_line_rebate        numeric
          )

AS
$BODY$
declare
  v_commission_watt                       numeric = .10;
  v_closer_gen_discount                   numeric;
  v_total_price_per_watt_before_promotion numeric;
  v_promotion_cost                        numeric;
  v_adders_dollars_per_watt               numeric;
  v_base_price                            numeric;
  v_total_price_per_watt                  numeric;
  v_cash_price                            numeric;
  v_loan_amount                           numeric;
  v_monthly_payment                       numeric;
  v_commission_dollars_per_kw             numeric;
  v_total_commissions                     numeric;
  x                                       record;
BEGIN

  -- current monthly payment ----  current estimated consumption(on proposal) / 12 * kwr(proposal Pricing)

  create temp table proposal_details
  (
    redline_amount           numeric,
    source_discount          numeric,
    adders_dollar_watts      numeric,
    base_price               numeric,
    commissions_dollar_watts numeric,
    total_ppw                numeric,
    system_size              numeric,
    cash_price               numeric,
    loan_amount              numeric,
    monthly_payment          numeric,
    commission_kw            numeric,
    total_commissions        numeric,
    above_line_rebate        numeric
  ) on commit drop;

  v_closer_gen_discount = p_closer_gen_discount;
  if p_source_id not in (523, 524) or p_source_id is null then
    v_closer_gen_discount = 0::numeric;
  end if;

  while v_commission_watt <= 1.00
    loop
      v_total_price_per_watt_before_promotion = 0::numeric;
      v_promotion_cost = 0::numeric;
      v_adders_dollars_per_watt = 0::numeric;
      v_base_price = 0::numeric;
      v_total_price_per_watt = 0::numeric;
      v_cash_price = 0::numeric;
      v_loan_amount = 0::numeric;
      v_monthly_payment = 0::numeric;
      v_commission_dollars_per_kw = 0::numeric;
      v_total_commissions = 0::numeric;

      v_total_price_per_watt_before_promotion =
            p_red_line_funding_amount - v_closer_gen_discount + ((coalesce(p_unapproved_zip_code_adder, 0) +
                                                                  coalesce(p_equipment_panel_adder, 0) +
                                                                  coalesce(p_equipment_inverter_adder, 0) +
                                                                  coalesce(p_zone_adder, 0) +
                                                                  coalesce(p_misc_adders, 0) +
                                                                  coalesce(p_small_system_size_adder_amount, 0)) /
                                                                 (p_system_size * 1000)) + (v_commission_watt / .68);
      if p_financial_product_id = 293 then
        v_promotion_cost =
            (v_total_price_per_watt_before_promotion * p_system_size * 1000 * p_initial_payment_factor * 18) /
            (1 - p_dealer_fee - (p_initial_payment_factor * 18));
      end if;

      v_adders_dollars_per_watt = (coalesce(p_unapproved_zip_code_adder, 0) +
                                   coalesce(p_equipment_panel_adder, 0) +
                                   coalesce(p_equipment_inverter_adder, 0) +
                                   coalesce(p_zone_adder, 0) +
                                   coalesce(p_misc_adders, 0) +
                                   coalesce(p_small_system_size_adder_amount, 0) +
                                   coalesce(v_promotion_cost, 0)) / (p_system_size * 1000);

      v_base_price = p_red_line_funding_amount - v_closer_gen_discount + v_adders_dollars_per_watt;
      v_total_price_per_watt = v_total_price_per_watt_before_promotion + v_promotion_cost / (p_system_size * 1000);
      v_cash_price = v_total_price_per_watt * p_system_size * 1000;
      v_loan_amount = (v_cash_price - p_above_line_rebate) / (1 - p_dealer_fee);
      v_monthly_payment = v_loan_amount * p_initial_payment_factor;
      v_commission_dollars_per_kw = v_commission_watt * 1000;
      v_total_commissions = v_commission_dollars_per_kw * p_system_size;


--       raise notice 'v_commission_watt %',v_commission_watt;
--       raise notice 'v_total_price_per_watt_before_promotion %',v_total_price_per_watt_before_promotion;
--       raise notice 'v_promotion_cost %',v_promotion_cost;
--       raise notice 'v_adders_dollars_per_watt %',v_adders_dollars_per_watt;
--       raise notice 'v_base_price %',v_base_price;
--       raise notice 'v_total_price_per_watt %',v_total_price_per_watt;
--       raise notice 'v_cash_price %',v_cash_price;
--       raise notice 'v_loan_amount %',v_loan_amount;
--       raise notice 'v_monthly_payment %',v_monthly_payment;
--       raise notice 'v_commission_dollars_per_kw %',v_commission_dollars_per_kw;
--       raise notice 'v_total_commissions %',v_total_commissions;

      insert into proposal_details(redline_amount,
                                   source_discount,
                                   adders_dollar_watts,
                                   base_price,
                                   commissions_dollar_watts,
                                   total_ppw,
                                   system_size,
                                   cash_price,
                                   loan_amount,
                                   monthly_payment,
                                   commission_kw,
                                   total_commissions,
                                   above_line_rebate)
      values (coalesce(p_red_line_funding_amount,0),
              coalesce(v_closer_gen_discount,0),
              round(coalesce(v_adders_dollars_per_watt,0), 4),
              round(coalesce(v_base_price,0), 4),
              coalesce(v_commission_watt,0),
              round(coalesce(v_total_price_per_watt,0), 4),
              p_system_size,
              round(coalesce(v_cash_price,0)),
              round(coalesce(v_loan_amount,0)),
              round(coalesce(v_monthly_payment,0)),
              coalesce(v_commission_dollars_per_kw,0),
              coalesce(v_total_commissions,0),
              coalesce(p_above_line_rebate,0));

      v_commission_watt = v_commission_watt + .10;
    end loop;

  return query
    select *
    from proposal_details;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
