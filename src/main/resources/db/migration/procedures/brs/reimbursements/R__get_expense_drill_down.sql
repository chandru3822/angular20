drop function if exists brs.get_expense_drilldown(p_user_id bigint, p_start_date DATE, p_end_date DATE, p_status varchar, p_budget_id bigint);
CREATE OR REPLACE FUNCTION brs.get_expense_drilldown(p_user_id bigint, p_start_date DATE, p_end_date DATE, p_status varchar, p_budget_id bigint)
  RETURNS SETOF json AS
$BODY$
DECLARE

--select brs.get_monthly_expense_budget_report_drill_down(2353912, '02/01/2018'::DATE, '02/28/2018'::DATE, 'ALL',1)
--select brs.get_monthly_expense_budget_report_drill_down(2353912, '02/01/2018'::DATE, '02/28/2018'::DATE, 'PENDING_APPROVAL',1)
--select brs.get_monthly_expense_budget_report_drill_down(2353912, '02/01/2018'::DATE, '02/28/2018'::DATE, 'PENDING_PAYMENT',1)
--select brs.get_monthly_expense_budget_report_drill_down(46132, '02/01/2018'::DATE, '02/28/2018'::DATE, 'PAID',1)
BEGIN

  CASE
    WHEN P_STATUS = 'PENDING_REVIEW' THEN
      CASE WHEN p_budget_id is null then --budget_id null = for specific user
        RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                     from (
                            SELECT u.first_name||' '||u.last_name purchaser,
                                   bt.name budget,
                                   e.expense_date,
                                   e.expense_amount,
                                   e.approval_date,
                                   e.paid_date,
                                   e.notes details,
                                   e.reimbursement_request_id
                            FROM brs.expense e
                                   left join flow."user" u on e.user_id = u.id
                                   left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                   left join brs.budget_type bt on eb.budget_type_id = bt.id
                            where e.expense_date between p_start_date and p_end_date
                              and e.user_id = p_user_id
                              and e.gl_code_id is null
                              and e.archived is not true
                              and e.approval_date is null
                              and e.rejected_date is null
                              and e.skip_approval is not true )results;
        ELSE
          RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                       from (
                              SELECT u.first_name||' '||u.last_name purchaser,
                                     bt.name budget,
                                     e.expense_date,
                                     e.expense_amount,
                                     e.approval_date,
                                     e.paid_date,
                                     e.notes details,
                                     e.reimbursement_request_id
                              FROM brs.expense e
                                     inner join flow."user" u on e.user_id = u.id
                                     inner join brs.expense_budget eb on e.expense_budget_id = eb.id
                                     inner join brs.budget_type bt on eb.budget_type_id = bt.id
                              where e.expense_date between p_start_date and p_end_date
                                and e.expense_budget_id = p_budget_id
                                and eb.user_id = p_user_id
                                and e.gl_code_id is null
                                and e.archived is not true
                                and e.expense_budget_id is not null
                                and e.approval_date is null
                                and e.rejected_date is null
                                and e.skip_approval is not true )results;
        END CASE;
    WHEN P_STATUS = 'PENDING_APPROVAL' THEN
    CASE WHEN p_budget_id is null then --budget_id null = for specific user
      RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                   from (
                          SELECT u.first_name||' '||u.last_name purchaser,
                                 bt.name budget,
                                 e.expense_date,
                                 e.expense_amount,
                                 e.approval_date,
                                 e.paid_date,
                                 e.notes details,
                                 e.reimbursement_request_id
                          FROM brs.expense e
                                 left join flow."user" u on e.user_id = u.id
                                 left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                 left join brs.budget_type bt on eb.budget_type_id = bt.id
                          where e.expense_date between p_start_date and p_end_date
                            and e.user_id = p_user_id
                            and e.archived is not true
                            and e.gl_code_id is not null
                            and e.approval_date is null
                            and e.rejected_date is null
                            and e.skip_approval is not true )results;
      ELSE
        RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                     from (
                            SELECT u.first_name||' '||u.last_name purchaser,
                                   bt.name budget,
                                   e.expense_date,
                                   e.expense_amount,
                                   e.approval_date,
                                   e.paid_date,
                                   e.notes details,
                                   e.reimbursement_request_id
                            FROM brs.expense e
                                   inner join flow."user" u on e.user_id = u.id
                                   inner join brs.expense_budget eb on e.expense_budget_id = eb.id
                                   inner join brs.budget_type bt on eb.budget_type_id = bt.id
                            where e.expense_date between p_start_date and p_end_date
                              and e.expense_budget_id = p_budget_id
                              and eb.user_id = p_user_id
                              and e.archived is not true
                              and e.gl_code_id is not null
                              and e.expense_budget_id is not null
                              and e.approval_date is null
                              and e.rejected_date is null
                              and e.skip_approval is not true )results;
      END CASE;

    when P_STATUS = 'PENDING_PAYMENT' THEN
      CASE WHEN p_budget_id is null then
        RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                     from (
                            SELECT u.first_name||' '||u.last_name purchaser,
                                   bt.name budget,
                                   e.expense_date,
                                   e.expense_amount,
                                   e.approval_date,
                                   e.paid_date,
                                   e.notes details,
                                   e.reimbursement_request_id
                            FROM brs.expense e
                                   left join flow."user" u on e.user_id = u.id
                                   left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                   left join brs.budget_type bt on eb.budget_type_id = bt.id
                            where e.expense_date between p_start_date and p_end_date
                              and e.user_id = p_user_id
                              and e.archived is not true
                              and e.approval_date is not null and rejected_date is null AND paid_date is null)results;
        ELSE
          RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                       from (
                              SELECT u.first_name||' '||u.last_name purchaser,
                                     bt.name budget,
                                     e.expense_date,
                                     e.expense_amount,
                                     e.approval_date,
                                     e.paid_date,
                                     e.notes details,
                                     e.reimbursement_request_id
                              FROM brs.expense e
                                     inner join flow."user" u on e.user_id = u.id
                                     inner join brs.expense_budget eb on e.expense_budget_id = eb.id
                                     inner join brs.budget_type bt on eb.budget_type_id = bt.id
                              where e.expense_date between p_start_date and p_end_date
                                and e.expense_budget_id = p_budget_id
                                and e.archived is not true
                                and eb.user_id = p_user_id
                                and e.approval_date is not null and rejected_date is null AND paid_date is null)results;
        END CASE;


    when P_STATUS = 'PAID' THEN
      CASE WHEN p_budget_id is null then
        RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                     from (
                            SELECT u.first_name||' '||u.last_name purchaser,
                                   bt.name budget,
                                   e.expense_date,
                                   e.expense_amount,
                                   e.approval_date,
                                   e.paid_date,
                                   e.notes details,
                                   e.reimbursement_request_id
                            FROM brs.expense e
                                   left join flow."user" u on e.user_id = u.id
                                   left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                   left join brs.budget_type bt on eb.budget_type_id = bt.id
                            where e.expense_date between p_start_date and p_end_date
                              and e.user_id = p_user_id
                              and e.archived is not true
                              and paid_date is not null)results;
        ELSE
          RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                       from (
                              SELECT u.first_name||' '||u.last_name purchaser,
                                     bt.name budget,
                                     e.expense_date,
                                     e.expense_amount,
                                     e.approval_date,
                                     e.paid_date,
                                     e.notes details,
                                     e.reimbursement_request_id
                              FROM brs.expense e
                                     inner join flow."user" u on e.user_id = u.id
                                     inner join brs.expense_budget eb on e.expense_budget_id = eb.id
                                     inner join brs.budget_type bt on eb.budget_type_id = bt.id
                              where e.expense_date between p_start_date and p_end_date
                                and e.expense_budget_id = p_budget_id
                                and eb.user_id = p_user_id
                                and e.archived is not true
                                and paid_date is not null)results;
        END CASE;

    ELSE
      --"ALL"
      CASE WHEN p_budget_id is null then
        RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                     from (
                            SELECT u.first_name||' '||u.last_name purchaser,
                                   bt.name budget,
                                   e.expense_date,
                                   e.expense_amount,
                                   e.approval_date,
                                   e.paid_date,
                                   e.notes details,
                                   e.reimbursement_request_id
                            FROM brs.expense e
                                   left join flow."user" u on e.user_id = u.id
                                   left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                   left join brs.budget_type bt on eb.budget_type_id = bt.id
                            where e.expense_date between p_start_date and p_end_date
                              and e.archived is not true
                              and e.user_id = p_user_id
                              and e.rejected_date is null )results;

        ELSE
          RETURN QUERY select array_to_json(array_agg(row_to_json(results)))
                       from (
                              SELECT u.first_name||' '||u.last_name purchaser,
                                     bt.name budget,
                                     e.expense_date,
                                     e.expense_amount,
                                     e.approval_date,
                                     e.paid_date,
                                     e.notes details,
                                     e.reimbursement_request_id
                              FROM brs.expense e
                                     left join flow."user" u on e.user_id = u.id
                                     left join brs.expense_budget eb on e.expense_budget_id = eb.id
                                     left join brs.budget_type bt on eb.budget_type_id = bt.id
                              where e.expense_date between p_start_date and p_end_date
                                and e.expense_budget_id = p_budget_id
                                and e.archived is not true
                                and eb.user_id = p_user_id
                                and e.rejected_date is null )results;

        END CASE;

    END CASE;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100
                   ROWS 1000;
