drop function if exists brs.calculate_partner_fees(p_project_id bigint,
                                                   p_user_id bigint);
CREATE OR REPLACE FUNCTION brs.calculate_partner_fees(p_project_id bigint,
                                                      p_user_id bigint)
    returns void AS
$BODY$

    --todo: org =

declare
--other values we save for use later on
    v_module_installation_cost_field_value            numeric := 0;
    v_ac_rough_wire                                   numeric := 0;
    v_custom_distance_adder                           numeric := 0;
    v_3_story_roof                                    numeric := 0;
    v_steep_roof                                      numeric := 0;
    v_storage_install                                 numeric := 0;

--cfga ids determined by nested ifs
    v_cfga_to_use_for_module_installation_cost        bigint;
    v_cfga_to_use_for_storage_rough_pricing           bigint;
    v_cfga_to_use_for_storage_trim_pricing            bigint;

--calculated values
    v_module_installation_cost                        numeric := 0;
    v_roofer_labor_pricing_calculated_value           numeric := 0;
    v_storage_rough_pricing_calculated_value          numeric := 0;
    v_storage_trim_pricing_calculated_value           numeric := 0;
    v_calculated_nh_trim_labor_pricing_to_save        numeric := 0;

    --todo all these ids
--cfga_ids(setting)
    v_nh_permit_cost_actual_cfga_id                   bigint  := 28326;
    v_nh_trim_labor_pricing_cfga_id                   bigint  := 28213;
    v_nh_rough_labor_pricing_cfga_id                  bigint  := 28230;
    v_nh_roofer_labor_pricing_cfga_id                 bigint  := 28240;
    v_nh_storage_rough_pricing_cfga_id                bigint  := 28334;
    v_nh_storage_trim_pricing_cfga_id                 bigint  := 28338;

    --todo all these ids
--cfga_ids(getting)
    v_alliance_permitting_partner_cfga_id              bigint := 28890;
    v_alliance_ip_partner_cfga_id                      bigint := 28888;
    v_permitting_labor_only_org_cfga_id                bigint := 29451;
    v_installation_type_cfga_id                        bigint := 28056;
    v_number_of_panels_cfga_id                         bigint := 28218;
    v_alliance_partner_roofer_cfga_id                  bigint := 28892;
    v_nh_comp_install_org_cfga_id                      bigint := 29438;
    v_nh_flat_roof_install_org_cfga_id                 bigint := 29441;
    v_nh_mixed_install_org_cfga_id                     bigint := 29444;
    v_nh_one_roof_install_org_cfga_id                  bigint := 29445;
    v_nh_metal_standing_seam_install_org_cfga_id       bigint := 29443;
    v_nh_flat_roof_tilt_up_install_org_cfga_id         bigint := 29442;
    v_nh_other_install_org_cfga_id                     bigint := 29783;
    v_rough_wire_cfga_id                               bigint := 28026;
    v_ac_rough_wire_fee_org_cfga_id                    bigint := 29446;
    v_distance_adder_cfga_id                           bigint := 28027;
    v_nh_distance_fee_org_cfga_id                      bigint := 29448;
    v_system_adders_cfga_id                            bigint := 28328;
    v_3_story_roof_fee_org_cfga_id                     bigint := 29447;
    v_steep_roof_fee_org_cfga_id                       bigint := 29449;
    v_nh_storage_install_fee_cfga_id                   bigint := 29450;
    v_nh_roof_type_cfga_id                             bigint := 28055;
    v_nh_roofer_$_panel_org_cfga_id                    bigint := 29731;
    v_nh_alliance_storage_ip_cfga_id                   bigint := 28893;
    v_nh_storage_configuration_group_cfga_id           bigint := 29876;
    v_en_5_non_backup_rough_wire_fee_org_cfga_id       bigint := 29758;
    v_en_5_non_backup_storage_install_fee_org_cfga_id  bigint := 29756;
    v_en_10_non_backup_rough_wire_fee_org_cfga_id      bigint := 29746;
    v_en_10_non_backup_storage_install_fee_org_cfga_id bigint := 29744;
    v_en_10_backup_rough_wire_fee_org_cfga_id          bigint := 29740;
    v_en_10_backup_storage_install_fee_org_cfga_id     bigint := 29738;
    v_en_20_non_backup_rough_wire_fee_org_cfga_id      bigint := 29752;
    v_en_20_non_backup_storage_install_fee_org_cfga_id bigint := 29750;
    v_tesla_135_rough_wire_fee_org_cfga_id             bigint := 29764;
    v_tesla_135_backup_storage_install_fee_org_cfga_id bigint := 29762;
    v_tesla_27_rough_wire_fee_org_cfga_id              bigint := 29770;
    v_tesla_27_backup_storage_install_fee_org_cfga_id  bigint := 29768;
    v_tesla_405_rough_wire_fee_org_cfga_id             bigint := 29776;
    v_tesla_405_backup_storage_install_fee_org_cfga_id bigint := 29774;
    v_tesla_54_rough_wire_fee_org_cfga_id              bigint := 29782;
    v_tesla_54_backup_storage_install_fee_org_cfga_id  bigint := 29780;

    --todo all these data types
