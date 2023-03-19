drop function if exists brs.get_closer_residual_details(p_closer_user_id bigint, p_date date);
CREATE or replace function brs.get_closer_residual_details(p_closer_user_id bigint, p_date date)
  RETURNS table
          (
            user_id                            bigint,
            closer_name                        text,
            required_fdc_residual_this_period  integer,
            qualified_fdc_residual_this_period bigint,
            residual_qualified                 boolean,
            has_current_snapshot               boolean,
            potential_residual                 numeric,
            earned_residual                    numeric,
            total_clawbacks                    numeric,
            manual_adjustments                 numeric,
            total_residual_paid                numeric,
            has_previous_snapshot              boolean,
            prior_period_qualified_fdc         integer,
            fda_in_month_not_qualifying        json,
            qualified_fdc                      json,
            clawback_projects                  json,
            total_qualifying_fdc_to_date       json,
            cancelled_fdc_during_period        integer,
            reactivated_fdc                    bigint,
            residual_qualified_fdc             bigint,
            no_previous_month_message          text
          )
AS
$BODY$
declare
  v_lifetime_fds              bigint;
  v_period_end                date;
  v_period_start              date;
  v_previous_grace_period_end date;
  v_grace_period_end          date;
  v_no_previous_month_message text;
  v_has_current_snapshot_id   bigint;
  v_has_previous_snapshot_id  bigint;
