-- Function: brs.get_data_from_proposal(bigint, bigint)

-- DROP FUNCTION brs.get_data_from_proposal(bigint, bigint);
drop function if exists brs.get_data_from_proposal(
  p_project_id bigint,
  p_proposal_nbr bigint,
  p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_data_from_proposal(
  p_project_id bigint,
  p_proposal_nbr bigint,
  p_run_by_id bigint)
  RETURNS SETOF json AS
$BODY$
declare
  v_loan_type varchar;
begin
  select case when position(' ' IN loan_type) = 0 then loan_type else substring(loan_type, 1, position(' ' IN loan_type) - 1) end
  into v_loan_type
  from brs.proposal_log_history
  where project_id = p_project_id and proposal_nbr = p_proposal_nbr;

  --select * from brs.get_data_from_proposal(1,2)
  RETURN QUERY select json_build_object(
                          'value',
                          round(system_size::numeric/1000,2),
                          'custom_fields.System Size',
                          round(system_size::numeric/1000,3),
                          'custom_fields.Proposal Number',
                          proposal_nbr::bigint,
                          'custom_fields.Proof of Homeowner''s Insurance Required?',
                          case when state = 'Florida' and  round(system_size::numeric/1000,3) >= 10 THEN
                            'Yes'
                               when state = 'North Carolina' or state = 'South Carolina' or state = 'Indiana'
                                    or state = 'Ohio' or (state = 'Colorado' and  utility_name != 'Colorado Springs') then
                            'Yes' else 'No' end,
                          'custom_fields.Financier',
                          case when v_loan_type = 'Mosiac' then json_build_array('Mosaic') else json_build_array(v_loan_type) end,
                          'custom_fields.Product',
                          case when v_loan_type = 'Mosiac' and (bp_plus_promotion) = 'Yes' then 'BluePower Plus PrePaid'
                          when (bp_plus_promotion) = 'Yes' then 'BluePower Plus' else 'BluePower' end,
                          'custom_fields.Loan Amount',
                          case when v_loan_type = 'Salal' then
                          round(((loan_amount)::numeric - (secondary_loan_amount)::numeric),2)::text
                            when (v_loan_type = 'Cash') then 0.00::text
                          else round((loan_amount)::numeric,2)::text end,
                          'custom_fields.Loan Term',
                          (loan_term),
                          'custom_fields.Interest Rate',
                          case when (interest_rate)::numeric is null then '0.00'::text else  round((interest_rate)::numeric * 100,2)::text end,
                          'custom_fields.Referral Promotion Amount',
                          case when (referral_promotion)::numeric is null then 0.00 else round((referral_promotion)::numeric,2) end,
                          -- 'custom_fields.Utility Rebate Amount',
                          -- case when (proposal->>'Current OET Rebate')::numeric is null then 0.00 else round((proposal->>'Current OET Rebate')::numeric,2) end,
                          'custom_fields.1st Year Production Estimate (kWh)',
                          (year_1_kwh_output),
                          'custom_fields.Panel Brand',
                          substring(panel FROM '[a-zA-Z]*'),
                          'custom_fields.Panel Watts',
                          (panel_wattage),
                          'custom_fields.Panel Quantity',
                          (panel_number),
                          'custom_fields.Inverter Brand',
                          (inverter_custom_getting),
                          'custom_fields.Energy Kit Required',
                          case when (number_of_ecobees)::bigint > 0 or (number_of_leds)::bigint > 0 then 'Yes' else 'No' end,
                          'custom_fields.Smart Thermostat Quantity',
                          case when (number_of_ecobees) is null then 0 else (number_of_ecobees)::bigint end,
                          'custom_fields.LED Lightbulb Quantity',
                          case when (number_of_leds) is null then 0 else (number_of_leds)::bigint end,
                          'custom_fields.Total Promotion Amount',
                          coalesce(((promotion_eighteen_months_free)::numeric),0)::bigint,
                          'custom_fields.Does Not Qualify for ETO',
                          case when cs.state_id != 37 then TRUE else FALSE end,
                          'custom_fields.Total Cash Down Payment',
                          case when (v_loan_type = 'Cash' and (loan_amount)::numeric is null) then 0.00::numeric
                          when (v_loan_type = 'Cash' and (loan_amount)::numeric > 0.00::numeric) then coalesce(round((loan_amount)::numeric,2),0)::numeric
                          when (v_loan_type != 'Cash' and (optional_down_payment)::numeric is null) then 0.00::numeric
                          when (v_loan_type != 'Cash' and (optional_down_payment)::numeric > 0.00::numeric) then coalesce(round((optional_down_payment)::numeric,2),0)::numeric
                          else 0.00::numeric
                          end,
                          'custom_fields.Number of Promotion Payments', 0,
                          --case when (proposal->>'Promotion 18 Months Free')::numeric > 0 and
                                    --d.proposal_complete_date::date between '2020-03-25'::date and '2020-04-30'::date then 1
                               --when (proposal->>'Promotion 18 Months Free')::numeric > 0 and
                                    --d.proposal_complete_date::date < '2020-03-25'::date or  d.proposal_complete_date::date > '2020-04-30'::date then 18 else 0 end,
                          'custom_fields.Secondary Loan Amount',
                          case when (secondary_loan_amount)::numeric is null then '0.00'::text else round((secondary_loan_amount)::numeric,2)::text end,
                          'custom_fields.Annual Utility Usage (kWh)',
                          coalesce(round(((total_yearly_usage_pre_solar)::numeric),2),0)::bigint,
                          'custom_fields.Interior Conduit Run',
                          case when (hidden_conduit_adder)::text = 'Yes' then true else false end,
                          'custom_fields.Pre-Solar Cost per kWh ($)',
                          (cost_per_kwh_before_solar)::text,
                          'custom_fields.Total Cost',
                          case when (total_cost)::numeric is null then '0.00'::text else round((total_cost)::numeric,2)::text end,
                          'custom_fields.Total System Price',
                          round((coalesce((loan_amount)::NUMERIC,0.00::NUMERIC) +
                           coalesce((secondary_loan_amount)::NUMERIC,0.00::NUMERIC) +
                           coalesce((optional_down_payment)::NUMERIC,0.00::NUMERIC)),2)::bigint,
                          'custom_fields.5% ITC Down Payment Amount',
                          round((coalesce((loan_amount)::NUMERIC,0.00::NUMERIC) +
                           coalesce((secondary_loan_amount)::NUMERIC,0.00::NUMERIC) +
                           coalesce((optional_down_payment)::NUMERIC,0.00::NUMERIC))*.05,2)::bigint,
                          'custom_fields.First Cash Payment Amount',
                          case when (v_loan_type = 'Cash') THEN
                                   coalesce(round((coalesce((loan_amount)::NUMERIC ,0.00::NUMERIC)) *.5 ,2),0)::bigint end,
                          'custom_fields.Estimated ITC',
                          coalesce(round(((itc)::numeric),2),0)::numeric,
                          'custom_fields.Estimated State Tax Credit',
                          coalesce(round(((state_tax_credit)::numeric),2),0)::bigint,
                          --'custom_fields.Non-Standard Installation Work',
                          --json_build_array(proposal->>'Non-Standard Work 1',proposal->>'Non-Standard Work 2',proposal->>'Non-Standard Work 3'),
                          'custom_fields.Notice of Cancellation Deadline',
                          (((now() AT TIME ZONE 'US/Mountain') :: DATE) + 3) :: DATE,
                         'custom_fields.Utility Rebate Amount ($ to BRS)',
                          case when cs.state_id = 37 then
                                   coalesce(round(((current_oet_rebate)::numeric),2),0)::bigint
                           when ((utility_name)::text = 'NV Energy' OR (utility_name)::text = 'Colorado Springs' OR (utility_name)::text = 'ComEd') then
                               coalesce(round(((down_payment_above_line_incentive)::numeric),2) - round(((optional_down_payment)::numeric),2),0)::bigint
                           else 0::bigint end,
                          'custom_fields.Ancillary Expense Type 1',
                          non_standard_work_1,
                          'custom_fields.Ancillary Expense Type 2',
                          coalesce(non_standard_work_2,non_standard_work_2),
                          'custom_fields.Ancillary Expense Type 3',
                          coalesce(non_standard_work_3,non_standard_work_3),
                          'custom_fields.Ancillary Expense Estimated Price 1',
                          coalesce((non_standard_work_1_cost)::numeric,0)::numeric,
                          'custom_fields.Ancillary Expense Estimated Price 2',
                          coalesce((non_standard_work_2_cost)::numeric,0)::numeric,
                          'custom_fields.Ancillary Expense Estimated Price 3',
                          coalesce((non_standard_work_3_cost)::numeric,0)::numeric,
                          'custom_fields.Total Ancillary Cost with Fees',
                          coalesce(round((round(((non_standard_work_1_cost)::numeric),2) + round(((non_standard_work_2_cost)::numeric),2) +
                          round(((non_standard_work_3_cost)::numeric),2)) /* (1+(proposal->>'Dealer Fee')::numeric)*/,2),0) --+ ((proposal->>'System Size (w)')::numeric * (proposal->>'Extra Promotion Cost')::numeric),2)
                      ) as results
               from brs.proposal_log_history pl
                 INNER JOIN flow.project p on p.id = pl.project_id
                 INNER JOIN flow.contact c ON c.id = p.contact_id
                 inner join flow.company_state cs on c.company_state_id = cs.id
               where pl.project_id = p_project_id and pl.proposal_nbr = p_proposal_nbr;

  insert into flow.company_function_log(function_name, parameters, run_by_id)
  values ('Get Data from Proposal', 'p_project_id: ' || p_project_id ||
                                    ' p_proposal_nbr: ' || p_proposal_nbr ||
                                    ' p_run_by_id: ' || p_run_by_id,
          p_run_by_id);

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

