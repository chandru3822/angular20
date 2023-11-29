drop function if exists brs.get_all_users_overrides_earned_in_open_payroll(p_payroll_id bigint, p_run_by_id bigint);
CREATE OR REPLACE FUNCTION brs.get_all_users_overrides_earned_in_open_payroll(p_payroll_id bigint, p_run_by_id bigint)
  RETURNS TABLE
          (
            project_id            bigint,
            closer                TEXT,
            closer_employee_id    TEXT,
            customer_name         CHARACTER VARYING(200),
            system_size           NUMERIC(10, 2),
            overrides_earned      NUMERIC,
            prior_pay             NUMERIC,
            current_pay           NUMERIC,
            override_plan_name    TEXT,
            user_allocation       NUMERIC(10, 2),
            milestone1_percentage NUMERIC(10, 2),
            milestone2_percentage NUMERIC(10, 2),
            plan_total            NUMERIC(10, 2)
          )

AS
$BODY$
declare
  v_period_end_date date;
  v_position_id     bigint;

BEGIN

  select period_end, position_id
  into v_period_end_date,v_position_id
  from brs.payroll
  where id = p_payroll_id;

  case
    when v_position_id = 1 then RETURN QUERY
      select foo.project_id::bigint,
             foo.closer,
             foo.closer_employee_id,
             foo.project_name::character varying,
             foo.system_size,
             case
               when cancelled_date is not null then
                 0
               when foo.commission_strategy =23610 and foo.substantial_completion_date is not null then
                   (foo.red_line_m1_allocation + foo.red_line_m2_allocation) * foo.total_commissions
               when foo.commission_strategy =23610 and foo.substantial_completion_date is null then
                   (foo.red_line_m1_allocation) * foo.total_commissions
               when foo.substantial_completion_date is null then
                 foo.system_size * foo.milestone1_amount
               else foo.system_size * (foo.milestone1_amount + foo.milestone2_amount) end                         overrides_earned,
             foo.overrides_paid                                                                                as prior_pay,
             case
               when cancelled_date is not null  then
                 0
               when foo.commission_strategy =23610 and foo.substantial_completion_date is not null then
                   (foo.red_line_m1_allocation + foo.red_line_m2_allocation) * foo.total_commissions
               when foo.commission_strategy =23610 and foo.substantial_completion_date is null then
                   (foo.red_line_m1_allocation) * foo.total_commissions
               when foo.substantial_completion_date is null then
                 foo.system_size * foo.milestone1_amount
               else foo.system_size * (foo.milestone1_amount + foo.milestone2_amount) end -
             foo.overrides_paid                                                                                as current_pay,
             foo.name                                                                                          as override_plan_name,
             case when foo.commission_strategy =23610 then
                    foo.red_line_m1_allocation + foo.red_line_m2_allocation
              else foo.user_allocation end ,
             case when foo.commission_strategy =23610 then
               foo.red_line_m1_allocation
              else foo.milestone1_amount end ,
             case when foo.commission_strategy =23610 then
               foo.red_line_m2_allocation
              else
              foo.milestone2_amount end ,
             case when foo.commission_strategy =23610 then
               0::numeric
               else foo.plan_total  end                                                                                  as plan_total
      from (select pd.project_id                                      as project_id,
                   u.first_name || ' ' || u.last_name        as closer,
                   pd.closer_employee_id,
                   pd.project_name::character varying                            as project_name,
                   pd.system_size                            as system_size,
                   opru1.m1_allocation + opru1.m2_allocation as user_allocation,
                   opru1.m1_allocation                       as milestone1_amount,
                   opru1.m2_allocation                       as milestone2_amount,
                   opru1.red_line_m1_allocation              as red_line_m1_allocation,
                   opru1.red_line_m2_allocation              as red_line_m2_allocation,
                   fd.total_commissions,
                   fd.desired_commission_amount,
                   fd.commission_strategy,
                   op.total                                  as plan_total,
                   (select coalesce(sum(dcl.paid_to_date), 0)
                    from brs.project_commission_ledger dcl
                           inner join flow.project d1 on d1.id = dcl.project_id
                    WHERE dcl.project_id = d1.id
                      and dcl.ledger_type_id = 3
                      and dcl.user_id = u.id
                      and d1.id = pd.project_id
                      and dcl.position_id = 1)                  overrides_paid,
                   op.name                                   as name,
                   fd.substantial_completion_date,
                   fd.overrides_earned_m1,
                   fd.cancelled_date
            from brs.payroll p1
                    inner join brs.project_details pd on pd.project_id = any (p1.selected_project_ids)
                   inner join brs.financial_details fd on fd.project_id = pd.project_id
                   inner join brs.override_plan op on op.id = fd.override_plan_id
                   inner join brs.override_plan_receiving_user opru1
                              on opru1.override_plan_id = op.id
                   inner join flow.user u on u.id = opru1.user_id
            where p1.id = p_payroll_id
              and op.position_id = 1
            union
            select pd.project_id                               as project_id,
                   u.first_name || ' ' || u.last_name as closer,
                   pd.closer_employee_id,
                   pd.project_name::character varying                     as project_name,
                   pd.system_size                     as system_size,
                   0                                  as user_allocation,
                   0                                  as milestone1_amount,
                   0                                  as milestone2_amount,
                   0              as red_line_m1_allocation,
                   0              as red_line_m2_allocation,
                   0 as total_commissions,
                   0  as desired_commission_amount,
                   fd.commission_strategy,
                   0                                  as plan_total,
                   (select coalesce(sum(dcl.paid_to_date), 0)
                    from brs.project_commission_ledger dcl
                           inner join flow.project d1 on d1.id = dcl.project_id
                    WHERE dcl.project_id = d1.id
                      and dcl.ledger_type_id = 3
                      and dcl.user_id = u.id
                      and d1.id = pd.project_id
                      and dcl.position_id = 1)           overrides_paid,
                   null                               as name,
                   fd.substantial_completion_date,
                   fd.overrides_earned_m1,
                   fd.cancelled_date
            from brs.payroll p1
                     inner join brs.project_details pd on pd.project_id = any (p1.selected_project_ids)
                   inner join brs.financial_details fd on fd.project_id = pd.project_id
                   inner join brs.project_commission_ledger pcl on pcl.project_id = fd.project_id and
                                                                   ledger_type_id = 3 and
                                                                   p1.position_id = 1
                   inner join flow.user u on u.id = pcl.user_id
              and not exists(select id
                             from brs.override_plan_receiving_user opru1
                             where opru1.user_id = pcl.user_id
                               and opru1.override_plan_id = fd.override_plan_id)
            where p1.id = p_payroll_id
              and p1.position_id = 1) as foo
    order by 1;


    when v_position_id = 4 then RETURN QUERY
      select foo.project_id::bigint,
             foo.closer,
             foo.closer_employee_id,
             foo.project_name::character varying,
             foo.system_size,
             foo.overrides_earned,
             foo.overrides_paid                        as prior_pay,
             foo.overrides_earned - foo.overrides_paid as current_pay,
             foo.name                                  as override_plan_name,
             foo.user_allocation,
             foo.milestone1_amount,
             foo.milestone2_amount,
             foo.plan_total                            as plan_total
      from (select pd.project_id                                      as project_id,
                   u.first_name || ' ' || u.last_name        as closer,
                   pd.closer_employee_id,
                   pd.project_name::character varying                            as project_name,
                   pd.system_size                            as system_size,
                   opru1.m1_allocation + opru1.m2_allocation as user_allocation,
                   opru1.m1_allocation                       as milestone1_amount,
                   opru1.m2_allocation                       as milestone2_amount,
                   op.total                                  as plan_total,

                   (select coalesce(
                             (SELECT sum(case
                                           when pd1.cancelled_date is not null then
                                             0::numeric
                                           else coalesce((select m1_allocation
                                                          from brs.override_plan_receiving_user opru
                                                          where opru.override_plan_id = op.id
                                                            and opru.user_id = u.id),
                                                         0) end) total
                              FROM brs.project_details pd1
                                     inner join brs.project_override po on po.project_id = pd1.project_id
                                     inner join brs.override_plan op
                                                on op.id = po.override_plan_id and op.position_id = 4
                                     inner join brs.override_plan_receiving_user opru on opru.override_plan_id = op.id
                              WHERE pd1.project_id = pd.project_id
                                and opru.user_id = u.id),
                             0))                             AS overrides_earned,
                   (select coalesce(sum(dcl.paid_to_date), 0)
                    from brs.project_commission_ledger dcl
                           inner join flow.project d1 on d1.id = dcl.project_id
                    WHERE dcl.ledger_type_id = 3
                      and dcl.user_id = u.id
                      and d1.id = pd.project_id
                      and dcl.position_id = 4)                  overrides_paid,
                   op.name                                   as name
            from brs.payroll p1
                     inner join brs.project_details pd on pd.project_id = any (p1.selected_project_ids)
                   inner join brs.project_override po on po.project_id = pd.project_id
                   inner join brs.override_plan op on op.id = po.override_plan_id
                   inner join brs.override_plan_receiving_user opru1
                              on opru1.override_plan_id = po.override_plan_id
                   inner join flow.user u on u.id = opru1.user_id
            where p1.id = p_payroll_id
              and op.position_id = 4) as foo;

    end case;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
