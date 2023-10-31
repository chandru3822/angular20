drop function if exists brs.get_proposal_deposits(p_version_id bigint,p_state_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_deposits(p_version_id bigint,p_state_id bigint)
  returns table
          (
            deposit_amount numeric,
            states text
          )
AS
$BODY$
declare
BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 410)') ->> 'value')::numeric,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 341)') ->> 'intArrayValue') as states
      from brs.get_proposal_version_value(p_version_id, array [(341, null, null, p_state_id)::ProposalFieldFilter],
                                          'PROPOSAL_DEPOSITS');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
