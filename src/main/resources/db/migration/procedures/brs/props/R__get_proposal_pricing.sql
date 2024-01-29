drop function if exists brs.get_proposal_pricing(p_version_id bigint,p_utility_company_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_pricing(p_version_id bigint,p_utility_company_id bigint)
    returns table(instant_use_assumption numeric,
                  net_metring_rate numeric,
                  production_factor_east_west numeric,
                  production_factor_south numeric,
                  maximum_funding_amount_per_watt numeric,
                  minimum_funding_amount_per_watt numeric,
                  current_estimated_cost_per_kwh numeric,
                  utility_cost_escalator numeric,
                  red_line_funding_amount numeric,
                  closer_gen_discount numeric,
                  virtual_sales_base_price numeric) AS
$BODY$
declare


BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 147)') ->> 'value')::numeric as instant_use_assumption,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 92)') ->> 'value')::numeric  as net_metring_rate,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 88)') ->> 'value')::numeric  as production_factor_east_west,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 89)') ->> 'value')::numeric  as production_factor_south,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 90)') ->> 'value')::numeric  as maximum_funding_amount_per_watt,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 91)') ->> 'value')::numeric  as minimum_funding_amount_per_watt,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 87)') ->> 'value')::numeric  as current_estimated_cost_per_kwh,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 94)') ->> 'value')::numeric  as utility_cost_escalator,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 380)') ->> 'value')::numeric as red_line_funding_amount,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 381)') ->> 'value')::numeric as closer_gen_discount,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 445)') ->> 'value')::numeric as virtual_sales_base_price
      from brs.get_proposal_version_value(p_version_id, array [(85, null, p_utility_company_id, null)::ProposalFieldFilter],
                                          'PROPOSAL_PRICING');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
