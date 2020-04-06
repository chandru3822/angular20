CREATE OR REPLACE FUNCTION blueraven.get_overrides_earned_by_user(p_payroll_id integer,p_user_id integer)
  RETURNS setof json AS
$BODY$
--select blueraven.get_overrides_earned_by_user(4 , 2353959)

BEGIN
  RETURN QUERY select array_to_json(array_agg(row_to_json(rows)))
               from (
                      select d1.deal_base_oid,d1.customer_name,d1.system_size,overrides_earned,overrides_paid,opru.allocation as override_allocation,
                        ( select name from blueraven.override_plan_vw opv3
                        where opv3.milestone_id =1 and
                              opv3.deal_id = sub_rows.id) as override_plan_name,
                      ( select opru.allocation from blueraven.override_plan_receiving_user opru
                        inner join blueraven.override_plan_vw opv3 on opv3.override_plan_id = opru.override_plan_id
                      where opv3.milestone_id =1 and opru.user_id = p_user_id and
                            opv3.deal_id = sub_rows.id) as user_allocation,
                      (select opma.allocation from blueraven.override_plan_milestone_allocation opma
                        inner join blueraven.override_plan_vw opv1 on opv1.override_plan_id = opma.override_plan_id and opv1.milestone_id = 1
                        inner join blueraven.milestone_query_condition mqc on mqc.id = opma.milestone_query_condition_id and
                                                                              mqc.milestone_id = 1 where opv1.deal_id = sub_rows.id) as milestone1_percentage,
                      (select opma.allocation from blueraven.override_plan_milestone_allocation opma
                        inner join blueraven.override_plan_vw opv2 on opv2.override_plan_id = opma.override_plan_id and opv2.milestone_id = 2
                        inner join blueraven.milestone_query_condition mqc on mqc.id = opma.milestone_query_condition_id and
                                                                              mqc.milestone_id = 2 where opv2.deal_id = sub_rows.id) as milestone2_percentage,
                      (select opv2.total
                       from blueraven.override_plan_vw opv2
                       where opv2.deal_id = sub_rows.id
                       limit 1) as plan_total
                      from (
                             select d.id,
                               coalesce(blueraven.get_overrides_earned_not_associated_with_deals(array[d.id], period_end ,p_user_id ),0) overrides_earned,
                               coalesce(blueraven.get_total_overrides( p.id,array[d.id],p_user_id ),0) as overrides_paid
                             from blueraven.payroll p
                               inner join blueraven.deal d on array[d.deal_base_oid] <@ p.selected_deal_ids
                             where p.id = p_payroll_id
                             group by d.id,period_end,p.id) as sub_rows
                        inner join blueraven.deal d1 on d1.id = sub_rows.id
                        left join blueraven.override_plan_vw opv on opv.deal_id = d1.id and milestone_id = 1
                        left join blueraven.override_plan_receiving_user opru on opru.override_plan_id = opv.override_plan_id and opru.user_id = p_user_id
                      where sub_rows.overrides_earned != 0 or sub_rows.overrides_paid != 0
                      order by 2) as rows;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;
