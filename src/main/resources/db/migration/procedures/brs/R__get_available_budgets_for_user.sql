CREATE OR REPLACE FUNCTION brs.get_available_budgets_for_user(p_platform_user_id integer, p_expense_date date)
  RETURNS SETOF json
  LANGUAGE plpgsql
AS
$function$
declare
  v_position_ids   integer[];
  v_budget_user_id integer;

BEGIN

  -- get all active position ids for user
  select array(select distinct position_id
               into v_position_ids
               from flow.user_positions_vw u
               where user_id = p_platform_user_id
                 and u.archived is false
                 and u.start_date < now()
                 and (u.end_date is null or u.end_date > now()));

  --select blueraven.get_available_budgets_for_user(2354208, '2018-01-12')

  case
    when (p_platform_user_id = 2354046) then
      -- if the user is Austin Thompson then use Dane Nielson's user id, yep, that's right
      select 2353912 into v_budget_user_id;
    when (v_position_ids && '{3,6,10,227,237,238,226,219,73}') then
      -- if the user is a closer regional,setter regional, or recruiter use their own user id
      select p_platform_user_id into v_budget_user_id;
    when (v_position_ids && '{1,2}') then
      -- if the user is a closer, find the closer regional and use that user id
      with closers as (
        SELECT distinct org_id as region_id
        FROM flow.user_positions_vw u
        where u.user_id = p_platform_user_id
          and u.org_level_id = 10 -- 10 = level 5 = region for company_id = 3
          and u.position_id in (1, 2)
      )
      select user_id
      into v_budget_user_id
      from flow.user_positions_vw u
             INNER JOIN closers c on c.region_id = u.org_id
      WHERE position_id = 3
        and archived is false
        and u.start_date < now()
        and (u.end_date is null or u.end_date > now());
    when (v_position_ids && '{4,5}') then
      -- if the user is a setter, find the setter regional and use that user id
      with setters as (
        SELECT distinct org_id as region_id
        FROM flow.user_positions_vw u
        where u.user_id = p_platform_user_id
          and u.org_level_id = 10 -- 10 = level 5 = region for company_id = 3
          and u.position_id in (4, 5)
      )
      select user_id
      into v_budget_user_id
      from flow.user_positions_vw u
             INNER JOIN setters s on s.region_id = u.org_id
      WHERE position_id = 6
        and archived is false
        and u.start_date < now()
        and (u.end_date is null or u.end_date > now());
    else
      select null into v_budget_user_id;
    END case;
  RETURN QUERY
    select array_to_json(array_agg(row_to_json(sub_rows)))
    from (
           WITH single_row AS (SELECT eb.user_id,
                                      eb.budget_type_id,
                                      eb.original_expense_budget_id,
                                      max(eb.date_created) date_created
                               FROM brs.expense_budget eb
                               GROUP BY eb.user_id, eb.budget_type_id, eb.original_expense_budget_id)
           SELECT eb.id,
                  eb.date_created                                           "dateCreated",
                  eb.date_modified                                          "dateModified",
                  bt.name                                                as "budgetType",
                  eb.start_date                                             "startDate",
                  u.first_name || ' ' || u.last_name || ' - ' || bt.name as "fullBudgetName",
                  eb.end_date                                               "endDate",
                  eb.amount,
                  eb.user_id                                                "userId",
                  u.first_name || ' ' || u.last_name                     as "userFullName",
                  eb.original_expense_budget_id                             "originalExpenseBudgetId"
           FROM brs.expense_budget eb
                  INNER JOIN single_row sr on sr.user_id = eb.user_id and
                                              eb.original_expense_budget_id = sr.original_expense_budget_id and
                                              sr.date_created = eb.date_created
                  INNER JOIN brs.budget_type bt on bt.id = eb.budget_type_id
                  INNER JOIN flow."user" u on u.id = eb.user_id
           where bt.archived is false
             AND u.id = v_budget_user_id
             AND eb.start_date <= p_expense_date
             AND eb.end_date >= p_expense_date
           ORDER BY bt.name
         ) as sub_rows;

END
$function$
