package com.albatross.api.v1.company.blueraven.services.expenses.queries;

public class ExpenseQuery {

  //language=PostgreSQL
  public final static String getAllGlCodes = """
    SELECT
      id,
      code,
      description,
      archived
    FROM brs.gl_code gl
    where archived is false
    order by code
    """;

  //language=PostgreSQL
  public final static String getOneGlCode = """
    SELECT
      id,
      code,
      description,
      archived
    FROM brs.gl_code gl
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertGlCode = """
    INSERT INTO brs.gl_code(code, description, created_by_id, date_created, modified_by_id, date_modified)
    values(:code, :description, :userId, now(), :userId, now())
    """;

  //language=PostgreSQL
  public final static String updateGlCode = """
    UPDATE brs.gl_code
      SET code = :code,
          description = :description,
          modified_by_id = :userId,
          date_modified = now()
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String deleteGlCode = """
    UPDATE brs.gl_code
      SET archived = true,
          modified_by_id = :userId,
          date_modified = now()
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String getAllInDateRange = """
    SELECT e.id,
           e.skip_approval,
           e.approval_date,
           e.approved_by_id,
           a.first_name || ' ' || a.last_name approved_by,
           e.date_created,
           case when submitted_by_id is not null
             then e.date_submitted
             else null end as date_submitted,
           e.expense_amount,
           e.expense_budget_id,
           bt.name budget_type,
           eb.budget_type_id,
           e.expense_date,
           e.gl_code_id,
           pos.id position_id,
           pos.position position_name,
           eb.user_id expense_budget_user_id,
           ebu.first_name || ' ' || ebu.last_name expense_budget_user,
           g.code gl_code,
           e.notes,
           e.paid_by_id,
           p.first_name || ' ' || p.last_name paid_by,
           e.paid_date,
           e.reimbursement_request_id,
           e.user_id,
           u.first_name || ' ' || u.last_name created_by,
           e.submitted_by_id,
           s.first_name || ' ' || s.last_name submitted_by,
           rr.details reimbursement_request_details
   FROM brs.expense e
     INNER JOIN flow."user" u on u.id = e.user_id
     inner JOIN flow.user_position up on up.user_id = u.id and up.primary_flag is true
                                                      and up.start_date < now()
                                                      and (up.end_date is null or up.end_date > now())
     inner JOIN flow.position pos on pos.id = up.position_id and pos.company_id = 3
     LEFT JOIN flow."user" s on s.id = e.submitted_by_id
     LEFT JOIN brs.gl_code g on g.id = e.gl_code_id
     LEFT JOIN flow."user" a on a.id = e.approved_by_id
     LEFT JOIN flow."user" p on p.id = e.paid_by_id
     LEFT JOIN brs.expense_budget eb on eb.id = e.expense_budget_id
     LEFT JOIN flow."user" ebu on ebu.id = eb.user_id
     LEFT JOIN brs.budget_type bt on bt.id = eb.budget_type_id
     LEFT JOIN brs.reimbursement_request rr on rr.id = e.reimbursement_request_id
   WHERE e.expense_date BETWEEN :startDate and :endDate
      and e.archived is not true
      AND e.rejected_date is null
      AND (rr.reimbursement_request_status_id is null or rr.reimbursement_request_status_id != 6)
   order by e.date_submitted
    """;

  //language=PostgreSQL
  public final static String getAllUnpaid = """
    SELECT  e.id,
            e.approval_date,
            e.approved_by_id,
            a.first_name || ' ' || a.last_name approved_by,
            e.date_created,
            case when submitted_by_id is not null
              then e.date_submitted
              else null end as date_submitted,
            e.expense_amount,
            e.expense_budget_id,
            bt.name budget_type,
            eb.budget_type_id,
            e.expense_date,
            e.gl_code_id,
            e.archived,
            pos.id position_id,
            pos.position position_name,
            eb.user_id expense_budget_user_id,
            ebu.first_name || ' ' || ebu.last_name expense_budget_user,
            g.code gl_code,
            e.notes,
            e.paid_by_id,
            p.first_name || ' ' || p.last_name paid_by,
            e.paid_date,
            e.reimbursement_request_id,
            e.user_id,
            u.first_name || ' ' || u.last_name created_by,
            e.submitted_by_id,
            s.first_name || ' ' || s.last_name submitted_by,
            rr.details reimbursement_request_details
          FROM brs.expense e
            INNER JOIN flow."user" u on u.id = e.user_id
            inner JOIN flow.user_position up on up.user_id = u.id and up.primary_flag is true
                                          and up.start_date < now()
                                          and (up.end_date is null or up.end_date > now())
            inner JOIN flow.position pos on pos.id = up.position_id and pos.company_id = 3
            LEFT JOIN flow."user" s on s.id = e.submitted_by_id
            LEFT JOIN brs.gl_code g on g.id = e.gl_code_id
            LEFT JOIN flow."user" a on a.id = e.approved_by_id
            LEFT JOIN flow."user" p on p.id = e.paid_by_id
            LEFT JOIN brs.expense_budget eb on eb.id = e.expense_budget_id
            LEFT JOIN flow."user" ebu on ebu.id = eb.user_id
            LEFT JOIN brs.budget_type bt on bt.id = eb.budget_type_id
            LEFT JOIN brs.reimbursement_request rr on rr.id = e.reimbursement_request_id
          WHERE e.paid_date is null
                  and e.archived is not true
                AND e.skip_approval is not true
                AND e.rejected_date is null
                AND (rr.reimbursement_request_status_id is null or rr.reimbursement_request_status_id not in (2,6))
          order by e.date_submitted
    """;

  //language=PostgreSQL
  public final static String getAllPaidInDateRange = """
    SELECT  e.id,
            e.approval_date,
            e.approved_by_id,
            a.first_name || ' ' || a.last_name approved_by,
            e.date_created,
            case when submitted_by_id is not null
              then e.date_submitted
              else null end as date_submitted,
            e.expense_amount,
            e.expense_budget_id,
            bt.name budget_type,
            eb.budget_type_id,
            e.expense_date,
            e.gl_code_id,
            pos.id position_id,
            pos.position position_name,
            eb.user_id expense_budget_user_id,
            ebu.first_name || ' ' || ebu.last_name expense_budget_user,
            g.code gl_code,
            e.notes,
            e.paid_by_id,
            p.first_name || ' ' || p.last_name paid_by,
            e.paid_date,
            e.reimbursement_request_id,
            e.user_id,
            u.first_name || ' ' || u.last_name created_by,
            e.submitted_by_id,
            s.first_name || ' ' || s.last_name submitted_by,
            rr.details reimbursement_request_details
          FROM brs.expense e
            INNER JOIN flow."user" u on u.id = e.user_id
            inner JOIN flow.user_position up on up.user_id = u.id and up.primary_flag is true
                                                        and up.start_date < now()
                                                        and (up.end_date is null or up.end_date > now())
            inner JOIN flow.position pos on pos.id = up.position_id and pos.company_id = 3
            LEFT JOIN flow."user" s on s.id = e.submitted_by_id
            LEFT JOIN brs.gl_code g on g.id = e.gl_code_id
            LEFT JOIN flow."user" a on a.id = e.approved_by_id
            LEFT JOIN flow."user" p on p.id = e.paid_by_id
            LEFT JOIN brs.expense_budget eb on eb.id = e.expense_budget_id
            LEFT JOIN flow."user" ebu on ebu.id = eb.user_id
            LEFT JOIN brs.budget_type bt on bt.id = eb.budget_type_id
            LEFT JOIN brs.reimbursement_request rr on rr.id = e.reimbursement_request_id
          WHERE e.paid_date is not null
              and e.archived is not true
            and e.paid_date BETWEEN :startDate and :endDate
            AND e.rejected_date is null
    """;

  //language=PostgreSQL
  public final static String insertExpense = """
    INSERT INTO brs.expense(expense_budget_id, expense_date, submitted_by_id, gl_code_id,
                    notes, reimbursement_request_id, user_id, expense_amount, skip_approval)
    values(:expenseBudgetId, :expenseDate, :submittedById, :glCodeId,
            :notes, :reimbursementRequestId, :userId, :expenseAmount, :skipApproval);
    """;

  //language=PostgreSQL
  public final static String updateDefaultExpense = """
    UPDATE brs.expense
    SET expense_budget_id = :expenseBudgetId,
        expense_date = :expenseDate,
        submitted_by_id = :submittedById,
        gl_code_id = :glCodeId,
        user_id = :userId,
        expense_amount = :expenseAmount,
        modified_by_id = :updatedByUserId,
        date_modified = now(),
        date_submitted = now()
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String updateExpense = """
    UPDATE brs.expense
    SET expense_budget_id = :expenseBudgetId,
        expense_date = :expenseDate,
        gl_code_id = :glCodeId,
        notes = :notes,
        expense_amount = :expenseAmount,
        modified_by_id = :updatedByUserId,
        paid_date = :paidDate,
        paid_by_id = :paidById,
        date_modified = now(),
        date_submitted = now(),
        submitted_by_id = :submittedById
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String addDefaultLineItem = """
    INSERT INTO brs.expense(expense_date, reimbursement_request_id,
                    user_id, expense_amount, expense_budget_id)
    values(:expenseDate, :reimbursementRequestId,
            :userId, :expenseAmount, :expenseBudgetId);
    """;

  //language=PostgreSQL
  public final static String payExpense = """
    UPDATE brs.expense
    SET paid_date = now() + interval '2 day',
      paid_by_id = :paidById,
      date_modified = now(),
      modified_by_id = :paidById
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String approveExpense = """
    UPDATE brs.expense
      SET approval_date = now(),
          approved_by_id = :approvedById,
          date_modified = now(),
          modified_by_id = :approvedById,
          submitted_by_id = :reviewedById,
          date_submitted = coalesce(:dateReviewed, now())
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String rejectExpense = """
    UPDATE brs.expense
      SET rejected_date = now(),
          rejected_by_id = :rejectedById,
          date_modified = now(),
          modified_by_id = :rejectedById
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String rejectAllExpensesForRequest = """
    UPDATE brs.expense
      SET rejected_date = now(),
          rejected_by_id = :rejectedById,
          date_modified = now(),
          modified_by_id = :rejectedById
    WHERE reimbursement_request_id = :requestId;
    """;

  //language=PostgreSQL
  public final static String updateLineItemsToNewBudgetId = """
    UPDATE brs.expense
      SET expense_budget_id = :newBudgetId, date_modified = now()
    WHERE expense_budget_id = :oldBudgetId;
    """;

  //language=PostgreSQL
  public final static String getRequestId = """
    SELECT reimbursement_request_id
      FROM brs.expense
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String getUnpaidExpensesForRequest = """
    select e.*
    from brs.expense e
    where e.reimbursement_request_id = :requestId
          and e.archived is not true
          and paid_date is null
          and rejected_date is null
          and skip_approval is not true
    """;

  //language=PostgreSQL
  public final static String deleteExpense = """
    UPDATE brs.expense
        SET archived = TRUE, date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String rejectExpensesWhenRequestIsRejected = """
    UPDATE brs.expense
        SET rejected_date = now(), date_modified = now()
    where reimbursement_request_id = :id
    """;
}
