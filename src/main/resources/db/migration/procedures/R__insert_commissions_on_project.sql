CREATE OR REPLACE FUNCTION brs.insert_commissions_on_project(p_project_id integer)

RETURNS void
    LANGUAGE plpgsql
    AS $function$
declare
    v_override_plan_id integer;
    v_commission_plan_id integer;
    v_user_id integer;
BEGIN

    select user_id
    into v_user_id
    from flow.user_project up
    inner join flow.user_position up1 on up1.id = up.user_position_id
    where up.project_id = p_project_id and up1.position_id = 1 and
          up.end_date is null;

    select op.id
    into v_override_plan_id
    from brs.override_plan op
    inner join brs.override_plan_assigned_user opau on opau.override_plan_id = op.id and opau.user_id = v_user_id
    where (now() AT TIME ZONE 'US/Mountain') >= opau.start_date and case when opau.end_date is not null then
                                                                             (now() AT TIME ZONE 'US/Mountain') <= opau.end_date else 1=1 end;

    select cp.id
    into v_commission_plan_id
    from brs.commission_plan cp
             inner join brs.commission_plan_user cpu on cpu.commission_plan_id = cp.id and cpu.user_id = v_user_id
    where (now() AT TIME ZONE 'US/Mountain') >= cpu.start_date and case when cpu.end_date is not null then
                                                                                 (now() AT TIME ZONE 'US/Mountain') <= cpu.end_date else 1=1 end;

    insert into brs.project_commission( project_id, commission_plan_id)
    values (p_project_id,v_commission_plan_id);

    insert into brs.project_override( project_id, override_plan_id)
    values (p_project_id,v_override_plan_id);

END;
$function$
