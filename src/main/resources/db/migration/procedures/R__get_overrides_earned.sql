CREATE OR REPLACE FUNCTION brs.get_overrides_earned(p_project_ids bigint[],
                                                    p_user_id integer)
    RETURNS numeric AS
$BODY$
DECLARE
    v_total numeric;
BEGIN
    select (select sum(total)
            from (SELECT case
                             when cancelled_date.cancelled_date is not null then
                                 0::numeric
                             else coalesce(round(system_size.system_size::numeric * sum(opru.m1_allocation), 2),
                                           0) end total
                  FROM flow.project p1
                           inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id in (4,9) and pps.process_step_complete_date is not null
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                           left JOIN lateral (select *
                                              from flow.get_value_for_custom_field(1,
                                                                                   5,
                                                                                   p1.id) as source_id1) source_id1
                                     on true
                           INNER JOIN lateral (select *
                                               from flow.get_value_for_custom_field(4,
                                                                                    333,
                                                                                    p1.id,
                                                                                    4) as system_size) system_size
                                      on true
                           left join lateral (select *
                                              from flow.get_value_for_custom_field(1,
                                                                                   52,
                                                                                   p1.id) as cancelled_date) as cancelled_date
                                     on true
                  WHERE array [p1.id] <@ p_project_ids::integer[]
                    and user_id = p_user_id
                  group by cancelled_date, system_size) as foo) +
           (select sum(total)
            from (SELECT case
                             when cancelled_date.cancelled_date is not null
                                 then
                                 0::numeric
                             else coalesce(round(
                                                   system_size.system_size::numeric * sum(opru.m2_allocation),
                                                   2),
                                           0) end total
                  FROM flow.project p1
                           inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id in (4,35) and pps.process_step_complete_date is not null
                           inner join brs.project_override po on po.project_id = p1.id
                           inner join brs.override_plan op on op.id = po.override_plan_id
                           inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                           left JOIN lateral (select *
                                              from flow.get_value_for_custom_field(
                                                           1,
                                                           5,
                                                           p1.id) as source_id1) source_id1
                                     on true
                           INNER JOIN lateral (select *
                                               from flow.get_value_for_custom_field(
                                                            4,
                                                            333,
                                                            p1.id,
                                                            4) as system_size) system_size
                                      on true
                           left join lateral (select *
                                              from flow.get_value_for_custom_field(
                                                           1,
                                                           52,
                                                           p1.id) as cancelled_date) as cancelled_date
                                     on true
                  WHERE array [p1.id] <@ p_project_ids::integer[]
                    and user_id = p_user_id
                  group by cancelled_date, system_size) as foo)
    into v_total;
    return v_total;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
