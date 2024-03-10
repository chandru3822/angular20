DROP FUNCTION IF EXISTS brs.get_proposal_commission_details(p_product_id bigint,
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
drop function if exists brs.get_proposal_commission_details(p_proposal_id bigint,
                                                            p_product_id bigint,
                                                            p_financial_product_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_commission_details(p_proposal_id bigint,
                                                               p_product_id bigint,
                                                               p_financial_product_id bigint)
  returns table
          (
            redline_amount                   numeric,
            source_discount                  numeric,
            adders_dollar_watts              numeric,
            base_price                       numeric,
            commissions_dollar_watts         numeric,
            total_ppw                        numeric,
            system_size                      numeric,
            cash_price                       numeric,
            loan_amount                      numeric,
            monthly_payment                  numeric,
            commission_kw                    numeric,
            total_commissions                numeric,
            above_line_rebate                numeric,
            recommended                      boolean,
            monthly_cost_today_without_solar varchar,
            apr                             numeric,
            loan_term                        numeric
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
  v_recommended_option                    boolean;
  x                                       record;
  v_version_id                            bigint;
  v_dealer_fee                            numeric;
  v_source_id                             bigint;
  v_system_size                           numeric;
  v_unapproved_zip_code_adder             numeric;
  v_red_line_funding_amount               numeric;
  v_equipment_panel_adder                 numeric;
  v_equipment_inverter_adder              numeric;
  v_zone_adder                            numeric;
  v_misc_adders                           numeric;
  v_small_system_size_adder_amount        numeric;
  v_initial_payment_factor                numeric;
  v_above_line_rebate                     numeric;
  v_monthly_cost_today_without_solar      varchar;
  v_apr                                   numeric;
  v_loan_term                             numeric;
BEGIN

  select t.version_id,
         t.system_size,
         t.unapproved_zip_code_adder,
         t.red_line_funding_amount,
         t.closer_gen_discount,
         t.equipment_panel_adder,
         t.equipment_inverter_adder,
         t.zone_adder,
         t.misc_adders,
         t.small_system_size_adder_amount,
         t.initial_payment_factor,
         t.above_line_rebate,
         t.monthly_cost_today_without_solar
  into v_version_id,v_system_size,v_unapproved_zip_code_adder,v_red_line_funding_amount,v_closer_gen_discount,
    v_equipment_panel_adder,v_equipment_inverter_adder,v_zone_adder,v_misc_adders,v_small_system_size_adder_amount,
    v_initial_payment_factor,v_above_line_rebate,v_monthly_cost_today_without_solar
  from brs.get_calculated_proposal_values(p_proposal_id, false) as t;

  select p.dealer_fee,p.apr,p.loan_term
  into v_dealer_fee,v_apr,v_loan_term
  from brs.get_proposal_finance_products(v_version_id, p_financial_product_id) as p;

  select source_id
  into v_source_id
  from brs.get_proposal_details(p_proposal_id);

  -- current monthly payment ----  current estimated consumption(on proposal) / 12 * kwr(proposal Pricing)

  create temp table proposal_details
  (
    redline_amount                   numeric,
    source_discount                  numeric,
    adders_dollar_watts              numeric,
    base_price                       numeric,
    commissions_dollar_watts         numeric,
    total_ppw                        numeric,
    system_size                      numeric,
    cash_price                       numeric,
    loan_amount                      numeric,
    monthly_payment                  numeric,
    commission_kw                    numeric,
    total_commissions                numeric,
    above_line_rebate                numeric,
    recommended                      boolean,
    monthly_cost_today_without_solar varchar,
    apr                              numeric,
    loan_term                        numeric
  ) on commit drop;

  if v_source_id not in (523, 524) or v_source_id is null then
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
        v_red_line_funding_amount - v_closer_gen_discount + ((coalesce(v_unapproved_zip_code_adder, 0) +
                                                              coalesce(v_equipment_panel_adder, 0) +
                                                              coalesce(v_equipment_inverter_adder, 0) +
                                                              coalesce(v_zone_adder, 0) +
                                                              coalesce(v_misc_adders, 0) +
                                                              coalesce(v_small_system_size_adder_amount, 0)) /
                                                             (v_system_size * 1000)) + (v_commission_watt / .68);
      if p_product_id = 293 then
        v_promotion_cost =
          (v_total_price_per_watt_before_promotion * v_system_size * 1000 * v_initial_payment_factor * 18) /
          (1 - v_dealer_fee - (v_initial_payment_factor * 18));
      end if;

      v_adders_dollars_per_watt = (coalesce(v_unapproved_zip_code_adder, 0) +
                                   coalesce(v_equipment_panel_adder, 0) +
                                   coalesce(v_equipment_inverter_adder, 0) +
                                   coalesce(v_zone_adder, 0) +
                                   coalesce(v_misc_adders, 0) +
                                   coalesce(v_small_system_size_adder_amount, 0) +
                                   coalesce(v_promotion_cost, 0)) / (v_system_size * 1000);

      v_base_price = v_red_line_funding_amount - v_closer_gen_discount + v_adders_dollars_per_watt;
      v_total_price_per_watt = v_total_price_per_watt_before_promotion + v_promotion_cost / (v_system_size * 1000);
      v_cash_price = v_total_price_per_watt * v_system_size * 1000;
      v_loan_amount = (v_cash_price - v_above_line_rebate) / (1 - v_dealer_fee);
      v_monthly_payment = v_loan_amount * v_initial_payment_factor;
      v_commission_dollars_per_kw = v_commission_watt * 1000;
      v_total_commissions = v_commission_dollars_per_kw * v_system_size;


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

      --for now BR wants the recommended option to be the one where the commission in $/kW is 400. but they want to be able to configure that later.
      v_recommended_option = (coalesce(v_commission_dollars_per_kw, 0) = 400);

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
                                   above_line_rebate,
                                   recommended,
                                   monthly_cost_today_without_solar,
                                   apr,
                                   loan_term)
      values (coalesce(v_red_line_funding_amount, 0),
              coalesce(v_closer_gen_discount, 0),
              round(coalesce(v_adders_dollars_per_watt, 0), 4),
              round(coalesce(v_base_price, 0), 4),
              coalesce(v_commission_watt, 0),
              round(coalesce(v_total_price_per_watt, 0), 4),
              v_system_size,
              round(coalesce(v_cash_price, 0)),
              round(coalesce(v_loan_amount, 0)),
              round(coalesce(v_monthly_payment, 0)),
              coalesce(v_commission_dollars_per_kw, 0),
              coalesce(v_total_commissions, 0),
              coalesce(v_above_line_rebate, 0),
              v_recommended_option,
              v_monthly_cost_today_without_solar,
              v_apr,
              v_loan_term);

      v_commission_watt = v_commission_watt + .10;
    end loop;

  return query
    select *
    from proposal_details;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
