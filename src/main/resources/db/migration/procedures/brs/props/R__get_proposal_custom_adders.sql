drop function if exists brs.get_proposal_custom_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_custom_adders(p_version_id bigint)
  returns table
          (
            pk text,
            proposal_adder_cfga integer,
            project_adder_cfga integer,
            adder_name text
          )
AS
$BODY$
declare
BEGIN
  return query
    select get_proposal_version_value->> 'pk'as pk,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 989)') ->> 'value')::integer  as proposal_adder_cfga,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 990)') ->> 'value')::integer  as project_adder_cfga,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 718)') ->> 'value')::text  as adder_name
    from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                        'PROPOSAL_CUSTOM_ADDERS');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
