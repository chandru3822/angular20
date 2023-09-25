drop function if exists brs.get_current_residual_clawbacks(p_closer_user_id bigint);
CREATE or replace function brs.get_current_residual_clawbacks(p_closer_user_id bigint)
  RETURNS table(user_id bigint,
                project_id bigint,
                amount numeric,
                clawback_date date) AS
$BODY$
begin

  return query
  select p_closer_user_id,pd.project_id,case when rl.amount is null then 0 else rl.amount end as amount,rl.date_created::date
  from brs.project_details pd
  inner join brs.residual_ledger rl on rl.project_id = pd.project_id and rl.user_id = pd.closer_user_id and rl.residual_clawback_paid is false
  and rl.ledger_type_id = 4
  and rl.user_id = p_closer_user_id and pd.closer_user_id = p_closer_user_id
  where pd.cancelled_date is not null;



END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