--cfga_values as their correct data types
    v_alliance_permitting_partner_value               bigint;
    v_alliance_ip_partner_value                       bigint;
    --keep v_permitting_labor_only_value as text since we just get it and then set it. we dont need to convert it
    v_permitting_labor_only_value                     text;
    v_installation_type_value                         bigint;
    v_alliance_partner_roofer_value                   bigint;
    v_number_of_panels_value                          bigint;
    v_rough_wire_value                                bigint;
    v_ac_rough_wire_fee_value                         numeric;
    v_distance_adder_value                            boolean;
    v_system_adders_value                             bigint[];
    v_nh_roof_type_value                              bigint;
    v_nh_roofer_$_panel_value                         numeric;
    v_nh_alliance_storage_ip_value                    bigint;
    v_nh_storage_configuration_group_value            bigint;

    --todo all these ids - lov ids dont exist in prod until after the migration - ask kaleb
--lov_ids
    --once kalebs script has run, come back and hard code these instead of selecting into them cuz that is slow af
    v_comp_install_lov_id                             bigint;
    v_over_tile_lov_id                                bigint;
    v_inset_install_lov_id                            bigint;
    v_flat_roof_lov_id                                bigint;
    v_mixed_install_lov_id                            bigint;
    v_one_roof_install_lov_id                         bigint;
    v_metal_standing_seam_install_lov_id              bigint;
    v_flat_roof_tilt_up_install_lov_id                bigint;
    v_other_install_lov_id                            bigint;
    v_sunpower_lov_id                                 bigint;
    v_3_story_roof_lov_id                             bigint;
    v_steep_roof_lov_id                               bigint;
    v_tile_lov_id                                     bigint;
    v_enphase_battery_system_5_kWh_non_backup_lov_id  bigint;
    v_enphase_battery_system_10_kWh_non_backup_lov_id bigint;
    v_enphase_battery_system_10_kWh_backup_lov_id     bigint;
    v_enphase_battery_system_20_kWh_non_backup_lov_id bigint;
    v_tesla_powerwall_3_battery_system_135_lov_id     bigint;
    v_tesla_powerwall_3_battery_system_27_lov_id      bigint;
    v_tesla_powerwall_3_battery_system_405_lov_id     bigint;
    v_tesla_powerwall_3_battery_system_54_lov_id      bigint;

