drop function if exists brs.get_proposal_equipment_adders(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_equipment_adders(p_version_id bigint)
    returns table(equipment_type_id bigint,
                  smart_thermostat_value numeric,
                  energy_efficiency_reduction_thermostat numeric,
                  unit_type_id_smart_thermostat numeric) AS
$BODY$
declare
BEGIN
  return query
      select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 117)') ->> 'intValue')::bigint   as equipment_type_id,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 119)') ->> 'value')::numeric   as smart_thermostat_value,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 145)') ->> 'value')::numeric   as energy_efficiency_reduction_thermostat,
             (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::numeric as unit_type_id_smart_thermostat
      from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                          'PROPOSAL_EQUIPMENT_ADDERS');


END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
