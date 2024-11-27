package com.albatross.api.v1.company.blueraven.services.queries;

public class PandaDocQuery {

  //language=PostgreSQL
  public final static String getProjectDetails = """
    SELECT
      plh.project_id,
      plh.id as proposal_log_history_id,
      plh.financial_option,
      plh.proposal_nbr,
      s.state,
      (select lov.name
       from flow.list_of_value lov
       where lov.id = pd.primary_financier) as financier,
       (
         select lov.name
         from flow.project_custom_field_value pcfv
         inner join flow.list_of_value lov on lov.id = pcfv.int_value
         where pcfv.project_id = p.id and
               pcfv.custom_field_group_assignment_id = 17280
       ) as "leadSource",
      (select first_name from flow.user where id = pd.closer_user_id)            AS closer_first_name,
      (select last_name from flow.user where id = pd.closer_user_id)             AS closer_last_name,
      (select email from flow.user where id = pd.closer_user_id) AS closer_email,
      (select search_phone from flow.user where id = pd.closer_user_id) AS closer_phone,
      c.first_name            AS customer_first_name,
      c.last_name             AS customer_last_name,
      c.email                 AS customer_email,
      s.abbreviation as mailing_state,
      case when c.phone is not null and c.phone <> '' then c.phone else c.mobile end as phone,
      p.city,
      p.street1 as mailing_street1,
      p.street2  as mailing_street2,
      p.postal_code,
      case when cy.country is null then 'United States' else cy.country end,
      p.project_name,
      cp.company_id,
      (plh.optional_down_payment::numeric + plh.required_down_payment::numeric) as optional_down_payment,
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
      (plh.net_system_cost::numeric) as system_cost,
      plh.storage_brand,
      case when pr.process_name = 'z Battery Only' then true else false end as is_battery_only,
      plh.inverter_custom_getting,
      plh.panel_model,
      plh.storage_name,
      plh.dealer_fee,
      plh.financed_pv_price_per_watt_to_customer,
      plh.first_year_avoided_bill,
      plh.monthly_solar_costs,
      plh.eighteen_plus_payment_itc_only,
      plh.battery_manufacturers_warranty,
      p.object_category_id
    FROM flow.project p
           JOIN brs.project_details pd on p.id = pd.project_id
           JOIN brs.proposal_log_history plh on p.id = plh.project_id
           JOIN flow.contact c ON c.id = p.contact_id
           join flow.company_state cs on cs.id = p.company_state_id
           join flow.state s on s.id = cs.state_id
           left join flow.company_country cc on cc.id = p.company_country_id
           left JOIN flow.country cy on cy.id = cc.country_id
           JOIN flow.company_process cp on cp.id = p.company_process_id
           left JOIN flow.process pr on pr.id = cp.process_id
    WHERE p.id = :projectId and plh.proposal_nbr = :proposalNbr
    """;

  //language=PostgreSQL
  public final static String getNewHomesProjectDetails = """
    SELECT
      concat(c.first_name, ' ', c.last_name) as "builder",
      pcfv1.text_value AS "communityName",
      pcfv2.text_value AS "lotNumber",
      pcfv3.text_value AS "planType"
    FROM flow.project p
           LEFT JOIN flow.contact c ON c.id = (select contact_id from flow.project where id = p.parent_id)
           LEFT JOIN flow.project_custom_field_value pcfv1 ON pcfv1.project_id = :projectId AND pcfv1.custom_field_group_assignment_id = 29879
           LEFT JOIN flow.project_custom_field_value pcfv2 ON pcfv2.project_id = :projectId AND pcfv2.custom_field_group_assignment_id = 28127
           LEFT JOIN flow.project_custom_field_value pcfv3 ON pcfv3.project_id = :projectId AND pcfv3.custom_field_group_assignment_id = 29874
    WHERE p.id = :projectId
    """;

  //language=PostgreSQL
  public final static String hasDolphinPortalAccess = """
    select :currentUserId in
      (select unnest(string_to_array(value, ',')::bigint[])
         from flow.company_configuration_value
      where code = 'DOLPHIN_USER_IDS')
    """;
}
