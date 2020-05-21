DROP FUNCTION IF EXISTS brs.get_commission_account_details(integer,BIGINT [],INTEGER,INTEGER,DATE,DATE,INTEGER,INTEGER);
/*MILESTONE 1 9 MILESTONE 2 35*/
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
                     closer_user_id                              INT,
                     closer                                      TEXT,
                     closer_is_terminated                        BOOLEAN,
                     source_name                                 VARCHAR,
                     stage_name                                  VARCHAR,
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
                     proof_of_howmeowners_insurance_required     BOOLEAN,
                     proof_of_homeowners_insurance_obtained_date DATE,
                     financier                                   TEXT,
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
                        system_size.system_size::numeric as system_size,
                        up2.user_id as closer_user_id,
                        u.first_name||' '||u.last_name                                  AS closer,
                        (cust.user_status_type = 'Terminated')                           AS closer_is_terminated,
                        source.source::character varying as source_name,
                        stage.stage::character varying as stage_name,
                        cancelled_date.cancelled_date::date as cancelled_date,
                        installation_agreement_signed_date.installation_agreement_signed_date::date as installation_agreement_signed_date,
                        final_design_signed_date.final_design_signed_date::date as final_design_signed_date,
                        CASE WHEN final_design_signed_date.final_design_signed_date::date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS fds_color,
                        CASE WHEN agreement_signed_date.agreement_signed_date::date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS asd_color,
                        CASE WHEN substantial_completion_date.substantial_completion_date::date IS NULL
                                 THEN 'red' ELSE 'black' END                           AS scd_color,
                        CASE WHEN proof_of_homeowners_insurance_required.proof_of_homeowners_insurance_required = 'Yes'
                            and proof_of_homeowners_insurance_obtained.proof_of_homeowners_insurance_obtained::date is null
                                 THEN 'red' ELSE 'black' END                           AS pohi_color,
                        CASE WHEN financier.financier = 'Cash' and
                                  first_cash_paid_date.first_cash_paid_date::date is null
                                 THEN 'red' ELSE 'black' END                           AS deposit_color,
                        agreement_signed_date.agreement_signed_date::date as agreement_signed_date,
                        utitlity_bill_verified_date.utitlity_bill_verified_date::date as utility_bill_verified_date,
                        proof_of_homeowners_insurance_required.proof_of_homeowners_insurance_required::boolean as proof_of_howmeowners_insurance_required,
                        proof_of_homeowners_insurance_obtained.proof_of_homeowners_insurance_obtained::date as proof_of_homeowners_insurance_obtained_date,
                        financier.financier                                   AS financier,
                        first_cash_paid_date.first_cash_paid_date::date as first_cash_payment_paid_date,
                        first_cash_payment_amount.first_cash_payment_amount::numeric as first_cash_payment_amount,
                        total_system_price.total_system_price::numeric as total_system_price,
                        case when financier.financier = 'Cash' THEN
                                 round(first_cash_payment_amount.first_cash_payment_amount::numeric/total_system_price.total_system_price::numeric,2)
                         else 0::numeric end as percent_of_cash_deposit,
                        substantial_completion_date.substantial_completion_date::date as substantial_completion_date,
                        (SELECT array_to_json(array_agg(row_to_json(_overrides_per_user))) AS overrides_per_user
                         FROM ((SELECT p1.id AS project_id,
                                       u.id,
                                       u.first_name,
                                       u.last_name,
                                       coalesce(
                                               round(system_size.system_size::numeric*opru.m1_allocation,2),
                                               0)  total,
                                       1 as milestone_id
                                FROM flow.project p1
                                         inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 9 and
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
                                               round(system_size.system_size::numeric*opru.m2_allocation,2),
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

                        (SELECT coalesce(round(cp.total*system_size.system_size::numeric
                                                   - case when cpsa.fee_type_id = 1 then coalesce(system_size.system_size::numeric*cpsa.fee_amount, 0) else
                                                                                coalesce(cpsa.fee_amount, 0) end ,2),
                                         0) total
                         FROM flow.project p2
                                  inner join brs.project_commission pc on pc.project_id = p2.id
                                  inner join brs.commission_plan cp on pc.commission_plan_id = cp.id
                                  left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id  and cpsa.milestone_id = 2
                         where p2.id = p.id and  cpsa.source_id = sourceId.sourceId::integer) AS total_commissions,
                        coalesce(
                                (select system_size.system_size::numeric * op2.total
                                 from brs.override_plan op2
                                          inner join brs.project_override po on op2.id = po.override_plan_id
                                 where po.project_id = p.id),
                                0)                                                          AS total_overrides,
                        coalesce(
                                (SELECT case when cancelled_date.cancelled_date is not null then
                                                 0::NUMERIC
                                             else coalesce(round(cpa.allocation*system_size.system_size::numeric- case when cpsa.milestone_id =1 then
                                                                                                                    case when cpsa.fee_type_id = 1 then coalesce(system_size.system_size::numeric* cpsa.fee_amount,0)
                                                                                                                        else coalesce(cpsa.fee_amount,0) end
                                                                                                                    else 0 end,2),
                                                           0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id  =9  and pps.process_step_complete_date is not null
                                          inner join brs.project_commission pc on pc.project_id = p1.id
                                          inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                          inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                          left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id  and cpsa.source_id = sourceId.sourceId::integer
                                 WHERE p1.id = p.id ),0) + coalesce(
                                (SELECT case when cancelled_date.cancelled_date is not null THEN
                                                 0::NUMERIC
                                             else coalesce(round(cpa.allocation*system_size.system_size::numeric-case when cpsa.milestone_id =2 then
                                                                                                                    case when cpsa.fee_type_id = 1 then coalesce(system_size.system_size::numeric* cpsa.fee_amount,0)
                                                                                                                         else coalesce(cpsa.fee_amount,0) end
                                                                                                                else 0 end,2),
                                                           0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 35 and pps.process_step_complete_date is not null
                                          inner join brs.project_commission pc on pc.project_id = p1.id
                                          inner join brs.commission_plan cp on cp.id = pc.commission_plan_id
                                          inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 2
                                          left join brs.commission_plan_source_allocation cpsa on cpsa.commission_plan_id = cp.id and cpa.milestone_id = 2   and cpsa.source_id = sourceId.sourceId::integer
                                 WHERE p1.id = p.id),0) AS commission_earned,
                        coalesce(
                                (SELECT case when cancelled_date.cancelled_date is not null then
                                                 0::numeric
                                             else coalesce(round(system_size.system_size::numeric*(select sum(m1_allocation)
                                                                                                   from brs.override_plan_receiving_user opru
                                                                                                   where opru.override_plan_id = op.id),2),0) end total
                                 FROM flow.project p1
                                          inner join flow.project_process_step pps on pps.project_id = p1.id and pps.process_step_id = 9 and pps.process_step_complete_date is not null
                                          inner join brs.project_override po on po.project_id = p1.id
                                          inner join brs.override_plan op on op.id = po.override_plan_id
                                 WHERE p1.id = p.id),0) + coalesce(
                                (SELECT case when cancelled_date.cancelled_date is not null then
                                                 0::NUMERIC
                                             else coalesce(round(system_size.system_size::numeric * (select sum(m2_allocation)
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
                          inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_complete_date is not null and process_step_id = 9
                          inner join flow.contact c on c.id = p.contact_id
                          inner join flow.user_project up on up.project_id = p.id
                          inner join flow.user_position up2  on up2.id = up.user_position_id and up2.position_id = 1
                          INNER JOIN flow.user u ON u.id = up2.user_id
                          inner join flow.user_status_type ust  on ust.user_id = u.id
                          inner join flow.company_user_status_type cust on cust.id = ust.company_user_status_type_id and cust.company_id = 3
                          left join brs.exclude_commission ec on ec.project_id = p.id
                          left JOIN lateral (select * from flow.get_value_for_custom_field(1 ,
                                                                                           5,
                                                                                           p.id,
                                                                                                0,
                                                                                            false) as source)  source on true
                          left JOIN lateral (select * from flow.get_value_for_custom_field(1 ,
                                                                                           5,
                                                                                           p.id,
                                                                                           0,
                                                                                           true) as sourceId)  sourceId on true
                          left JOIN lateral (select * from flow.get_value_for_custom_field(1 ,
                                                                                           387,
                                                                                           p.id) as stage)  stage on true
                          left JOIN lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                            333,
                                                                                            p.id,
                                                                                            4) as system_size) system_size on true
                          left join lateral (select * from flow.get_value_for_custom_field(1 ,
                                                                                           52,
                                                                                           p.id) as cancelled_date) as cancelled_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           58,
                                                                                           p.id,
                                                                                           4)as installation_agreement_signed_date) as installation_agreement_signed_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           104,
                                                                                           p.id,
                                                                                           9)as final_design_signed_date) as final_design_signed_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           108,
                                                                                           p.id,
                                                                                           4)as agreement_signed_date) as agreement_signed_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           348,
                                                                                           p.id,
                                                                                           68)as utitlity_bill_verified_date) as utitlity_bill_verified_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           266,
                                                                                           p.id,
                                                                                           68)as proof_of_homeowners_insurance_required) as proof_of_homeowners_insurance_required on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           265,
                                                                                           p.id,
                                                                                           68)as proof_of_homeowners_insurance_obtained) as proof_of_homeowners_insurance_obtained on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           109,
                                                                                           p.id,
                                                                                           4)as financier) as financier on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           112,
                                                                                           p.id,
                                                                                           57)as first_cash_paid_date) as first_cash_paid_date on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           110,
                                                                                           p.id,
                                                                                           56)as first_cash_payment_amount) as first_cash_payment_amount on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           345,
                                                                                           p.id,
                                                                                           4)as total_system_price) as total_system_price on true
                          left join lateral (select * from flow.get_value_for_custom_field(4 ,
                                                                                           327,
                                                                                           p.id,
                                                                                           35)as substantial_completion_date) as substantial_completion_date on true
                 WHERE  (ec.project_id is null) and
                    CASE WHEN p_project_ids IS NOT NULL
                        THEN p.id = ANY(p_project_ids) ELSE 1 = 1 END
                    AND CASE WHEN p_contact_id IS NOT NULL
                                 THEN c.id = p_contact_id ELSE 1 = 1 END
                    AND CASE WHEN p_sales_rep IS NOT NULL
                                 THEN p_sales_rep = u.id ELSE 1 = 1 END
                    AND CASE WHEN p_cancel_start_date IS NOT NULL
                                 THEN cancelled_date.cancelled_date::date BETWEEN p_cancel_start_date AND p_cancel_end_date
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
