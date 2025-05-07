drop function if exists brs.get_proposal_small_system_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_small_system_adders(p_version_id bigint)
    returns table(
      small_system_size_adder numeric,
      upper_value numeric,
      lower_value numeric,
      small_system_size_unit_type_id bigint
      ) AS
$BODY$
declare
BEGIN
  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as small_system_size_adder,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 132)') ->> 'value')::numeric  as upper_value,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 997)') ->> 'value')::numeric  as lower_value,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as small_system_size_unit_type_id
    from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_SMALL_SYSTEM_ADDERS');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
