drop function if exists flow.set_pps_cfv_migration(p_project_id bigint,p_project_process_step_id bigint, p_user_id bigint,p_cfga bigint, p_value_to_save text);
  CREATE OR REPLACE FUNCTION flow.set_pps_cfv_migration(p_project_id bigint,p_project_process_step_id bigint, p_user_id bigint,p_cfga bigint, p_value_to_save text)
    returns boolean AS
$BODY$
declare
    v_field_saved boolean;
    v_existing_id bigint;
    v_project_process_step_id bigint;
    v_data_type_id bigint;
BEGIN

        select cfv.id into v_existing_id
        from flow.project_process_step_custom_field_value cfv
                 inner join flow.project_process_step pps on cfv.project_process_step_id = pps.id
        where pps.id = p_project_process_step_id
          and cfv.custom_field_group_assignment_id = p_cfga;

        select pps.id, cdt.data_type_id into v_project_process_step_id, v_data_type_id
        from flow.project_process_step pps
                 inner join flow.custom_field_group cfg on cfg.process_step_id = pps.process_step_id
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
                 inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                 inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where pps.id = p_project_process_step_id
          and cfga.id = p_cfga;

        if(v_existing_id is null) then
    -- 1,date
    -- 2,timestamp
    -- 3,boolean
    -- 4,numeric
    -- 5,text
    -- 6,bigint
    -- 7,bigint array
    -- 8,system
    -- 9,System List
            if v_data_type_id = 1 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, p_value_to_save::date, null, null, null, null, null, null, p_user_id);
            elsif v_data_type_id = 2 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, p_value_to_save::timestamp, null, null, null, null, null, p_user_id);
            elsif v_data_type_id = 3 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, p_value_to_save::boolean, null, null, null, null, p_user_id);
            elsif v_data_type_id = 4 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null,p_value_to_save::numeric(10,2), null, null, p_user_id);
            elsif v_data_type_id = 5 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, p_value_to_save::text, null,null, null, p_user_id);
            elsif v_data_type_id = 6 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null, null, p_value_to_save::bigint, null, p_user_id);
            elsif v_data_type_id = 7 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null, null, null, p_value_to_save::bigint[], p_user_id);
            end if;
        else
            if v_data_type_id = 1 then
                update flow.project_process_step_custom_field_value
                    set date_value = p_value_to_save::date
                where id = v_existing_id;
            elsif v_data_type_id = 2 then
                update flow.project_process_step_custom_field_value
                set timestamp_value = p_value_to_save::timestamp
                where id = v_existing_id;
            elsif v_data_type_id = 3 then
                update flow.project_process_step_custom_field_value
                set boolean_value = p_value_to_save::boolean
                where id = v_existing_id;
            elsif v_data_type_id = 4 then
                update flow.project_process_step_custom_field_value
                set numeric_value = p_value_to_save::numeric(10,2)
                where id = v_existing_id;
            elsif v_data_type_id = 5 then
                update flow.project_process_step_custom_field_value
                set text_value = p_value_to_save::text
                where id = v_existing_id;
            elsif v_data_type_id = 6 then
                update flow.project_process_step_custom_field_value
                set int_value = p_value_to_save::bigint
                where id = v_existing_id;
            elsif v_data_type_id = 7 then
                update flow.project_process_step_custom_field_value
                set int_array_value = p_value_to_save::bigint[]
                where id = v_existing_id;
            end if;
        end if;
    --     not sure why we are returning anything
        v_field_saved = true;
        return v_field_saved;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
