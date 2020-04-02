CREATE OR REPLACE FUNCTION blueraven.get_overrides_earned_by_user_snapshot(p_payroll_id integer,p_user_id integer)
  RETURNS setof json AS
$BODY$
--select blueraven.get_overrides_earned_by_user_snapshot(2 , 2353959)

BEGIN
  RETURN QUERY select array_to_json(array_agg(row_to_json(rows)))
   from (
     with overrides_earned_by_deal as (select
                                         sum(coalesce(amount,0)) as overrides_earned,closer_id,deal_base_oid,d.id as deal_id
                                       from blueraven.deal_commission_ledger dcl
                                         inner join blueraven.deal d on d.id = dcl.deal_id
                                       where ledger_type_id = 3 and payroll_id = p_payroll_id
                                             and closer_id = p_user_id
                                       group by closer_id,deal_base_oid,d.id),
         overides_paid_to_date_by_deal as (select
                                             sum(coalesce(paid_to_date,0)) as overrides_paid,closer_id,deal_base_oid,d.id as deal_id
                                           from blueraven.deal_commission_ledger dcl
                                             inner join blueraven.deal d on d.id = dcl.deal_id
                                           where ledger_type_id = 3 and payroll_id < p_payroll_id
                                                 and closer_id = p_user_id
                                                 AND ARRAY[d.deal_base_oid] <@ (SELECT selected_deal_ids
                                                                                FROM blueraven.payroll
                                                                                WHERE id = p_payroll_id)
                                           group by closer_id,deal_base_oid,d.id),
         overides_paid_to_date_by_deal_payroll1 as (select sum(coalesce(paid_to_date,0)) as overrides_paid,closer_id,
                                                      deal_base_oid,d.id as deal_id
                                                    from blueraven.deal_commission_ledger dcl
                                                      inner join blueraven.deal d on d.id = dcl.deal_id
                                                    where ledger_type_id = 3 and payroll_id = 0
                                                          and closer_id = p_user_id and dcl.closer_id not in(select dcl.closer_id
                                                                                                         from blueraven.deal_commission_ledger
                                                                                                         where ledger_Type_id = 3 and payroll_id = p_payroll_id)
                                                          and array[deal_base_oid] <@ (select p.selected_deal_ids
                                                                                       from blueraven.payroll p
                                                                                       where id = p_payroll_id)
                                                          and dcl.closer_id not in (select sales_rep_id from blueraven.deal_commission_snapshot
                                                                                    where payroll_id = p_payroll_id)
                                                    group by closer_id,deal_base_oid,d.id)
     select d1.deal_base_oid,d1.customer_name,d1.system_size,
       coalesce(oebd.overrides_earned,0) as overrides_earned,coalesce(optdbd.overrides_paid,0) as overrides_paid,
       ( select name from blueraven.override_plan_vw opv3
       where opv3.milestone_id =1 and
             opv3.deal_id = d1.id) as override_plan_name,
       ( select opru.allocation from blueraven.override_plan_receiving_user opru
         inner join blueraven.override_plan_vw opv3 on opv3.override_plan_id = opru.override_plan_id
       where opv3.milestone_id =1 and opru.user_id = p_user_id and
             opv3.deal_id = d1.id) as user_allocation,
       (select opv2.allocation from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 1) as milestone1_percentage,
       (select opv2.allocation from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 2) as milestone2_percentage,
       (select opv2.total from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 1) as plan_total
     from blueraven.deal_commission_ledger dcl1
       inner join blueraven.deal d1 on d1.id = dcl1.deal_id
       left join overrides_earned_by_deal oebd on oebd.deal_id = dcl1.deal_id
       left join overides_paid_to_date_by_deal optdbd on optdbd.deal_id = dcl1.deal_id
     where dcl1.ledger_type_id = 3
           and dcl1.closer_id = p_user_id
           and dcl1.payroll_id = p_payroll_id
     union
     select d1.deal_base_oid,d1.customer_name,d1.system_size,
       0::numeric as overrides_earned,coalesce(optdbd.overrides_paid,0) as overrides_paid,
       ( select name from blueraven.override_plan_vw opv3
       where opv3.milestone_id =1 and
             opv3.deal_id = d1.id) as override_plan_name,
       ( select opru.allocation from blueraven.override_plan_receiving_user opru
         inner join blueraven.override_plan_vw opv3 on opv3.override_plan_id = opru.override_plan_id
       where opv3.milestone_id =1 and opru.user_id = p_user_id and
             opv3.deal_id = d1.id) as user_allocation,
       (select opv2.allocation from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 1) as milestone1_percentage,
       (select opv2.allocation from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 2) as milestone2_percentage,
       (select opv2.total from blueraven.override_plan_vw opv2
       where opv2.deal_id = d1.id and opv2.milestone_id = 1) as plan_total
     from blueraven.deal_commission_ledger dcl1
       inner join blueraven.deal d1 on d1.id = dcl1.deal_id
       inner join  overides_paid_to_date_by_deal_payroll1 optdbd on optdbd.deal_id = dcl1.deal_id
     where dcl1.ledger_type_id = 3
           and dcl1.closer_id = p_user_id
           and dcl1.payroll_id = 0
        ) as rows;
 END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;