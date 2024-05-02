drop function if exists brs.get_closer_residual_details(p_closer_user_id bigint, p_date date);
CREATE or replace function brs.get_closer_residual_details(p_closer_user_id bigint, p_date date)
  RETURNS table
          (
            user_id                            bigint,
            closer_name                        text,
            required_fdc_residual_this_period  numeric,
            qualified_fdc_residual_this_period numeric,
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
            clawback_projects_drilldown        json,
            total_qualifying_fdc_to_date       json,
            cancelled_fdc_during_period        bigint,
            reactivated_fdc                    numeric,
            residual_qualified_fdc             bigint,
            no_previous_month_message          text,
            is_system_size                     boolean,
            total_existing_clawbacks           numeric,
            total_current_clawbacks            numeric
          )
AS
$BODY$
declare
  v_lifetime_fds              bigint;
  v_sum_system_size_qualified              numeric;
  v_system_size_by_source numeric;
  v_count_qualified_fdc bigint;
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
  where r2.period_start = p_date
    --todo: @scott i am pretty sure this needs to be here. check with me -randa
    and s.user_id = p_closer_user_id
  ;

  select s.id
  into v_has_previous_snapshot_id
  from brs.user_residual_snapshot s
         inner join brs.residual r2 on r2.id = s.residual_id
  where r2.period_start = p_date - interval '1 month'
    and s.user_id = p_closer_user_id;

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
  from brs.get_residual_qualified_lifetime_fds(p_closer_user_id,v_period_end,v_grace_period_end);

  select count(1),sum(system_size_adjusted_for_source),sum(system_size_by_source)
  into v_count_qualified_fdc,v_sum_system_size_qualified,v_system_size_by_source
  from brs.get_residual_fds_qualified_this_period(p_closer_user_id,
                                                  v_period_end,
                                                  v_period_start,
                                                  v_previous_grace_period_end,
                                                  v_grace_period_end);

  case
    when v_has_current_snapshot_id is null then return query
      select foo.id                                                                as user_id,
             foo.closer_name,
             foo.required_fdc_residual_this_period::numeric,
             coalesce(foo.qualified_fdc_residual_this_period, 0)::numeric,
             ((coalesce(foo.qualified_fdc_residual_this_period, 0) >=
             coalesce(foo.required_fdc_residual_this_period, 0)) or partial_allocation is not null)                                                         as residual_qualified,
             false                                                                                                       as has_current_snapshot,
             (SELECT SUM((json_element ->> 'expected_residual')::numeric) AS total_amount
              FROM (SELECT json_array_elements(foo.total_qualifying_fdc_to_date) AS json_element) as potential_residual) as potential_residual,
             case
               when ((coalesce(foo.qualified_fdc_residual_this_period, 0) >=
                    coalesce(foo.required_fdc_residual_this_period, 0)) or partial_allocation is not null) then
                 (SELECT SUM((json_element ->> 'expected_residual')::numeric) AS total_amount
                  FROM (SELECT json_array_elements(foo.total_qualifying_fdc_to_date) AS json_element) as potential_residual)
               else 0.00 end                                                                                             as earned_residual,
             coalesce(foo.total_clawbacks, 0),
             coalesce(foo.manual_adjustments, 0),
             case
               when ((coalesce(foo.qualified_fdc_residual_this_period, 0) >=
                      coalesce(foo.required_fdc_residual_this_period, 0)) or partial_allocation is not null) then
                 (SELECT SUM((json_element ->> 'expected_residual')::numeric) AS total_amount
                  FROM (SELECT json_array_elements(foo.total_qualifying_fdc_to_date) AS json_element) as potential_residual) - coalesce(foo.total_clawbacks, 0) +
                     coalesce(foo.manual_adjustments, 0)
               else 0.00 - coalesce(foo.total_clawbacks, 0) +
                    coalesce(foo.manual_adjustments, 0) end                        as total_residual_paid,
             case when v_has_previous_snapshot_id is null then false else true end as has_previous_snapshot,
             coalesce(foo.prior_period_qualified_fdc, 0)                           as prior_period_qualified_fdc,
             coalesce(foo.fda_in_month_not_qualifying, '[]')::json,
             coalesce(foo.qualified_fdc, '[]')::json,
             coalesce(foo.clawback_projects, '[]')::json,
             coalesce(foo.clawback_projects_drilldown, '[]')::json,
             coalesce(foo.total_qualifying_fdc_to_date, '[]')::json,
             foo.cancelled_fdc_during_period                                       as cancelled_fdc_during_period,
             case when foo.is_system_size is false then
             coalesce(v_lifetime_fds, 0) - coalesce(foo.prior_period_qualified_fdc, 0) -
             coalesce(foo.qualified_fdc_residual_this_period, 0) +
             coalesce(foo.cancelled_fdc_during_period, 0) else 0 end                         as reactivated_fdc,
             foo.residual_qualified_fdc                                            as residual_qualified_fdc,
             v_no_previous_month_message,
             foo.is_system_size,
             foo.total_existing_clawbacks,
             foo.total_current_clawbacks
      from (select u.id,
                   rp.is_system_size,
                   concat(u.first_name, ' ', u.last_name)                                                                                as closer_name,
                   rpa.allocation                                                                                                        as required_fdc_residual_this_period,
                   case when rp.is_system_size is true then
                          v_sum_system_size_qualified else
                     v_count_qualified_fdc end as qualified_fdc_residual_this_period,
                   0                                                                                             as potential_residual,
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
                                 fds_nq.first_cash_payment_amount,
                                 fds_nq.system_size,
                                 fds_nq.is_system_size,
                                 fds_nq.expected_residual,
                                 fds_nq.plan_name,
                                 fds_nq.system_size_adjusted_for_source,
                                 fds_nq.system_size_by_source
                          from brs.get_residual_fds_not_qualified_this_period(u.id,v_period_start,v_period_end,v_grace_period_end,
                                                                              v_lifetime_fds,
                                                                              v_count_qualified_fdc,
                                                                              v_sum_system_size_qualified) as fds_nq
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
                                 fds_nq.first_cash_payment_amount,
                                 fds_nq.system_size,
                                 fds_nq.is_system_size,
                                 fds_nq.expected_residual,
                                 fds_nq.plan_name,
                                 fds_nq.system_size_adjusted_for_source,
                                 fds_nq.system_size_by_source,
                                 fds_nq.source_name
                          from brs.get_residual_fds_qualified_this_period(u.id,
                                                                          v_period_end,
                                                                          v_period_start,
                                                                          v_previous_grace_period_end,
                                                                          v_grace_period_end,
                                                                          false,
                                                                          v_lifetime_fds,
                                                                          v_count_qualified_fdc,
                                                                          v_sum_system_size_qualified) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id) as qualified_fdc1)                as qualified_fdc,
                   (select array_to_json(array_agg(row_to_json(current_clawbacks1)))
                    from (select p.contact_name,
                                 fds_nq.project_id,
                                 p.cancelled_date,
                                 (select sum(amount)
                                  from brs.get_current_residual_clawbacks(u.id))  as current_clawbacks,
                                 (select sum(amount)
                                  from brs.get_existing_residual_clawbacks(u.id)) as existing_clawbacks,
                                  p.system_size,
                                  fd.residual_plan as plan_name
                          from brs.get_current_residual_clawbacks(u.id) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id
                                 inner join brs.financial_details fd on fd.project_id = p.project_id
                          group by p.contact_name, fds_nq.project_id, p.cancelled_date,p.system_size,fd.residual_plan) as current_clawbacks1)                           as clawback_projects,
                   (select array_to_json(array_agg(row_to_json(clawback_projects_drilldown1)))
                    from (select fds_nq.project_id,fds_nq.amount,fds_nq.paid_date,
                                 fds_nq.plan_name,fds_nq.residual_id,fds_nq.description
                          from brs.get_current_residual_clawbacks(u.id) as fds_nq) as clawback_projects_drilldown1)                           as clawback_projects_drilldown,
                   (select array_to_json(array_agg(row_to_json(total_qualifying_fdc_to_date1)))
                    from (select p.contact_name, fds_nq.project_id,fds_nq.system_size,fds_nq.plan_name,fds_nq.qualified_date,fds_nq.expected_residual,fds_nq.is_system_size,
                                 fds_nq.system_size_adjusted_for_source,fds_nq.system_size_by_source
                          from brs.get_residual_qualified_lifetime_fds(u.id,v_period_end,v_grace_period_end,v_lifetime_fds,v_count_qualified_fdc,v_sum_system_size_qualified) as fds_nq
                                 inner join brs.project_details p on p.project_id = fds_nq.project_id) as total_qualifying_fdc_to_date1) as total_qualifying_fdc_to_date,
            (select sum(count)::bigint
            from (
            (select count(1) count
            from (
              (select count(1), project_id from brs.get_current_residual_clawbacks(u.id) group by project_id)) as foo
            group by foo.project_id)) as foo1)::bigint as cancelled_fdc_during_period,
              coalesce (v_lifetime_fds, 0) as residual_qualified_fdc,
            (select (coalesce((select sum(amount) from brs.get_existing_residual_clawbacks(p_closer_user_id)),0))) as total_existing_clawbacks ,
            (select coalesce((select sum(amount) from brs.get_current_residual_clawbacks(p_closer_user_id)),0)) as total_current_clawbacks,
            (select partial_allocation
             from brs.residual_plan_partial_allocation rppa
             inner join brs.residual_plan_partial_allocation_type rppat on rppat.id = rppa.residual_plan_partial_allocation_type_id
             where rppa.residual_plan_allocation_id = rpa.id
               and case  when rp.is_based_on_source is true then
                           ((v_system_size_by_source >= rppa.fdc_count and rppa.residual_plan_partial_allocation_type_id = 2) or
                            (v_sum_system_size_qualified >= rppa.fdc_count and rppa.residual_plan_partial_allocation_type_id = 1)) and
                           v_sum_system_size_qualified < rpa.allocation
                       when rp.is_system_size is true then
                          v_sum_system_size_qualified >= rppa.fdc_count and
                          v_sum_system_size_qualified < rpa.allocation
                        else v_count_qualified_fdc >= rppa.fdc_count and
                             v_count_qualified_fdc < rpa.allocation end
             order by case when rp.is_system_size is true then rppa.partial_allocation end desc,
                      case when rp.is_system_size is false then rppa.fdc_count end desc limit 1)as partial_allocation
            from flow.user u
              inner join brs.user_residual ur on ur.user_id = u.id
              inner join brs.residual_plan rp on rp.id = ur.residual_plan_id
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
             coalesce(foo.fda_in_month_not_qualifying::json, '[]')::json,
             coalesce(foo.qualified_fdc::json, '[]')::json,
             coalesce(foo.clawback_projects::json, '[]')::json,
             '[]'::json,
             coalesce(foo.total_qualifying_fdc_to_date::json, '[]')::json,
             foo.cancelled_fdc_during_period,
             v_lifetime_fds - foo.prior_period_qualified_fdc - foo.qualified_fdc_residual_this_period +
             foo.cancelled_fdc_during_period as reactivated_fdc,
             foo.residual_qualified_fdc,
             foo.v_no_previous_month_message,
             false,
             foo.existing_clawbacks,
             foo.current_clawbacks_in_period
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
                                 inner join brs.project_details p2 on p2.project_id = urps.project_id
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
                                 inner join brs.project_details p2 on p2.project_id = urps.project_id
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
                                 inner join brs.project_details p2 on p2.project_id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code = 'CLAWBACKS'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as current_clawbacks1)            as clawback_projects,
                   (select array_to_json(array_agg(row_to_json(total_qualifying_fdc_to_date1)))
                    from (select p2.contact_name,
                                 urps.project_id,
                                 urps.system_size,
                                 urps.residual_plan,
                                 urps.qualified_date,
                                 urps.total
                          from brs.user_residual_snapshot urs
                                 inner join brs.user_residual_project_snapshot urps
                                            on urps.user_residual_snapshot_id = urs.id
                                 inner join brs.project_details p2 on p2.project_id = urps.project_id
                                 inner join brs.user_residual_project_snapshot_type urpst
                                            on urpst.id = urps.user_residual_project_snapshot_type_id and
                                               urpst.user_residual_project_snapshot_code = 'LIFETIME_QUALIFIED_FDS'
                          where urs.user_id = p_closer_user_id
                            and urs.id = v_has_current_snapshot_id) as total_qualifying_fdc_to_date1) as total_qualifying_fdc_to_date,
              (select sum(count)::bigint
              from (
              (select count(1) as count
            from (
              (select count(1), project_id from brs.get_user_residual_project_snapshot_by_type(urs2.residual_id, urs2.user_id, 4) group by project_id)) as foo
            group by foo.project_id))as foo1)::bigint as cancelled_fdc_during_period,
              coalesce (v_lifetime_fds, 0) as residual_qualified_fdc,
              v_no_previous_month_message as v_no_previous_month_message,
              urs2.existing_clawbacks,
              urs2.current_clawbacks_in_period
            from brs.user_residual_snapshot urs2
            where urs2.id = v_has_current_snapshot_id) as foo;

    end case;

END
$BODY$
  LANGUAGE plpgsql
  VOLATILE
  COST 100;
