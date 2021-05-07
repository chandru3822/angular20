CREATE OR REPLACE FUNCTION brs.get_commissions_earned_for_setters(p_project_ids integer[],p_period_end date )
    RETURNS NUMERIC AS
$BODY$
DECLARE
    v_total numeric;
BEGIN

   select  coalesce(
            (SELECT case when pd.cancelled_date is not null then
                             0::NUMERIC
                         else coalesce(sum(cpa.allocation),
                                       0) end total
             FROM flow.project p1
                      inner join brs.project_details pd on p1.id = pd.project_id
                      inner join brs.project_commission pc on pc.project_id = p1.id
                      inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 4
                      inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
             WHERE  p1.id = any(p_project_ids)
                group by pd.cancelled_date),0)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;


