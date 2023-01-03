drop function if exists brs.get_overrides_earned(p_project_ids bigint[],
                                                 p_period_end date,
                                                 p_user_id bigint);
CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_ids bigint[],
                                                    p_period_end date,
                                                    p_user_id bigint)
    RETURNS numeric AS
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
    select (select coalesce(sum(total),0)
            from (SELECT case
                             when pd.cancelled_date is not null then
                                 0::numeric
                             else coalesce(round(pd.system_size::numeric * sum(opru.m1_allocation), 2),
                                           0) end total
                  FROM flow.project p1
                           inner join brs.project_details pd on pd.project_id = p1.id
                           inner join milestone_one_projects mop2 on mop2.project_id = p1.id and
                                                                     mop2.milestone_one_complete_date::date <= p_period_end
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                  WHERE  p1.id = any(p_project_ids)
                    and user_id = p_user_id
                  group by cancelled_date, system_size) as foo) +
           (select coalesce(sum(total),0)
            from (SELECT case
                             when pd.cancelled_date is not null
                                 then
                                 0::numeric
                             else coalesce(round(
                                                   pd.system_size::numeric * sum(opru.m2_allocation),
                                                   2),
                                           0) end total
                  FROM flow.project p1
                           inner join brs.project_details pd on pd.project_id = p1.id
                           inner join milestone_two_projects mtp2 on mtp2.project_id = p1.id and
                                                                     mtp2.milestone_two_complete_date::date <= p_period_end
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id

                  WHERE  p1.id = any(p_project_ids)
                    and user_id = p_user_id
                  group by pd.cancelled_date, pd.system_size) as foo)
    into v_total;

    insert into flow.company_function_log(function_name, parameters)
    values ('Get Overrides Earned', 'p_project_ids: ' || p_project_ids::text ||
                                    ' p_period_end: ' || p_period_end ||
                                    ' p_user_id: ' || p_user_id);

    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
