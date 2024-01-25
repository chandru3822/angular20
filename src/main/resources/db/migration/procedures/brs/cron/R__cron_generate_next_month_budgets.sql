drop function if exists brs.cron_generate_next_month_budgets();
CREATE OR REPLACE FUNCTION brs.cron_generate_next_month_budgets()
    RETURNS void AS
$BODY$
declare
    v_next_month_start date;
    v_next_month_end date;
    r              record;
BEGIN
    select (date_trunc('month', current_date) + interval '1 month')::date,
           (date_trunc('month', current_date) + interval '2 month' - interval '1 day')::date
           into v_next_month_start, v_next_month_end;

    for r in SELECT
                 tem.amount,
                 tem.user_id
             FROM brs.budget_template tem
             WHERE tem.archived is not true
               and not exists(
                 select eb.id
                 from brs.expense_budget eb
                 where eb.user_id = tem.user_id
                   and eb.archived is false
                   and eb.start_date = (date_trunc('month', current_date) + interval '1 month')::date
             )
    loop
        insert into brs.expense_budget(user_id, amount, date_created, created_by_id, date_modified, modified_by_id, start_date, end_date)
        values (r.user_id, r.amount, now(), 99999999, now(), 99999999, v_next_month_start, v_next_month_end);
    end loop;

END

$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

