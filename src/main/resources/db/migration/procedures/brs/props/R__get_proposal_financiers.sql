drop function if exists brs.get_proposal_financiers(p_version_id bigint,p_financier_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_financiers(p_version_id bigint,p_financier_id bigint)
  returns table
          (
            non_solar_cap   numeric,
            non_solar_threshold_for_additional_fee numeric,
            additional_fee_for_exceeding_non_solar_threshold numeric,
            maximum_dollar_per_watt_for_solar numeric
          )
AS
$BODY$
declare
BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 106)') ->> 'value')::numeric as non_solar_cap,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 103)') ->> 'value')::numeric  non_solar_threshold_for_additional_fee,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 107)') ->> 'value')::numeric  additional_fee_for_exceeding_non_solar_threshold,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 105)') ->> 'value')::numeric  maximum_dollar_per_watt_for_solar
      from brs.get_proposal_version_value(p_version_id, array [(102, null, p_financier_id, null)::ProposalFieldFilter],
                                          'PROPOSAL_FINANCIERS');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
