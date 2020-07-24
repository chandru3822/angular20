CREATE OR REPLACE FUNCTION brs.get_commissions_earned(p_project_ids integer[])
    RETURNS NUMERIC AS
$BODY$
DECLARE
    v_total numeric;
BEGIN
    select (
               select coalesce(
                              (SELECT case
                                          when pd.cancelled_date is not null then
                                              0::NUMERIC
                                          else coalesce(round(cpa.allocation * pd.system_size::numeric - case
                                                                                                                      when cpsa.milestone_id = 1
                                                                                                                          then
                                                                                                                          case
                                                                                                                              when cpsa.fee_type_id = 1
                                                                                                                                  then coalesce(pd.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                              else coalesce(cpsa.fee_amount, 0) end
                                                                                                                      else 0 end,
                                                              2),
                                                        0) end total
                               FROM flow.project p1
                                        inner join flow.project_process_step pps
                                                   on pps.project_id = p1.id and pps.process_step_id = 9 and
                                                      pps.process_step_complete_date is not null
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and
                                                     cpsa.source_id = pd.source
                               WHERE p1.id = p.id), 0) + coalesce(
                              (SELECT case
                                          when pd.cancelled_date is not null THEN
                                              0::NUMERIC
                                          else coalesce(round(cpa.allocation * pd.system_size::numeric - case
                                                                                                                      when cpsa.milestone_id = 2
                                                                                                                          then
                                                                                                                          case
                                                                                                                              when cpsa.fee_type_id = 1
                                                                                                                                  then coalesce(pd.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                              else coalesce(cpsa.fee_amount, 0) end
                                                                                                                      else 0 end,
                                                              2),
                                                        0) end total
                               FROM flow.project p1
                                        inner join flow.project_process_step pps
                                                   on pps.project_id = p1.id and pps.process_step_id = 35 and
                                                      pps.process_step_complete_date is not null
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2 and
                                                     cpsa.source_id = pd.source
                               WHERE p1.id = p.id), 0)
               from flow.project p
               inner join brs.project_details pd on pd.project_id = p.id
               inner join flow.list_of_value lov_source on lov_source.id = pd.source
               where array [p.id] <@ p_project_ids)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;


