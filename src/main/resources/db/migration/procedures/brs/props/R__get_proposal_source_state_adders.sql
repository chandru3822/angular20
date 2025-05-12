drop function if exists brs.get_proposal_source_state_adders(p_version_id bigint, p_state_id bigint, p_lead_source bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_source_state_adders(p_version_id bigint, p_state_id bigint, p_lead_source bigint)
  returns table
          (
            source_state integer,
            lead_gen integer,
            adder_amount numeric,
            unit_type_id integer
          )
AS
$BODY$
declare
BEGIN
  return query
    select
      (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 86)') ->> 'intValue')::integer  as source_state,
      (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 121)') ->> 'intValue')::integer  as lead_gen,
      (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as adder_amount,
      (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::integer  as unit_type_id
    from brs.get_proposal_version_value(p_version_id, array [(86, null, p_state_id, null)::ProposalFieldFilter,
      (121, null, p_lead_source, null)::ProposalFieldFilter],
                                        'PROPOSAL_SOURCE_STATE_ADDERS');
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
