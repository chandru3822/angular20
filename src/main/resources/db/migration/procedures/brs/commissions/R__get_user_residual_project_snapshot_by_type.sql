drop function if exists brs.get_user_residual_project_snapshot_by_type(p_residual_id bigint, p_closer_user_id bigint,
                                                                        p_user_residual_project_snapshot_type_id bigint);
CREATE or replace function brs.get_user_residual_project_snapshot_by_type(p_residual_id bigint, p_closer_user_id bigint,
                                                                          p_user_residual_project_snapshot_type_id bigint)
  RETURNS table
          (
            project_id                                  bigint,
            final_design_complete_date                  date,
            final_design_signed_date                    date,
            utility_bill_verified_date                  date,
            financial_agreement_signed_date             date,
            proof_of_homeowners_insurance_required      bigint,
            proof_of_homeowners_insurance_obtained_date date,
            state                                       varchar,
            total_cash_down_payment                     numeric,
            first_cash_payment_amount                   numeric,
            substantial_completion_date                 date,
            cancelled_date                              date,
            on_hold_date                                date,
            qualified_date                              date,
            total                                       numeric
          )
AS
$BODY$
begin

  return query
    select urps.project_id,
           urps.final_design_complete_date,
           urps.final_design_signed_date,
           urps.utility_bill_verified_date,
           urps.financial_agreement_signed_date,
           urps.proof_of_homeowners_insurance_required,
           urps.proof_of_homeowners_insurance_obtained_date,
           urps.state,
           urps.total_cash_down_payment,
           urps.first_cash_payment_amount,
           urps.substantial_completion_date,
           urps.cancelled_date,
           urps.on_hold_date,
           urps.qualified_date,
           urps.total
    from brs.user_residual_snapshot urs
           inner join brs.user_residual_project_snapshot urps on urps.user_residual_snapshot_id = urs.id
           inner join brs.user_residual_project_snapshot_type urpst
                      on urpst.id = urps.user_residual_project_snapshot_type_id and
                         urpst.id = p_user_residual_project_snapshot_type_id
    where urs.user_id = p_closer_user_id
      and urs.residual_id = p_residual_id;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;


