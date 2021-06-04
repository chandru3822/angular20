CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_ids bigint[],
                                                    p_period_end date,
                                                    p_user_id integer)
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
             select project_id, min(process_step_complete_date) milestone_two_complete_date
             from flow.project_process_step pps
                      inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                      inner join flow.process_step_status_type psst on cpsst.process_step_status_type_id = psst.id and psst.id = 2
             where pps.process_step_id = 3365
             group by project_id
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
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
