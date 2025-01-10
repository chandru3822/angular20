drop function if exists brs.custom_change_project_cfv(p_project_id bigint, p_user_id bigint, p_cfga bigint, p_value_to_save text, p_ignore_if_null boolean);
create or replace function brs.custom_change_project_cfv(p_project_id bigint, p_user_id bigint, p_cfga bigint, p_value_to_save text, p_ignore_if_null boolean DEFAULT false) returns boolean
    language plpgsql
as
$$
declare
    v_field_saved boolean;
    v_existing_id bigint;
    v_data_type_id bigint;
    v_request_is_valid boolean;
    v_existing_value text;
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
        --get the existing value while here too so we can use it later if needed
        select cfv.id,
               coalesce(text_value,
                        boolean_value::text,
                        date_value::text,
                        timestamp_value::text,
                        numeric_value::text,
                        int_value::text,
                        int_array_value::text)
        into v_existing_id, v_existing_value
        from flow.project_custom_field_value cfv
        where cfv.project_id = p_project_id
          and cfv.custom_field_group_assignment_id = p_cfga;

        select cdt.data_type_id into v_data_type_id
        from flow.custom_field_group_assignment cfga
                 inner join flow.custom_field cf on cfga.custom_field_id = cf.id
                 inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where cfga.id = p_cfga;


        if (v_existing_id is null and p_ignore_if_null is not true) then
            -- 1,date =>  do nothing
            -- 2,timestamp => do nothing
            -- 3,boolean => do nothing
            -- 4,numeric => save numeric value
            -- 5,text => save text value
            -- 6,bigint => save int value
            -- 7,bigint array => save value to array (still needs brackets in input)
            -- 8,system => do nothing
            -- 9,System List => do nothing
            if v_data_type_id = 1 then
                return false;
            elsif v_data_type_id = 2 then
                return false;
            elsif v_data_type_id = 3 then
                return false;
            elsif v_data_type_id = 4 then
                insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_project_id, p_cfga, null, null, null, null,p_value_to_save::numeric(10,2), null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 5 or v_data_type_id = 13 then
                insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_project_id, p_cfga, null, null, null, p_value_to_save::text, null,null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 6 then
                insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_project_id, p_cfga, null, null, null, null, null, p_value_to_save::bigint, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 7 then
                insert into flow.project_custom_field_value(project_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_project_id, p_cfga, null, null, null, null, null, null, p_value_to_save::bigint[], p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 8 or v_data_type_id = 9 then
                return false;
            end if;
        elseif v_existing_id is not null then -- If a value already exists
        -- 1,date =>  adds number of days to date
        -- 2,timestamp => add number of days to timestamp (can include decimals)
        -- 3,boolean => do nothing
        -- 4,numeric => add value to numeric value
        -- 5,text => aggregate value to existing text value
        -- 6,bigint => add int value to existing int value
        -- 7,bigint array => if value is not already included, add new value to int_array. Else do nothing -- Must be saved as array value in square brackets
        -- 8,system => do nothing
        -- 9,System List => do nothing
            if p_ignore_if_null is not true or (v_existing_value is not null and v_existing_value != '') then
                if v_data_type_id = 1 then
                    update flow.project_custom_field_value
                    set date_value = (v_existing_value::timestamp + (p_value_to_save::int * INTERVAL '1 day')),
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 2 then
                    update flow.project_custom_field_value
                    set timestamp_value = (v_existing_value::timestamp + (p_value_to_save::numeric * INTERVAL '1 day')),
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 3 then
                    return false;
                elsif v_data_type_id = 4 then
                    update flow.project_custom_field_value
                    set numeric_value = (v_existing_value::numeric(10,2) + p_value_to_save::numeric(10,2)),
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 5 or v_data_type_id = 13 then
                    update flow.project_custom_field_value
                    set text_value = v_existing_value::text || p_value_to_save::text,
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 6 then
                    update flow.project_custom_field_value
                    set int_value = (v_existing_value::bigint + p_value_to_save::bigint),
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 7 then
                    update flow.project_custom_field_value
                        set int_array_value = array(
                            select unnest(v_existing_value::bigint[])
                            union
                            select unnest(p_value_to_save::bigint[])
                        ),
                        modified_by_id = p_user_id,
                        date_modified = now()
                    where id = v_existing_id;
                elsif v_data_type_id = 8 or v_data_type_id = 9 then
                    return false;
                end if;
            end if;
        else
            return false;
        end if;
        --     not sure why we are returning anything
        v_field_saved = true;
        return v_field_saved;
    else
        return false;
    end if;

END
$$;


