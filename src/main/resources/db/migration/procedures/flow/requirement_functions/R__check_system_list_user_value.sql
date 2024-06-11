drop function if exists flow.system_list_field_user_value_compare(p_project_id bigint, p_pps_id bigint, p_ppse_id bigint, p_cfga_id_1 bigint, p_cfga_id_2 bigint);
create or replace function flow.system_list_field_user_value_compare(p_project_id bigint, p_pps_id bigint, p_ppse_id bigint, p_cfga_id_1 bigint, p_cfga_id_2 bigint)
    returns boolean as
$BODY$
declare
    v_cfga_1_value          text;
    v_cfga_2_value          text;
    v_cfga_1_company_id     bigint;
    v_cfga_2_company_id     bigint;
    v_cfga_1_system_list_id bigint;
    v_cfga_2_system_list_id bigint;
    v_user_id_1             text;
    v_user_id_2             text;

    --written by carlin, pseudo-not-checked by randa 6/11/24

    BEGIN
    --verify that both cfga ids come from the same company (which also ensures they are valid cfga ids)
    select cf.company_id, company_system_list_id
    into v_cfga_1_company_id,v_cfga_1_system_list_id
    from flow.custom_field_group_assignment cfga
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
    where cfga.id = p_cfga_id_1;
    select cf.company_id, company_system_list_id
    into v_cfga_2_company_id,v_cfga_2_system_list_id
    from flow.custom_field_group_assignment cfga
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
    where cfga.id = p_cfga_id_2;
    --only continue if both company ids are the same
    if (v_cfga_1_company_id = v_cfga_2_company_id and v_cfga_1_system_list_id in (1,2,4) and v_cfga_2_system_list_id in (1,2,4)) then
        select * into v_cfga_1_value
        from flow.get_cfv_value_as_text(p_project_id::bigint, p_ppse_id::bigint, p_cfga_id_1);

        if (v_cfga_1_system_list_id in (1,2)) then
            select up.user_id::text into v_user_id_1
            from flow.user_position up
            where up.id = v_cfga_1_value::bigint;
        else
            v_user_id_1 = v_cfga_1_value;
        end if;

        select * into v_cfga_2_value
        from flow.get_cfv_value_as_text(p_project_id::bigint, p_ppse_id::bigint, p_cfga_id_2);

        if (v_cfga_2_system_list_id in (1,2)) then
            select up.user_id::text into v_user_id_2
            from flow.user_position up
            where up.id = v_cfga_2_value::bigint;
        else
            v_user_id_2 = v_cfga_2_value;
        end if;

    end if;
    return (v_user_id_1 = v_user_id_2 or (v_user_id_1 is null and v_user_id_2 is null));
END
$BODY$
    language plpgsql VOLATILE COST 100;