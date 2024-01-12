drop function if exists brs.get_lead_allocation_score(p_users bigint[], p_closer_gen_source_ids bigint[],
                                                      p_interval bigint);
CREATE OR REPLACE FUNCTION brs.get_lead_allocation_score(p_lead_gen_num bigint, p_lead_gen_den bigint,
                                                         p_self_gen bigint, p_manual_allocation numeric,
                                                         p_run_manual_allocation boolean)
  RETURNS numeric
AS
$BODY$
declare
  v_score numeric;
BEGIN
  v_score = 0;
  if p_lead_gen_den is null or p_lead_gen_den = 0 then
    v_score = 0;
  else
    if p_manual_allocation is not null and p_run_manual_allocation is true
    then
      v_score = 0;
    else
      v_score = ((p_lead_gen_num / p_lead_gen_den::numeric * case
                                                               when p_lead_gen_den < 30
                                                                 then
                                                                 50
                                                               when p_lead_gen_den >= 30
                                                                 then
                                                                 200
        end) +
                 (p_self_gen * 6) +
                 (p_lead_gen_num * 3));
    end if;
  end if;
  return v_score;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
