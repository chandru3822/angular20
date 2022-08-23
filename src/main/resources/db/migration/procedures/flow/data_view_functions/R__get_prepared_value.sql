drop function if exists flow.get_prepared_value(p_data_type_id bigint,p_value text);
CREATE OR REPLACE FUNCTION flow.get_prepared_value(p_data_type_id bigint,p_value text)

RETURNS text AS

$BODY$
DECLARE
v_value text;
BEGIN

  if p_data_type_id = 1 then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::date';
  elsif p_data_type_id = 2 then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::timestamp';
  elsif p_data_type_id = 4 then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::numeric';
  elsif p_data_type_id = 5 then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::text';
  elsif p_data_type_id in (6,8,9) then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::bigint';
  elsif p_data_type_id = 3 then
    case when p_value is null then select 'null' into v_value; else select quote_literal(p_value) into v_value; end case;
    v_value = v_value || '::boolean';
  elsif p_data_type_id = 7 then
    case when p_value is null or p_value = '{}' then select 'null' into v_value; else select quote_literal(string_agg(lov.name, ', '))
                                                                                                              from flow.list_of_value lov
                                                                                                              where lov.id = any (p_value::bigint[])
                                                                                                              into v_value; end case;
    else
    v_value = v_value || '::text';
  end if;
  return v_value;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
