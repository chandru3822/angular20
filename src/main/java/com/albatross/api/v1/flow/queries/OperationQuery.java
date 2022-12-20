package com.albatross.api.v1.flow.queries;

public class OperationQuery {

  //language=PostgreSQL
  public final static String getTypes = """
        select *
        from flow.operation_type
        where archived is not true
    """;



}
