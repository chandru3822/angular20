drop function if exists brs.get_monthly_expense_budget_report(p_user_id bigint, p_start_date date, p_end_date date);
CREATE OR REPLACE FUNCTION brs.get_monthly_expense_budget_report(p_user_id bigint, p_start_date date, p_end_date date)
    RETURNS SETOF json AS
$BODY$
DECLARE

--select brs.get_monthly_expense_budget_report(2353912, '2018-03-01'::date,'2018-03-31'::date)
--select brs.get_monthly_expense_budget_report(46132, '01/01/2018'::date,'01/31/2018'::date)

BEGIN

    RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                 from (with budget_info as (select to_char(eb.start_date, 'FMMonth YYYY')                               budget_name,
                                                   eb.id                                                                budget_id,
                                                   eb.amount,
                                                   eb.start_date,
                                                   eb.end_date,
                                                   eb.amount                                                            monthly_budget,
                                                   coalesce(sum(rr.amount)
                                                   filter (where rr.approval_date is null and rr.rejected_date is null),0) pending_review,
                                                            coalesce(sum(rr.amount)
                                                   filter (where rr.paid_date is null and rr.approval_date is not null and
                                                                 rr.rejected_date is null),0)                              pending_approval,
                                                                     coalesce(sum(rr.amount)
                                                   filter (where rr.approval_date is not null and
                                                                 rr.rejected_date is null AND
                                                                 rr.paid_date is null),0)                                  pending_payment,
                                                                              coalesce(sum(rr.amount) filter (where rr.paid_date is not null),0)      paid
                                            --                              sum(coalesce(o.amount,0)) other,
--                              sum(eb.amount) - sum(coalesce(rr.amount, 0)) - sum(coalesce(pa.amount, 0)) -
--                              sum(coalesce(pp.amount, 0)) - sum(coalesce(p.amount, 0)) remaining_budget
                                            from brs.expense_budget eb
                                                     left join brs.reimbursement_request rr
                                                               on eb.id = rr.expense_budget_id and rr.archived is not true
                                            where eb.user_id = p_user_id
                                              and eb.start_date between p_start_date and p_end_date
                                            group by eb.id, budget_name, eb.amount, eb.start_date, eb.end_date)


                       select *,
                              (monthly_budget - pending_review - pending_approval - pending_payment - paid) as remaining_budget
                       from budget_info
                       ) results;


END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100
                     ROWS 1000;

