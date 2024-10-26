drop function if exists brs.set_feat_db_cfv_no_checks(p_feat_db_source_id bigint, p_user_id bigint,
                                                       p_cfga bigint,
                                                       p_value_to_save text,
                                                       p_feat_db_type text);
CREATE OR REPLACE FUNCTION brs.set_feat_db_cfv_no_checks(p_feat_db_source_id bigint, p_user_id bigint,
                                                          p_cfga bigint,
                                                          p_value_to_save text,
                                                          p_feat_db_type text)
    returns void AS
$BODY$
declare
    v_data_type_id bigint;
    v_true_boolean_strings text[];
BEGIN
    v_true_boolean_strings = array['true', 'yes']::text[];

    if p_value_to_save is not null then
        select cdt.data_type_id
        into v_data_type_id
        from brs.custom_field_group_assignment cfga
                 inner join brs.custom_field cf on cfga.custom_field_id = cf.id
                 inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
        where cfga.id = p_cfga;

        -- 1,date
        -- 2,timestamp
        -- 3,boolean
        -- 4,numeric
        -- 5,text
        -- 6,bigint
        -- 7,bigint array
        -- 8,system
        -- 9,System List
        if (p_feat_db_type = 'AHJ_NEW_HOME') then
            insert into brs.feat_db_ahj_new_home_custom_field_value(ahj_new_home_id, custom_field_group_assignment_id,
                                                                    created_by_id, modified_by_id,
                                                                    date_value, timestamp_value,
                                                                    boolean_value, text_value,
                                                                    numeric_value, int_value,
                                                                    int_array_value)
            values (p_feat_db_source_id, p_cfga, p_user_id, p_user_id,
                    case when v_data_type_id = 1 then p_value_to_save::date end,
                    case when v_data_type_id = 2 then p_value_to_save::timestamp end,
                    --sometimes the boolean value comes in as 'Yes'...this should solve that
                    case when v_data_type_id = 3 then case when lower(p_value_to_save::text) = any(v_true_boolean_strings::text[]) then true else false end end,
                    case when v_data_type_id = 4 then p_value_to_save::numeric end,
                    case when v_data_type_id = 5 then p_value_to_save::text end,
                    case when v_data_type_id in (6,9) then p_value_to_save::bigint end,
                    case when v_data_type_id = 7 then p_value_to_save::bigint[] end
                    )
            on conflict do nothing;
        elsif (p_feat_db_type = 'AHJ_UTILITY') then
            insert into brs.feat_db_utility_custom_field_value(utility_id, custom_field_group_assignment_id,
                                                                    created_by_id, modified_by_id,
                                                                    date_value, timestamp_value,
                                                                    boolean_value, text_value,
                                                                    numeric_value, int_value,
                                                                    int_array_value)
            values (p_feat_db_source_id, p_cfga, p_user_id, p_user_id,
                    case when v_data_type_id = 1 then p_value_to_save::date end,
                    case when v_data_type_id = 2 then p_value_to_save::timestamp end,
                       --sometimes the boolean value comes in as 'Yes'...this should solve that
                    case when v_data_type_id = 3 then case when lower(p_value_to_save::text) = any(v_true_boolean_strings::text[]) then true else false end end,
                    case when v_data_type_id = 4 then p_value_to_save::numeric end,
                    case when v_data_type_id = 5 then p_value_to_save::text end,
                    case when v_data_type_id in (6,9) then p_value_to_save::bigint end,
                    case when v_data_type_id = 7 then p_value_to_save::bigint[] end
                   )
            on conflict do nothing;
        end if;
    end if;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
