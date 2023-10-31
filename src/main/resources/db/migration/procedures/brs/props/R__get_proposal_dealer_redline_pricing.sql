drop function if exists brs.get_proposal_dealer_redline_pricing(p_version_id bigint,p_state_id bigint,p_dealer bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_dealer_redline_pricing(p_version_id bigint,p_state_id bigint,p_dealer bigint)
    returns table(dealer_redline_price numeric) AS
$BODY$
declare
BEGIN
  return query
  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 380)') ->> 'value')::numeric
  from brs.get_proposal_version_value(p_version_id, array [(341, null, null, p_state_id)::ProposalFieldFilter,
                                                                                    (407, null, p_dealer, null)::ProposalFieldFilter],
                                      'PROPOSAL_DEALER_REDLINE_PRICING');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
