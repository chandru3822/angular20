DROP FUNCTION IF EXISTS brs.get_commission_account_details(bigint, BIGINT[], bigint, bigint, DATE, DATE, bigint, bigint);
DROP FUNCTION IF EXISTS brs.get_commission_account_details(bigint, BIGINT[], bigint, bigint, DATE, DATE, bigint, bigint,boolean);
/*MILESTONE 1 175 MILESTONE 2 35*/
CREATE OR REPLACE FUNCTION brs.get_commission_account_details(p_payroll_id bigint,
                                                               p_project_ids BIGINT[],
                                                               p_contact_id bigint,
                                                               p_sales_rep bigint,
                                                               p_cancel_start_date DATE,
                                                               p_cancel_end_date DATE,
                                                               p_override_plan_id bigint,
                                                               p_commission_plan_id bigint,
                                                               p_query_overrides boolean default false)
  RETURNS TABLE
          (
            project_id                                  bigint,
            customer_id                                 bigint,
            customer_name                               VARCHAR,
            system_size                                 NUMERIC(10, 2),
            user_id                                     bigint,
            employee_id                                 text,
            closer                                      character varying,
            closer_is_terminated                        BOOLEAN,
            source_name                                 VARCHAR,
            cancelled_date                              DATE,
            installation_agreement_signed_date          DATE,
            final_design_signed_date                    DATE,
            fds_color                                   TEXT,
            asd_color                                   TEXT,
            scd_color                                   TEXT,
            pohi_color                                  TEXT,
            deposit_color                               TEXT,
            agreement_signed_date                       DATE,
            utility_bill_verified_date                  DATE,
            proof_of_howmeowners_insurance_required     character varying,
            proof_of_homeowners_insurance_obtained_date DATE,
            financier                                   character varying,
            first_cash_payment_paid_date                DATE,
            first_cash_payment_amount                   NUMERIC(10, 2),
            total_system_price                          NUMERIC(10, 2),
            percent_of_cash_deposit                     numeric(10, 2),
            substantial_completion_date                 DATE,
            overrides_per_user                          JSON,
            override_plan                               TEXT,
            override_plan_status                        TEXT,
            override_plan_id                            bigint,
            commission_plan                             TEXT,
            commission_plan_status                      TEXT,
            commission_plan_id                          bigint,
            total_commissions                           NUMERIC(10, 2),
            total_overrides                             NUMERIC(10, 2),
            commission_earned                           NUMERIC(10, 2),
            override_earned                             NUMERIC(10, 2),
            commission_adjustments                      NUMERIC(10, 2),
            override_adjustments                        NUMERIC(10, 2),
            commission_paid_to_date                     NUMERIC(10, 2),
            commission_forfeited_paid_to_date           NUMERIC(10, 2),
            commission_forfeited_by_closer              NUMERIC(10, 2),
            overrides_paid_to_date                      NUMERIC(10, 2),
            current_pay_commissions                     NUMERIC(10, 2),
            current_pay_overrides                       NUMERIC(10, 2),
            remaining_value                             NUMERIC(10, 2),
            remaining_value_commissions                 NUMERIC(10, 2),
            remaining_value_overrides                   NUMERIC(10, 2),
            project_total_value                         NUMERIC(10, 2),
            amount_to_pay                               NUMERIC(10, 2),
            forfeited_amount                            NUMERIC(10, 2),
            current_pay                                 NUMERIC(10, 2)
          )
  LANGUAGE plpgsql
AS
$$
DECLARE
  v_is_show_all     BOOLEAN   :=
      p_project_ids IS NULL AND p_contact_id IS NULL AND
      p_sales_rep IS NULL AND
      p_cancel_start_date IS NULL AND p_cancel_end_date IS NULL AND p_override_plan_id IS NULL AND
      p_commission_plan_id IS NULL;
  --select * from blueraven.get_commission_account_details('2018-07-20',null,null,null,null,null,null,null,null);
  v_period_end_date date;
  v_amounts         numeric[] = '{0.00,-0.01,0.01}';
