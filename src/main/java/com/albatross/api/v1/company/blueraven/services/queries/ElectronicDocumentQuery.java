package com.albatross.api.v1.company.blueraven.services.queries;

public class ElectronicDocumentQuery {

  //language=PostgreSQL
  public final static String getAhjQueryStr = """
    select s.abbreviation || ' - ' || ah.name
        from brs.project_details pd
        inner join flow.project p on p.id = pd.project_id
        inner join brs.feat_db_ahj ah on ah.id = pd.ahj
        left outer join flow.company_state cs on cs.id = p.company_state_id
        left outer join flow.state s on s.id = cs.state_id
    where pd.project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String getUtilityQueryStr = """
    select s.abbreviation || ' - ' || au.name
        from brs.project_details pd
        inner join flow.project p on p.id = pd.project_id
        inner join brs.feat_db_utility au on au.id = pd.utility_company
        left outer join flow.company_state cs on cs.id = p.company_state_id
        left outer join flow.state s on s.id = cs.state_id
    where pd.project_id = :projectId
    """;

  //language=PostgreSQL
  public final static String getStateQueryStr = """
    select s.abbreviation
        from brs.project_details pd
        inner join flow.project p on p.id = pd.project_id
        left outer join flow.company_state cs on cs.id = p.company_state_id
        left outer join flow.state s on s.id = cs.state_id
    where pd.project_id = :projectId
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
  public final static String getProjectsDetails = """
    SELECT p.id, p.project_name, p.street1, p.street2, p.city,
           s.state, s.abbreviation, p.postal_code, c.first_name,
           c.last_name, c.email, c.phone, pd.system_size, pd.total_system_price, pd.referral_promotion_amount,
           pd.total_cash_down_payment, pd.installation_agreement_signed_date,
           pd.year_1_kwh_output, pd.estimated_itc,
           (case when pd.primary_financier_name = 'Cash' then least(1000, 0.10 * (pd.total_system_price - pd.referral_promotion_amount))
                else least(pd.total_cash_down_payment, 1000, 0.10 * (pd.total_system_price - pd.referral_promotion_amount))
                end) as cash_down_payment,
            (case when pd.primary_financier_name = 'Cash' then (pd.total_system_price - pd.referral_promotion_amount) / 2
                else pd.total_cash_down_payment
                end) as progress_payment
    FROM flow.project p INNER JOIN brs.project_details pd on p.id = pd.project_id
                        INNER JOIN flow.company_state cs on p.company_state_id = cs.id
                        INNER JOIN flow.state s on cs.state_id = s.id
                        INNER JOIN flow.contact c on p.contact_id = c.id
    where p.id = :projectId
    """;
}
