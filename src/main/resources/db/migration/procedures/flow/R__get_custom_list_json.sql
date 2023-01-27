drop function if exists flow.get_custom_list_json(text, bigint, bigint, bigint[], bigint, bigint);
CREATE OR REPLACE FUNCTION flow.get_custom_list_json(p_custom_field_sql text,
                                                      p_company_id bigint,
                                                     p_company_system_list_id bigint, p_system_list_option_ids bigint[],
                                                     p_selected_int_value bigint,
                                                     p_project_id bigint)

RETURNS json AS

$BODY$
DECLARE
v_value json;
v_sql   text;
BEGIN

  if p_company_system_list_id is not null then
    -- i think subOptions will always be true from here
    select coalesce((
               SELECT array_to_json(array_agg(row_to_json(lovs)))
               FROM (
                      select * from flow.get_system_list_options(p_company_id::bigint, p_company_system_list_id::bigint,
                                                                 true, p_system_list_option_ids::bigint[], p_selected_int_value::bigint)
               ) lovs), '[]') into v_value;

  elsif p_custom_field_sql is not null then
    v_sql = REPLACE(p_custom_field_sql, ':projectId', coalesce(p_project_id::text, ''));
    v_sql = REPLACE(v_sql, ':companyId', coalesce(p_company_id::text, ''));
    v_sql = concat('select coalesce((
                      SELECT array_to_json(array_agg(row_to_json(lovs)))
                       FROM ( ' ,
                             v_sql ,
                           ') lovs), ''[]'')');
--     raise notice 'sql FUNCTION CRAP is HERE: %', v_sql;
    execute v_sql into v_value;

  end if;

  return v_value;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
