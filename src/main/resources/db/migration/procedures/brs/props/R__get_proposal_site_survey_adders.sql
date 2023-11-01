drop function if exists brs.get_proposal_site_survey_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_site_survey_adders(p_version_id bigint)
    returns table(adder_name text,val bigint,site_survey_duration integer,applied_by_default boolean,can_be_completed_by_surveyor text,states jsonb) AS
$BODY$
declare
BEGIN
  return query
  select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 340)') ->> 'value')            as adder_name,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 340)') ->> 'intValue')::bigint as val,
         coalesce((select jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 339)') ->> 'value')::integer,
                  0)                                                                        as site_survey_duration,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 329)') ->> 'value')::boolean            as applied_by_default,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 338)') ->> 'value')            as can_be_completed_by_surveyor,
         (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 341)') ->> 'intArrayValue')::jsonb           as states
  from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                      'PROPOSAL_SITE_SURVEY');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
