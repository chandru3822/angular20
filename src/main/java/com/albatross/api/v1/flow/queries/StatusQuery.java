package com.albatross.api.v1.flow.queries;

public class StatusQuery {

  //language=PostgreSQL
  public final static String getTypesForCompany = """
    select *
    from flow.status_type
    """;

  //language=PostgreSQL
  public final static String getType = """
      select id,
             status_type
      from flow.status_type st
      where id = :typeId
      order by st.status_type
    """;

  //language=PostgreSQL
  public final static String deleteType = """
        update flow.status_type
        set archived = true
        where id = :id
    """;

  //language=PostgreSQL
  public final static String updateType = """
      update flow.status_type
        set status_type = :statusType
      where id = :id
    """;

  //language=PostgreSQL
  public final static String insertType = """
      insert into flow.status_type(status_type)
        values (:statusType)
      returning id
    """;


}
