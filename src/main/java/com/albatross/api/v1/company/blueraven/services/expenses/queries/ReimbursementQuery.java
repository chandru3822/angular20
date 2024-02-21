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
       p.position as position_name
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
    INSERT INTO brs.reimbursement_request(amount, details, attachment_id, expense_budget_id, created_by_id,
          expense_date, reimbursement_request_status_id, budget_type_id, gl_code_id,
          approval_date, approved_by_id)
    values(:amount, :details, :attachmentId, :expenseBudgetId, :userId, :expenseDate, :statusId, :budgetTypeId, :glCodeId,
        case when :setApprovalFields::boolean is true then now() end, case when :setApprovalFields::boolean is true then :userId end);
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
       modified_by_id = :userId,
       date_modified = now(),
       expense_date = :expenseDate,
       reimbursement_request_status_id = :statusId,
       approved_by_id = case when approved_by_id is null and :setApprovalFields::boolean then :userId else approved_by_id end,
       approval_date = case when approval_date is null and :setApprovalFields::boolean then now() else approval_date end
    WHERE id = :id;
    """;

  //language=PostgreSQL
  public final static String updateStatus = """
    UPDATE brs.reimbursement_request
    SET reimbursement_request_status_id = :reimbursementRequestStatusId,
        date_modified = now(),
        rejected_date = case when :reimbursementRequestStatusId = 2 then now() else rejected_date end,
        rejected_by_id = case when :reimbursementRequestStatusId = 2 then :userId else rejected_by_id end,
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
        date_modified = now(),
        modified_by_id = :userId
    where id = :id
    """;

  //language=PostgreSQL
  public final static String getRequestList = """
    SELECT rr.id,
           rr.amount,
           rr.date_created,
           rr.details,
           rr.expense_date,
           rr.reimbursement_request_status_id,
           rr.notes,
           rr.paid_date,
           rr.paid_by_id,
           concat(pu.first_name, ' ', pu.last_name) as paid_by,
           rr.approved_by_id,
           rr.approval_date,
           concat(au.first_name, ' ', au.last_name) as approved_by,
           rr.expense_budget_id,
           eb.user_id as expense_budget_user_id,
           bt.name as budget_type,
           gl.code as gl_code,
           rr.gl_code_id,
           rr.budget_type_id,
           rr.created_by_id,
           eb.user_id as expense_budget_user_id,
           ebu.first_name || ' ' || ebu.last_name as expense_budget_user
    FROM brs.reimbursement_request rr
      LEFT JOIN flow."user" pu on pu.id = rr.paid_by_id
      LEFT JOIN flow."user" au on au.id = rr.approved_by_id
      LEFT JOIN brs.expense_budget eb on eb.id = rr.expense_budget_id
      left join flow.user ebu on ebu.id = eb.user_id
      LEFT JOIN brs.budget_type bt on bt.id = rr.budget_type_id
      LEFT JOIN brs.gl_code gl on gl.id = rr.gl_code_id
    WHERE
      case when :onlyUnpaid::boolean is true
        then rr.paid_date is null
        else rr.expense_date::DATE BETWEEN :startDate::DATE AND :endDate::DATE
      end
      and rr.reimbursement_request_status_id = 1
      and rr.archived is not true
    order by rr.expense_date desc, expense_budget_user desc
    """;

  //language=PostgreSQL
  public final static String markRequestPaid = """
    UPDATE brs.reimbursement_request
        SET paid_date = now(),
            paid_by_id = :userId,
            modified_by_id = :userId
    where id = :id
    """;
}
