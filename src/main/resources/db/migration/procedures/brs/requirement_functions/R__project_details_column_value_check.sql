drop function if exists brs.data_view_column_value_includes_check(bigint, int, int, text);
CREATE OR REPLACE FUNCTION brs.data_view_column_value_includes_check(p_project_id bigint, p_data_view_field_config_id int, p_data_view_child_field_config_id int, p_value_to_check_for text)
    returns boolean AS
$BODY$
declare
    v_data_view_value text;
BEGIN

  -- this function should only be used for "IN" checks because the Settings screen can already handle checking = and != for data view fields

   if(p_data_view_field_config_id is not null) then
     select *
     from flow.get_value_for_data_view_field(p_data_view_field_config_id, p_project_id)
     into v_data_view_value;
   elsif(p_data_view_child_field_config_id is not null) then
     select *
     from flow.get_value_for_data_view_child_field(p_data_view_child_field_config_id, p_project_id)
     into v_data_view_value;
   end if;

--   RAISE NOTICE 'value %', v_data_view_value;

  -- IN check, value passed in should be an array
--     return v_data_view_value = any ( string_to_array( trim(both ' ' from regexp_replace(p_value_to_check_for, '\s*,\s*', ',')), ',')::text[] );
    return v_data_view_value IN ( select trim(unnest(string_to_array(p_value_to_check_for, ',')::text[])) );

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
