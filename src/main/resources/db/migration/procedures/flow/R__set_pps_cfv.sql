CREATE OR REPLACE FUNCTION flow.set_pps_cfv(p_project_id integer, p_cfga integer, p_value_to_save text)
    returns boolean AS
$BODY$
declare
    v_field_saved boolean;
    v_existing_id int;
    v_project_process_step_id int;
    v_data_type_id int;
    v_request_is_valid boolean;
BEGIN

    --check that the project company id and the cfga company id are the same in case the user screwed it up
    select ( select cp.company_id
             from flow.project p
                      inner join flow.company_process cp on cp.id = p.company_process_id
             where p.id = p_project_id) = (select cot.company_id
                                     from flow.custom_field_group_assignment cfga
                                              inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                                              inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
                                     where cfga.id = p_cfga) into v_request_is_valid;

    if v_request_is_valid is true then
        select cfv.id into v_existing_id
        from flow.project_process_step_custom_field_value cfv
                 inner join flow.project_process_step pps on cfv.project_process_step_id = pps.id
        where pps.project_id = p_project_id
          and cfv.custom_field_group_assignment_id = p_cfga
          and pps.main is true;

        select pps.id, cdt.data_type_id into v_project_process_step_id, v_data_type_id
        from flow.project_process_step pps
                 inner join flow.custom_field_group cfg on cfg.process_step_id = pps.process_step_id
                 inner join flow.custom_field_group_assignment cfga on cfga.custom_field_group_id = cfg.id
                 inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                 inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where project_id = p_project_id
          and cfga.id = p_cfga
          and pps.main is true;

        if(v_existing_id is null) then
    -- 1,date
    -- 2,timestamp
    -- 3,boolean
    -- 4,numeric
    -- 5,text
    -- 6,integer
    -- 7,integer array
    -- 8,system
    -- 9,System List
            if v_data_type_id = 1 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, p_value_to_save::date, null, null, null, null, null, null, 2350555);
            elsif v_data_type_id = 2 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, p_value_to_save::timestamp, null, null, null, null, null, 2350555);
            elsif v_data_type_id = 3 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, p_value_to_save::boolean, null, null, null, null, 2350555);
            elsif v_data_type_id = 4 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, p_value_to_save::numeric(10,2), null, null, null, 2350555);
            elsif v_data_type_id = 5 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null, null, p_value_to_save::boolean, null, 2350555);
            elsif v_data_type_id = 6 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null, null, p_value_to_save::int, null, 2350555);
            elsif v_data_type_id = 7 then
                insert into flow.project_process_step_custom_field_value(project_process_step_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id)
                values (v_project_process_step_id, p_cfga, null, null, null, null, null, null, p_value_to_save::int[], 2350555);
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
                set int_value = p_value_to_save::int
                where id = v_existing_id;
            elsif v_data_type_id = 7 then
                update flow.project_process_step_custom_field_value
                set int_array_value = p_value_to_save::int[]
                where id = v_existing_id;
            end if;
        end if;
    --     not sure why we are returning anything
        v_field_saved = true;
        return v_field_saved;
    else
        return false;
    end if;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
