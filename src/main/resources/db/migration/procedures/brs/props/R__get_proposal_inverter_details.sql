drop function if exists brs.get_proposal_inverter_details(p_version_id bigint,p_inverter_brand_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_inverter_details(p_version_id bigint,p_inverter_brand_id bigint)
    returns table(inverter_efficiency numeric,
                  inverter_unit_type_id bigint,
                  inverter_adder_amount numeric) AS
$BODY$
declare
BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 142)') ->> 'value')::numeric  as inverter_efficiency,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as adder_amount
      from brs.get_proposal_version_value(p_version_id, array [(131, null, p_inverter_brand_id, null)::ProposalFieldFilter],
                                          'PROPOSAL_INVERTER_DETAILS');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
