CREATE OR REPLACE FUNCTION brs.get_monthly_expense_budget_report(p_user_id integer, p_start_date date, p_end_date date)
  RETURNS SETOF json AS
$BODY$
DECLARE

--select brs.get_monthly_expense_budget_report(2353912, '2018-03-01'::date,'2018-03-31'::date)
--select brs.get_monthly_expense_budget_report(46132, '01/01/2018'::date,'01/31/2018'::date)

BEGIN

  RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
               from (
                      with pending_approval as
                             (select e.expense_budget_id, sum(e.expense_amount)amount
                              from brs.expense e
                              where e.expense_date between p_start_date and p_end_date
                                and e.archived is not true
                                and e.expense_budget_id is not null
                                and e.approval_date is null
                                and rejected_date is null
                                and e.skip_approval is not true
                              group by expense_budget_id) ,
                           pending_payment as
                             (select e.expense_budget_id, sum(e.expense_amount)amount
                              from brs.expense e
                              where e.expense_date between p_start_date and p_end_date
                                and e.archived is not true
                                and e.approval_date is not null and rejected_date is null AND paid_date is null
                              group by e.expense_budget_id) ,
                           paid as
                             (select e.expense_budget_id, sum(e.expense_amount)amount
                              from brs.expense e
                              where e.expense_date between p_start_date and p_end_date
                                and e.archived is not true
                                and e.paid_date is not null
                              group by e.expense_budget_id),
                           other as
                             (select e.expense_budget_id, sum(e.expense_amount)amount
                              from brs.expense e
                              where e.expense_date between p_start_date and p_end_date
                                and e.archived is not true
                                and e.skip_approval is true
                              group by e.expense_budget_id),
                           active_expense_budget   AS (select * from brs.expense_budget where (user_id, budget_type_id, date_created) in (SELECT
                                                                                                                                                  eb.user_id,
                                                                                                                                                  eb.budget_type_id,
                                                                                                                                                  max(eb.date_created) date_created
                                                                                                                                                FROM brs.expense_budget eb
                                                                                                                                                WHERE eb.archived is not true
                                                                                                                                                  and eb.start_date between p_start_date and p_end_date
                                                                                                                                                GROUP BY eb.user_id, eb.budget_type_id) )
                      select eb.budget_type_id,
                             bt.name budget_name,
                             sum(coalesce(eb.amount,0)) monthly_budget,
                             sum(coalesce(pa.amount,0)) pending_approval,
                             sum(coalesce(pp.amount,0)) pending_payment,
                             sum(coalesce(p.amount,0)) paid,
                             sum(coalesce(o.amount,0)) other,
                             sum(eb.amount)-sum(coalesce(pa.amount,0))-sum(coalesce(pp.amount,0))-sum(coalesce(p.amount,0))-sum(coalesce(o.amount,0))  remaining_budget
                      from active_expense_budget eb
                             inner join brs.budget_type bt on eb.budget_type_id = bt.id
                             left outer join pending_approval pa on eb.id = pa.expense_budget_id
                             left outer join pending_payment pp on eb.id = pp.expense_budget_id
                             left outer join paid p on eb.id = p.expense_budget_id
                             left outer join other o on eb.id = o.expense_budget_id
                      where eb.user_id = p_user_id
                        and eb.start_date between p_start_date and p_end_date
                      group by eb.budget_type_id, bt.name) results;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;

