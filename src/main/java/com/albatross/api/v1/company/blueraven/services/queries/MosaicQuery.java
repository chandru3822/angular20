package com.albatross.api.v1.company.blueraven.services.queries;

public class MosaicQuery {
  //language=PostgreSQL
  public final static String getProjectIdFromMosaicApplicationId = """
     select plh.project_id
      from brs.proposal_log_history plh
      where plh.mosaic_application_id = :mosaicApplicationId::text
    """;

  //language=PostgreSQL
  public final static String setFinancialAgreementSigned = """
    UPDATE brs.proposal_log_history
    SET financial_agreement_signed = :dateValue, date_modified = now()
    WHERE project_id = :projectId and mosaic_application_id is not null
    """;

  //language=PostgreSQL
  public final static String setCountersigned = """
    UPDATE brs.proposal_log_history
    SET countersigned = :dateValue, date_modified = now()
    WHERE project_id = :projectId and mosaic_application_id is not null
    """;
}
