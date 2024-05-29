drop function if exists brs.get_proposal_rebates(p_version_id bigint);
CREATE OR REPLACE FUNCTION brs.get_proposal_rebates(p_version_id bigint)
  returns table
          (
            rebate_id                         bigint,
            rebate_type_id                    bigint,
            rebate_amount                     numeric,
            unit_type_id                      bigint,
            first_year_cap_on_rebate          bigint,
            max_amount_captured_first_year    numeric,
            rebate_cap_amount                 numeric,
            rebate_cap_percent_of_total       numeric,
            utility_company_id                bigint,
            state_id                          bigint,
            rebate_applied_at                 bigint,
            minimum_tsrf_for_qualification    bigint,
            srec_less_10                      numeric,
            srec_between_10_25                numeric,
            srec_greater_25                   numeric,
            srec_realization                  numeric,
            odoe_battery_rebate_amount        numeric,
            odoe_battery_rebate_cap_amount    numeric,
            odoe_battery_rebate_percent_total numeric,
            odoe_system_size_cutoff           numeric,
            rebate text,
            selectable_by_user boolean,
            applicable_storage_types bigint[]
          )
AS
$BODY$
declare
BEGIN
  return query
      select
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 93)') ->> 'intValue')::bigint as rebate_id,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 96)') ->> 'intValue')::bigint as rebate_type_id,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 98)') ->> 'value')::numeric as rebate_amount,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 97)') ->> 'intValue')::bigint as unit_type_id,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 99)') ->> 'intValue')::bigint as first_year_cap_on_rebate,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 100)') ->> 'value')::numeric as max_amount_captured_first_year,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 101)') ->> 'value')::numeric as rebate_cap_amount,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 133)') ->> 'value')::numeric as rebate_cap_percent_of_total,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 85)') ->> 'intValue')::bigint as utility_company_id,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 86)') ->> 'intValue')::bigint as state_id,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 357)') ->> 'intValue')::bigint as rebate_applied_at,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 399)') ->> 'value')::bigint as minimum_tsrf_for_qualification,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 369)') ->> 'value')::numeric as srec_less_10,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 370)') ->> 'value')::numeric as srec_between_10_25,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 371)') ->> 'value')::numeric as srec_greater_25,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 372)') ->> 'value')::numeric as srec_realization,

        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 382)') ->> 'value')::numeric as odoe_battery_rebate_amount,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 383)') ->> 'value')::numeric as odoe_battery_rebate_cap_amount,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 384)') ->> 'value')::numeric as odoe_battery_rebate_percent_total,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 385)') ->> 'value')::numeric as odoe_system_size_cutoff,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 93)') ->> 'value')::text as rebate,
        (jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 414)') ->> 'value')::boolean as selectable_by_user,
        ARRAY(SELECT jsonb_array_elements_text((jsonb_path_query(get_proposal_version_value, '$.fields[*] ? (@.fieldId == 494)') -> 'intArrayValue')))::bigint[] as applicable_storage_types
      from brs.get_proposal_version_value(p_version_id, array [(null, null, null, null)::ProposalFieldFilter],
                                          'PROPOSAL_REBATE');
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
