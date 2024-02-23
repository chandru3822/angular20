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
    inner join flow.project p on p.id = plh.project_id
    where p.id = :projectId
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
           plh.fullname,
           plh.storage_size_kwh,
           plh.system_size,
           plh.inverter_custom_getting,
           plh.panel,
           plh.panel_wattage,
           plh.storage_brand,
           p.street1 as projectStreet1,
           p.street2 as projectStreet2,
           p.city as projectCity,
           s.abbreviation as projectState,
           p.postal_code as projectZipCode
    from brs.proposal_log_history plh
         left join flow.project p on plh.project_id = p.id
         left outer join flow.company_state cs on p.company_state_id = cs.id
         left outer join flow.state s ON s.id = cs.state_id
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
  public final static String getFinancialOption = """
      select *
      from brs.get_goodleap_financial_option(:loanType::varchar, :loanTerm::varchar, :interestRate::varchar, :proposalLogHistoryId::bigint);
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
    SET credit_last_checked_by = :creditLastCheckedBy,
        date_modified = now()
    WHERE project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String getSunpowerProducts = """
    SELECT
        MAX(financialProductId) AS financialProductId,
        MAX(inverterId) AS inverterId,
        MAX(panelId) AS panelId,
        MAX(storageId) AS storageId
    FROM (
             SELECT CASE WHEN product_name ILIKE :financialName THEN sunpower_id END AS financialProductId,
                    NULL AS inverterId,
                    NULL AS panelId,
                    NULL AS storageId
             FROM brs.sunpower_product sp
             WHERE product_name ILIKE :financialName

             UNION ALL

             SELECT NULL AS financialProductId,
                    CASE WHEN product_name ILIKE :inverterName THEN sunpower_id END AS inverterId,
                    NULL AS panelId,
                    NULL AS storageId
             FROM brs.sunpower_product sp
             WHERE product_name ILIKE :inverterName

             UNION ALL

             SELECT NULL AS financialProductId,
                    NULL AS inverterId,
                    CASE WHEN product_name ILIKE :panelName THEN sunpower_id END AS panelId,
                    NULL AS storageId
             FROM brs.sunpower_product sp
             WHERE product_name ILIKE :panelName

             UNION ALL

             SELECT NULL AS financialProductId,
                    NULL AS inverterId,
                    NULL AS panelId,
                    CASE WHEN product_name ILIKE :batteryName THEN sunpower_id END AS storageId
             FROM brs.sunpower_product sp
             WHERE product_name ILIKE :batteryName
         ) AS subquery;
    """;

  //language=PostgreSQL
  public final static String getSrec = """
    select
      plh.id,
      plh.proposal_nbr as proposal_number,
      plh.project_id,
      plh.il_srec_disclosure_form_id,
      pd.contact_name,
      pd.contact_email,
      coalesce(pd.contact_phone, pd.contact_mobile_phone) as contact_phone,
      pd.project_name,
      pd.project_state_abbreviation,
      pd.utility_company_name,
      plh.loan_type,
      pd.project_street1,
      pd.project_city,
      pd.project_postal_code,
      pd.system_size,
      plh.system_size_ac,
      plh.year_1_kwh_output as year_one_kwh_output,
      plh.loan_amount,
      plh.optional_down_payment,
      plh.required_down_payment,
      plh.all_rebates->>'Illinois SREC' as srec_value,
      plh.total_cost
    from brs.proposal_log_history plh
    inner join brs.project_details pd on pd.project_id = plh.project_id
    where plh.project_id = :projectId and
          plh.proposal_nbr = :proposalNumber
        
  """;

  //language=PostgreSQL
  public final static String setDisclosureId = """
    update brs.proposal_log_history plh
    set il_srec_disclosure_form_id = :formId
    where plh.project_id = :projectId and
          plh.proposal_nbr = :proposalNumber
  """;
}
