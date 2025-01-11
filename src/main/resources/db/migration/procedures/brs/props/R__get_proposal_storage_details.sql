drop function if exists brs.get_proposal_storage_details(p_version_id bigint, p_storage_type_id bigint);
drop function if exists brs.get_proposal_storage_details(p_version_id bigint, p_storage_type_id bigint, p_financier_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_storage_details(p_version_id bigint, p_storage_type_id bigint, p_financier_id bigint)
  returns table
          (
            number_of_batteries            numeric,
            cash_price_storage             numeric,
            storage_capacity               numeric,
            storage_name                   text,
            storage_id                     bigint,
            storage_brand                  text,
            storage_brand_id               bigint,
            nominal_power                  numeric,
            battery_manufacturers_warranty bigint,
            battery_workmanship_warranty   bigint,
            grid_tied_battery   boolean
          )
AS
$BODY$
declare
BEGIN
  return query
    select (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 155)') ->>
            'value')::numeric                                                                                        as number_of_batteries,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 157)') ->>
            'value')::numeric                                                                                        as cash_price_storage,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 151)') ->>
            'value')::numeric                                                                                        as storage_capacity,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 160)') ->>
            'value')::text                                                                                           as storage_name,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 160)') ->>
            'intValue')::bigint                                                                                      as storage_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 412)') ->>
            'value')::text                                                                                           as storage_brand,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 412)') ->>
            'intValue')::bigint                                                                                      as storage_brand_id,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 152)') ->>
            'value')::numeric                                                                                        as nominal_power,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 441)') ->>
            'value')::bigint                                                                                         as battery_manufacturers_warranty,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 442)') ->>
            'value')::bigint                                                                                         as battery_workmanship_warranty,
           (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 979)') ->>
            'value')::boolean                                                                                         as grid_tied_battery
    from brs.get_proposal_version_value(p_version_id, array [(160, null, p_storage_type_id, null)::ProposalFieldFilter,
      (102, null, p_financier_id, null)::ProposalFieldFilter],
                                        'PROPOSAL_STORAGE_DETAILS');

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
