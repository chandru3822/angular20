CREATE OR REPLACE FUNCTION brs.get_commissions_earned_for_setters(p_project_ids integer[],p_period_end date )
    RETURNS NUMERIC AS
$BODY$
DECLARE
    v_total numeric;
BEGIN

   select  coalesce(
            (SELECT case when cancelled_date is not null then
                             0::NUMERIC
                         else coalesce(sum(cpa2.allocation),
                                       0) end total
             from (
                      select pd3.setter_user_id,pc.commission_plan_id,count(1) as pitched_count,pd3.cancelled_date
                      from brs.project_details pd3
                               inner join brs.project_commission pc on pc.project_id = pd3.project_id
                               inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 4
                      where pd3.setter_milestone_pay::date >= '2021-04-15'
                        and pd3.setter_milestone_pay <= p_period_end
                        and  pd3.project_id = any(p_project_ids)
                        and pd3.first_appointment_not_pitched_or_missed <= p_period_end and pd3.first_appointment_not_pitched_or_missed >= (p_period_end) - 7
                      group by pd3.setter_user_id,pc.commission_plan_id,pd3.cancelled_date)as foo
                      inner join brs.commission_plan_allocation cpa2 on cpa2.commission_plan_id = foo.commission_plan_id and
                                                                        ((foo.pitched_count between cpa2.min and cpa2.max) or (foo.pitched_count > cpa2.max))
                group by cancelled_date),0)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;



