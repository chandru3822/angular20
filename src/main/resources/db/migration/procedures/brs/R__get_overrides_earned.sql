CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_ids bigint[],
                                                    p_user_id integer)
    RETURNS numeric AS
$BODY$
DECLARE
    v_total numeric;
BEGIN
    select (select sum(total)
            from (SELECT case
                             when pd.cancelled_date is not null then
                                 0::numeric
                             else coalesce(round(pd.system_size::numeric * sum(opru.m1_allocation), 2),
                                           0) end total
                  FROM flow.project p1
                           inner join brs.project_details pd on pd.project_id = p1.id
                           inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 175 and
                                                                       pps.process_step_complete_date is not null
                                                                        and main is true
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                  WHERE  p1.id = any(p_project_ids::integer[])
                    and user_id = p_user_id
                  group by cancelled_date, system_size) as foo) +
           (select sum(total)
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
                           inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 35 and
                                                                       pps.process_step_complete_date is not null
                      and main is true
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id

                  WHERE  p1.id = any(p_project_ids::integer[])
                    and user_id = p_user_id
                  group by pd.cancelled_date, pd.system_size) as foo)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
