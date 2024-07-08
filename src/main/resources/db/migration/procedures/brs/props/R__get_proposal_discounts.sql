drop function if exists brs.get_proposal_discounts(p_version_id bigint,p_utility_id bigint,p_qualifies_for_swr boolean);
CREATE OR REPLACE FUNCTION brs.get_proposal_discounts(p_version_id bigint,p_utility_id bigint,p_qualifies_for_swr boolean)
  returns table
          (
            kwh_rate_discount numeric,
            maximum_funding_amount_discount numeric,
            minimum_funding_amount_discount numeric,
            redline_funding_amount_discount numeric,
            virtual_sales_price_amount_discount numeric,
            qualifies_for_swr boolean
          )
AS
$BODY$
declare
BEGIN
  return query
      select
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 497)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 498)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 499)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 500)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 501)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 502)') ->> 'value')::boolean
      from brs.get_proposal_version_value(p_version_id, array [(85, null, p_utility_id, null)::ProposalFieldFilter,
        (502, p_qualifies_for_swr, null, null)::ProposalFieldFilter],
                                          'PROPOSAL_DISCOUNTS');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
