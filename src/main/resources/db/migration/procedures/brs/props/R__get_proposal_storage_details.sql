drop function if exists brs.get_proposal_storage_details(p_version_id bigint,p_storage_type_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_storage_details(p_version_id bigint,p_storage_type_id bigint)
    returns table(number_of_batteries numeric,
                  cash_price_storage numeric,
                  storage_capacity numeric) AS
$BODY$
declare
BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 155)') ->> 'value')::numeric as number_of_batteries,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 157)') ->> 'value')::numeric as cash_price_storage,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 151)') ->> 'value')::numeric as storage_capacity
      from brs.get_proposal_version_value(p_version_id, array [(160, null, p_storage_type_id, null)::ProposalFieldFilter],
                                          'PROPOSAL_STORAGE_DETAILS');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
