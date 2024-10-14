package com.albatross.api.v1.company.blueraven.services.queries;

public class EnfinQuery {
  //language=PostgreSQL
  public final static String getProjectIdFromEnfinApplicationId = """
     select plh.project_id
      from brs.proposal_log_history plh
      where plh.enfin_application_id = :enfinApplicationId::text
    """;
}
