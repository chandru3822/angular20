drop function if exists brs.get_commission_users(p_include_inactive boolean);
CREATE OR REPLACE FUNCTION brs.get_commission_users(p_include_inactive boolean)
  RETURNS TABLE
          (
            user_id                         bigint,
            name                            text,
            employee_id                     TEXT,
            primary_position                character varying,
            org_name                        character varying,
            user_status_type_id             bigint,
            commission_plan                 text,
            commission_plan_start           date,
            commission_description          text,
            commission_plan_id              bigint,
            override_plan                   text,
            override_plan_start             date,
            override_description            text,
            override_plan_id                bigint,
            residual_plan_id                bigint,
            residual_plan_start             date,
            residual_plan                   text,
            available_commission_strategies text
          )

AS
$BODY$
BEGIN
  return query
    SELECT u.id                                                                                                          AS user_id,
           concat(u.first_name, ' ', u.last_name)                                                                        AS name,
           v.text_value                                                                                                  as employee_id,
           p.position                                                                                                    as primary_position,
           o.org_name,
           ust.id                                                                                                        AS user_status_type_id,
           cp.name                                                                                                       AS commission_plan,
           cpu.start_date                                                                                                as commission_plan_start,
           cp.description                                                                                                AS commission_description,
           cp.id                                                                                                         AS commission_plan_id,
           op.name                                                                                                       AS override_plan,
           opau.start_date                                                                                               as override_plan_start,
           op.description                                                                                                AS override_description,
           op.id                                                                                                         AS override_plan_id,
           rp.id                                                                                                         as residual_plan_id,
           rpu.start_date                                                                                                as residual_plan_start,
           rp.name                                                                                                       as residual_plan,
           (select string_agg(lov.name,',') as available_commission_strategy
                  from (select unnest(int_array_value) avaialbe_commission_strategies, ucfv.user_id
                        from flow.user_custom_field_value ucfv
                        where ucfv.custom_field_group_assignment_id = 26897
                          and int_array_value is not null
                          and ucfv.user_id = u.id) as foo
                         inner join flow.list_of_value lov on lov.id = foo.avaialbe_commission_strategies) as available_commission_strategies
    FROM flow.user u
           INNER JOIN flow.user_position up ON up.user_id = u.id AND
                                               ((up.primary_flag IS TRUE AND up.end_date IS NULL AND
                                                 up.archived IS NOT TRUE) OR
                                                1 = 1)
           inner join flow.position p on p.id = up.position_id
      AND up.id IN (select up5.id
                    from flow.user_position up5
                           inner join flow.custom_field cf on up5.position_id = any (cf.system_list_option_ids) and
                                                              cf.parent_custom_field_id = 9959
                    where up5.primary_flag is true
                      and up5.archived is false
                      and cf.archived is false)
           inner join flow.org o on o.id = up.org_id
           inner join flow.company_user_status cus on cus.user_id = u.id
           inner join flow.user_status_type ust
                      on ust.id = cus.user_status_type_id and ust.company_id = 3
           left join brs.commission_plan_user cpu on cpu.user_id = u.id and cpu.end_date is null
           LEFT JOIN brs.commission_plan cp ON cp.id = cpu.commission_plan_id and cp.position_id = 1
           LEFT JOIN brs.override_plan_assigned_user opau ON opau.user_id = u.id AND
                                                             opau.end_date is null
           LEFT JOIN brs.override_plan op ON opau.override_plan_id = op.id and op.position_id = 1
           left join brs.residual_plan_user rpu on rpu.user_id = u.id and rpu.end_date is null
           left join brs.residual_plan rp on rp.id = rpu.residual_plan_id
           left join flow.user_custom_field_value v on v.user_id = u.id and v.custom_field_group_assignment_id = 19176
    where case
            when p_include_inactive is false then
              ust.id in (9, 14, 16)
            else 1=1 end
--     GROUP BY u.id, o.org_name, u.first_name, u.last_name, ust.id, cp.name, cp.description, cp.id, op.name,
--              op.description, op.id,
--              rp.id, rp.name, v.text_value, p.position, cpu.start_date, opau.start_date, rpu.start_date
    ORDER BY name;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
