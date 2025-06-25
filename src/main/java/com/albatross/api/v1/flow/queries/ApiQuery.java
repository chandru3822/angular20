package com.albatross.api.v1.flow.queries;

public class ApiQuery {

  //language=
  //language=PostgreSQL
  public final static String getApiConfig = """
    select list_of_value_id,value
    from flow.api_config
    """;

}
