DROP FUNCTION IF EXISTS brs.get_proposal_commission_details(p_proposal_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_commission_details(p_proposal_id bigint)
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
            total_commissions        numeric
          )

AS
$BODY$
declare
  v_commission_watt                                numeric = .10;
  v_version_id                                     bigint;
  v_utility_company_id                             bigint;
  v_project_process_step_id                        bigint;
  v_red_line_funding_amount                        numeric;
  v_closer_gen_discount                            numeric;
  v_source_id                                      bigint;
  v_system_size                                    numeric;
  v_unapproved_zip_code_adder                      numeric;
  v_panel_brand_id                                 bigint;
  v_equipment_panel_adder                          numeric;
  v_panel_watts                                    bigint;
  v_panel_adder_amount                             numeric;
  v_panel_unit_type_id                             bigint;
  v_panel_states                                   bigint[];
  v_panel_degradation_factor                       numeric;
  v_state_id                                       bigint;
  v_inverter_efficiency                            numeric;
  v_inverter_unit_type_id                          bigint;
  v_inverter_adder_amount                          numeric;
  v_inverter_brand_id                              bigint;
  v_equipment_inverter_adder                       numeric;
  v_postal_code                                    character varying;
  v_postal_adder_amount                            numeric;
  v_misc_adders_array                              bigint[];
  v_misc_adders                                    numeric;
  v_small_system_size_adder                        numeric;
  v_small_system_size_value                        numeric;
  v_small_system_size_unit_type_id                 bigint;
  v_small_system_size_adder_amount                 numeric;
  v_total_price_per_watt_before_promotion          numeric;
  v_promotion_cost                                 numeric;
  v_financial_product_id                           bigint;
  v_apr                                            numeric;
  v_financial_option                               character varying;
  v_reamortized_payment_factor_without_itc_paydown numeric;
  v_loan_term                                      numeric;
  v_dealer_fee                                     numeric;
  v_reamortization_factor                          numeric;
  v_financier_id                                   numeric;
  v_financier                                      character varying;
  v_initial_payment_factor                         numeric;
  v_adders_dollars_per_watt                        numeric;
  v_base_price                                     numeric;
  v_total_price_per_watt                           numeric;
  v_cash_price                                     numeric;
  v_loan_amount                                    numeric;
  v_monthly_payment                                numeric;
  v_commission_dollars_per_kw                      numeric;
  v_total_commissions                              numeric;
  x                                                record;
