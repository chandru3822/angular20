drop function if exists brs.get_total_commissions_amount(p_project_id bigint);
drop function if exists brs.get_total_commissions_amount(p_project_id bigint,p_from_booking boolean);
CREATE OR REPLACE FUNCTION brs.get_total_commissions_amount(p_project_id bigint)
  RETURNS NUMERIC AS
$BODY$
DECLARE
  v_total                     numeric;
  v_primary_financier         bigint;
  v_source_id                 bigint;
  v_system_size               numeric;
  v_loan_term                 bigint;
  v_interest_rate             numeric;
  v_desired_commission_amount numeric;
  v_commission_strategy_id    bigint;
  v_commission_strategy_type_id bigint;
  v_proposal_number_id             bigint;
  v_proposal_selected_adder_amount numeric;
  v_proposal_custom_adder_amount   numeric;
  v_project_selected_adder_amount  numeric;
  v_project_custom_adder_amount    numeric;
  v_version_id                     bigint;
  v_total_project_adders numeric;
  v_total_proposal_adders numeric;
  v_project_adders_last_reviewed_date date;
  v_fdc_date date;
BEGIN

  select commission_strategy_type_id,
         pd.proposal_number_id,
         pd.interest_rate,
         pd.loan_term,
         pd.system_size,
         pd.source,
         pd.primary_financier,
         fd.desired_commission_amount,
         fd.commission_strategy,
         fd.project_adders_last_reviewed_date,
         fd.final_design_complete_date
  into v_commission_strategy_type_id,
    v_proposal_number_id,
    v_interest_rate,
    v_loan_term,
    v_system_size,
    v_primary_financier,
    v_source_id,
    v_desired_commission_amount,
    v_commission_strategy_id,
    v_project_adders_last_reviewed_date,
    v_fdc_date
  from brs.financial_details fd
         inner join brs.project_details pd on pd.project_id = fd.project_id
         inner join brs.commission_plan c on c.id = fd.commission_plan_id
  where fd.project_id = p_project_id;

  select project_selected_adder_amount,
         project_custom_adder_amount,
         proposal_selected_adder_amount,
         proposal_custom_adder_amount,
         version_id
  into v_project_selected_adder_amount,
    v_project_custom_adder_amount,
    v_proposal_selected_adder_amount,
    v_proposal_custom_adder_amount,
    v_version_id
  from brs.get_adder_amounts(v_proposal_number_id);

  v_total_project_adders = coalesce(v_project_selected_adder_amount,0) + coalesce(v_project_custom_adder_amount,0);
  v_total_proposal_adders = coalesce(v_proposal_selected_adder_amount,0) + coalesce(v_proposal_custom_adder_amount,0);

  if v_commission_strategy_id in (24102,24871,26056) and v_commission_strategy_type_id = 1 then
    v_total = v_desired_commission_amount * v_system_size * 1000;
  else

    SELECT coalesce(round(cp.total * case
                                       when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
                                         then 0
                                       else v_system_size::numeric end
                            - case
                                when cpsa.fee_type_id = 1 then coalesce(case
                                                                          when v_primary_financier = 722 and v_loan_term = 427 and v_interest_rate = 2.99
                                                                            then 0
                                                                          else v_system_size::numeric end *
                                                                        cpsa.fee_amount, 0)
                                else
                                  coalesce(cpsa.fee_amount, 0) end, 2),
                    0)
    into v_total
    FROM flow.project p2
           inner join brs.project_commission pc on pc.project_id = p2.id
           inner join brs.commission_plan cp on pc.commission_plan_id = cp.id and cp.position_id = 1
           left join brs.commission_plan_source_allocation cpsa
                     on cpsa.commission_plan_id = cp.id and cpsa.milestone_id = 2 and cpsa.source_id = v_source_id
    where p2.id = p_project_id;
  end if;
  return coalesce(v_total,0) + case when v_project_adders_last_reviewed_date is not null or v_fdc_date is not null then  coalesce(v_total_proposal_adders,0) - coalesce(v_total_project_adders,0) else 0::numeric end;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
