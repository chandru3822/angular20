package com.albatross.api.v1.company.blueraven.services.queries;

public class MetroAreaQuery {

  //language=PostgreSQL
  public final static String getAllActive = """
    SELECT
         lov.id,
         lov.name as "metroArea",
         lov.archived
       FROM flow.list_of_value lov
       WHERE lov.parent_id = 172
         AND lov.archived IS FALSE
       ORDER BY lov.name
    """;
}
