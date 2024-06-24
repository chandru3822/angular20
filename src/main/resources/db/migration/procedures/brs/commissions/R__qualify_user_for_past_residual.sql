drop type if exists brs.project_qualified_date_type CASCADE;;
CREATE TYPE brs.project_qualified_date_type AS
(
  project_id     bigint,
  qualified_date DATE
);
drop function if exists brs.qualify_user_for_past_residual(p_user_id bigint, p_residual_id bigint,
                                                           p_project_qualified_date_type brs.project_qualified_date_type[],
                                                           p_lifetime_qualified_fds bigint,
                                                           p_qualified_fdc_in_period bigint,
                                                           p_fdc_not_qualified_in_period bigint,
                                                           p_potential_residual numeric,
                                                           p_earned_residual numeric,
                                                           p_end_of_period_date date, p_grace_period_end date,
                                                           p_clawback_due numeric);
CREATE OR REPLACE FUNCTION brs.qualify_user_for_past_residual(p_user_id bigint, p_residual_id bigint,
                                                              p_project_qualified_date_type brs.project_qualified_date_type[],
                                                              p_lifetime_qualified_fds bigint,
                                                              p_qualified_fdc_in_period bigint,
                                                              p_fdc_not_qualified_in_period bigint,
                                                              p_potential_residual numeric,
                                                              p_earned_residual numeric,
                                                              p_end_of_period_date date, p_grace_period_end date,
                                                              p_clawback_due numeric default null)
  RETURNS void
  LANGUAGE plpgsql AS
$BODY$
DECLARE
  v_user_residual_snapshot_id bigint;
  rec                         brs.project_qualified_date_type;
  v_lifetime_fds              bigint;
  v_count_qualified_fdc       numeric;
  v_sum_system_size_qualified numeric;
  v_system_size_by_source     numeric;
BEGIN
  select urs.id
  into v_user_residual_snapshot_id
  from brs.user_residual_snapshot urs
  where user_id = p_user_id
    and residual_id = p_residual_id;

  FOREACH rec IN ARRAY p_project_qualified_date_type
    loop
    --raise notice 'project_id %',rec.project_id;
    --raise notice 'qualified_date %',rec.qualified_date;
      insert into brs.residual_project_override_qualified_date(project_id, override_qualified_date, date_created,
                                                               date_modified, created_by_id, modified_by_id)
      values (rec.project_id, rec.qualified_date, now(), now(), 99999999, 99999999);

      update brs.user_residual_project_snapshot urps
      set user_residual_project_snapshot_type_id = 2
      from brs.user_residual_snapshot u
      where u.id = urps.user_residual_snapshot_id
        and u.user_id = p_user_id
        and u.residual_id = p_residual_id
        and user_residual_project_snapshot_type_id = 3
        and urps.project_id = rec.project_id;

    end loop;

  update brs.user_residual_snapshot urs
  set lifetime_qualified_fds      = p_lifetime_qualified_fds,
      qualified_fdc_in_period     = p_qualified_fdc_in_period,
      fdc_not_qualified_in_period = p_fdc_not_qualified_in_period,
      residual_earned             = true,
      percent_of_residual_earned  = 100,
      potential_residual          = p_potential_residual,
      earned_residual             = p_earned_residual,
      residual_total              = p_earned_residual
  where id = v_user_residual_snapshot_id;

  select count(1)
  into v_lifetime_fds
  from brs.get_residual_qualified_lifetime_fds(p_user_id, p_end_of_period_date, p_grace_period_end);

  select count(1), sum(ao.system_size_adjusted_for_source), sum(ao.system_size_by_source)
  into v_count_qualified_fdc,v_sum_system_size_qualified,v_system_size_by_source
  from brs.get_residual_fds_qualified_this_period(p_user_id) ao;

  insert into brs.user_residual_project_snapshot(user_residual_snapshot_id, project_id,
                                                 user_residual_project_snapshot_type_id,
                                                 final_design_complete_date, final_design_signed_date,
                                                 utility_bill_verified_date,
                                                 financial_agreement_signed_date,
                                                 proof_of_homeowners_insurance_required,
                                                 proof_of_homeowners_insurance_obtained_date, total_cash_down_payment,
                                                 first_cash_payment_amount, substantial_completion_date, cancelled_date,
                                                 on_hold_date, qualified_date, total, date_created, created_by_id,
                                                 date_modified, modified_by_id, state, system_size,
                                                 residual_plan, system_size_adjusted_for_source, system_size_by_source)
    (select v_user_residual_snapshot_id,
            ao.project_id,
            1,
            ao.final_design_complete_date,
            ao.final_design_signed_date,
            ao.utility_bill_verified_date,
            ao.financial_agreement_signed_date,
            ao.proof_of_homeowners_insurance_required,
            ao.proof_of_homeowners_insurance_obtained_date,
            ao.total_cash_down_payment,
            ao.first_cash_payment_amount,
            ao.substantial_completion_date,
            ao.cancelled_date,
            ao.on_hold_date,
            ao.qualified_date,
            ao.expected_residual,
            now(),
            99999999,
            now(),
            99999999,
            ao.state,
            ao.system_size,
            16,
            ao.system_size_adjusted_for_source,
            ao.system_size_by_source
     from brs.get_residual_qualified_lifetime_fds(
            p_user_id::bigint, p_end_of_period_date, p_grace_period_end,v_lifetime_fds,v_count_qualified_fdc,v_sum_system_size_qualified,v_system_size_by_source) ao);


  FOREACH rec IN ARRAY p_project_qualified_date_type
    LOOP
    --raise notice 'project_id %',rec.project_id;
    --raise notice 'qualified_date %',rec.qualified_date;
      insert into brs.residual_project_qualified_date(project_id, qualified_date, date_created, date_modified,
                                                      created_by_id, modified_by_id, residual_id, excluded_from_cancel)
      values (rec.project_id, rec.qualified_date, now(), now(), 99999999, 99999999, 16, false);
    end loop;

  if p_clawback_due is not null then
    update brs.residual_clawback rc
    set clawback_due     = p_clawback_due,
        applied_clawback = 0
    where user_id = p_user_id;
  end if;

  insert into brs.residual_ledger(project_id,
                                  user_id,
                                  ledger_type_id,
                                  amount,
                                  note,
                                  residual_id,
                                  date_created,
                                  created_by_id,
                                  date_modified,
                                  modified_by_id)
    (select urps.project_id,
            urs.user_id,
            (select id from brs.ledger_type as lt where lt.ledger_type = 'RESIDUAL'),
            urps.total,
            'Residuals',
            urs.residual_id,
            now(),
            99999999,
            now(),
            99999999
     from brs.user_residual_project_snapshot urps
            inner join brs.user_residual_snapshot as urs on urs.id = urps.user_residual_snapshot_id and
                                                            urs.user_id = p_user_id
     where urs.residual_id = p_residual_id
       and urps.user_residual_project_snapshot_type_id = 1);


END;
$BODY$


