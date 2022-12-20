package com.albatross.api.v1.flow.queries;

public class AccessControlQuery {

  //language=PostgreSQL
  public final static String getAll = """
       select ac.id,
              ac.access_level,
              ac.access_code,
              ac.archived,
              ac.display_order
       from flow.access_control ac
       where ac.archived is not true
       order by ac.display_order
    """;


}
