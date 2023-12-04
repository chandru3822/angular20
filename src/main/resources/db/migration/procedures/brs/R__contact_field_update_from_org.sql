drop function if exists brs.contact_field_update_from_org(p_contact_id bigint, p_cfga_id bigint,
                                                           p_user_id bigint,
                                                           p_override_existing boolean);
CREATE OR REPLACE FUNCTION brs.contact_field_update_from_org(p_contact_id bigint, p_cfga_id bigint,
                                                              p_user_id bigint,
                                                              p_override_existing boolean default false)
    returns boolean AS
$BODY$
declare
    v_user_primary_org_id  integer;
    v_cfga_custom_field_id integer;
    v_org_cfga_id          integer;
    v_value_to_save text;
BEGIN


        --if no value was sent in then try to find a matching value on the users primary org with the same cf id. and use that
        --get users primary org
        select up.org_id
        into v_user_primary_org_id
        from flow.user_position up
        where up.user_id = p_user_id
          and up.archived is false
          and up.primary_flag is true;

        --get the custom field id of the cfga being saved to
        select cfga.custom_field_id
        into v_cfga_custom_field_id
        from flow.custom_field_group_assignment cfga
        where cfga.id = p_cfga_id;

        --get the cfga id of the field on the org with the same custom field id
        select cfga.id
        into v_org_cfga_id
        from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                 inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
        where cfga.custom_field_id = v_cfga_custom_field_id
          and cot.object_type_id = 5
          and cfga.archived is false
          and cfg.archived is false;

        --get the value from the field on the org
        select coalesce(text_value,
                        boolean_value::text,
                        date_value::text,
                        timestamp_value::text,
                        numeric_value::text,
                        int_value::text,
                        int_array_value::text)
        into v_value_to_save
        from flow.organization_custom_field_value cfv
        where cfv.org_id = v_user_primary_org_id
          and cfv.custom_field_group_assignment_id = v_org_cfga_id;

        if(v_value_to_save is not null and p_cfga_id is not null) then
            perform flow.set_contact_cfv(p_contact_id, p_user_id,
                                         p_cfga_id, v_value_to_save::text,
                                         p_override_existing);
        end if;
    -- why?
    return true;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
