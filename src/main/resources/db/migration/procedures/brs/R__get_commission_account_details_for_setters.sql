DROP FUNCTION IF EXISTS brs.get_commission_account_details_for_setters(integer,BIGINT [],INTEGER,INTEGER,DATE,DATE,INTEGER,INTEGER);
CREATE OR REPLACE FUNCTION brs.get_commission_account_details_for_setters(p_payroll_id         integer,
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
                     project_name                               VARCHAR,
                     user_id                              bigint,
                     setter                                      TEXT,
                     setter_is_terminated                        BOOLEAN,
                     source_name                                 VARCHAR,
                     cancelled_date                              DATE,
                     closer_appointment_start                    timestamp,
                     closer_appointment_outcome                         varchar,
                     overrides_per_user                          JSON,
                     override_plan                               TEXT,
                     override_plan_id                            INT,
                     commission_plan                             TEXT,
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
    v_period_end_date date;
    v_amounts numeric[] = '{0.00,-0.01,0.01}';
BEGIN

    select period_end
    into v_period_end_date
    from brs.payroll
        where id = p_payroll_id;


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
                        u.id as setter_user_id,
                        u.first_name||' '||u.last_name                                  AS setter,
                        (ust.user_status_type = 'Terminated')                           AS setter_is_terminated,
                        lov_source.name as source_name,
                        pd.cancelled_date as cancelled_date,
                        pd.closer_appointment_start as closer_appointment_start,
                        pd.closer_appointment_outcome_name::varchar as closer_appointment_outcome,
                       (SELECT array_to_json(array_agg(row_to_json(_overrides_per_user))) AS overrides_per_user
                         FROM (SELECT p1.id AS project_id,
                                       u.id,
                                       u.first_name,
                                       u.last_name,
                                       coalesce(
                                               opru.m1_allocation,
                                               0)  total,
                                       1 as milestone_id
                                FROM flow.project p1
                                         inner join brs.project_details pd on pd.project_id = p1.id and
                                                                              pd.setter_milestone_pay::date <= v_period_end_date
                                         inner join brs.project_override po on po.project_id = p1.id
                                         inner join brs.override_plan op on po.override_plan_id = op.id and op.position_id = 4
                                         INNER JOIN brs.override_plan_receiving_user opru
                                                    ON opru.override_plan_id = op.id
                                         INNER JOIN flow.user u ON u.id = opru.user_id
                                where p1.id = p.id) AS _overrides_per_user),
                        (SELECT op.name AS override_plan
                         FROM brs.override_plan op
                                  inner join brs.project_override po on po.override_plan_id = op.id
                         WHERE po.project_id = p.id and op.position_id = 4
                        )                                                       AS override_plan,
                        (SELECT op.id AS override_plan_id
                         FROM brs.override_plan op
                                  inner join brs.project_override po on po.override_plan_id = op.id
                         WHERE po.project_id = p.id and op.position_id = 4
                        )                                                       AS override_plan_id,
                        (SELECT cp.name AS commission_plan
                         FROM brs.commission_plan cp
                                  inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                         WHERE pc.project_id = p.id and cp.position_id = 4
                        )                                                       AS commission_plan,
                        (SELECT cp.id AS commission_plan_id
                         FROM brs.commission_plan cp
                                  inner join brs.project_commission pc on pc.commission_plan_id = cp.id
                         WHERE pc.project_id = p.id  and cp.position_id = 4
                        )                                                       AS commission_plan_id,

                        (SELECT coalesce(cp.total,
                                         0) total
                         FROM flow.project p2
                                  inner join brs.project_commission pc on pc.project_id = p2.id
                                  inner join brs.commission_plan cp on pc.commission_plan_id = cp.id and cp.position_id = 4
                         where p2.id = p.id) AS total_commissions,
                        coalesce(
                                (select op2.total
                                 from brs.override_plan op2
                                          inner join brs.project_override po on op2.id = po.override_plan_id
                                 where po.project_id = p.id and op2.position_id = 4),
                                0)                                                          AS total_overrides,
                        coalesce(
                                (SELECT case when pd.cancelled_date is not null then
                                                 0::NUMERIC
                                             else coalesce(cpa.allocation,
                                                           0) end total
                                 FROM flow.project p1
                                          inner join brs.project_details pd on p1.id = pd.project_id
                                          inner join brs.project_commission pc on pc.project_id = p1.id
                                          inner join brs.commission_plan cp on cp.id = pc.commission_plan_id and cp.position_id = 4
                                          inner join brs.commission_plan_allocation cpa on cpa.commission_plan_id = cp.id and cpa.milestone_id = 1
                                 WHERE p1.id = p.id ),0)  AS commission_earned,
                        coalesce(
                                (SELECT case when pd.cancelled_date is not null then
                                                 0::numeric
                                             else coalesce((select sum(m1_allocation)
                                                                from brs.override_plan_receiving_user opru
                                                                where opru.override_plan_id = op.id),0) end total
                                 FROM flow.project p1
                                          inner join brs.project_details pd on p1.id = pd.project_id
                                          inner join brs.project_override po on po.project_id = p1.id
                                          inner join brs.override_plan op on op.id = po.override_plan_id and op.position_id = 4
                                 WHERE p1.id = p.id ),0) AS override_earned,
                        coalesce(brs.get_ledger_adjustment_current_totals( p_payroll_id,array[p.id],1),0) AS commission_adjustments,
                        --TODO implement this at a later date.
                        0::numeric AS override_adjustments,
                        (SELECT coalesce(sum(amount), 0)
                         FROM brs.project_commission_ledger dcl
                         WHERE dcl.project_id = p.id::integer
                           AND dcl.ledger_type_id = 1
                           and dcl.position_id = 4)
                            AS commission_paid_to_date,
                        (
                            SELECT coalesce(sum(dcl.paid_to_date), 0)
                            FROM brs.project_commission_ledger dcl
                            WHERE dcl.project_id = p.id  and
                                    dcl.ledger_type_id = 3
                              and dcl.position_id = 4
                        )   AS overrides_paid_to_date
                 FROM flow.project p
                         -- inner join milestone1 mop on mop.project_id = p.id
                          inner join brs.project_details pd on pd.project_id = p.id
                          inner join flow.contact c on c.id = p.contact_id
                          INNER JOIN flow.user u ON u.id = pd.setter_user_id
                          inner join flow.company_user_status cus  on cus.user_id = u.id
                          inner join flow.user_status_type ust on ust.id = cus.user_status_type_id and ust.company_id = 3
                          left join flow.list_of_value lov_source on lov_source.id = pd.source
                 WHERE pd.setter_milestone_pay::date >= '2021-05-03' and
                     CASE WHEN p_project_ids IS NOT NULL
                              THEN p.id = ANY(p_project_ids) ELSE
                         pd.setter_milestone_pay::date <= v_period_end_date  END
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
                       THEN not COALESCE(foo.commission_earned,0) + COALESCE(foo.override_earned,0) +
                            (COALESCE(foo.commission_adjustments,0) - COALESCE(foo.commission_paid_to_date,0) -
                             COALESCE(foo.overrides_paid_to_date,0)) =  any(v_amounts) ELSE 1 = 1 END
          AND CASE WHEN p_override_plan_id IS NOT NULL
                       THEN foo.override_plan_id = p_override_plan_id ELSE 1 = 1 END
          AND CASE WHEN p_commission_plan_id IS NOT NULL
                       THEN foo.commission_plan_id = p_commission_plan_id
                   ELSE 1 = 1 END;

END
$$;