BEGIN

  select period_end
  into v_period_end_date
  from brs.payroll
  where id = p_payroll_id;


  RETURN QUERY
    select *, coalesce(foo1.current_pay_commissions, 0) + coalesce(foo1.current_pay_overrides, 0) as current_pay
    from (SELECT p.id::bigint                                                        as project_id,
                 p.contact_id::bigint                                                as customer_id,
                 p.project_name,
                 fd.system_size,
                 u.id::bigint                                                        as closer_user_id,
                 (select text_value
                  from flow.user_custom_field_value ucfv
                  where custom_field_group_assignment_id = 19176
                    and ucfv.user_id = u.id),
                 pd.closer_name                                                      AS closer,
                 (ust.user_status_type = 'Terminated')                               AS closer_is_terminated,
                 fd.source_name::varchar                                             as source_name,
                 fd.cancelled_date                                                   as cancelled_date,
                 pd.installation_agreement_signed_date                               as installation_agreement_signed_date,
                 pd.final_design_signed_date                                         as final_design_signed_date,
                 CASE
                   WHEN pd.final_design_signed_date IS NULL
                     THEN 'red'
                   ELSE 'black' END                                                  AS fds_color,
                 CASE
                   WHEN pd.financial_agreement_signed_date IS NULL
                     THEN 'red'
                   ELSE 'black' END                                                  AS asd_color,
                 CASE
                   WHEN fd.substantial_completion_date IS NULL
                     THEN 'red'
                   ELSE 'black' END                                                  AS scd_color,
                 CASE
                   WHEN pd.proof_of_homeowners_insurance_required_name = 'YES'
                     and pd.proof_of_homeowners_insurance_obtained_date is null
                     THEN 'red'
                   ELSE 'black' END                                                  AS pohi_color,
                 CASE
                   WHEN fd.primary_financier_name = 'Cash' and
                        pd.first_cash_payment_paid_date is null
                     THEN 'red'
                   ELSE 'black' END                                                  AS deposit_color,
                 pd.financial_agreement_signed_date                                  as agreement_signed_date,
                 pd.utility_bill_verified_date                                       as utility_bill_verified_date,
                 pd.proof_of_homeowners_insurance_required_name::varchar             as proof_of_howmeowners_insurance_required,
                 pd.proof_of_homeowners_insurance_obtained_date                      as proof_of_homeowners_insurance_obtained_date,
                 pd.primary_financier_name::varchar                                  AS financier,
                 pd.first_cash_payment_paid_date                                     as first_cash_payment_paid_date,
                 pd.first_cash_payment_amount                                        as first_cash_payment_amount,
                 pd.total_system_price                                               as total_system_price,
                 case
                   when fd.primary_financier_name = 'Cash' THEN
                     round(pd.first_cash_payment_amount::numeric / pd.total_system_price::numeric, 2)
                   else 0::numeric end                                               as percent_of_cash_deposit,
                 fd.substantial_completion_date                                      as substantial_completion_date,
                 case when p_query_overrides is true then
                 (SELECT array_to_json(array_agg(row_to_json(_overrides_per_user))) AS overrides_per_user
                  FROM ((SELECT p1.id AS project_id,
                                u.id,
                                u.first_name,
                                u.last_name,
                                coalesce(
                                  round(case
                                          when pd.cancelled_date is not null then 0::numeric
                                          when pd.primary_financier_name = 'LoanPal' and pd.loan_term = 427 and
                                               pd.interest_rate = 2.99 then 0
                                          else pd.system_size::numeric end * opru.m1_allocation, 2),
                                  0)     total,
                                1     as milestone_id
                         FROM flow.project p1
                               inner join brs.financial_details f on f.project_id = p1.id
                                inner join brs.override_plan op on op.id = f.override_plan_id and op.position_id = 1
                                INNER JOIN brs.override_plan_receiving_user opru
                                           ON opru.override_plan_id = op.id
                                INNER JOIN flow.user u ON u.id = opru.user_id
                         where p1.id = p.id
                           and exists (select ppscfv.id
                                       from flow.project_process_step pps
                                              inner join flow.project_process_step_custom_field_value ppscfv
                                                         on ppscfv.project_process_step_id = pps.id and
                                                            ppscfv.custom_field_group_assignment_id = 1251
                                       where pps.project_id = p1.id
                                         and pps.process_step_id = 175
                                         and ppscfv.date_value is not null
                                         and ppscfv.date_value <= v_period_end_date
                                       ))
                        UNION
                        (SELECT p1.id AS project_id,
                                u.id,
                                u.first_name,
                                u.last_name,
                                coalesce(
                                  round(case when pd.cancelled_date is not null then 0::numeric
                                          when pd.primary_financier_name = 'LoanPal' and pd.loan_term = 427 and
                                               pd.interest_rate = 2.99 then 0
                                          else pd.system_size::numeric end * opru.m2_allocation, 2),
                                  0)     total,
                                2     as milestone_id
                         FROM flow.project p1
                                inner join brs.financial_details d on d.project_id = p1.id
                                inner join brs.override_plan op on op.id = d.override_plan_id and op.position_id = 1
                                INNER JOIN brs.override_plan_receiving_user opru
                                           ON opru.override_plan_id = op.id
                                INNER JOIN flow.user u ON u.id = opru.user_id
                         where p1.id = p.id
                           and exists (select ppscfv.id
                                       from flow.project_process_step pps
                                              inner join flow.project_process_step_custom_field_value ppscfv
                                                         on ppscfv.project_process_step_id = pps.id and
                                                            ppscfv.custom_field_group_assignment_id = 21009
                                       where pps.project_id = p1.id
                                         and pps.process_step_id = 3365
                                         and ppscfv.date_value is not null
                                        and ppscfv.date_value <= v_period_end_date
                                       ))
                        union
                        (select pcl.project_id AS project_id,
                                u2.id,
                                u2.first_name,
                                u2.last_name,
                                0.00::numeric,
                                2 as milestone_id
                         from brs.project_commission_ledger pcl
                                inner join flow."user" u2 on u2.id = pcl.user_id
                         where pcl.project_id = fd.project_id and pcl.ledger_type_id = 3 and
                           not exists (select fd1.id
                                       from brs.financial_details fd1
                                              inner join brs.override_plan_receiving_user o on o.override_plan_id = fd1.override_plan_id and
                                                                                               o.user_id = pcl.user_id
                                       where fd1.project_id = fd.project_id))) AS _overrides_per_user) else null::json end,
                 fd.override_plan                                                    AS override_plan,
                 fd.override_plan_status                                             AS override_plan_status,
                 fd.override_plan_id                                                 AS override_plan_id,
                 fd.commission_plan                                                  AS commission_plan,
                 fd.commission_plan_status                                           AS commission_plan_status,
                 fd.commission_plan_id                                               AS commission_plan_id,
                 coalesce(fd.total_commissions, 0)                                   AS total_commissions,
                 coalesce(fd.total_overrides, 0)                                     AS total_overrides,
                 coalesce(fd.commissions_earned_m1, 0) + case
                                                           when fd.substantial_completion_date <= v_period_end_date then
                                                             coalesce(fd.commissions_earned_m2, 0)
                                                           else
                                                             0::numeric end          AS commission_earned,
                 coalesce(fd.overrides_earned_m1, 0) + case
                                                         when fd.substantial_completion_date <= v_period_end_date then
                                                           coalesce(fd.overrides_earned_m2, 0)
                                                         else 0::numeric end         AS override_earned,
                 coalesce(la.*,0)                                                         AS commission_adjustments,
                 0::numeric                                                          AS override_adjustments,
                 coalesce(fd.total_commissions_paid_to_date, 0)                      AS commission_paid_to_date,
                 coalesce(fd.total_commissions_forfeited_paid_to_date, 0)            AS commission_forfeited_paid_to_date,
                 coalesce(pd.commission_forfeited_by_closer, 0)                      as commission_forfeited_by_closer,
                 coalesce(fd.total_overrides_paid_to_date, 0)                        AS overrides_paid_to_date,
                 case
                   when fd.cancelled_date is not null then
                         coalesce(fd.commissions_earned_m1, 0) + case
                                                                   when fd.substantial_completion_date <= v_period_end_date
                                                                     then
                                                                     coalesce(fd.commissions_earned_m2, 0)
                                                                   else 0::numeric end
                         + coalesce(la.*,0) - coalesce(fd.total_commissions_paid_to_date, 0)
                   else
                       coalesce(current_pay.amount_to_pay::numeric, 0) +
                       coalesce(la.*,0) end                                               AS current_pay_commissions,
                 coalesce(fd.overrides_earned_m1, 0) + case
                                                         when fd.substantial_completion_date <= v_period_end_date then
                                                           coalesce(fd.overrides_earned_m2, 0)
                                                         else 0::numeric end
                   -
                 coalesce(fd.total_overrides_paid_to_date, 0)                        AS current_pay_overrides,
                 case
                   when fd.cancelled_date is not null then
                     0::numeric
                   ELSE
                     coalesce(fd.total_commissions, 0) end + case
                                                               when fd.cancelled_date is not null THEN
                                                                 0::numeric
                                                               else coalesce(fd.total_overrides, 0) end -
                 (coalesce(fd.total_commissions_paid_to_date, 0) +
                  coalesce(fd.total_overrides_paid_to_date, 0))                      AS remaining_value,
                 case
                   when fd.cancelled_date is not null
                     then 0::numeric
                   else coalesce(fd.total_commissions, 0) - coalesce(fd.total_commissions_paid_to_date, 0) -
                        coalesce(fd.total_commissions_forfeited_paid_to_date, 0)
                   end                                                               AS remaining_value_commissions,
                 case
                   when fd.cancelled_date is not null
                     then 0::numeric
                   else coalesce(fd.total_overrides, 0) - coalesce(fd.total_overrides_paid_to_date, 0)
                   end                                                               AS remaining_value_overrides,
                 coalesce(fd.total_commissions, 0) + coalesce(fd.total_overrides, 0) AS project_total_value,
                 current_pay.amount_to_pay,
                 current_pay.forfeited_amount
          FROM flow.project p
                 inner join brs.financial_details fd on fd.project_id = p.id
                 inner join brs.project_details pd on pd.project_id = p.id
                 INNER JOIN flow.user u ON u.id = pd.closer_user_id
                 inner join flow.company_user_status cus on cus.user_id = u.id
                 inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                 left join brs.exclude_commission ec on ec.project_id = p.id
                 left join lateral brs.get_ledger_adjustment_current_totals(p_payroll_id, array [p.id], 1) la on true
                 join lateral brs.get_current_pay(coalesce(fd.total_commissions, 0),
                                                  coalesce(fd.commissions_earned_m1, 0) + case
                                                                                            when fd.substantial_completion_date <= v_period_end_date
                                                                                              then
                                                                                              coalesce(fd.commissions_earned_m2, 0)
                                                                                            else 0::numeric end,
                                                  coalesce(fd.total_commissions_paid_to_date, 0),
                                                  coalesce(pd.commission_forfeited_by_closer, 0),
                                                  coalesce(fd.total_commissions_forfeited_paid_to_date, 0)) as current_pay
                      on true
          WHERE ((pd.on_hold_date is null) or (pd.on_hold_date is not null and off_hold_date is not null))
            and (ec.project_id is null)
            and (fd.final_design_complete_date <= v_period_end_date or
                 fd.substantial_completion_date <= v_period_end_date)
            and CASE
                  WHEN p_override_plan_id IS NOT NULL
                    THEN fd.override_plan_id = p_override_plan_id
                  ELSE 1 = 1 END
            AND CASE
                  WHEN p_commission_plan_id IS NOT NULL
                    THEN fd.commission_plan_id = p_commission_plan_id
                  ELSE 1 = 1 END
            and CASE
                  WHEN p_project_ids IS NOT NULL
                    THEN p.id = ANY (p_project_ids)
                  ELSE
                    pd.final_design_complete_date is not null END
            AND CASE
                  WHEN p_contact_id IS NOT NULL
                    THEN p.contact_id = p_contact_id
                  ELSE 1 = 1 END
            AND CASE
                  WHEN p_sales_rep IS NOT NULL
                    THEN p_sales_rep = u.id
                  ELSE 1 = 1 END
            AND CASE
                  WHEN p_cancel_start_date IS NOT NULL
                    THEN fd.cancelled_date::date BETWEEN p_cancel_start_date AND p_cancel_end_date
                  ELSE 1 = 1 END
          order by 3) as foo1
    where CASE
            WHEN p_project_ids IS NOT NULL
              THEN foo1.project_id = ANY (p_project_ids) else (foo1.amount_to_pay = 0 and foo1.forfeited_amount > 0) or  not (coalesce(foo1.current_pay_commissions, 0) + coalesce(foo1.current_pay_overrides, 0)) = any (v_amounts) end;
END
$$;
