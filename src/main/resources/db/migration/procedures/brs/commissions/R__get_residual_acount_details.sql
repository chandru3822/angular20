DROP FUNCTION IF EXISTS brs.get_residual_account_details();
CREATE OR REPLACE FUNCTION brs.get_residual_account_details()
  RETURNS TABLE
          (
            first_name                 varchar,
            last_name                  varchar,
            user_id                    bigint,
            employee_id                text,
            region_name                varchar,
            office_name                varchar,
            office_state               varchar,
            user_position_name         varchar,
            user_full_name             text,
            user_status_type           varchar,
            hire_date                  date,
            residual_start_date        date,
            residual_plan_name         text,
            lifetime_fdc               bigint,
            qualified_this_period_fdc  bigint,
            fds_not_qualified          bigint,
            required_fdc_per_month     integer,
            residual_earned            boolean,
            percent_of_residual_earned numeric,
            potential_residual         numeric,
            earned_residual            numeric,
            clawback                   numeric,
            adjustment_override        numeric,
            total                      numeric
          )
  LANGUAGE plpgsql
AS
$$
declare
  v_period_end                date;
  v_period_start              date;
  v_previous_grace_period_end date;
  v_grace_period_end          date;
begin

  select period_start, period_end, previous_grace_period_end, grace_period_end
  into v_period_start,v_period_end,v_previous_grace_period_end,v_grace_period_end
  from brs.residual r2
  where current is true;

  return query
    select foo1.first_name,
           foo1.last_name,
           foo1.user_id,
           foo1.employee_id,
           foo1.region_name,
           foo1.office_name,
           foo1.office_state,
           foo1.user_position_name,
           foo1.user_full_name,
           foo1.user_status_type,
           foo1.hire_date,
           foo1.residual_start_date,
           foo1.residual_plan_name,
           foo1.lifetime_fdc,
           foo1.qualified_this_period_fdc,
           foo1.fds_not_qualified,
           foo1.required_fdc_per_month,
           foo1.residual_earned,
           foo1.percent_of_residual_earned,
           foo1.potential_residual,
           case
             when foo1.residual_earned is true then
               foo1.potential_residual
             else 0.00 end as earned_residual,
           foo1.clawback,
           foo1.adjustment_override,
           case
             when foo1.residual_earned is true or foo1.clawback > 0 then
               foo1.potential_residual - foo1.clawback + foo1.adjustment_override
             else 0.00 end as total
    from (select *,
                 rpa.allocation                                                   as required_fdc_per_month,
                 case
                   when rppa.id is null then
                     foo.qualified_this_period_fdc >= rpa.allocation
                   when rppa.id is not null and foo.qualified_this_period_fdc = rppa.fdc_count then
                     true end                                                     as residual_earned,
                 case
                   when rppa.id is null then
                     case
                       when foo.qualified_this_period_fdc >= rpa.allocation then
                         100
                       else 0 end
                   else coalesce(rppa.partial_allocation, 100) end                as percent_of_residual_earned,
                 case
                   when rppa.id is null then
                     foo.lifetime_fdc * foo.total
                   when rppa.id is not null and foo.qualified_this_period_fdc = rppa.fdc_count then
                     foo.lifetime_fdc * (rppa.partial_allocation * foo.total) end as potential_residual
          from (select u.first_name,
                       u.last_name,
                       u.id                                                                  as user_id,
                       ucfv.text_value                                                       as employee_id,
                       (select org_name
                        from flow.user_positions_vw upv
                        where upv.user_id = u.id
                          and upv.primary_flag is true
                          and upv.org_level_id = 10
                        limit 1)                                                             as region_name,
                       (select org_name
                        from flow.user_positions_vw upv
                        where upv.user_id = u.id
                          and upv.primary_flag is true
                          and upv.org_level_id = 11
                        limit 1)                                                             as office_name,
                       (select s.abbreviation
                        from flow.user_positions_vw upv
                               inner join flow.company_state cs on cs.id = upv.company_state_id
                               inner join flow.state s on s.id = cs.state_id
                        where upv.user_id = u.id
                          and upv.primary_flag is true
                          and upv.org_level_id = 11
                        limit 1)                                                             as office_state,
                       (select p.position
                        from flow.user_position up
                               inner join flow.position p on p.id = up.position_id
                        where up.user_id = u.id
                          and up.primary_flag is true
                        limit 1)                                                             as user_position_name,
                       concat(u.first_name, ' ', u.last_name)                                as user_full_name,
                       ust.user_status_type,
                       ucfv2.date_value                                                      as hire_date,
                       rpu.start_date                                                        as residual_start_date,
                       rp.name                                                               as residual_plan_name,
                       rp.id                                                                 as residual_plan_id,
                       (select count(1)
                        from brs.get_residual_qualified_lifetime_fds(u.id))                  as lifetime_fdc,
                       (select count(1)
                        from brs.get_residual_fds_qualified_this_period(u.id,
                                                                        v_period_end,
                                                                        v_period_start,
                                                                        v_previous_grace_period_end,
                                                                        v_grace_period_end)) as qualified_this_period_fdc,
                       (select count(1)
                        from brs.get_residual_fds_not_qualified_this_period(u.id))           as fds_not_qualified,
                       (select * from brs.get_total_residual_clawbacks(u.id))                as clawback,
                       rp.total,
                       coalesce((select sum(ra.amount)
                                 from brs.residual_adjustment ra
                                 where ra.user_id = u.id and ra.residual_id = r.id), 0)      as adjustment_override
                from flow."user" u
                       left join flow.user_custom_field_value ucfv
                                 on ucfv.user_id = u.id and ucfv.custom_field_group_assignment_id = 19176
                       inner join flow.company_user_status cus on cus.user_id = u.id
                       inner join flow.user_status_type ust
                                  on ust.id = cus.user_status_type_id and ust.company_id = 3 and ust.id in (9, 14)
                       left join flow.user_custom_field_value ucfv2
                                 on u.id = ucfv2.user_id and ucfv2.custom_field_group_assignment_id = 331
                       inner join brs.user_residual ur on ur.user_id = u.id
                       inner join brs.residual_plan rp on rp.id = ur.residual_plan_id and rp.residual_plan_status_id = 2
                       inner join brs.residual_plan_user rpu on rpu.residual_plan_id = rp.id and rpu.user_id = u.id
                       left join brs.residual r on r.current is true and r.period_end is not null
                where u.id in (2438980,
                               2433935,
                               2353957) and exists(select id
                             from flow.user_position up2
                             where up2.user_id = u.id
                               and up2.position_id in (1, 2, 3, 517)
                               and up2.primary_flag is true)) as foo
                 inner join brs.residual_plan_allocation rpa on rpa.residual_plan_id = foo.residual_plan_id and
                                                                foo.lifetime_fdc between rpa.min and coalesce(rpa.max, 1000000)
                 left join brs.residual_plan_partial_allocation rppa on rppa.residual_plan_allocation_id = rpa.id and
                                                                        rppa.fdc_count =
                                                                        foo.qualified_this_period_fdc) as foo1
    where foo1.lifetime_fdc > 0
       or foo1.clawback != 0;

END
$$;
