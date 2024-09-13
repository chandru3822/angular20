drop function if exists brs.insert_override_plan_from_template(
  IN p_closer_org_id bigint,
  in p_closer_user_id bigint
);
CREATE OR REPLACE FUNCTION brs.insert_override_plan_from_template(
  IN p_closer_org_id bigint,
  in p_closer_user_id bigint
)
  RETURNS numeric
  LANGUAGE plpgsql AS
$BODY$
declare
  v_sum_allocation              numeric;
  v_template_override_plan_id   bigint;
  v_override_plan_id            bigint;
  v_user_commission_strategy_id bigint[];
BEGIN

  select o.id
  into v_override_plan_id
  from brs.override_plan o
         inner join brs.override_plan_assigned_user opau on opau.override_plan_id = o.id
  where opau.user_id = p_closer_user_id
    and opau.end_date is null;

  if v_override_plan_id is null then

    select int_array_value
    into v_user_commission_strategy_id
    from flow."user" u
           inner join flow.user_custom_field_value ucfv
                      on ucfv.user_id = u.id and custom_field_group_assignment_id = 26897
    where u.id = p_closer_user_id;

    if array_length(v_user_commission_strategy_id, 1) = 1 and v_user_commission_strategy_id && '{24102,24871}' then

      select o.id
      into v_template_override_plan_id
      from brs.override_plan o
             inner join brs.commission_override_custom_field_value cocfv
                        on cocfv.override_plan_id = o.id and cocfv.custom_field_group_assignment_id = 870--stage value
      where o.org_id = p_closer_org_id
        and cocfv.int_value = any (v_user_commission_strategy_id)
        and status_id = 2;

      if v_template_override_plan_id is not null then
        insert into brs.override_plan_assigned_user(override_plan_id, user_id, start_date, end_date, note, date_modified)
        values (v_template_override_plan_id, p_closer_user_id, ((now() AT TIME ZONE 'US/Mountain') :: DATE), null,
                'Auto generated Override plan', now())
        returning override_plan_id into v_override_plan_id;
      end if;
    end if;
  end if;

  if v_override_plan_id is not null then
    select op.id,
           (select sum(opru.m1_allocation + opru.m2_allocation)
            from brs.override_plan_receiving_user opru
            where opru.override_plan_id = op.id)
    into v_override_plan_id,v_sum_allocation
    from brs.override_plan op
    where op.id = v_override_plan_id;
  end if;

  return coalesce(v_sum_allocation, 0);

END ;
$BODY$;
