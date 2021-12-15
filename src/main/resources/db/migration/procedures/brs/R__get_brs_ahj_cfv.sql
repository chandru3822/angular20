-- DROP FUNCTION IF EXISTS brs.get_brs_ahj_cfv(integer, integer, character varying);
CREATE OR REPLACE FUNCTION brs.get_brs_ahj_cfv(p_project_id INTEGER, p_brs_ahj_table character varying, p_brs_ahj_cf_id INTEGER, p_expected_value character varying)

RETURNS boolean
    LANGUAGE plpgsql
    AS $function$

-- select * from brs.get_brs_ahj_cfv(62778, 'Design', 26, 'No')
BEGIN

    case when lower(trim(p_brs_ahj_table)) = 'design' then
        -- gets the selected value for the ahj custom field
        return (select coalesce( ( select lov.name = p_expected_value
            from brs.ahj a
                 inner join brs.ahj_design ad on ad.ahj_id = a.id
                 inner join brs.ahj_design_custom_field_value cfv on cfv.ahj_design_id = ad.id
                 inner join brs.custom_field_group_assignment bcfga on bcfga.id = cfv.custom_field_group_assignment_id
                 inner join brs.custom_field bcf on bcf.id = bcfga.custom_field_id
                 inner join brs.list_of_value lov on lov.id = cfv.int_value
        where a.id = (select int_value
                      from flow.project_custom_field_value pcfv
                               inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                               inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                      where cf.id = (select cf.id
                                     from flow.custom_field cf
                                     where cf.parent_custom_field_id = 10124
                                       and cf.company_id = (
                                         select cp.company_id
                                         from flow.project p
                                                  inner join flow.company_process cp on p.company_process_id = cp.id
                                         where p.id = p_project_id
                                     )) -- this is the id of the ahj custom field in flow
                        and pcfv.project_id = p_project_id ) -- this is the project id
          and bcf.id = p_brs_ahj_cf_id ), false) as result);  -- this is the brs.custom_field.id for whichever field you want

    when lower(trim(p_brs_ahj_table)) = 'permit' then
            -- gets the selected value for the ahj custom field
            return (select coalesce( ( select lov.name = p_expected_value
                                       from brs.ahj a
                                                inner join brs.ahj_permit ap on ap.ahj_id = a.id
                                                inner join brs.ahj_permit_custom_field_value cfv on cfv.ahj_permit_id = ap.id
                                                inner join brs.custom_field_group_assignment bcfga on bcfga.id = cfv.custom_field_group_assignment_id
                                                inner join brs.custom_field bcf on bcf.id = bcfga.custom_field_id
                                                inner join brs.list_of_value lov on lov.id = cfv.int_value
                                       where a.id = (select int_value
                                                     from flow.project_custom_field_value pcfv
                                                              inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                                                              inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                     where cf.id = (select cf.id
                                                                    from flow.custom_field cf
                                                                    where cf.parent_custom_field_id = 10124
                                                                      and cf.company_id = (
                                                                        select cp.company_id
                                                                        from flow.project p
                                                                                 inner join flow.company_process cp on p.company_process_id = cp.id
                                                                        where p.id = p_project_id
                                                                    )) -- this is the id of the ahj custom field in flow
                                                       and pcfv.project_id = p_project_id ) -- this is the project id
                                         and bcf.id = p_brs_ahj_cf_id ), false) as result);  -- this is the brs.custom_field.id for whichever field you want
    when lower(trim(p_brs_ahj_table)) = 'inspection' then
            -- gets the selected value for the ahj custom field
            return (select coalesce( ( select lov.name = p_expected_value
                                       from brs.ahj a
                                                inner join brs.ahj_inspection ai on ai.ahj_id = a.id
                                                inner join brs.ahj_inspection_custom_field_value cfv on cfv.ahj_inspection_id = ai.id
                                                inner join brs.custom_field_group_assignment bcfga on bcfga.id = cfv.custom_field_group_assignment_id
                                                inner join brs.custom_field bcf on bcf.id = bcfga.custom_field_id
                                                inner join brs.list_of_value lov on lov.id = cfv.int_value
                                       where a.id = (select int_value
                                                     from flow.project_custom_field_value pcfv
                                                              inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                                                              inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                     where cf.id = (select cf.id
                                                                    from flow.custom_field cf
                                                                    where cf.parent_custom_field_id = 10124
                                                                      and cf.company_id = (
                                                                        select cp.company_id
                                                                        from flow.project p
                                                                                 inner join flow.company_process cp on p.company_process_id = cp.id
                                                                        where p.id = p_project_id
                                                                    )) -- this is the id of the ahj custom field in flow
                                                       and pcfv.project_id = p_project_id ) -- this is the project id
                                         and bcf.id = p_brs_ahj_cf_id ), false) as result);  -- this is the brs.custom_field.id for whichever field you want
        when lower(trim(p_brs_ahj_table)) = 'utility' then
            -- gets the selected value for the ahj UTILITY custom field
            return (select coalesce( ( select lov.name = p_expected_value
                                         from brs.ahj_utility au
                                         inner join brs.ahj_utility_custom_field_value cfv on cfv.ahj_utility_id = au.id
                                         inner join brs.custom_field_group_assignment bcfga on bcfga.id = cfv.custom_field_group_assignment_id
                                         inner join brs.custom_field bcf on bcf.id = bcfga.custom_field_id
                                         inner join brs.list_of_value lov on lov.id = cfv.int_value
                                         where au.id = (select int_value
                                                        from flow.project_custom_field_value pcfv
                                                                 inner join flow.custom_field_group_assignment cfga on cfga.id = pcfv.custom_field_group_assignment_id
                                                                 inner join flow.custom_field cf on cf.id = cfga.custom_field_id
                                                        where cf.id = (select cf.id
                                                                       from flow.custom_field cf
                                                                       where cf.parent_custom_field_id = 10137
                                                                         and cf.company_id = (
                                                                           select cp.company_id
                                                                           from flow.project p
                                                                                    inner join flow.company_process cp on p.company_process_id = cp.id
                                                                           where p.id = p_project_id
                                                                       )) -- this is the id of the ahj UTILITY custom field in flow
                                                          and pcfv.project_id = p_project_id ) -- this is the project id
                                             and bcf.id = p_brs_ahj_cf_id ), false) as result);  -- this is the brs.custom_field.id for whichever field you want
        else return null;
    end case;
END
$function$
