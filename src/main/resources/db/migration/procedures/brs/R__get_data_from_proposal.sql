-- Function: brs.get_data_from_proposal(integer, integer)

-- DROP FUNCTION brs.get_data_from_proposal(integer, integer);

CREATE OR REPLACE FUNCTION brs.get_data_from_proposal(
  p_project_id integer,
  p_proposal_nbr integer)
  RETURNS SETOF json AS
$BODY$
declare
  v_loan_type varchar;
begin
  select substring(proposal->>'Loan Type',1,position(' ' in proposal->>'Loan Type')-1)
  into v_loan_type
  from brs.proposal_log
  where project_id = p_project_id and proposal_nbr = p_proposal_nbr;

  --select * from brs.get_data_from_proposal(1,2)
  RETURN QUERY select json_build_object(
                          'value',
                          round((proposal->>'System Size (w)')::numeric/1000,2),
                          'custom_fields.System Size',
                          round((proposal->>'System Size (w)')::numeric/1000,3),
                          'custom_fields.Proposal Number',
                          (proposal->>'Proposal ID')::integer,
                          'custom_fields.Proof of Homeowner''s Insurance Required?',
                          case when proposal->>'State' = 'Florida' and  round((proposal->>'System Size (w)')::numeric/1000,2) >= 10 THEN
                            'Yes'
                               when proposal->>'State' = 'North Carolina' or proposal->>'State' = 'South Carolina' or proposal->>'State' = 'Indiana'
                                    or proposal->>'State' = 'Ohio' or (proposal->>'State' = 'Colorado' and  proposal->>'Utility Name' != 'Colorado Springs') then
                            'Yes' else 'No' end,
                          'custom_fields.Financier',
                          case when v_loan_type = 'Mosiac' then json_build_array('Mosaic') else json_build_array(v_loan_type) end,
                          'custom_fields.Product',
                          case when v_loan_type = 'Mosiac' and (proposal->>'BP+ Promotion') = 'Yes' then 'BluePower Plus PrePaid'
                          when (proposal->>'BP+ Promotion') = 'Yes' then 'BluePower Plus' else 'BluePower' end,
                          'custom_fields.Loan Amount',
                          case when v_loan_type = 'Salal' then
                          round(((proposal->>'Loan Amount')::numeric - (proposal->>'Secondary Loan Amount')::numeric),2)::text
                            when (v_loan_type = 'Cash') then 0.00::text
                          else round((proposal->>'Loan Amount')::numeric,2)::text end,
                          'custom_fields.Loan Term',
                          (proposal->>'Loan Term'),
                          'custom_fields.Interest Rate',
                          case when (proposal->>'Interest Rate')::numeric is null then '0.00'::text else  round((proposal->>'Interest Rate')::numeric * 100,2)::text end,
                          'custom_fields.Referral Promotion Amount',
                          case when (proposal->>'Referral Promotion')::numeric is null then 0.00 else round((proposal->>'Referral Promotion')::numeric,2) end,
                          -- 'custom_fields.Utility Rebate Amount',
                          -- case when (proposal->>'Current OET Rebate')::numeric is null then 0.00 else round((proposal->>'Current OET Rebate')::numeric,2) end,
                          'custom_fields.1st Year Production Estimate (kWh)',
                          (proposal->>'Year 1 kWh Output'),
                          'custom_fields.Panel Brand',
                          substring(proposal->>'Panel',1,position(' ' in proposal->>'Panel')-1),
                          'custom_fields.Panel Watts',
                          (proposal->>'Panel Wattage'),
                          'custom_fields.Panel Quantity',
                          (proposal->>'Panel Number'),
                          'custom_fields.Inverter Brand',
                          (proposal->>'Inverter Customer Getting'),
                          'custom_fields.Energy Kit Required',
                          case when (proposal->>'Number of EcoBees')::integer > 0 or (proposal->>'Number of LEDs')::integer > 0 then 'Yes' else 'No' end,
                          'custom_fields.Smart Thermostat Quantity',
                          case when (proposal->>'Number of EcoBees') is null then 0 else (proposal->>'Number of EcoBees')::integer end,
                          'custom_fields.LED Lightbulb Quantity',
                          case when (proposal->>'Number of LEDs') is null then 0 else (proposal->>'Number of LEDs')::integer end,
                          'custom_fields.Total Promotion Amount',
                          coalesce(((proposal->>'Promotion 18 Months Free')::numeric),0)::integer,
                          'custom_fields.Does Not Qualify for ETO',
                          case when cs.state_id != 37 then TRUE else FALSE end,
                          'custom_fields.Total Cash Down Payment',
                          case when (v_loan_type = 'Cash' and (proposal->>'Loan Amount')::numeric is null) then 0.00::numeric
                          when (v_loan_type = 'Cash' and (proposal->>'Loan Amount')::numeric > 0.00::numeric) then coalesce(round((proposal->>'Loan Amount')::numeric,2),0)::numeric
                          when (v_loan_type != 'Cash' and (proposal->>'Optional Down Payment')::numeric is null) then 0.00::numeric
                          when (v_loan_type != 'Cash' and (proposal->>'Optional Down Payment')::numeric > 0.00::numeric) then coalesce(round((proposal->>'Optional Down Payment')::numeric,2),0)::numeric
                          else 0.00::numeric
                          end,
                          'custom_fields.Number of Promotion Payments', 0,
                          --case when (proposal->>'Promotion 18 Months Free')::numeric > 0 and
                                    --d.proposal_complete_date::date between '2020-03-25'::date and '2020-04-30'::date then 1
                               --when (proposal->>'Promotion 18 Months Free')::numeric > 0 and
                                    --d.proposal_complete_date::date < '2020-03-25'::date or  d.proposal_complete_date::date > '2020-04-30'::date then 18 else 0 end,
                          'custom_fields.Secondary Loan Amount',
                          case when (proposal->>'Secondary Loan Amount')::numeric is null then '0.00'::text else round((proposal->>'Secondary Loan Amount')::numeric,2)::text end,
                          'custom_fields.Annual Utility Usage (kWh)',
                          coalesce(round(((proposal->>'Total Yearly Usage (Pre-Solar)')::numeric),2),0)::integer,
                          'custom_fields.Interior Conduit Run',
                          case when (proposal->>'Hidden Conduit Adder')::text = 'Yes' then true else false end,
                          'custom_fields.Pre-Solar Cost per kWh ($)',
                          (proposal->>'Cost per kWh Before Solar')::text,
                          'custom_fields.Total System Price',
                          round((coalesce((proposal->>'Loan Amount')::NUMERIC,0.00::NUMERIC) +
                           coalesce((proposal->>'Secondary Loan Amount')::NUMERIC,0.00::NUMERIC) +
                           coalesce((proposal->>'Optional Down Payment')::NUMERIC,0.00::NUMERIC)),2)::integer,
                          'custom_fields.5% ITC Down Payment Amount',
                          round((coalesce((proposal->>'Loan Amount')::NUMERIC,0.00::NUMERIC) +
                           coalesce((proposal->>'Secondary Loan Amount')::NUMERIC,0.00::NUMERIC) +
                           coalesce((proposal->>'Optional Down Payment')::NUMERIC,0.00::NUMERIC))*.05,2)::integer,
                          'custom_fields.First Cash Payment Amount',
                          case when (v_loan_type = 'Cash') THEN
                                   coalesce(round((coalesce((proposal->>'Loan Amount')::NUMERIC ,0.00::NUMERIC)) *.5 ,2),0)::integer end,
                          'custom_fields.Estimated ITC',
                          coalesce(round(((proposal->>'ITC')::numeric),2),0)::numeric,
                          'custom_fields.Estimated State Tax Credit',
                          coalesce(round(((proposal->>'State Tax Credit')::numeric),2),0)::integer,
                          --'custom_fields.Non-Standard Installation Work',
                          --json_build_array(proposal->>'Non-Standard Work 1',proposal->>'Non-Standard Work 2',proposal->>'Non-Standard Work 3'),
                          'custom_fields.Notice of Cancellation Deadline',
                          (((now() AT TIME ZONE 'US/Mountain') :: DATE) + 3) :: DATE,
                         'custom_fields.Utility Rebate Amount ($ to BRS)',
                          case when cs.state_id = 37 then
                                   coalesce(round(((proposal->>'Current OET Rebate')::numeric),2),0)::integer
                           when ((proposal->>'Utility Name')::text = 'NV Energy' OR (proposal->>'Utility Name')::text = 'Colorado Springs' OR (proposal->>'Utility Name')::text = 'ComEd') then
                               coalesce(round(((proposal->>'Down PaymentAbove Line Incentives')::numeric),2) - round(((proposal->>'Optional Down Payment')::numeric),2),0)::integer
                           else 0::integer end,
                          'custom_fields.Ancillary Expense Type 1',
                          proposal->>'Non-Standard Work 1',
                          'custom_fields.Ancillary Expense Type 2',
                          coalesce(proposal->>'Non Standard Work 2',proposal->>'Non-Standard Work 2'),
                          'custom_fields.Ancillary Expense Type 3',
                          coalesce(proposal->>'Non Standard Work 3',proposal->>'Non-Standard Work 3'),
                          'custom_fields.Ancillary Expense Estimated Price 1',
                          coalesce((proposal->>'Non-Standard Work 1 Cost')::numeric,0)::numeric,
                          'custom_fields.Ancillary Expense Estimated Price 2',
                          coalesce((proposal->>'Non-Standard Work 2 Cost')::numeric,0)::numeric,
                          'custom_fields.Ancillary Expense Estimated Price 3',
                          coalesce((proposal->>'Non-Standard Work 3 Cost')::numeric,0)::numeric,
                          'custom_fields.Total Ancillary Cost with Fees',
                          coalesce(round((round(((proposal->>'Non-Standard Work 1 Cost')::numeric),2) + round(((proposal->>'Non-Standard Work 2 Cost')::numeric),2) +
                          round(((proposal->>'Non-Standard Work 3 Cost')::numeric),2)) /* (1+(proposal->>'Dealer Fee')::numeric)*/,2),0) --+ ((proposal->>'System Size (w)')::numeric * (proposal->>'Extra Promotion Cost')::numeric),2)
                      ) as results
               from brs.proposal_log pl
                 INNER JOIN flow.project p on p.id = pl.project_id
                 INNER JOIN flow.contact c ON c.id = p.contact_id
                 inner join flow.company_state cs on c.company_state_id = cs.id
               where pl.project_id = p_project_id and pl.proposal_nbr = p_proposal_nbr;

END
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100
ROWS 1000;

