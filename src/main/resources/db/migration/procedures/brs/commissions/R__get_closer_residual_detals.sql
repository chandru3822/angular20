drop function if exists brs.get_closer_residual_details(p_closer_user_id bigint);
CREATE or replace function brs.get_closer_residual_details(p_closer_user_id bigint)
  RETURNS table
          (
            user_id                            bigint,
            closer_name                        text,
            required_fdc_residual_this_period  integer,
            qualified_fdc_residual_this_period bigint,
            residual_qualified                 boolean,
            potential_residual                 numeric,
            earned_residual                    numeric,
            total_clawbacks                    numeric,
            manual_adjustments                 numeric,
            total_residual_paid                numeric,
            prior_period_qualified_fdc         integer,
            cancelled_fds_during_period        numeric,
            fda_in_month_not_qualifying        json,
            qualified_fdc                      json,
            current_clawbacks                  json,
            total_qualifying_fdc_to_date       json,
            cancelled_fdc_during_period        integer,
            reactivated_fdc                    integer,
            residual_qualified_fdc             integer
          )
AS
$BODY$
declare
  v_lifetime_fds bigint;
begin
  select count(1)
  into v_lifetime_fds
  from brs.get_residual_qualified_lifetime_fds(p_closer_user_id);

  return query
    select foo.id                                             as user_id,
           foo.closer_name,
           foo.required_fdc_residual_this_period,
           coalesce(foo.qualified_fdc_residual_this_period,0),
           coalesce(foo.qualified_fdc_residual_this_period, 0) >
           coalesce(foo.required_fdc_residual_this_period, 0) as residual_qualified,
           coalesce(foo.potential_residual,0),
           case
             when coalesce(foo.qualified_fdc_residual_this_period, 0) >
                  coalesce(foo.required_fdc_residual_this_period, 0) then
               foo.potential_residual
             else 0.00 end                                    as earned_residual,
           coalesce(foo.total_clawbacks, 0),
           coalesce(foo.manual_adjustments, 0),
           case
             when foo.qualified_fdc_residual_this_period > foo.required_fdc_residual_this_period then
                   coalesce(foo.potential_residual, 0) - coalesce(foo.total_clawbacks, 0) +
                   coalesce(foo.manual_adjustments, 0)
             else 0.00 - coalesce(foo.total_clawbacks, 0) +
                  coalesce(foo.manual_adjustments, 0) end     as total_residual_paid,
           coalesce(foo.prior_period_qualified_fdc, 0),
           coalesce(foo.cancelled_fds_during_period, 0),
           coalesce(foo.fda_in_month_not_qualifying, '[]'),
           coalesce(foo.qualified_fdc, '[]'),
           coalesce(foo.current_clawbacks, '[]'),
           coalesce(foo.total_qualifying_fdc_to_date, '[]'),
           0 as cancelled_fdc_during_period,
           0 as reactivated_fdc,
           0 as residual_qualified_fdc
    from (select u.id,
                 concat(u.first_name, ' ', u.last_name)                                                                                as closer_name,
                 rpa.allocation                                                                                                        as required_fdc_residual_this_period,
                 (select count(1)
                  from brs.get_residual_fds_qualified_this_period(u.id))                                                               as qualified_fdc_residual_this_period,
                 v_lifetime_fds * rp.total                                                                                             as potential_residual,
                 (select * from brs.get_total_residual_clawbacks(u.id))                                                                as total_clawbacks,
                 (select sum(ra.amount)
                  from brs.residual_adjustment ra
                  where ra.user_id = u.id
                    and ra.residual_id = (select id from brs.residual r where current is true))                                        as manual_adjustments,
                 (select urs.qualified_fdc_in_period
                  from brs.user_residual_snapshot urs
                  where urs.user_id = u.id
                  order by residual_id desc
                  limit 1)                                                                                                             as prior_period_qualified_fdc,
                 (select sum(cancelled_count)
                  from (select count(1) as cancelled_count, rl.project_id
                        from brs.project_details pd
                               inner join brs.residual_ledger rl on rl.user_id = pd.closer_user_id and
                                                                    rl.ledger_type_id = 4 and
                                                                    rl.residual_clawback_paid is false
                        where pd.closer_user_id = u.id
                        group by rl.project_id) as foo)                                                                                as cancelled_fds_during_period,
                 (select array_to_json(array_agg(row_to_json(fda_not_qualifying)))
                  from (select p.contact_name,
                               fds_nq.project_id,
                               fds_nq.final_design_signed_date,
                               fds_nq.cancelled_date,
                               fds_nq.first_cash_payment_amount,
                               fds_nq.utility_bill_verified_date,
                               fds_nq.on_hold_date
                        from brs.get_residual_fds_not_qualified_this_period(u.id) as fds_nq
                               inner join brs.project_details p on p.project_id = fds_nq.project_id) as fda_not_qualifying)            as fda_in_month_not_qualifying,
                 (select array_to_json(array_agg(row_to_json(qualified_fdc1)))
                  from (select p.contact_name, fds_nq.project_id
                        from brs.get_residual_fds_qualified_this_period(u.id) as fds_nq
                               inner join brs.project_details p on p.project_id = fds_nq.project_id) as qualified_fdc1)                as qualified_fdc,
                 (select array_to_json(array_agg(row_to_json(current_clawbacks1)))
                  from (select p.contact_name,
                               fds_nq.project_id,
                               (select sum(amount) from brs.get_current_residual_clawbacks(u.id))  as total_clawbacks,
                               (select sum(amount) from brs.get_existing_residual_clawbacks(u.id)) as existing_clawbacks
                        from brs.get_current_residual_clawbacks(u.id) as fds_nq
                               inner join brs.project_details p on p.project_id = fds_nq.project_id
                        group by p.contact_name, fds_nq.project_id) as current_clawbacks1)                                             as current_clawbacks,
                 (select array_to_json(array_agg(row_to_json(total_qualifying_fdc_to_date1)))
                  from (select p.contact_name, fds_nq.project_id, rp.total
                        from brs.get_residual_qualified_lifetime_fds(u.id) as fds_nq
                               inner join brs.project_details p on p.project_id = fds_nq.project_id) as total_qualifying_fdc_to_date1) as total_qualifying_fdc_to_date

          from flow.user u
                 inner join brs.residual_plan_user rpu on rpu.user_id = u.id and
                                                          (rpu.end_date is null or
                                                           now() at time zone 'US/Mountain' between rpu.start_date and rpu.end_date)
                 inner join brs.residual_plan rp on rp.id = rpu.residual_plan_id
                 inner join brs.residual_plan_allocation rpa on rpa.residual_plan_id = rp.id and
                                                                v_lifetime_fds >= rpa.min and
                                                                v_lifetime_fds < greatest(rpa.max, 10000000)
          where u.id = p_closer_user_id) as foo;


END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
