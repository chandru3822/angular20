drop function if exists brs.get_proposal_zone_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_zone_adders(p_version_id bigint)
  returns table
          (
            adder_value   numeric,
            postal_codes bigint[]
          )
AS
$BODY$
declare
BEGIN
  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric                                          as adder_value,
           ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 122)') -> 'value')))::bigint[] as postal_codes
    from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_ZONE_ADDERS');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
