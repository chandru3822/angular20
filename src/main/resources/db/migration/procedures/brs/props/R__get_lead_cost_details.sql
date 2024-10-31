drop function if exists brs.get_lead_cost_details(p_version_id bigint,p_postal_code text);
CREATE OR REPLACE FUNCTION brs.get_lead_cost_details(p_version_id bigint,p_postal_code text)
	returns table(round_robin_name text,
	              digital_lead_cost numeric,
	              setter_lead_cost numeric) AS
$BODY$
declare
  v_rr_id bigint;
BEGIN

  select pc.round_robin_id
    into v_rr_id
	from flow.postal_code pc
	where pc.postal_code = p_postal_code;

	return query
		select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 977)') ->> 'value')::text  as round_robin_name,
			(jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 975)') ->> 'value')::numeric as digital_lead_cost,
			(jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 976)') ->> 'value')::numeric  as sett_lead_cost
		from brs.get_proposal_version_value(p_version_id, array [(977, null, v_rr_id, null)::ProposalFieldFilter], 'PROPOSAL_LEAD_COST_ADDERS');

END
$BODY$
	LANGUAGE plpgsql VOLATILE
	                 COST 100;
