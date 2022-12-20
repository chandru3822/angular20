package com.albatross.api.v1.flow.queries;

public class CountryQuery {

  //language=PostgreSQL
  public final static String getAll = """
    select c.id,
       c.country,
       c.abbreviation
    from flow.country c
    order by c.country
    """;

  //language=PostgreSQL
  public final static String getAllForCompany = """
    select cc.id,
       cc.company_id,
       cc.archived,
       cc.country_id,
       c.country,
       c.abbreviation
    from flow.company_country cc
        inner join flow.country c on c.id = cc.country_id
    where cc.archived is not true
      and cc.company_id = :companyId
    order by c.country
    """;

}
