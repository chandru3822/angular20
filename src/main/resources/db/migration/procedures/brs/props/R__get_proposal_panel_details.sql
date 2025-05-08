drop function if exists brs.get_proposal_panel_details(p_version_id bigint,p_panel_brand_id bigint,p_panel_watts bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_panel_details(p_version_id bigint,p_panel_brand_id bigint,p_panel_watts bigint)
    returns table(panel_degradation_factor numeric,
                  panel_unit_type_id bigint,
                  panel_adder_amount numeric,
                  panel_states bigint[],
                  primary_financier bigint) AS
$BODY$
declare
BEGIN
  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 136)') ->> 'value')::numeric  as panel_degradation_factor,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric  as adder_amount,
           ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 341)') -> 'intArrayValue')))::bigint[]   as states,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 102)') ->> 'intValue')::bigint  as primary_financier
    from brs.get_proposal_version_value(p_version_id, array [(138, null, p_panel_brand_id, null)::ProposalFieldFilter,
      (139, p_panel_watts, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_PANEL_DETAIL');




END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
