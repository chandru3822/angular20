package com.albatross.api.v1.company.blueraven.services.queries;

public class InstallAgreementQuery {

  //language=PostgreSQL
  public final static String getFinancierFromProposalLog = """
    WITH p AS (
          SELECT loan_type
          FROM brs.proposal_log_history
          WHERE project_id = :projectId AND proposal_nbr = :proposalNbr
      )
      SELECT case when position(' ' IN p.loan_type) = 0 then p.loan_type else substring(p.loan_type, 1, position(' ' IN p.loan_type) - 1) end AS financier
      FROM p
    """;

  //language=PostgreSQL
  public final static String getUtilityFromProposalLog = """
    SELECT utility_name as utility_company
    FROM brs.proposal_log_history
    WHERE project_id = :projectId AND proposal_nbr = :proposalNbr
    """;

  //language=PostgreSQL
  public final static String getProjects = """
    SELECT *
    FROM brs.get_request_for_installation_agreements(:view_all, :showCancelled, :user_id, :companyId,
        :query, :limit, :offset)
    """;

  //language=PostgreSQL
  public final static String getProjectsCount = """
    SELECT *
    FROM brs.get_request_for_installation_agreements_count(:view_all, :showCancelled, :user_id, :companyId,
        :query)
    """;

  //language=PostgreSQL
  public final static String setAgreementSent = """
    UPDATE flow.project_process_step_custom_field_value
        SET timestamp_value = now(),
            date_modified = now()
    WHERE project_process_step_id = (select id from flow.project_process_step where
        project_id = :projectId and process_step_id = 4 and custom_field_group_assignment_id = 482)
    """;

  //language=PostgreSQL
  public final static String setRequestStatus = """
    INSERT INTO brs.installation_agreement_requests (
        project_id,
        proposal_nbr,
        send_installation_agreement,
        send_finance_docs,
        is_spanish,
        request_successful,
        user_id,
        created_date
    ) values (
        :projectId,
        :proposalNbr,
        :sendInstallationAgreement,
        :sendFinanceDocs,
        :isSpanish,
        :success,
        :userId,
        NOW())
    """;

  //language=PostgreSQL
  public final static String getProposalNumbers = """
    select proposal_nbr,
           loan_type
    from brs.proposal_log_history plh
    inner join flow.project p on p.id::text = plh.project_id::text
    where p.id = :projectId
    """;

  //language=PostgreSQL
  public final static String getLoanAmountFromLog = """
    SELECT loan_amount
    from brs.proposal_log_history
        where project_id::bigint = :projectId::bigint
        and proposal_nbr::bigint = :proposalNbr::bigint
    """;

  //language=PostgreSQL
  public final static String getProjectDetailsFromLog = """
    select plh.loan_amount,
           plh.loan_term,
           plh.interest_rate,
           u.first_name as salesRepresentativeFirstName,
           u.last_name as salesRepresentativeLastName,
           u.email as salesRepresentativeEmail,
           plh.project_id,
           plh.address,
           plh.city,
           plh.state,
           plh.zip,
           case when c.mobile is not null and c.mobile <> '' then c.mobile else c.phone end as phone,
           c.email,
           plh.fullname
    from brs.proposal_log_history plh
         left join flow.project p on plh.project_id = p.id
         left join flow.user_position up on p.user_position_id = up.id
         left join flow.user u on up.user_id = u.id
         left join flow.contact c on p.contact_id = c.id
    where project_id::bigint = :projectId::bigint and
          proposal_nbr::bigint = :proposalNbr::bigint
    """;

  //language=PostgreSQL
  public final static String getDealId = """
    SELECT deal_id
    from brs.project_details
    where project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String updateEmailAddress = """
    UPDATE flow.contact
    SET email = :emailAddress, date_modified = now()
    WHERE id = (select contact_id from flow.project where id = :projectId)
    """;

  //language=PostgreSQL
  public final static String getLoanType = """
    select plh.loan_type from brs.proposal_log_history plh
    WHERE project_id = :projectId and proposal_nbr = :proposalNbr;
    """;

  //language=PostgreSQL
  public final static String getSunlightHashId = """
    select plh.sunlight_hash_id from brs.proposal_log_history plh
      WHERE plh.project_id = :projectId and plh.proposal_nbr = :proposalNbr;
    """;

  //language=PostgreSQL
  public final static String setSunlightHashId = """
    UPDATE brs.proposal_log_history
    SET sunlight_hash_id = :sunlightHashId, date_modified = now()
    WHERE project_id = :projectId and proposal_nbr = :proposalNbr
    """;

  //language=PostgreSQL
  public final static String getSunpowerUrl = """
    select plh.sunpower_url from brs.proposal_log_history plh
    WHERE plh.project_id = :projectId and plh.proposal_nbr = :proposalNbr;
    """;

  //language=PostgreSQL
  public final static String getSunpowerUrlPerProject = """
    select plh.sunpower_url from brs.proposal_log_history plh
    WHERE plh.project_id = :projectId and plh.sunpower_url is not null
    limit 1;
    """;

  //language=PostgreSQL
  public final static String setSunpowerUrl = """
    UPDATE brs.proposal_log_history
    SET sunpower_url = :url, date_modified = now()
    WHERE project_id = :projectId and proposal_nbr = :proposalNbr
    """;

  //language=PostgreSQL
  public final static String getCreditLastCheckedBy = """
    select pd.credit_last_checked_by from brs.project_details pd
    WHERE pd.project_id = :projectId;
    """;

  //language=PostgreSQL
  public final static String setCreditLastCheckedBy = """
    UPDATE brs.project_details
    SET credit_last_checked_by = :creditLastCheckedBy
    WHERE project_id = :projectId
    """;
}