BEGIN
    --once kalebs script has run, come back and hard code these instead of selecting into them cuz that is slow af
    select id into v_comp_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Comp Install'));
    select id into v_over_tile_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Over Tile'));
    select id into v_inset_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Inset Install'));
    select id into v_flat_roof_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Flat Roof Install'));
    select id into v_mixed_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Mixed Install'));
    select id into v_one_roof_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('OneRoof install'));
    select id into v_metal_standing_seam_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Metal Standing Seam Install'));
    select id into v_flat_roof_tilt_up_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Flat Roof Tilt Up Install'));
    select id into v_other_install_lov_id from flow.list_of_value where archived is false and parent_id = 25266 and trim(lower(name)) = trim(lower('Other'));
    select id into v_sunpower_lov_id from flow.list_of_value where archived is false and parent_id = 25238 and trim(lower(name)) = trim(lower('Sunpower'));
    select id into v_3_story_roof_lov_id from flow.list_of_value where archived is false and parent_id = 25442 and trim(lower(name)) = trim(lower('3+ Story Roof'));
    select id into v_steep_roof_lov_id from flow.list_of_value where archived is false and parent_id = 25442 and trim(lower(name)) = trim(lower('Custom Home Adder – Steep Roof'));
    select id into v_tile_lov_id from flow.list_of_value where archived is false and parent_id = 25264 and trim(lower(name)) = trim(lower('Tile'));
    select id into v_enphase_battery_system_5_kWh_non_backup_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Enphase Battery System 5 kWh Non-Backup'));
    select id into v_enphase_battery_system_10_kWh_non_backup_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Enphase Battery System 10 kWh Non-Backup'));
    select id into v_enphase_battery_system_10_kWh_backup_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Enphase Battery System 10 kWh Backup'));
    select id into v_enphase_battery_system_20_kWh_non_backup_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Enphase Battery System 20 kWh Non-Backup'));
    select id into v_tesla_powerwall_3_battery_system_135_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Tesla Powerwall 3 Battery System 13.5 kWh Backup'));
    select id into v_tesla_powerwall_3_battery_system_27_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Tesla Powerwall 3 Battery System 27 kWh Backup'));
    select id into v_tesla_powerwall_3_battery_system_405_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Tesla Powerwall 3 Battery System 40.5 kWh Backup'));
    select id into v_tesla_powerwall_3_battery_system_54_lov_id from flow.list_of_value where archived is false and parent_id = 25995 and trim(lower(name)) = trim(lower('Tesla Powerwall 3 Battery System 54 kWh Backup'));

    --populate all the commonly used values
    select flow.get_cfv_value_as_text(p_project_id, null, v_alliance_ip_partner_cfga_id)::bigint
    into v_alliance_ip_partner_value;
    select flow.get_cfv_value_as_text(p_project_id, null, v_alliance_partner_roofer_cfga_id)::bigint
    into v_alliance_partner_roofer_value;
    select flow.get_cfv_value_as_text(p_project_id, null, v_installation_type_cfga_id)::bigint
    into v_installation_type_value;
    select flow.get_cfv_value_as_text(p_project_id, null, v_number_of_panels_cfga_id)::bigint
    into v_number_of_panels_value;
    select flow.get_cfv_value_as_text(p_project_id, null, v_nh_storage_configuration_group_cfga_id)::bigint
    into v_nh_storage_configuration_group_value;

    raise notice 'v_installation_type_value = %', v_installation_type_value::text;
    raise notice 'v_number_of_panels_value = %', v_number_of_panels_value::text;

    if (v_alliance_ip_partner_value is not null) then
        select flow.get_cfv_value_as_text(p_project_id, null, v_alliance_permitting_partner_cfga_id)::bigint
        into v_alliance_permitting_partner_value;

        raise notice 'v_alliance_ip_partner_value = %', v_alliance_ip_partner_value::text;
        raise notice 'v_alliance_permitting_partner_value = %', v_alliance_permitting_partner_value::text;
        if (v_alliance_permitting_partner_value = v_alliance_ip_partner_value) then
            --v_permitting_labor_only_value stays as ::text since we get and save, we don't do anything with it
            select flow.get_cfv_value_as_text(p_project_id, null, v_permitting_labor_only_org_cfga_id, v_alliance_permitting_partner_value)
            into v_permitting_labor_only_value;

            raise notice 'v_permitting_labor_only_value = %', v_permitting_labor_only_value::text;
            perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint,
                                         v_nh_permit_cost_actual_cfga_id::bigint,
                                         v_permitting_labor_only_value::text, false);
        end if;

        if (v_installation_type_value = v_comp_install_lov_id
            OR v_installation_type_value = v_over_tile_lov_id
            OR (v_installation_type_value = v_inset_install_lov_id AND v_alliance_partner_roofer_value is null)) then
            v_cfga_to_use_for_module_installation_cost = v_nh_comp_install_org_cfga_id;
        elsif (v_installation_type_value = v_flat_roof_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_flat_roof_install_org_cfga_id;
        elsif (v_installation_type_value = v_mixed_install_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_mixed_install_org_cfga_id;
        elsif (v_installation_type_value = v_one_roof_install_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_one_roof_install_org_cfga_id;
        elsif (v_installation_type_value = v_metal_standing_seam_install_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_metal_standing_seam_install_org_cfga_id;
        elsif (v_installation_type_value = v_flat_roof_tilt_up_install_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_flat_roof_tilt_up_install_org_cfga_id;
        elsif (v_installation_type_value = v_other_install_lov_id) then
            v_cfga_to_use_for_module_installation_cost = v_nh_other_install_org_cfga_id;
        end if;

        if (v_cfga_to_use_for_module_installation_cost is not null) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_cfga_to_use_for_module_installation_cost, v_alliance_ip_partner_value)::numeric
            into v_module_installation_cost_field_value;

            v_module_installation_cost = v_module_installation_cost_field_value * v_number_of_panels_value;
        end if;

        select flow.get_cfv_value_as_text(p_project_id, null, v_rough_wire_cfga_id)::bigint into v_rough_wire_value;
        if (v_rough_wire_value = v_sunpower_lov_id) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_ac_rough_wire_fee_org_cfga_id, v_alliance_ip_partner_value)::numeric
            into v_ac_rough_wire_fee_value;

            v_ac_rough_wire = v_ac_rough_wire_fee_value;
        end if;

        select flow.get_cfv_value_as_text(p_project_id, null, v_distance_adder_cfga_id)::boolean
        into v_distance_adder_value;
        if (v_distance_adder_value is not null and v_distance_adder_value is true) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_nh_distance_fee_org_cfga_id, v_alliance_ip_partner_value)::numeric
            into v_custom_distance_adder;
        end if;

        select flow.get_cfv_value_as_text(p_project_id, null, v_system_adders_cfga_id)::bigint[]
        into v_system_adders_value;
        if (v_system_adders_value is not null and v_3_story_roof_lov_id = any (v_system_adders_value)) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_3_story_roof_fee_org_cfga_id)::numeric
            into v_3_story_roof;
        end if;

        if (v_system_adders_value is not null and v_steep_roof_lov_id = any (v_system_adders_value)) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_steep_roof_fee_org_cfga_id, v_alliance_ip_partner_value)::numeric into v_steep_roof;
        end if;

        if(v_nh_storage_configuration_group_value is not null) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_nh_storage_install_fee_cfga_id, v_alliance_ip_partner_value)::numeric into v_storage_install;
        end if;

        v_calculated_nh_trim_labor_pricing_to_save =
                    v_module_installation_cost + v_custom_distance_adder + v_3_story_roof + v_steep_roof + v_storage_install;
        raise notice 'v_module_installation_cost = %', v_module_installation_cost::text;
        raise notice 'v_custom_distance_adder = %', v_custom_distance_adder::text;
        raise notice 'v_3_story_roof = %', v_3_story_roof::text;
        raise notice 'v_steep_roof = %', v_steep_roof::text;
        raise notice 'v_calculated_nh_trim_labor_pricing_to_save = %', v_calculated_nh_trim_labor_pricing_to_save::text;
        perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint, v_nh_trim_labor_pricing_cfga_id::bigint,
                                     v_calculated_nh_trim_labor_pricing_to_save::text, false);
        raise notice 'v_ac_rough_wire = %', v_ac_rough_wire::text;
        perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint, v_nh_rough_labor_pricing_cfga_id::bigint,
                                     v_ac_rough_wire::text, false);

    end if;

    if (v_alliance_partner_roofer_value is not null) then
        select flow.get_cfv_value_as_text(p_project_id, null, v_nh_roof_type_cfga_id)::bigint into v_nh_roof_type_value;
        if (v_installation_type_value = v_inset_install_lov_id
            OR (v_installation_type_value = v_comp_install_lov_id AND v_nh_roof_type_value = v_tile_lov_id)) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_nh_roofer_$_panel_org_cfga_id, v_alliance_partner_roofer_value)::numeric
            into v_nh_roofer_$_panel_value;

            v_roofer_labor_pricing_calculated_value = v_number_of_panels_value * v_nh_roofer_$_panel_value;
        end if;
        raise notice 'v_number_of_panels_value = %', v_number_of_panels_value::text;
        raise notice 'v_nh_roofer_$_panel_value = %', v_nh_roofer_$_panel_value::text;
        raise notice 'v_roofer_labor_pricing_calculated_value = %', v_roofer_labor_pricing_calculated_value::text;
        perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint, v_nh_roofer_labor_pricing_cfga_id::bigint,
                                     v_roofer_labor_pricing_calculated_value::text, false);
    end if;

    select flow.get_cfv_value_as_text(p_project_id, null, v_nh_alliance_storage_ip_cfga_id)::bigint
    into v_nh_alliance_storage_ip_value;
    if (v_nh_alliance_storage_ip_value is not null) then

        if (v_nh_storage_configuration_group_value = v_enphase_battery_system_5_kWh_non_backup_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_en_5_non_backup_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_en_5_non_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_enphase_battery_system_10_kWh_non_backup_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_en_10_non_backup_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_en_10_non_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_enphase_battery_system_10_kWh_backup_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_en_10_backup_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_en_10_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_enphase_battery_system_20_kWh_non_backup_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_en_20_non_backup_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_en_20_non_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_tesla_powerwall_3_battery_system_135_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_tesla_135_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_tesla_135_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_tesla_powerwall_3_battery_system_27_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_tesla_27_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_tesla_27_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_tesla_powerwall_3_battery_system_405_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_tesla_405_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_tesla_405_backup_storage_install_fee_org_cfga_id;
        elsif (v_nh_storage_configuration_group_value = v_tesla_powerwall_3_battery_system_54_lov_id) then
            v_cfga_to_use_for_storage_rough_pricing = v_tesla_54_rough_wire_fee_org_cfga_id;
            v_cfga_to_use_for_storage_trim_pricing = v_tesla_54_backup_storage_install_fee_org_cfga_id;
        end if;

        if (v_cfga_to_use_for_storage_rough_pricing is not null) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_cfga_to_use_for_storage_rough_pricing, v_nh_alliance_storage_ip_value)::numeric
            into v_storage_rough_pricing_calculated_value;
        end if;
        if (v_cfga_to_use_for_storage_trim_pricing is not null) then
            select flow.get_cfv_value_as_text(p_project_id, null, v_cfga_to_use_for_storage_trim_pricing, v_nh_alliance_storage_ip_value)::numeric
            into v_storage_trim_pricing_calculated_value;
        end if;
        raise notice 'v_storage_rough_pricing_calculated_value = %', coalesce(v_permitting_labor_only_value, 0)::text;
        perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint,
                                     v_nh_storage_rough_pricing_cfga_id::bigint,
                                     coalesce(v_storage_rough_pricing_calculated_value, 0)::text, false);
        raise notice 'v_storage_trim_pricing_calculated_value = %', coalesce(v_permitting_labor_only_value,0)::text;
        perform flow.set_project_cfv(p_project_id::bigint, p_user_id::bigint, v_nh_storage_trim_pricing_cfga_id::bigint,
                                     coalesce(v_storage_trim_pricing_calculated_value, 0)::text, false);
    end if;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
