package com.albatross.api.v1.company.blueraven.services.queries;

public class EnfinQuery {
  //language=PostgreSQL
  public final static String getProjectIdFromEnfinApplicationId = """
     select plh.project_id
      from brs.proposal_log_history plh
      where plh.enfin_application_id = :enfinApplicationId::text
    """;

  //language=PostgreSQL
  public final static String getProjectIdFromEmail = """
     select pd.project_id
      from brs.project_details pd
      where pd.contact_email = :email
      limit 1
    """;

  //language=PostgreSQL
  public final static String setFinancialAgreementSigned = """
    UPDATE brs.proposal_log_history
    SET financial_agreement_signed = :dateValue, date_modified = now()
    WHERE project_id = :projectId and enfin_application_id is not null
    """;
}