BEGIN
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
    total_commissions        numeric
  ) on commit drop;

  select prop.proposal_version_id, project_process_step_id,p.postal_code, pcfv17.int_value
  into v_version_id,v_project_process_step_id,v_postal_code,v_financial_product_id
  from brs.proposal prop
         inner join flow.project_process_step pps on prop.project_process_step_id = pps.id
         inner join flow.project p on pps.project_id = p.id
         left join brs.proposal_custom_field_value pcfv17 on prop.id = pcfv17.proposal_id and
                                                             pcfv17.custom_field_group_assignment_id = 155
  where prop.id = p_proposal_id;

  v_postal_code = substring(v_postal_code, 1, 5);

  select
         ppscfv15.int_value,
         pd.source,
         ppscfv3.numeric_value,
         pd.unapproved_zip_code_adder,
         ppscfv5.int_value,
         ppscfv4.int_value,
         cs.state_id,
         ppscfv10.int_value,
         ppscfv13.int_array_value
  into
    v_utility_company_id,
    v_source_id,
    v_system_size,
    v_unapproved_zip_code_adder,
    v_panel_brand_id,
    v_panel_watts,
    v_state_id,
    v_inverter_brand_id,
    v_misc_adders_array
  from flow.project_process_step pps
         inner join brs.project_details d on d.project_id = pps.project_id
         inner join flow.project p on pps.project_id = p.id
         inner join flow.company_state cs on p.company_state_id = cs.id
         inner join brs.project_details pd on pd.project_id = p.id
         left join flow.project_process_step_custom_field_value ppscfv15
                   on ppscfv15.project_process_step_id = pps.id and
                      ppscfv15.custom_field_group_assignment_id = 23802
         left join flow.project_process_step_custom_field_value ppscfv3 on ppscfv3.project_process_step_id = pps.id and
                                                                           ppscfv3.custom_field_group_assignment_id = 22561
         left join flow.project_process_step_custom_field_value ppscfv5 on ppscfv5.project_process_step_id = pps.id and
                                                                           ppscfv5.custom_field_group_assignment_id = 22564
         left join flow.project_process_step_custom_field_value ppscfv4 on ppscfv4.project_process_step_id = pps.id and
                                                                           ppscfv4.custom_field_group_assignment_id = 22675
         left join flow.project_process_step_custom_field_value ppscfv10 on ppscfv10.project_process_step_id = pps.id and
                                                                            ppscfv10.custom_field_group_assignment_id = 22565
         left join flow.project_process_step_custom_field_value ppscfv13 on ppscfv13.project_process_step_id = pps.id and
                                                                            ppscfv13.custom_field_group_assignment_id = 25981
  where pps.id = v_project_process_step_id;


  select
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 147)') ->>
--           'value')::numeric                                                                                      as instant_use_assumption,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 92)') ->>
--           'value')::numeric                                                                                      as net_metring_rate,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 88)') ->>
--           'value')::numeric                                                                                      as production_factor_east_west,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 89)') ->>
--           'value')::numeric                                                                                      as production_factor_south,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 90)') ->>
--           'value')::numeric                                                                                      as maximum_funding_amount_per_watt,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 91)') ->>
--           'value')::numeric                                                                                      as minimum_funding_amount_per_watt,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 87)') ->>
--           'value')::numeric                                                                                      as current_estimated_cost_per_kwh,
--          (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 94)') ->>
--           'value')::numeric                                                                                      as utility_cost_escalator,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 380)') ->>
          'value')::numeric                                                                                      as red_line_funding_amount,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 381)') ->>
          'value')::numeric                                                                                      as closer_gen_discount
  into v_red_line_funding_amount,v_closer_gen_discount
  from brs.get_proposal_version_value(v_version_id, array [(85, null, v_utility_company_id, null)::ProposalFieldFilter],
                                      'PROPOSAL_PRICING');



  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 136)') ->> 'value')::numeric  as panel_degradation_factor,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as adder_amount,
         ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 341)') ->
                                                 'intArrayValue')))::bigint[]              as states

  into v_panel_degradation_factor,v_panel_unit_type_id,v_panel_adder_amount,v_panel_states
  from brs.get_proposal_version_value(v_version_id, array [(138, null, v_panel_brand_id, null)::ProposalFieldFilter,(139, null, v_panel_watts, null)::ProposalFieldFilter],
                                      'PROPOSAL_PANEL_DETAIL');

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_PANEL_DETAIL', v_panel_adder_amount::numeric,
                                     v_panel_unit_type_id::bigint, 0::numeric, v_panel_states, v_state_id)
  into v_equipment_panel_adder;


  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 142)') ->> 'value')::numeric  as inverter_efficiency,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as adder_amount
  into v_inverter_efficiency,v_inverter_unit_type_id,v_inverter_adder_amount
  from brs.get_proposal_version_value(v_version_id, array [(131, null, v_inverter_brand_id, null)::ProposalFieldFilter],
                                      'PROPOSAL_INVERTER_DETAILS');

  select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_INVERTER_DETAILS', v_inverter_adder_amount::numeric,
                                     v_inverter_unit_type_id::bigint, 0::numeric, null, null)
  into v_equipment_inverter_adder;


  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric as postal_adder_amount
  into v_postal_adder_amount
  from brs.get_proposal_version_value(v_version_id, array [(122, v_postal_code, null, null)::ProposalFieldFilter],
                                      'PROPOSAL_ZONE_ADDERS');


  for x in
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::integer as unit_type_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as adder_amount,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 329)') ->> 'value')::boolean   as default_value,
           (SELECT ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 126)') ->>
                                                           'intArrayValue')::jsonb)))::bigint[] as adder_id
     from  brs.get_proposal_version_value(v_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_MISC_ADDERS')

    loop
      if x.adder_id && v_misc_adders_array or (x.default_value is not null and x.default_value is true) then
        if x.unit_type_id = 459 then
          v_misc_adders = coalesce(v_misc_adders, 0) + x.adder_amount;
        elsif x.unit_type_id = 460 then
          v_misc_adders = coalesce(v_misc_adders, 0) + x.adder_amount * v_system_size * 1000;
        elsif x.unit_type_id = 458 then
          --percent of total  total_system_cost*rebate_amount
        end if;
      end if;
    end loop;


  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as small_system_size_adder,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 132)') ->> 'value')::numeric  as small_system_size_value,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as small_system_size_unit_type_id
  into v_small_system_size_adder,v_small_system_size_value,v_small_system_size_unit_type_id
  from brs.get_proposal_version_value(v_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                      'PROPOSAL_SMALL_SYSTEM_ADDERS');

  if v_system_size < v_small_system_size_value then
    select brs.get_amount_by_unit_type(v_system_size, 'PROPOSAL_SMALL_SYSTEM_ADDERS',
                                       v_small_system_size_adder::numeric, v_small_system_size_unit_type_id::bigint,
                                       0::numeric,
                                       null,
                                       null)
    into v_small_system_size_adder_amount;
  end if;

  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 111)') ->> 'value')::numeric   as apr,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 320)') ->> 'value')::text      as financial_option,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 148)') ->> 'value')::numeric   as reamortized_payment_factor_without_itc_paydown,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 110)') ->> 'value')::numeric   as loan_term,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 114)') ->> 'value')::numeric   as dealer_fee,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 116)') ->> 'value')::numeric   as reamortization_factor,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'intValue')::bigint as financier_id,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'value')::text      as financier,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 115)') ->> 'value')::numeric   as initial_payment_factor
  into v_apr,v_financial_option,v_reamortized_payment_factor_without_itc_paydown,v_loan_term,
    v_dealer_fee,v_reamortization_factor,v_financier_id,v_financier,v_initial_payment_factor
  from brs.get_proposal_version_value(v_version_id, array [(128, null, v_financial_product_id, null)::ProposalFieldFilter],
                                      'PROPOSAL_FINANCE_PRODUCTS');



  raise notice 'v_utility_company_id %',v_utility_company_id;
  raise notice 'v_source_id %',v_source_id;
  raise notice 'v_system_size %',v_system_size;
  raise notice 'v_panel_watts %',v_panel_watts;
  raise notice 'v_panel_brand_id %',v_panel_brand_id;
  raise notice 'v_inverter_brand_id %',v_inverter_brand_id;
  raise notice 'v_equipment_panel_adder %',v_equipment_panel_adder;
  raise notice 'v_unapproved_zip_code_adder %',v_unapproved_zip_code_adder;
  raise notice 'v_equipment_inverter_adder %',v_equipment_inverter_adder;
  raise notice 'v_postal_adder_amount %',v_postal_adder_amount;
  raise notice 'v_postal_code %',v_postal_code;
  raise notice 'v_version_id %',v_version_id;
  raise notice 'v_project_process_step_id %',v_project_process_step_id;
  raise notice 'v_misc_adders %',v_misc_adders;

  while v_commission_watt <= 1.00
    loop
      v_total_price_per_watt_before_promotion = 0::numeric;
      v_promotion_cost = 0::numeric;
      v_total_price_per_watt_before_promotion = v_red_line_funding_amount + v_closer_gen_discount + ((coalesce(v_unapproved_zip_code_adder,0) +
                                                                                                      coalesce(v_equipment_panel_adder,0) +
                                                                                                      coalesce(v_equipment_inverter_adder,0) +
                                                                                                      coalesce(v_postal_adder_amount,0) +
                                                                                                      coalesce(v_misc_adders,0) +
                                                                                                      coalesce(v_small_system_size_adder_amount,0))/(v_system_size * 1000))+ (v_commission_watt/.68);
      v_promotion_cost = (v_total_price_per_watt_before_promotion * v_system_size * 1000 * v_initial_payment_factor * 18) /
                         (1 - v_dealer_fee - (v_initial_payment_factor * 18));

      v_adders_dollars_per_watt = (coalesce(v_unapproved_zip_code_adder, 0) +
                                   coalesce(v_equipment_panel_adder, 0) +
                                   coalesce(v_equipment_inverter_adder, 0) +
                                   coalesce(v_postal_adder_amount, 0) +
                                   coalesce(v_misc_adders, 0) +
                                   coalesce(v_small_system_size_adder_amount, 0) +
                                   coalesce(v_promotion_cost, 0)) / v_system_size * 1000;

      v_base_price = v_red_line_funding_amount + v_closer_gen_discount + v_adders_dollars_per_watt;
      v_total_price_per_watt = v_total_price_per_watt_before_promotion + v_promotion_cost / (v_system_size * 1000);
      v_cash_price = v_total_price_per_watt * v_system_size * 1000;
      v_loan_amount =  v_cash_price / (1 - v_dealer_fee);
      v_monthly_payment = v_loan_amount * v_initial_payment_factor;
      v_commission_dollars_per_kw = v_commission_watt * 1000;
      v_total_commissions = v_commission_dollars_per_kw * v_system_size;


      raise notice 'v_commission_watt %',v_commission_watt;
      raise notice 'v_total_price_per_watt_before_promotion %',v_total_price_per_watt_before_promotion;
      raise notice 'v_promotion_cost %',v_promotion_cost;
      raise notice 'v_adders_dollars_per_watt %',v_adders_dollars_per_watt;
      raise notice 'v_base_price %',v_base_price;
      raise notice 'v_total_price_per_watt %',v_total_price_per_watt;
      raise notice 'v_cash_price %',v_cash_price;
      raise notice 'v_loan_amount %',v_loan_amount;
      raise notice 'v_monthly_payment %',v_monthly_payment;
      raise notice 'v_commission_dollars_per_kw %',v_commission_dollars_per_kw;
      raise notice 'v_total_commissions %',v_total_commissions;

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
                                   total_commissions)
      values (v_red_line_funding_amount,
              case when v_source_id in (523,524) then
                     v_closer_gen_discount else 0::numeric end,
              v_adders_dollars_per_watt,
              v_base_price,
              v_commission_watt,
              v_total_price_per_watt,
              v_system_size,
              v_cash_price,
              v_loan_amount,
              v_monthly_payment,
              v_commission_dollars_per_kw,
              v_total_commissions);

      v_commission_watt = v_commission_watt + .10;
    end loop;

  return query
    select *
    from proposal_details;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
