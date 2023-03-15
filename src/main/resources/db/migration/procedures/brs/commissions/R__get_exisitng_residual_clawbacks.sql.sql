drop function if exists brs.get_existing_residual_clawbacks(p_closer_user_id bigint);
CREATE or replace function brs.get_existing_residual_clawbacks(p_closer_user_id bigint)
  RETURNS table(user_id bigint,
                amount numeric) AS
$BODY$
begin

  return query
  select p_closer_user_id, case when rc.clawback_due is null then 0 else rc.clawback_due end  -
                           case when rc.applied_clawback is null then 0 else rc.applied_clawback end
                                          as amount
  from brs.residual_clawback rc
  where rc.user_id = p_closer_user_id;



END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
