drop function if exists brs.get_proposal_selected_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_selected_adders(p_version_id bigint)
  returns table
          (
            adders     bigint[],
            states     bigint[],
            fee_type   integer,
            amount     numeric,
            utility_id integer
          )
AS
$BODY$
declare
BEGIN
  return query
    select --998 prod for adders column
           ARRAY(SELECT jsonb_array_elements_text((
             jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 998)') ->
             'intArrayValue')))::bigint[]                                                                            as adders,
           ARRAY(SELECT jsonb_array_elements_text((
             jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 341)') ->
             'intArrayValue')))::bigint[]                                                                            as states,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->>
            'intValue')::integer                                                                                     as fee_type,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->>
            'value')::numeric                                                                                        as amount,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 85)') ->>
            'intValue')::integer                                                                                     as utility_id
    from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_SELECTED_ADDERS');
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
