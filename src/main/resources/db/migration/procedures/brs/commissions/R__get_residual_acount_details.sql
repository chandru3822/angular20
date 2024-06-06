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
            residual_plan_id           bigint,
            lifetime_fdc               bigint,
            lifetime_system_size       numeric,
            qualified_this_period_fdc  bigint,
            fds_not_qualified          bigint,
            required_fdc_per_month     integer,
            residual_earned            boolean,
            percent_of_residual_earned numeric,
            potential_residual         numeric,
            earned_residual            numeric,
            current_clawback           numeric,
            existing_clawback          numeric,
            total_clawback             numeric,
            adjustment_override        numeric,
            total                      numeric,
            qualified_this_period_system_size numeric,
              system_size_by_source numeric
          )
  LANGUAGE plpgsql
AS
$$
begin

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
           foo1.residual_plan_id1,
           foo1.lifetime_fdc,
           foo1.lifetime_system_size,
           foo1.qualified_this_period_fdc,
           foo1.fds_not_qualified,
           foo1.required_fdc_per_month,
           foo1.residual_earned,
           foo1.percent_of_residual_earned,
           foo1.potential_residual,
           case
             when foo1.residual_earned is true and foo1.user_id = any(foo1.selected_user_ids) then
               foo1.potential_residual
             else 0.00 end as earned_residual,
           foo1.current_clawback,
           foo1.existing_clawback,
           foo1.total_clawback,
           foo1.adjustment_override,
           case
             when foo1.residual_earned is true and foo1.user_id = any(foo1.selected_user_ids) and
                  coalesce(foo1.potential_residual,0) + coalesce(foo1.adjustment_override,0) - coalesce(foo1.total_clawback,0) > 0 then
                 coalesce(foo1.potential_residual,0) + coalesce(foo1.adjustment_override,0) - coalesce(foo1.total_clawback,0)
             when foo1.residual_earned is false and foo1.user_id = any(foo1.selected_user_ids) and coalesce(foo1.adjustment_override,0) > coalesce(foo1.total_clawback,0)  then
                 coalesce(foo1.adjustment_override,0) - coalesce(foo1.total_clawback,0)
             else 0.00 end as total,
          foo1.qualified_this_period_system_size1,
          foo1.system_size_by_source1
    from (select *,
                 rpa.allocation                                                   as required_fdc_per_month,
                 case
                   when alloc.partial_allocation is null then
                     case when foo.is_system_size is true then
                            foo.qualified_this_period_system_size >= rpa.allocation
                    else
                     foo.qualified_this_period_fdc >= rpa.allocation end
                   when alloc.partial_allocation is not null then
                     true end                                                     as residual_earned,
                 case
                   when alloc.partial_allocation is null then
                     case
                       when foo.is_system_size is true and foo.qualified_this_period_system_size >= rpa.allocation then
                         1
                       when foo.is_system_size is false and foo.qualified_this_period_fdc >= rpa.allocation then
                         1
                       else 0 end
                   else coalesce(alloc.partial_allocation, 1) end                as percent_of_residual_earned,
                     foo.lifetime_earned as potential_residual,
                 foo.qualified_this_period_system_size as qualified_this_period_system_size1,
                 foo.system_size_by_source as system_size_by_source1
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
                       rp.id                                                                 as residual_plan_id1,
                       (select count(1)
                        from brs.get_residual_qualified_lifetime_fds(u.id)
                        where is_system_size is false)                  as lifetime_fdc,
                       (select sum(system_size)
                        from brs.get_residual_qualified_lifetime_fds(u.id)
                        where is_system_size is true)                  as lifetime_system_size,
                       (select sum(expected_residual)
                        from brs.get_residual_qualified_lifetime_fds(u.id))                  as lifetime_earned,
                       (select count(1)
                        from brs.get_residual_fds_qualified_this_period(u.id,false)) as qualified_this_period_fdc,
                       (select sum(ao.system_size_adjusted_for_source) as qualified_this_period_system_size
                        from brs.get_residual_fds_qualified_this_period(u.id,false)as ao) as qualified_this_period_system_size,
                       (select sum(ao.system_size_by_source) as system_size_by_source
                        from brs.get_residual_fds_qualified_this_period(u.id,false)as ao) as system_size_by_source,
                       (select count(1)
                        from brs.get_residual_fds_not_qualified_this_period(u.id))           as fds_not_qualified,
                       coalesce((select sum(amount)  from brs.get_current_residual_clawbacks(u.id)),0) as current_clawback,
                       coalesce((select sum(amount) from brs.get_existing_residual_clawbacks(u.id)),0) as existing_clawback,
                       coalesce((select * from brs.get_total_residual_clawbacks(u.id)),0)                as total_clawback,
                       rp.total,
                       coalesce((select sum(ra.amount)
                                 from brs.residual_adjustment ra
                                 where ra.user_id = u.id and ra.residual_id = r.id), 0)      as adjustment_override,
                      r.selected_user_ids as selected_user_ids,
                      rp.is_system_size
                from flow."user" u
                       left join flow.user_custom_field_value ucfv
                                 on ucfv.user_id = u.id and ucfv.custom_field_group_assignment_id = 19176
                       inner join flow.company_user_status cus on cus.user_id = u.id
                       inner join flow.user_status_type ust
                                  on ust.id = cus.user_status_type_id and ust.company_id = 3 and ust.id in (9, 14)
                       left join flow.user_custom_field_value ucfv2
                                 on u.id = ucfv2.user_id and ucfv2.custom_field_group_assignment_id = 331
                       inner join brs.residual r on r.current is true
                       inner join brs.residual_plan_user rpu1 on rpu1.user_id = u.id and
                                                                r.period_end >= rpu1.start_date and
                                                                (rpu1.end_date is null or r.period_end <= rpu1.end_date)
                       inner join brs.residual_plan rp on rp.id = rpu1.residual_plan_id and rp.residual_plan_status_id = 2
                       inner join brs.residual_plan_user rpu on rpu.residual_plan_id = rp.id and rpu.user_id = u.id

                where
                      -- u.id in (2402401,2353957,2401231) and
                      exists(select id
                             from flow.user_position up2
                             where up2.user_id = u.id
                               and up2.position_id in (1, 2, 3, 517)
                               and up2.primary_flag is true)) as foo
                 inner join brs.residual_plan rp2 on rp2.id = foo.residual_plan_id1
                 inner join brs.residual_plan_allocation rpa on rpa.residual_plan_id = rp2.id and
                                                                foo.lifetime_fdc between rpa.min and coalesce(rpa.max, 1000000)
                 inner join brs.residual_plan_allocation a on a.residual_plan_id = foo.residual_plan_id1 and
                                                              foo.lifetime_fdc between a.min and coalesce(a.max, 1000000)
                 left join lateral (select partial_allocation
                                    from brs.residual_plan_partial_allocation rppa
                                           inner join brs.residual_plan_partial_allocation_type rppat
                                                      on rppat.id = rppa.residual_plan_partial_allocation_type_id
                                    where rppa.residual_plan_allocation_id = a.id
                                      and case
                                            when rp2.is_based_on_source is true then
                                              ((foo.system_size_by_source >= rppa.fdc_count and
                                                rppa.residual_plan_partial_allocation_type_id = 2) or
                                               (foo.qualified_this_period_system_size >= rppa.fdc_count and
                                                rppa.residual_plan_partial_allocation_type_id = 1)) and
                                              foo.qualified_this_period_system_size < a.allocation
                                            when foo.is_system_size is true then
                                              foo.qualified_this_period_system_size >= rppa.fdc_count and
                                              foo.qualified_this_period_system_size < a.allocation
                                            else foo.qualified_this_period_fdc >= rppa.fdc_count and
                                                 foo.qualified_this_period_fdc < a.allocation end
                                    order by case when foo.is_system_size is true then rppa.partial_allocation end desc,
                                             case when foo.is_system_size is false then rppa.fdc_count end desc
                                    limit 1) as alloc on true) as foo1
    where foo1.lifetime_fdc > 0
       or foo1.total_clawback != 0;

END
$$;
