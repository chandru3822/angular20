DROP FUNCTION IF EXISTS brs.get_commission_account_details(integer,BIGINT [],INTEGER,INTEGER,DATE,DATE,INTEGER,INTEGER);
/*MILESTONE 1 175 MILESTONE 2 35*/
CREATE OR REPLACE FUNCTION brs.get_commission_account_details(p_payroll_id         integer,
                                                              p_project_ids         BIGINT [],
                                                              p_contact_id   INTEGER,
                                                              p_sales_rep          INTEGER,
                                                              p_cancel_start_date  DATE,
                                                              p_cancel_end_date    DATE,
                                                              p_override_plan_id   INTEGER,
                                                              p_commission_plan_id INTEGER)
    RETURNS TABLE(
                     project_id                                  INTEGER,
                     customer_id                                 INT,
                     customer_name                               VARCHAR,
                     system_size                                 NUMERIC(10,2),
                     closer_user_id                              bigint,
                     closer                                      TEXT,
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
                     first_cash_payment_amount                   NUMERIC(10,2),
                     total_system_price                          NUMERIC(10,2),
                     percent_of_cash_deposit                     numeric(10,2),
                     substantial_completion_date                 DATE,
                     overrides_per_user                          JSON,
                     override_plan                               TEXT,
                     override_plan_status                        character VARYING,
                     override_plan_id                            INT,
                     commission_plan                             TEXT,
                     commission_plan_status                      character VARYING,
                     commission_plan_id                          INT,
                     total_commissions                           NUMERIC(10,2),
                     total_overrides                             NUMERIC(10,2),
                     commission_earned                           NUMERIC(10,2),
                     override_earned                             NUMERIC(10,2),
                     commission_adjustments                      NUMERIC(10,2),
                     override_adjustments                        NUMERIC(10,2),
                     commission_paid_to_date                     NUMERIC(10,2),
                     overrides_paid_to_date                      NUMERIC(10,2),
                     current_pay                                 NUMERIC(10,2),
                     current_pay_commissions                     NUMERIC(10,2),
                     current_pay_overrides                       NUMERIC(10,2),
                     remaining_value                             NUMERIC(10,2),
                     remaining_value_commissions                 NUMERIC(10,2),
                     remaining_value_overrides                   NUMERIC(10,2),
                     project_total_value                            NUMERIC(10,2)
                 )
    LANGUAGE plpgsql
AS $$
DECLARE
    v_is_show_all BOOLEAN :=
            p_project_ids IS NULL AND p_contact_id IS NULL AND
            p_sales_rep IS NULL AND
            p_cancel_start_date IS NULL AND p_cancel_end_date IS NULL AND p_override_plan_id IS NULL AND
            p_commission_plan_id IS NULL;
    --select * from blueraven.get_commission_account_details('2018-07-20',null,null,null,null,null,null,null,null);
