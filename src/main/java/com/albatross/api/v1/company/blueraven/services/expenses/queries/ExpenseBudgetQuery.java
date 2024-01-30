package com.albatross.api.v1.company.blueraven.services.expenses.queries;

public class ExpenseBudgetQuery {

  //language=PostgreSQL
  public final static String delete = """
    UPDATE brs.expense_budget
      SET archived = true,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String getAllBudgetType = """
    SELECT
        id,
        name,
        archived
    FROM brs.budget_type
    where archived is false
    order by name
    """;

  //language=PostgreSQL
  public final static String getOneBudgetType = """
    SELECT
        id,
        name,
        archived
    FROM brs.budget_type
    where id = :id
    """;

  //language=PostgreSQL
  public final static String insertBudgetType = """
    INSERT INTO brs.budget_type(name, created_by_id)
    values(:name, :userId)
    """;

  //language=PostgreSQL
  public final static String updateBudgetType = """
    UPDATE brs.budget_type
      SET name = :name,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String deleteBudgetType = """
    UPDATE brs.budget_type
      SET archived = true,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String getAllTemplates = """
    SELECT
      tem.id,
      tem.amount,
      tem.archived,
      tem.user_id,
      u.first_name || ' ' || u.last_name as user_full_name,
      (select id
           from brs.expense_budget eb
           where eb.user_id = tem.user_id
           and eb.archived is false
           and eb.start_date = date_trunc('month', current_date)::date) as current_month_budget_id
    FROM brs.budget_template tem
      INNER JOIN flow."user" u on u.id = tem.user_id
    WHERE tem.archived is not true
    ORDER BY user_full_name
    """;

  //language=PostgreSQL
  public final static String generateNextMonthBudgets = """
    select from brs.cron_generate_next_month_budgets();
  """;

  //language=PostgreSQL
  public final static String getOneTemplates = """
    SELECT
      tem.id,
      tem.amount,
      tem.archived,
      tem.user_id,
      u.first_name || ' ' || u.last_name as user_full_name,
      (select id
           from brs.expense_budget eb
           where eb.user_id = tem.user_id
           and eb.archived is false
           and eb.start_date = date_trunc('month', current_date)::date) as current_month_budget_id
    FROM brs.budget_template tem
      INNER JOIN flow."user" u on u.id = tem.user_id
    WHERE tem.id = :id
    """;

  //language=PostgreSQL
  public final static String insertBudgetTemplate = """
    INSERT INTO brs.budget_template(user_id, amount, created_by_id)
    values(:userId, :amount, :userId)
    """;

  //language=PostgreSQL
  public final static String updateBudgetTemplate = """
    UPDATE brs.budget_template
      SET amount = :amount,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String deleteBudgetTemplate = """
    UPDATE brs.budget_template
      SET archived = true,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String getAllInMonth = """
    SELECT
      eb.id,
      eb.start_date,
      eb.end_date,
      eb.notes,
      eb.archived,
      eb.amount,
      eb.user_id,
      u.first_name || ' ' || u.last_name as user_full_name,
      eb.date_created,
      eb.date_modified,
      eb.original_expense_budget_id
    FROM brs.expense_budget eb
           INNER JOIN flow."user" u on u.id = eb.user_id
    WHERE eb.archived is not true
      and eb.start_date = :startDate::date
    ORDER BY user_full_name, start_date
    """;

  //language=PostgreSQL
  public final static String getOne = """
    SELECT
      eb.id,
      eb.start_date,
      eb.end_date,
      eb.archived,
      eb.notes,
      eb.amount,
      eb.user_id,
      u.first_name || ' ' || u.last_name as user_full_name,
      eb.date_created,
      eb.date_modified
    FROM brs.expense_budget eb
           INNER JOIN flow."user" u on u.id = eb.user_id
    WHERE eb.id = :id
    """;

  //language=PostgreSQL
  public final static String updateExpenseBudget = """
    UPDATE brs.expense_budget
      SET amount = :amount,
          notes = :notes,
          date_modified = now(),
          modified_by_id = :userId
    WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String insertExpenseBudget = """
    INSERT INTO brs.expense_budget(start_date, end_date, amount, user_id, created_by_id, notes) VALUES
    (:startDate, :endDate, :amount, :userId, :createdById, :notes)
    """;

  //language=PostgreSQL
  public final static String getUsersWithBudget = """
    select DISTINCT u.id,
        u.first_name || ' ' || u.last_name as full_name
    from flow."user" u
           INNER JOIN brs.expense_budget eb on eb.user_id = u.id
           inner join flow.user_position up on u.id = up.user_id
    where u.archived is false
      and up.primary_flag is true
      and up.start_date < now()
      and (up.end_date is null or up.end_date > now())
      and eb.archived is not true
    ORDER BY full_name;
    """;

  //language=PostgreSQL
  public final static String getBudgetsForUser = """
    SELECT eb.id,
           eb.user_id,
           u.first_name || ' ' || u.last_name user_full_name,
           eb.amount,
           eb.start_date,
           concat(u.first_name, ' ', u.last_name, ' - ', to_char(eb.start_date, 'FMMonth YYYY'))  as full_budget_name,
           eb.end_date
      from brs.expense_budget eb
      inner join flow."user" u on eb.user_id = u.id
      where eb.user_id = :userId
      order by eb.start_date desc
    """;

  //language=PostgreSQL
  public final static String getAvailableUsers = """
    select distinct upv.user_id as id,
        upv.first_name || ' ' || upv.last_name as full_name
    from flow.user_positions_vw upv
    where position_id in (select unnest(string_to_array(value, ',')::bigint[])
                          from flow.company_configuration_value
                          where code = 'BUDGET_USER_POSITIONS')
      and upv.start_date < now()
      and (upv.end_date is null or upv.end_date > now())
    ORDER BY full_name
    """;

  //language=PostgreSQL
  public final static String getBudgetRemainingById = """
    SELECT eb.id,
           eb.amount,
           coalesce(sum(rr.amount),0) total_expenses,
           eb.amount - (coalesce(sum(rr.amount),0)) balance
           from brs.expense_budget eb
           LEFT JOIN brs.reimbursement_request rr on eb.id = rr.expense_budget_id and rr.rejected_date is null and rr.archived is not true
           where eb.id = :budgetId
           and eb.archived is not true
           GROUP BY eb.id,
           eb.amount
    """;

  //language=PostgreSQL
  public final static String checkIfExistsByUser = """
    select
      eb.id,
      eb.start_date,
      eb.end_date
    from brs.expense_budget eb
    WHERE eb.user_id = :userId
        AND (:startDate between eb.start_date AND eb.end_date
          OR :endDate between eb.start_date AND eb.end_date
          OR eb.start_date between :startDate AND :endDate
          OR eb.end_date between :startDate AND :endDate)
        AND eb.archived is not true
    """;

  //language=PostgreSQL
  public final static String getMonthlyBudgetReport = """
    select * from brs.get_monthly_expense_budget_report(:userId::bigint, :startDate::DATE, :endDate::DATE)
    """;
}
