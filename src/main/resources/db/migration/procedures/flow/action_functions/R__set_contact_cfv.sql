drop function if exists flow.set_contact_cfv(p_contact_id bigint, p_user_id bigint,p_cfga bigint, p_value_to_save text, p_override_existing boolean);
CREATE OR REPLACE FUNCTION flow.set_contact_cfv(p_contact_id bigint, p_user_id bigint,p_cfga bigint, p_value_to_save text, p_override_existing boolean default true)
    returns boolean AS
$BODY$
declare
    v_field_saved boolean;
    v_existing_id bigint;
    v_date_value_to_save text;
    v_data_type_id bigint;
    v_request_is_valid boolean;
    v_existing_value text;
BEGIN
--     now()
--     now() AT TIME ZONE 'US/MOUNTAIN'
--     now() AT TIME ZONE 'US/EASTERN'
--     2020-11-23
    if lower(trim(p_value_to_save)) like '%now()%' then
        EXECUTE 'select ' || p_value_to_save into v_date_value_to_save;
--         raise notice 'hello world %', v_date_value_to_save;
    end if;

    --check that the contact company id and the cfga company id are the same in case the user screwed it up
    select ( select c.company_id
             from flow.contact c
             where c.id = p_contact_id) = (select cot.company_id
                                     from flow.custom_field_group_assignment cfga
                                              inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
                                              inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
                                     where cfga.id = p_cfga) into v_request_is_valid;

    if v_request_is_valid is true then
        select cfv.id, coalesce(text_value,
                                boolean_value::text,
                                date_value::text,
                                timestamp_value::text,
                                numeric_value::text,
                                int_value::text,
                                int_array_value::text)
        into v_existing_id, v_existing_value
        from flow.contact_custom_field_value cfv
        where cfv.contact_id = p_contact_id
          and cfv.custom_field_group_assignment_id = p_cfga;

        select cdt.data_type_id into v_data_type_id
         from flow.custom_field_group_assignment cfga
           inner join flow.custom_field cf on cfga.custom_field_id = cf.id
           inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where cfga.id = p_cfga;


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
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, coalesce(v_date_value_to_save::date, p_value_to_save::date), null, null, null, null, null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 2 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, null, coalesce(v_date_value_to_save::timestamp, p_value_to_save::timestamp), null, null, null, null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 3 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, null, null, p_value_to_save::boolean, null, null, null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 4 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, null, null, null, null,p_value_to_save::numeric(10,2), null, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 5 or v_data_type_id = 13 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified, rich_text_value)
                values (p_contact_id, p_cfga, null, null, null, p_value_to_save::text, null,null, null, p_user_id, now(), p_user_id, now(), case when v_data_type_id = 13 then p_value_to_save::text end);
            elsif v_data_type_id = 6 or v_data_type_id = 9 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, null, null, null, null, null, p_value_to_save::bigint, null, p_user_id, now(), p_user_id, now());
            elsif v_data_type_id = 7 then
                insert into flow.contact_custom_field_value(contact_id, custom_field_group_assignment_id, date_value, timestamp_value, boolean_value, text_value, numeric_value, int_value, int_array_value, created_by_id, date_created, modified_by_id, date_modified)
                values (p_contact_id, p_cfga, null, null, null, null, null, null, p_value_to_save::bigint[], p_user_id, now(), p_user_id, now());
            end if;
        else
          --only  do update if told to do override existing OR (the existing value is null or empty)
          if p_override_existing is true or (v_existing_value is null or v_existing_value = '') then
            if v_data_type_id = 1 then
                update flow.contact_custom_field_value
                    set date_value = coalesce(v_date_value_to_save::date, p_value_to_save::date),
                        modified_by_id = p_user_id,
                        date_modified = now()
                where id = v_existing_id;
            elsif v_data_type_id = 2 then
                update flow.contact_custom_field_value
                set timestamp_value = coalesce(v_date_value_to_save::timestamp, p_value_to_save::timestamp),
                    modified_by_id = p_user_id,
                    date_modified = now()
                where id = v_existing_id;
            elsif v_data_type_id = 3 then
                update flow.contact_custom_field_value
                set boolean_value = p_value_to_save::boolean,
                    modified_by_id = p_user_id,
                    date_modified = now()
                where id = v_existing_id;
            elsif v_data_type_id = 4 then
                update flow.contact_custom_field_value
                set numeric_value = p_value_to_save::numeric(10,2),
                    modified_by_id = p_user_id,
                    date_modified = now()
                where id = v_existing_id;
            elsif v_data_type_id = 5 or v_data_type_id = 13 then
                update flow.contact_custom_field_value
                set text_value = p_value_to_save::text,
                    modified_by_id = p_user_id,
                    date_modified = now(),
                    rich_text_value = case when v_data_type_id = 13 then p_value_to_save::text end
                where id = v_existing_id;
            elsif v_data_type_id = 6 or v_data_type_id = 9 then
                update flow.contact_custom_field_value
                set int_value = p_value_to_save::bigint,
                    modified_by_id = p_user_id,
                    date_modified = now()
                where id = v_existing_id;
            elsif v_data_type_id = 7 then
                update flow.contact_custom_field_value
                set int_array_value = p_value_to_save::bigint[],
                    modified_by_id = p_user_id,
                    date_modified = now()
                where id = v_existing_id;
            end if;
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