BEGIN

    RETURN QUERY
        SELECT *,coalesce(foo.commission_earned,0) + coalesce(foo.override_earned,0) +
                 coalesce(foo.commission_adjustments,0) - (coalesce(foo.commission_paid_to_date,0) +
                                                           coalesce(foo.overrides_paid_to_date,0))                            AS current_pay,
               coalesce(foo.commission_earned,0)
                   - coalesce(foo.commission_paid_to_date,0)                          AS current_pay_commissions,
               coalesce(foo.override_earned,0)
                   - coalesce(foo.overrides_paid_to_date,0)                           AS current_pay_overrides,
               case when foo.cancelled_date is not null then
                        0::numeric ELSE
                        coalesce(foo.total_commissions,0) end + case when foo.cancelled_date is not null THEN
                                                                         0::numeric else coalesce(foo.total_overrides,0) end -
               (coalesce(foo.commission_paid_to_date,0) +
                coalesce(foo.overrides_paid_to_date,0))                            AS remaining_value,
               case when foo.cancelled_date is not null
                        then 0::numeric
                    else coalesce(foo.total_commissions,0) - coalesce(foo.commission_paid_to_date,0)
                   end                                                            AS remaining_value_commissions,
               case when foo.cancelled_date is not null
                        then 0::numeric
                    else coalesce(foo.total_overrides,0) - coalesce(foo.overrides_paid_to_date,0)
                   end                                                            AS remaining_value_overrides,
               coalesce(foo.total_commissions,0) + coalesce(foo.total_overrides,0) AS project_total_value
        FROM (
                 SELECT p.id as project_id,
                        c.id as customer_id,
                        p.project_name,
                        pd.system_size,
                        u.id as closer_user_id,
                        u.first_name||' '||u.last_name                                  AS closer,
                        (ust.user_status_type = 'Terminated')                           AS closer_is_terminated,
                        lov_source.name as source_name,
                        pd.cancelled_date as cancelled_date,
                        pd.installation_agreement_signed_date as installation_agreement_signed_date,
                        pd.final_design_signed_date as final_design_signed_date,
                        CASE WHEN pd.final_design_signed_date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS fds_color,
                        CASE WHEN pd.financial_agreement_signed_date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS asd_color,
                        CASE WHEN pd.substantial_completion_date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS scd_color,
                        CASE WHEN lov_proof_of_home.name = 'YES'
                            and pd.proof_of_homeowners_insurance_obtained_date is null
                                 THEN 'red' ELSE 'black' END                           AS pohi_color,
                        CASE WHEN lov_financier.name = 'Cash' and
                                  pd.first_cash_payment_paid_date is null
                                 THEN 'red' ELSE 'black' END                           AS deposit_color,
                        pd.financial_agreement_signed_date as agreement_signed_date,
                        pd.utility_bill_verified_date as utility_bill_verified_date,
                        lov_proof_of_home.name as proof_of_howmeowners_insurance_required,
                        pd.proof_of_homeowners_insurance_obtained_date as proof_of_homeowners_insurance_obtained_date,
                        lov_financier.name                                  AS financier,
                        pd.first_cash_payment_paid_date as first_cash_payment_paid_date,
                        pd.first_cash_payment_amount as first_cash_payment_amount,
                        pd.total_system_price as total_system_price,
                        case when lov_financier.name = 'Cash' THEN
                                 round(pd.first_cash_payment_amount::numeric/pd.total_system_price::numeric,2)
                             else 0::numeric end as percent_of_cash_deposit,
                        pd.substantial_completion_date as substantial_completion_date,
                        (SELECT array_to_json(array_agg(row_to_json(_overrides_per_user))) AS overrides_per_user
                         FROM ((SELECT p1.id AS project_id,
                                       u.id,
                                       u.first_name,
                                       u.last_name,
                                       coalesce(
                                               round(pd.system_size::numeric*opru.m1_allocation,2),
                                               0)  total,
                                       1 as milestone_id
                                FROM flow.project p1
                                         inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 175 and
                                                                                     pps.process_step_complete_date is not null
                                         inner join brs.project_override po on po.project_id = p1.id
                                         INNER JOIN brs.override_plan_receiving_user opru
                                                    ON opru.override_plan_id = po.override_plan_id
                                         INNER JOIN flow.user u ON u.id = opru.user_id
                                where p1.id = p.id)
                               UNION
                               (SELECT p1.id AS project_id,
                                       u.id,
                                       u.first_name,
                                       u.last_name,
                                       coalesce(
                                               round(pd.system_size::numeric*opru.m2_allocation,2),
                                               0)  total,
                                       2 as milestone_id
                                FROM flow.project p1
                                         inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 35 and
                                                                                     pps.process_step_complete_date is not null
                                         inner join brs.project_override po on po.project_id = p1.id
                                         INNER JOIN brs.override_plan_receiving_user opru
                                                    ON opru.override_plan_id = po.override_plan_id
                                         INNER JOIN flow.user u ON u.id = opru.user_id
                                where p1.id = p.id)) AS _overrides_per_user),
                        (SELECT op.name AS override_plan
                         FROM brs.override_plan op
                                  inner join brs.project_override po on po.override_plan_id = op.id
                         WHERE po.project_id = p.id
                        )                                                       AS override_plan,
                        (SELECT ops.status_type AS override_plan_status
                         FROM brs.override_plan op
                                  inner join brs.project_override po on po.override_plan_id = op.id
                                  inner join brs.override_plan_status ops on ops.id = op.status_id
                         WHERE po.project_id = p.id
                        )                                                       AS override_plan_status,
                        (SELECT op.id AS override_plan_id
                         FROM brs.override_plan op
                                  inner join brs.project_override po on po.override_plan_id = op.id
                         WHERE po.project_id = p.id
                        )                                                       AS override_plan_id,
                        (SELECT cp.name AS commission_plan
                         FROM brs.commission_plan cp
                                  inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                         WHERE pc.project_id = p.id
                        )                                                       AS commission_plan,
                        (SELECT cps.status_type AS commission_plan_status
                         FROM brs.commission_plan cp
                                  inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                                  inner join brs.commission_plan_status cps on cps.id = cp.status_id
                         WHERE pc.project_id = p.id
                        )                                                       AS commission_plan_status,
                        (SELECT cp.id AS commission_plan_id
                         FROM brs.commission_plan cp
                                  inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                         WHERE pc.project_id = p.id
                        )                                                       AS commission_plan_id,

                        (SELECT coalesce(round(cp.total*pd.system_size::numeric
                                                   - case when cpsa.fee_type_id = 1 then coalesce(pd.system_size::numeric*cpsa.fee_amount, 0) else
                                coalesce(cpsa.fee_amount, 0) end ,2),
                                         0) total
                         FROM flow.project p2
                                  inner join brs.project_commission pc on pc.project_id = p2.id
                                  inner join brs.commission_plan cp on pc.commission_plan_id = cp.id
                                  left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id  and cpsa.milestone_id = 2 and  cpsa.source_id = pd.source
                         where p2.id = p.id) AS total_commissions,
                        coalesce(
                                (select pd.system_size::numeric * op2.total
                                 from brs.override_plan op2
                                          inner join brs.project_override po on op2.id = po.override_plan_id
                                 where po.project_id = p.id),
                                0)                                                          AS total_overrides,
                        coalesce(
                                (SELECT case when pd.cancelled_date is not null then
                                                 0::NUMERIC
                                             else coalesce(round(cpa.allocation*pd.system_size::numeric- case when cpsa.milestone_id =1 then
                                                                                                                             case when cpsa.fee_type_id = 1 then coalesce(pd.system_size::numeric* cpsa.fee_amount,0)
                                                                                                                                  else coalesce(cpsa.fee_amount,0) end
                                                                                                                         else 0 end,2),
                                                           0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id  =175  and pps.process_step_complete_date is not null
                                          inner join brs.project_commission pc on pc.project_id = p1.id
                                          inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                          inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                          left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id  and cpsa.source_id = pd.source
                                 WHERE p1.id = p.id ),0) + coalesce(
                                (SELECT case when pd.cancelled_date is not null THEN
                                                 0::NUMERIC
                                             else coalesce(round(cpa.allocation*pd.system_size::numeric-case when cpsa.milestone_id =2 then
                                                                                                                            case when cpsa.fee_type_id = 1 then coalesce(pd.system_size::numeric* cpsa.fee_amount,0)
                                                                                                                                 else coalesce(cpsa.fee_amount,0) end
                                                                                                                        else 0 end,2),
                                                           0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 35 and pps.process_step_complete_date is not null
                                          inner join brs.project_commission pc on pc.project_id = p1.id
                                          inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                          inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                          left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2   and cpsa.source_id = pd.source
                                 WHERE p1.id = p.id),0) AS commission_earned,
                        coalesce(
                                (SELECT case when pd.cancelled_date is not null then
                                                 0::numeric
                                             else coalesce(round(pd.system_size::numeric*(select sum(m1_allocation)
                                                                                                     from brs.override_plan_receiving_user opru
                                                                                                     where opru.override_plan_id = op.id),2),0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 175 and pps.process_step_complete_date is not null
                                          inner join brs.project_override po on po.project_id = p1.id
                                          inner join brs.override_plan op on op.id = po.override_plan_id
                                 WHERE p1.id = p.id),0) + coalesce(
                                (SELECT case when pd.cancelled_date is not null then
                                                 0::NUMERIC
                                             else coalesce(round(pd.system_size::numeric * (select sum(m2_allocation)
                                                                                                       from brs.override_plan_receiving_user opru
                                                                                                       where opru.override_plan_id = op.id),2),0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 35 and pps.process_step_complete_date is not null
                                          inner join brs.project_override po on po.project_id = p1.id
                                          inner join brs.override_plan op on op.id = po.override_plan_id
                                 WHERE p1.id = p.id),0) AS override_earned,
                        coalesce(brs.get_ledger_adjustment_current_totals( p_payroll_id,array[p.id],1),0) AS commission_adjustments,
                        --TODO implement this at a later date.
                        0::numeric AS override_adjustments,
                        (SELECT coalesce(sum(amount), 0)
                         FROM brs.project_commission_ledger dcl
                         WHERE dcl.project_id = p.id::integer
                           AND dcl.ledger_type_id = 1)
                            AS commission_paid_to_date,
                        (
                            SELECT coalesce(sum(dcl.paid_to_date), 0)
                            FROM brs.project_commission_ledger dcl
                            WHERE dcl.project_id = p.id  and
                                    dcl.ledger_type_id = 3
                        ) /*+
          (
            select coalesce(sum(amount),0)
            from blueraven.payroll_adjustment  pca
            where pca.deal_id = d1.id and
                  pca.payroll_id < p_payroll_id AND
                  pca.payroll_adjustment_type_id = 2
          )*/
                            AS overrides_paid_to_date
                 FROM flow.project p
                          inner join brs.project_details pd on pd.project_id = p.id
                          inner join flow.project_process_step pps on pps.project_id = p.id and process_step_id = 175 and pps.process_step_complete_date is not null and main is true
                          inner join flow.contact c on c.id = p.contact_id
                          INNER JOIN flow.user u ON u.id = pd.closer_user_id
                          inner join flow.company_user_status cus  on cus.user_id = u.id
                          inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                          left join brs.exclude_commission ec on ec.project_id = p.id
                          left join flow.list_of_value lov_source on lov_source.id = pd.source
                          left join flow.list_of_value lov_financier on lov_financier.id = pd.primary_financier
                          left join flow.list_of_value lov_proof_of_home  on lov_proof_of_home.id = pd.proof_of_homeowners_insurance_required
                 WHERE  (ec.project_id is null) and
                     CASE WHEN p_project_ids IS NOT NULL
                              THEN p.id = ANY(p_project_ids) ELSE 1 = 1 END
                   AND CASE WHEN p_contact_id IS NOT NULL
                                THEN c.id = p_contact_id ELSE 1 = 1 END
                   AND CASE WHEN p_sales_rep IS NOT NULL
                                THEN p_sales_rep = u.id ELSE 1 = 1 END
                   AND CASE WHEN p_cancel_start_date IS NOT NULL
                                THEN pd.cancelled_date::date BETWEEN p_cancel_start_date AND p_cancel_end_date
                            ELSE 1 = 1 END
                 ORDER BY p.project_name
             ) AS foo
        WHERE CASE WHEN v_is_show_all IS TRUE
                       THEN COALESCE(foo.commission_earned,0) + COALESCE(foo.override_earned,0) +
                            (COALESCE(foo.commission_adjustments,0) - COALESCE(foo.commission_paid_to_date,0) -
                             COALESCE(foo.overrides_paid_to_date,0)) != 0 ELSE 1 = 1 END
          AND CASE WHEN p_override_plan_id IS NOT NULL
                       THEN foo.override_plan_id = p_override_plan_id ELSE 1 = 1 END
          AND CASE WHEN p_commission_plan_id IS NOT NULL
                       THEN foo.commission_plan_id = p_commission_plan_id
                   ELSE 1 = 1 END;
END
$$;
