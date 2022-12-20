package com.albatross.api.v1.flow.queries;

public class CompanyQuery {

  //language=PostgreSQL
  public final static String getAll = """
      select id,
        company_name
      from flow.company
      where archived is not true
      order by parent_company_id nulls first, company_name
    """;

  //language=PostgreSQL
  public final static String getById = """
      select id,
        company_name,
        default_password,
        minute_increment
      from flow.company
      where id = :id
    """;

  //language=PostgreSQL
  public final static String getCompaniesAssignedToUser = """
      with t1 as (
        select c1.id
        from (
               select min(level) as level
               from flow.company c
                      inner join flow.user_company uc on uc.company_id = c.id
               where user_id = :userId
                 and uc.archived is not true
                 and c.archived is not true
             ) as foo
               inner join flow.company c1 on c1.level = foo.level and c1.archived is false
               inner join flow.user_company uc1 on uc1.company_id = c1.id and uc1.user_id = :userId
        where uc1.archived is not true
          and c1.archived is not true
      ), companies as (
        select t2.id, parent_company_id, level, company_name
        from t1
               join lateral flow.company_hierarchy_filter_down(t1.id) as t2 on true
        order by parent_company_id, company_name
      )
      select c.id, c.company_name, comp.default_password
      from companies c
             inner join flow.company comp on comp.id = c.id
             inner join flow.user_status_type ust on ust.company_id = c.id
             inner join flow.company_user_status cus on cus.user_status_type_id = ust.id
      where cus.user_id = :userId
        and ust.has_access is true
      order by c.level, c.parent_company_id, c.company_name
    """;

  //language=PostgreSQL
  public final static String getCompaniesAvailableForUser = """
      with t1 as (
        select c1.id
        from (
               select min(level) as level
               from flow.company c
                      inner join flow.user_company uc on uc.company_id = c.id
               where user_id = :userId
                 and uc.archived is not true
                 and c.archived is not true
             ) as foo
               inner join flow.company c1 on c1.level = foo.level and c1.archived is false
               inner join flow.user_company uc1 on uc1.company_id = c1.id and uc1.user_id = :userId
        where uc1.archived is not true
          and c1.archived is not true
      )
      select t2.id, parent_company_id, company_name
      from t1
       join lateral flow.company_hierarchy_filter_down(t1.id) as t2 on true
      order by parent_company_id, company_name
    """;

  //language=PostgreSQL
  public final static String updateCompany = """
      update flow.company
        set company_name = :companyName,
            default_password = :defaultPassword,
            minute_increment = :minuteIncrement,
            modified_by_id = :modifiedById,
            date_modified = now()
      where id = :id
    """;

  //language=PostgreSQL
  public final static String getConfigurationValues = """
    select *
    from flow.company_configuration_value
    where archived is false
    and readonly is false
    order by name
    """;

  //language=PostgreSQL
  public final static String updateConfigurationValue = """
    update flow.company_configuration_value
      set value = trim(:value),
          modified_by_id = :modifiedById,
          date_modified = now()
    where id = :id
    """;

}
