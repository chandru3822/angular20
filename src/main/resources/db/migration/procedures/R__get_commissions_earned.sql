CREATE OR REPLACE FUNCTION brs.get_commissions_earned(p_project_ids integer[])
    RETURNS NUMERIC AS
$BODY$
DECLARE
    v_total numeric;
BEGIN
    select (
               select coalesce(
                              (SELECT case
                                          when cancelled_date.cancelled_date is not null then
                                              0::NUMERIC
                                          else coalesce(round(cpa.allocation * system_size.system_size::numeric - case
                                                                                                                      when cpsa.milestone_id = 1
                                                                                                                          then
                                                                                                                          case
                                                                                                                              when cpsa.fee_type_id = 1
                                                                                                                                  then coalesce(system_size.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                              else coalesce(cpsa.fee_amount, 0) end
                                                                                                                      else 0 end,
                                                              2),
                                                        0) end total
                               FROM flow.project p1
                                        inner join flow.project_process_step pps
                                                   on pps.project_id = p1.id and pps.process_step_id in (4, 9) and
                                                      pps.process_step_complete_date is not null
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and
                                                     cpsa.source_id = source_id1.source_id1::integer
                               WHERE p1.id = p.id), 0) + coalesce(
                              (SELECT case
                                          when cancelled_date.cancelled_date is not null THEN
                                              0::NUMERIC
                                          else coalesce(round(cpa.allocation * system_size.system_size::numeric - case
                                                                                                                      when cpsa.milestone_id = 2
                                                                                                                          then
                                                                                                                          case
                                                                                                                              when cpsa.fee_type_id = 1
                                                                                                                                  then coalesce(system_size.system_size::numeric * cpsa.fee_amount, 0)
                                                                                                                              else coalesce(cpsa.fee_amount, 0) end
                                                                                                                      else 0 end,
                                                              2),
                                                        0) end total
                               FROM flow.project p1
                                        inner join flow.project_process_step pps
                                                   on pps.project_id = p1.id and pps.process_step_id in (4, 35) and
                                                      pps.process_step_complete_date is not null
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2 and
                                                     cpsa.source_id = source_id1.source_id1::integer
                               WHERE p1.id = p.id), 0)
               from flow.project p
                        left JOIN lateral (select *
                                           from flow.get_value_for_custom_field(1,
                                                                                5,
                                                                                p.id) as source_id1) source_id1 on true
                        INNER JOIN lateral (select *
                                            from flow.get_value_for_custom_field(4,
                                                                                 333,
                                                                                 p.id,
                                                                                 4) as system_size) system_size on true
                        left join lateral (select *
                                           from flow.get_value_for_custom_field(1,
                                                                                52,
                                                                                p.id) as cancelled_date) as cancelled_date
                                  on true
               where array [p.id] <@ p_project_ids)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;


