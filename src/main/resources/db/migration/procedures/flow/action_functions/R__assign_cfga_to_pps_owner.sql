drop function if exists flow.assign_cfga_to_pps_owner(bigint, bigint, bigint, bigint, boolean);

CREATE OR REPLACE FUNCTION flow.assign_cfga_to_pps_owner(p_project_id bigint, p_pps_id bigint, p_current_user_id bigint,
    p_cfga_input bigint, p_override_existing boolean) returns void
    LANGUAGE plpgsql
AS
$function$
declare
    v_data_type_id   bigint;
    v_system_list_id bigint;
    v_cfga_value text;
    v_user_position_id bigint;
    v_existing_pps_user_position_id bigint;
    v_available_positions integer[];

BEGIN

    select pps.user_position_id into v_existing_pps_user_position_id
    from flow.project_process_step pps
    where id = p_pps_id;

    -- Only run if override is true or
    if p_override_existing or v_existing_pps_user_position_id is null then
        select cdt.data_type_id, csl.system_list_id
        into v_data_type_id, v_system_list_id
        from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                 inner join flow.company_system_list csl on cf.company_system_list_id = csl.id
                 inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where cfga.id = p_cfga_input;

        select array_agg(pspop.position_id) into v_available_positions -- Is this right?
        from flow.project p
                 inner join flow.project_process_step pps on p.id = pps.project_id and pps.id = p_pps_id and pps.archived is false
                 inner join flow.process_step_process psp on psp.company_process_id = p.company_process_id and psp.process_step_id = pps.process_step_id and psp.archived is false
                 inner join flow.process_step_process_owning_position pspop on psp.id = pspop.process_step_process_id and pspop.archived is false
        where p.id = p_project_id
        ;

        -- Only allow if CFGA value is a system list field that can be assigned as the owner of that process step.
        if v_system_list_id in (1,2,4) and v_data_type_id = 9 then
            select * into v_cfga_value
            from flow.get_cfv_value_as_text(p_project_id::bigint, null::bigint, p_cfga_input);

            -- How intricate do I want to make this? If the user's position is still active do we want to assign it?
            if (v_system_list_id in (1,2)) then
                select up.id into v_user_position_id
                from flow.user_position up
                where up.id = v_cfga_value::bigint
                  and up.archived is not true
                  and (up.end_date is null or up.end_date::date >= now()::date)
                  and up.position_id = any(v_available_positions); -- Is this right?
            else
                select up.id into v_user_position_id
                from flow.user_position up
                where up.user_id = v_cfga_value::bigint
                  and up.archived is not true
                  and (up.end_date is null or up.end_date::date >= now()::date)
                  and up.position_id = any(v_available_positions)
                order by up.primary_flag desc,
                         up.start_date desc limit 1;
            end if;

            if v_user_position_id is not null then
                update flow.project_process_step
                set user_position_id = v_user_position_id,
                    date_modified = now(),
                    modified_by_id = p_current_user_id
                where id = p_pps_id;
            end if;
        end if;
    end if;
END
$function$


