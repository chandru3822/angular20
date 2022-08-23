drop function if exists flow.get_secondary_detail_value(p_list_of_value_id bigint,
                                                        p_company_system_list_id bigint,
                                                        p_value bigint,
                                                        p_custom_field_sql_column character varying,
                                                        p_custom_field_sql_reference_table character varying);
CREATE OR REPLACE FUNCTION flow.get_secondary_detail_value(p_list_of_value_id bigint,
                                                           p_company_system_list_id bigint,
                                                           p_value bigint,
                                                           p_custom_field_sql_column character varying,
                                                           p_custom_field_sql_reference_table character varying)
  RETURNS text AS
$BODY$
DECLARE
  v_value text;
BEGIN
  if p_list_of_value_id is not null then
    select name
    into v_value
    from flow.list_of_value
    where id = p_value;
  elsif p_company_system_list_id is not null then
    select name from flow.get_system_list_option_value(p_company_system_list_id,p_value)
    into v_value;
  elsif p_custom_field_sql_column is not null then
    execute $$select $$||p_custom_field_sql_column||
    $$ from $$||p_custom_field_sql_reference_table||
    $$ where id = $$||p_value
    into v_value;
  end if;
  return v_value;
END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



