drop function if exists brs.get_total_residual_clawbacks(p_closer_user_id bigint);
CREATE or replace function brs.get_total_residual_clawbacks(p_closer_user_id bigint)
  RETURNS numeric AS
$BODY$
  declare
    v_total_residual_clawbacks numeric;
begin

select (coalesce((select sum(amount) from brs.get_existing_residual_clawbacks(p_closer_user_id)),0) + coalesce((select sum(amount) from brs.get_current_residual_clawbacks(p_closer_user_id)),0))
    into v_total_residual_clawbacks;

return coalesce(v_total_residual_clawbacks,0);



END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
