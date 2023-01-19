package com.albatross.api.v1.flow.queries;

public class SystemListQuery {

  //language=PostgreSQL
  public final static String getSystemListsForCompany = """
      select sl.id,
             sl.system_list,
             sl.archived,
             csl.company_id,
             csl.id as company_system_list_id,
             sl.system_list_type_id,
             sl.has_sub_options
      from flow.company_system_list csl
      inner join flow.system_list sl on sl.id = csl.system_list_id
      where csl.company_id = :companyId
      order by sl.system_list
    """;

  //language=PostgreSQL
  public final static String getSystemListOptionsForCompany = """
select * from flow.get_system_list_options(:companyId::bigint, :systemListId::bigint, :subOptions::boolean, array[ :systemListOptionIds ]::bigint[], :intValue::bigint);
    """;

}
