drop function if exists brs.get_proposal_misc_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_misc_adders(p_version_id bigint)
  returns table
          (
            unit_type_id  integer,
            adder_amount  numeric,
            default_value boolean,
            adder_id      bigint[]
          )
AS
$BODY$
declare
BEGIN
  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::integer as unit_type_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as adder_amount,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 329)') ->> 'value')::boolean   as default_value,
           (SELECT ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 126)') ->>
                                                           'intArrayValue')::jsonb)))::bigint[] as adder_id
    from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_MISC_ADDERS');

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
