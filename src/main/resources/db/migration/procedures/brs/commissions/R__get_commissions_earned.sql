drop function if exists brs.get_commissions_earned(p_project_ids bigint[],p_period_end date );
CREATE OR REPLACE FUNCTION brs.get_commissions_earned(p_project_ids bigint[],p_period_end date )
    RETURNS NUMERIC AS
$BODY$
DECLARE
    v_total numeric;
BEGIN
    with milestone_one_projects as (
        select project_id, min(process_step_complete_date) milestone_one_complete_date
        from flow.project_process_step pps
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
        where pps.process_step_id = 175
        group by project_id
    ),
         milestone_two_projects as (
             select coalesce(pps.project_id,pd.project_id) as project_id, coalesce(min(process_step_complete_date),pd.substantial_completion_date)::date milestone_two_complete_date
             from brs.project_details pd
                      left join flow.project_process_step pps on pps.project_id = pd.project_id and pps.process_step_id = 3365
                      left join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                      left join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
             group by pps.project_id,pd.project_id,pd.substantial_completion_date
         )
               select coalesce(
                              (SELECT sum(case
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
                                                        0) end) total
                               FROM flow.project p1
                                        inner join milestone_one_projects mop on mop.project_id = p1.id and mop.milestone_one_complete_date::date <= p_period_end
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and
                                                     cpsa.source_id = pd.source and cpsa.milestone_id = 1
                               WHERE p1.id = p.id), 0) + coalesce(
                              (SELECT sum(case
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
                                                        0) end) total
                               FROM flow.project p1
                                        inner join milestone_two_projects mtp on mtp.project_id = p1.id and mtp.milestone_two_complete_date::date <= p_period_end
                                        inner join brs.project_commission pc on pc.project_id = p1.id
                                        inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 1
                                        inner join brs.commission_plan_allocation cpa
                                                   on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                        left join brs.commission_plan_source_allocation cpsa
                                                  on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2 and
                                                     cpsa.source_id = pd.source and cpsa.milestone_id = 2
                               WHERE p1.id = p.id), 0)
               from flow.project p
               inner join brs.project_details pd on pd.project_id = p.id
               inner join flow.list_of_value lov_source on lov_source.id = pd.source
               where p.id = any(p_project_ids)
    into v_total;

    insert into flow.company_function_log(function_name, parameters)
    values ('Get Commissions Earned', 'p_project_ids: ' || p_project_ids ||
                                      ' p_period_end: ' || p_period_end);

    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;


