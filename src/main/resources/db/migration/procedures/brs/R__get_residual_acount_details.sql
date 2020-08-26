DROP FUNCTION IF EXISTS brs.get_residual_account_details(date);
/*MILESTONE 1 9 MILESTONE 2 35*/
CREATE OR REPLACE FUNCTION brs.get_residual_account_details(p_date date)
    RETURNS TABLE(
                     project_id                                  INTEGER,
                     customer_id                                 INT,
                     customer_name                               VARCHAR,
                     system_size                                 NUMERIC(10,2),
                     locked                                      BOOLEAN,
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
v_month_start date;
v_month_end   date;
BEGIN

    select date_trunc('month', p_date -1)::date as month_start,
           (date_trunc('month',p_date -1)+'1month' - interval '1 day')::date as month_end
    into v_month_start,v_month_end;

    RETURN QUERY
        with fdc as (
        select up3.user_id,count(1) fdc
        from flow.project p
                 inner join flow.user_project up on up.project_id = p.id and up.end_date is not null
                 inner join flow.user_position up3  on up3.id = up.user_position_id and up3.position_id = 1
                 inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_id = 4 and pps.process_step_complete_date is not null
            and pps.process_step_complete_date between v_month_start and v_month_end
        group by up3.user_id)
            select *,
                   case when cancelled_date is not null then 0 else coalesce(residual_earned,0) end as residual_earned,
                   case when cancelled_date is null then 0 else coalesce(residual_paid ,0) end as residual_paid,
                   case when cancelled_date is not null then 0 - coalesce(residual_paid,0) else coalesce(residual_earned,0) end as residual_owed
        from (
                 SELECT p.id as project_id,
                        c.id as contact_id,
                        p.project_name,
                        system_size.system_size::numeric as system_size,
                        up2.user_id as closer_user_id,
                        u.first_name||' '||u.last_name                                  AS closer,
                        --(u.user_status_type_id = 3)                                     AS closer_is_terminated,
                        false AS closer_is_terminated,
                        'source'::character varying as source_name,
                        'stage'::character varying as stage_name,
                        cancelled_date.cancelled_date::date as cancelled_date,
                        installation_agreement_signed_date.installation_agreement_signed_date::date as installation_agreement_signed_date,
                        null::date as final_design_signed_date,
                        null::date as agreement_signed_date,
                        null::date as utility_bill_verified_date,
                        null::boolean as proof_of_howmeowners_insurance_required,
                        null::date as proof_of_homeowners_insurance_obtained_date,
                        null::text                                    AS financier,
                        null::date as first_cash_payment_paid_date,
                        null::numeric as first_cash_payment_amount,
                        null::numeric as total_system_price,
                        null::numeric as percent_of_cash_deposit,
                        null::date as substantial_completion_date,
                        rp.id  AS residual_plan,
                        (select sum(paid)
                            from brs.residual_ledger rl
                            where rl.user_project_id = up.id) as residual_paid,
                        rpa.total as residual_earned,
                        rpa.id as allocation_id
                 FROM flow.project p
                          inner join flow.project_process_step pps on pps.project_id = p.id and pps.process_step_complete_date is not null and process_step_complete_date < p_date and  process_step_id in (4,9,35)
                          inner join flow.contact c on c.id = p.contact_id
                          inner join flow.user_project up on up.project_id = p.id and up.end_date is null
                          inner join flow.user_position up2  on up2.id = up.user_position_id and up2.position_id = 1
                          inner join fdc f on f.user_id = up2.user_id
                          INNER JOIN flow.user u ON u.id = up2.user_id
                          inner join brs.project_residual pr on pr.project_id = p.id
                          inner join brs.residual_plan rp on rp.id = pr.residual_plan_id
                          left join brs.residual_plan_allocation rpa on rpa.residual_plan_id = rp.id and f.fdc between rpa.nbr_fdc_lower and rpa.nbr_fdc_upper
                          left JOIN lateral (select * from flow.get_value_for_custom_field(1 ,
                                                                                           5,
                                                                                           p.id) as source_id1)  source_id1 on true
                          INNER JOIN lateral (select * from flow.get_value_for_custom_field(4 ,
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
                 WHERE p.id = 184253) as foo
    where foo.allocation_id is not null or cancelled_date is not null;
END
$$;
