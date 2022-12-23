package com.albatross.api.v1.company.blueraven.services.queries;

public class PandaDocQuery {

  //language=PostgreSQL
  public final static String getProjectDetails = """
    SELECT
      plh.project_id,
      plh.proposal_nbr,
      s.state,
      (select lov.name
       from flow.list_of_value lov
       where lov.id = pd.primary_financier) as financier,
      (select first_name from flow.user where id = pd.closer_user_id)            AS closer_first_name,
      (select last_name from flow.user where id = pd.closer_user_id)             AS closer_last_name,
      (select email from flow.user where id = pd.closer_user_id) AS closer_email,
      c.first_name            AS customer_first_name,
      c.last_name             AS customer_last_name,
      c.email                 AS customer_email,
      s.abbreviation as mailing_state,
      c.phone,
      p.city,
      p.street1 as mailing_street1,
      p.street2  as mailing_street2,
      p.postal_code,
      case when cy.country is null then 'United States' else cy.country end,
      p.project_name,
      cp.company_id,
      plh.optional_down_payment,
      round(plh.system_size::numeric/1000,2) as system_size,
      round(plh.optional_down_payment::numeric * 0.5, 2) as first_cash_payment_amount,
      pd.total_system_price,
      pd.utility_company,
      plh.interest_rate,
      plh.loan_term,
      plh.loan_type,
      plh.loan_amount,
      plh.total_cost,
      (plh.down_payment_above_line_incentive::numeric - plh.optional_down_payment::numeric) as solar_rebate,
      plh.itc,
      plh.state_tax_credit,
      (plh.loan_amount::numeric - plh.itc::numeric - plh.state_tax_credit::numeric) as system_cost
    FROM flow.project p
           JOIN brs.project_details pd on p.id = pd.project_id
           JOIN brs.proposal_log_history plh on p.id = plh.project_id
           JOIN flow.contact c ON c.id = p.contact_id
           join flow.company_state cs on cs.id = p.company_state_id
           join flow.state s on s.id = cs.state_id
           left join flow.company_country cc on cc.id = p.company_country_id
           left JOIN flow.country cy on cy.id = cc.country_id
           JOIN flow.company_process cp on cp.id = p.company_process_id
    WHERE p.id = :projectId and plh.proposal_nbr = :proposalNbr
    """;
}
