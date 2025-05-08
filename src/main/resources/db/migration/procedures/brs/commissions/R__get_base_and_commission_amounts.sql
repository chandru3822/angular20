drop function if exists brs.get_base_and_commission_amounts(p_proposal_id bigint);
CREATE OR REPLACE function brs.get_base_and_commission_amounts(p_proposal_id bigint)
  returns TABLE(base_amount numeric,
                commission_amount numeric)
AS
$BODY$
declare
  v_base_amount                numeric;
  v_commission_amount numeric;
BEGIN
  select numeric_value
  into v_base_amount
  from brs.proposal_custom_field_value pcfv
  where pcfv.custom_field_group_assignment_id = 1329
    and pcfv.proposal_id = p_proposal_id;

  select numeric_value
  into v_commission_amount
  from brs.proposal_custom_field_value pcfv
  where pcfv.custom_field_group_assignment_id = 1330
    and pcfv.proposal_id = p_proposal_id;

  return query select coalesce(v_base_amount, 0), COALESCE(v_commission_amount, 0);
END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
