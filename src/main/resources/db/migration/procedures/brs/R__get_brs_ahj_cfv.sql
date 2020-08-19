-- DROP FUNCTION IF EXISTS brs.get_brs_ahj_cfv(integer, integer, character varying);
CREATE OR REPLACE FUNCTION brs.get_brs_ahj_cfv(p_project_id INTEGER, p_brs_ahj_cf_id INTEGER, p_expected_value character varying)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$

-- select * from brs.get_brs_ahj_cfv(62778, 26, 'No')
BEGIN

    -- gets the selected value for the ahj custom field
    return (select coalesce( ( select lov.name = p_expected_value
        from brs.ahj a
             inner join brs.ahj_design ad on ad.ahj_id = a.id
             inner join brs.custom_field_value cfv on cfv.source_id = ad.id
             inner join brs.custom_field_group_assignment bcfga on bcfga.id = cfv.custom_field_group_assignment_id
             inner join brs.custom_field bcf on bcf.id = bcfga.custom_field_id
             inner join brs.list_of_value lov on lov.id = cfv.int_value
    where a.id = (select int_value
                  from flow.project_custom_field_value pcfv
                           inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                           inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                  where cf.id = 392 -- this is the id of the ahj custom field in flow
                    and pcfv.project_id = p_project_id ) -- this is the project id
      and bcf.id = p_brs_ahj_cf_id ), false) as result);  -- this is the brs.custom_field.id for whichever field you want

END
$function$
