package com.albatross.api.v1.company.blueraven.services.expenses.queries;

public class ReimbursementQuery {

  //language=PostgreSQL
  public final static String getPendingRequests = """
    SELECT rr.id,
       rr.amount,
       rr.date_created,
       rr.details,
       rr.notes,
       rr.attachment_id,
       rr.expense_date,
       rr.reimbursement_request_status_id,
       rr.expense_budget_id,
       eb.user_id as expense_budget_user_id,
       ebu.first_name || ' ' || ebu.last_name as expense_budget_user,
       bt.name as budget_type,
       rr.budget_type_id,
       rr.gl_code_id,
       rr.created_by_id,
       u.first_name || ' ' || u.last_name as created_by,
       p.position as position_name,
       coalesce((SELECT array_to_json(array_agg(row_to_json(expenses)))
                 FROM (
                        SELECT e.id,
                               e.date_created "dateCreated",
                               e.expense_amount "expenseAmount",
                               e.reimbursement_request_id as "reimbursementRequestId"
                        FROM brs.expense e
                        WHERE e.reimbursement_request_id = rr.id
                          AND e.rejected_date is null
                      ) AS expenses), '[]') AS expenses
    FROM brs.reimbursement_request rr
       INNER JOIN flow."user" u on u.id = rr.created_by_id
       inner JOIN flow.user_position up on up.user_id = u.id
                                   and up.archived is false
                                     and up.primary_flag is true
                      and up.start_date < now()
                      and (up.end_date is null or up.end_date > now())
       inner join flow.position p on p.id = up.position_id and p.company_id = 3
       LEFT JOIN brs.expense_budget eb on eb.id = rr.expense_budget_id
       LEFT JOIN flow."user" ebu on ebu.id = eb.user_id
       LEFT JOIN brs.budget_type bt on bt.id = rr.budget_type_id
    WHERE rr.reimbursement_request_status_id = 3
      and rr.archived is not true
    order by rr.date_created desc
    """;

  //language=PostgreSQL
  public final static String getRequestsForUserByStatus = """
    SELECT rr.id,
           rr.amount,
           rr.date_created,
           rr.details,
           rr.expense_date,
           rr.reimbursement_request_status_id,
           rr.notes,
           rr.expense_budget_id,
           eb.user_id as expense_budget_user_id,
           bt.name as budget_type,
           rr.created_by_id,
           u.first_name || ' ' || u.last_name as created_by
    FROM brs.reimbursement_request rr
      INNER JOIN flow."user" u on u.id = rr.created_by_id
      LEFT JOIN brs.expense_budget eb on eb.id = rr.expense_budget_id
      LEFT JOIN brs.budget_type bt on bt.id = rr.budget_type_id
    WHERE rr.reimbursement_request_status_id = :statusId
        and rr.expense_date::DATE BETWEEN :startDate::DATE AND :endDate::DATE
        and u.id = :userId
        and rr.archived is not true
    """;

  //language=PostgreSQL
  public final static String insert = """
    INSERT INTO brs.reimbursement_request(amount, details, attachment_id, expense_budget_id, created_by_id, expense_date, reimbursement_request_status_id, budget_type_id, gl_code_id)
    values(:amount, :details, :attachmentId, :expenseBudgetId, :createdById, :expenseDate, :statusId, :budgetTypeId, :glCodeId);
    """;

  //language=PostgreSQL
  public final static String update = """
    update brs.reimbursement_request
     set amount = :amount,
       details = :details,
       attachment_id = :attachmentId,
       expense_budget_id = :expenseBudgetId,
       gl_code_id = :glCodeId,
       budget_type_id = :budgetTypeId,
       modified_by_id = :createdById,
       expense_date = :expenseDate,
       reimbursement_request_status_id = :statusId
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String updateStatus = """
    UPDATE brs.reimbursement_request
    SET reimbursement_request_status_id = :reimbursementRequestStatusId,
        date_modified = now(),
        modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String saveReimbursementNote = """
    UPDATE brs.reimbursement_request
      SET notes = :notes
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String deleteRequest = """
    UPDATE brs.reimbursement_request
        SET archived = TRUE,
        date_modified = now()
    where id = :id
    """;

  //language=PostgreSQL
  public final static String deleteExpensesForRequest = """
    UPDATE brs.expense
        SET archived = TRUE,
            date_modified = now()
    where reimbursement_request_id = :id
    """;
}
