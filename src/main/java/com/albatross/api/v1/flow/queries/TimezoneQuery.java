package com.albatross.api.v1.flow.queries;

public class TimezoneQuery {

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select ct.id,
           ct.timezone_id,
           t.timezone,
           ct.company_id,
           ct.archived
    from flow.company_timezone ct
        inner join flow.timezone t on t.id = ct.timezone_id
    where ct.company_id = :companyId
        and ct.archived is not true
    order by t.timezone
    """;



}