begin

  select s.id
  into v_has_current_snapshot_id
  from brs.user_residual_snapshot s
         inner join brs.residual r2 on r2.id = s.residual_id
  where r2.period_start = p_date;

  select s.id
  into v_has_previous_snapshot_id
  from brs.user_residual_snapshot s
         inner join brs.residual r2 on r2.id = s.residual_id
  where r2.period_start = p_date - interval '1 month';

  select value
  into v_no_previous_month_message
  from flow.company_configuration_value ccv
  where code = 'RESIDUAL_NO_PRIOR_MONTH';

  SELECT (date_trunc('month', p_date + interval '1 month') - interval '1 day')::date
  into v_period_end;

  select cast(date_trunc('month', p_date) as date)
  into v_period_start;

  select cast(date_trunc('month', p_date) as date) + 14
  into v_previous_grace_period_end;

  select cast(date_trunc('month', p_date + interval '1 month') as date) + 14
  into v_grace_period_end;


  select count(1)
  into v_lifetime_fds
  from brs.get_residual_qualified_lifetime_fds(p_closer_user_id);

  case
    when v_has_current_snapshot_id is null then return query
      select foo.id                                                                as user_id,
             foo.closer_name,
             foo.required_fdc_residual_this_period,
             coalesce(foo.qualified_fdc_residual_this_period, 0),
             coalesce(foo.qualified_fdc_residual_this_period, 0) >=
             coalesce(foo.required_fdc_residual_this_period, 0)                    as residual_qualified,
             false                                                                 as has_current_snapshot,
             coalesce(foo.potential_residual, 0),
             case
               when coalesce(foo.qualified_fdc_residual_this_period, 0) >=
                    coalesce(foo.required_fdc_residual_this_period, 0) then
                 foo.potential_residual
               else 0.00 end                                                       as earned_residual,
             coalesce(foo.total_clawbacks, 0),
             coalesce(foo.manual_adjustments, 0),
             case
               when foo.qualified_fdc_residual_this_period >= foo.required_fdc_residual_this_period then
                     coalesce(foo.potential_residual, 0) - coalesce(foo.total_clawbacks, 0) +
                     coalesce(foo.manual_adjustments, 0)
               else 0.00 - coalesce(foo.total_clawbacks, 0) +
                    coalesce(foo.manual_adjustments, 0) end                        as total_residual_paid,
             case when v_has_previous_snapshot_id is null then false else true end as has_previous_snapshot,
             coalesce(foo.prior_period_qualified_fdc, 0)                           as prior_period_qualified_fdc,
             coalesce(foo.fda_in_month_not_qualifying, '[]'),
             coalesce(foo.qualified_fdc, '[]'),
             coalesce(foo.clawback_projects, '[]'),
             coalesce(foo.total_qualifying_fdc_to_date, '[]'),
             foo.cancelled_fdc_during_period                                       as cancelled_fdc_during_period,
             coalesce(v_lifetime_fds, 0) - coalesce(foo.prior_period_qualified_fdc, 0) -
             coalesce(foo.qualified_fdc_residual_this_period, 0) +
             coalesce(foo.cancelled_fdc_during_period, 0)                          as reactivated_fdc,
             foo.residual_qualified_fdc                                            as residual_qualified_fdc,
             v_no_previous_month_message
      from (select u.id,
                   concat(u.first_name, ' ', u.last_name)                                                                                as closer_name,
                   rpa.allocation                                                                                                        as required_fdc_residual_this_period,
                   (select count(1)
                    from brs.get_residual_fds_qualified_this_period(u.id,
                                                                    v_period_end,
                                                                    v_period_start,
                                                                    v_previous_grace_period_end,
                                                                    v_grace_period_end))                                                 as qualified_fdc_residual_this_period,
                   v_lifetime_fds * rp.total                                                                                             as potential_residual,
                   (select * from brs.get_total_residual_clawbacks(u.id))                                                                as total_clawbacks,
                   (select sum(ra.amount)
                    from brs.residual_adjustment ra
                    where ra.user_id = u.id
                      and ra.residual_id = (select id from brs.residual r where current is true))                                        as manual_adjustments,
                   coalesce(
                     (select urs.lifetime_qualified_fds
                      from brs.user_residual_snapshot urs
                      where urs.user_id = u.id
                        and urs.id = v_has_previous_snapshot_id),
                     0)                                                                                                                  as prior_period_qualified_fdc,

                   (select array_to_json(array_agg(row_to_json(fda_not_qualifying)))
                    from (select p.contact_name,
                                 fds_nq.project_id,
                                 fds_nq.final_design_signed_date,
                                 fds_nq.final_design_complete_date,
                                 fds_nq.utility_bill_verified_date,
                                 fds_nq.financial_agreement_signed_date,
                                 fds_nq.proof_of_homeowners_insurance_obtained_date,
                                 fds_nq.proof_of_homeowners_insurance_required,
                                 fds_nq.substantial_completion_date,
                                 fds_nq.cancelled_date,
                                 fds_nq.on_hold_date,
                                 fds_nq.total_cash_down_payment,
                                 fds_nq.first_cash_payment_amount
                          from brs.get_residual_fds_not_qualified_this_period(u.id) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id) as fda_not_qualifying)            as fda_in_month_not_qualifying,
                   (select array_to_json(array_agg(row_to_json(qualified_fdc1)))
                    from (select p.contact_name,
                                 fds_nq.project_id,
                                 fds_nq.final_design_signed_date,
                                 fds_nq.final_design_complete_date,
                                 fds_nq.utility_bill_verified_date,
                                 fds_nq.financial_agreement_signed_date,
                                 fds_nq.proof_of_homeowners_insurance_obtained_date,
                                 fds_nq.proof_of_homeowners_insurance_required,
                                 fds_nq.substantial_completion_date,
                                 fds_nq.cancelled_date,
                                 fds_nq.on_hold_date,
                                 fds_nq.total_cash_down_payment,
                                 fds_nq.first_cash_payment_amount
                          from brs.get_residual_fds_qualified_this_period(u.id,
                                                                          v_period_end,
                                                                          v_period_start,
                                                                          v_previous_grace_period_end,
                                                                          v_grace_period_end) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id) as qualified_fdc1)                as qualified_fdc,
                   (select array_to_json(array_agg(row_to_json(current_clawbacks1)))
                    from (select p.contact_name,
                                 fds_nq.project_id,
                                 p.cancelled_date,
                                 (select sum(amount)
                                  from brs.get_current_residual_clawbacks(u.id))  as current_clawbacks,
                                 (select sum(amount)
                                  from brs.get_existing_residual_clawbacks(u.id)) as existing_clawbacks
                          from brs.get_current_residual_clawbacks(u.id) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id
                          group by p.contact_name, fds_nq.project_id, p.cancelled_date) as current_clawbacks1)                           as clawback_projects,
                   (select array_to_json(array_agg(row_to_json(total_qualifying_fdc_to_date1)))
                    from (select p.contact_name, fds_nq.project_id
                          from brs.get_residual_qualified_lifetime_fds(u.id) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id) as total_qualifying_fdc_to_date1) as total_qualifying_fdc_to_date,
            (select count(1)
            from (
              (select count(1), project_id from brs.get_current_residual_clawbacks(u.id) group by project_id)) as foo
            group by foo.project_id) as cancelled_fdc_during_period,
              coalesce (v_lifetime_fds, 0) as residual_qualified_fdc

            from flow.user u
              inner join brs.residual_plan_user rpu
            on rpu.user_id = u.id and
              (rpu.end_date is null or
              now() at time zone 'US/Mountain' between rpu.start_date and rpu.end_date)
              inner join brs.residual_plan rp on rp.id = rpu.residual_plan_id
              inner join brs.residual_plan_allocation rpa on rpa.residual_plan_id = rp.id and
              v_lifetime_fds between rpa.min and
              coalesce (rpa.max, 10000000)
            where u.id = p_closer_user_id) as foo;
    when v_has_current_snapshot_id is not null then return query
      select foo.user_id,
             foo.closer_name,
             foo.required_fdc_residual_this_period,
             foo.qualified_fdc_residual_this_period,
             foo.residual_qualified,
             foo.has_current_snapshot,
             foo.potential_residual,
             foo.earned_residual,
             foo.total_clawbacks,
             foo.manual_adjustments,
             foo.total_residual_paid,
             foo.has_previous_snapshot,
             foo.prior_period_qualified_fdc,
             foo.fda_in_month_not_qualifying,
             foo.qualified_fdc,
             foo.clawback_projects,
             foo.total_qualifying_fdc_to_date,
             foo.cancelled_fdc_during_period,
             v_lifetime_fds - prior_period_qualified_fdc - foo.qualified_fdc_residual_this_period +
             foo.cancelled_fdc_during_period as reactivated_fdc,
             foo.residual_qualified_fdc,
             foo.v_no_previous_month_message
      from (select urs2.user_id,
                   urs2.user_full_name                                                                as closer_name,
                   coalesce(urs2.required_fdc_per_month, 0)                                              required_fdc_residual_this_period,
                   coalesce(urs2.qualified_fdc_in_period, 0)                                             qualified_fdc_residual_this_period,
                   coalesce(urs2.qualified_fdc_in_period, 0) >=
                   coalesce(urs2.required_fdc_per_month, 0)                                           as residual_qualified,
                   true                                                                               as has_current_snapshot,
                   coalesce(urs2.potential_residual, 0)                                               as potential_residual,
                   coalesce(urs2.earned_residual, 0)                                                  as earned_residual,
                   coalesce(urs2.clawback, 0)                                                         as total_clawbacks,
                   coalesce(urs2.adjustment_override, 0)                                              as manual_adjustments,
                   coalesce(urs2.residual_total, 0)                                                   as total_residual_paid,
                   case when v_has_previous_snapshot_id is not null then true else false end          as has_previous_snapshot,
                   coalesce((select urs3.lifetime_qualified_fds
                             from brs.user_residual_snapshot urs3
                             where urs3.user_id = p_closer_user_id
                               and urs3.id = v_has_previous_snapshot_id),
                            0)                                                                        as prior_period_qualified_fdc,

                   (select array_to_json(array_agg(row_to_json(fda_not_qualifying)))
                    from (select p2.contact_name,
                                 urps.project_id,
                                 urps.final_design_signed_date,
                                 urps.final_design_complete_date,
                                 urps.utility_bill_verified_date,
                                 urps.financial_agreement_signed_date,
                                 urps.proof_of_homeowners_insurance_obtained_date,
                                 urps.proof_of_homeowners_insurance_required,
                                 urps.substantial_completion_date,
                                 urps.cancelled_date,
                                 urps.on_hold_date,
                                 urps.total_cash_down_payment,
                                 urps.first_cash_payment_amount
                          from brs.user_residual_snapshot urs
                                 inner join brs.user_residual_project_snapshot urps
                                            on urps.user_residual_snapshot_id = urs.id
                                 inner join brs.project_details p2 on p2.id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code =
                                               'FDS_NOT_QUALIFIED_THIS_PERIOD'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as fda_not_qualifying)            as fda_in_month_not_qualifying,
                   (select array_to_json(array_agg(row_to_json(qualified_fdc1)))
                    from (select p2.contact_name,
                                 urps.project_id,
                                 urps.final_design_signed_date,
                                 urps.final_design_complete_date,
                                 urps.utility_bill_verified_date,
                                 urps.financial_agreement_signed_date,
                                 urps.proof_of_homeowners_insurance_obtained_date,
                                 urps.proof_of_homeowners_insurance_required,
                                 urps.substantial_completion_date,
                                 urps.cancelled_date,
                                 urps.on_hold_date,
                                 urps.total_cash_down_payment,
                                 urps.first_cash_payment_amount
                          from brs.user_residual_snapshot urs
                                 inner join brs.user_residual_project_snapshot urps
                                            on urps.user_residual_snapshot_id = urs.id
                                 inner join brs.project_details p2 on p2.id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code = 'FDS_QUALIFIED_THIS_PERIOD'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as qualified_fdc1)                as qualified_fdc,
                   (select array_to_json(array_agg(row_to_json(current_clawbacks1)))
                    from (select p2.contact_name,
                                 urps.project_id,
                                 urps.cancelled_date,
                                 urps.total
                          from brs.user_residual_snapshot urs
                                 inner join brs.user_residual_project_snapshot urps
                                            on urps.user_residual_snapshot_id = urs.id
                                 inner join brs.project_details p2 on p2.id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code = 'CLAWBACKS'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as current_clawbacks1)            as clawback_projects,
                   (select array_to_json(array_agg(row_to_json(total_qualifying_fdc_to_date1)))
                    from (select p2.contact_name,
                                 urps.project_id
                          from brs.user_residual_snapshot urs
                                 inner join brs.user_residual_project_snapshot urps
                                            on urps.user_residual_snapshot_id = urs.id
                                 inner join brs.project_details p2 on p2.id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code = 'LIFETIME_QUALIFIED_FDS'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as total_qualifying_fdc_to_date1) as total_qualifying_fdc_to_date,
            (select count(1)
            from (
              (select count(1), project_id from brs.get_user_residual_project_snapshot_by_type(urs2.residual_id, urs2.user_id, 4) group by project_id)) as foo
            group by foo.project_id) as cancelled_fdc_during_period,
              coalesce (v_lifetime_fds, 0) as residual_qualified_fdc,
              v_no_previous_month_message as v_no_previous_month_message
            from brs.user_residual_snapshot urs2
            where urs2.id = v_has_current_snapshot_id) as foo;

    end case;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;



select *
from flow.user;
