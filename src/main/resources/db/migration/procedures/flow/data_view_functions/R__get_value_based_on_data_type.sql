CREATE OR REPLACE FUNCTION flow.get_value_based_on_data_type(p_data_type_id INTEGER)

RETURNS text AS

$BODY$
DECLARE
v_value text;
BEGIN

  if p_data_type_id = 1 then
    v_value = 'date_value';
  elsif p_data_type_id = 2 then

    v_value = 'timestamp_value';
  elsif p_data_type_id = 4 then

    v_value = 'numeric_value';
  elsif p_data_type_id in  (5,13) then

    v_value = 'text_value';
  elsif p_data_type_id in (6,8,9) then

    v_value = 'int_value';
  elsif p_data_type_id = 3 then

    v_value = 'boolean_value';
  elsif p_data_type_id = 7 then

    v_value = 'int_array_value';
  end if;
  return v_value;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
