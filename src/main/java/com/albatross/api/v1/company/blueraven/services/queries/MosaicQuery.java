package com.albatross.api.v1.company.blueraven.services.queries;

public class MosaicQuery {
  //language=PostgreSQL
  public final static String getProjectIdFromMosaicApplicationId = """
     select plh.project_id
      from brs.proposal_log_history plh
      where plh.mosaic_application_id = :mosaicApplicationId::text
    """;
}
