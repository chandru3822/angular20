drop function if exists brs.get_lead_cost_details(p_version_id bigint,p_postal_code text);
CREATE OR REPLACE FUNCTION brs.get_lead_cost_details(p_version_id bigint,p_postal_code text)
	returns table(round_robin_name text,
                digital_lead_cost numeric,
                setter_lead_cost numeric,
                digital_lead_cost_cap numeric,
                sett_lead_cost_cap numeric,
                organic_lead_cost numeric,
                organic_lead_cost_cap numeric) AS
$BODY$
declare
  v_rr_id bigint;
BEGIN

  select pc.round_robin_id
    into v_rr_id
	from flow.postal_code pc
	where pc.postal_code = p_postal_code;

  if v_rr_id is not null then

  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 977)') ->> 'value')::text  as round_robin_name,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 975)') ->> 'value')::numeric as digital_lead_cost,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 976)') ->> 'value')::numeric  as sett_lead_cost,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 993)') ->> 'value')::numeric  as digital_lead_cost_cap,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 994)') ->> 'value')::numeric  as sett_lead_cost_cap,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 995)') ->> 'value')::numeric  as organic_lead_cost,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 996)') ->> 'value')::numeric  as organic_lead_cost_cap
    from brs.get_proposal_version_value(p_version_id, array [(977, null, v_rr_id, null)::ProposalFieldFilter], 'PROPOSAL_LEAD_COST_ADDERS');

  else
    return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 977)') ->> 'value')::text  as round_robin_name,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 975)') ->> 'value')::numeric as digital_lead_cost,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 976)') ->> 'value')::numeric  as sett_lead_cost,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 993)') ->> 'value')::numeric  as digital_lead_cost_cap,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 994)') ->> 'value')::numeric  as sett_lead_cost_cap,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 995)') ->> 'value')::numeric  as organic_lead_cost,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 996)') ->> 'value')::numeric  as organic_lead_cost_cap
      from brs.get_proposal_version_value(p_version_id, array [(977, null, 133, null)::ProposalFieldFilter], 'PROPOSAL_LEAD_COST_ADDERS');
  end if;

END
$BODY$
	LANGUAGE plpgsql VOLATILE
	                 COST 100;
