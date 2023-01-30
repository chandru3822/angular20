drop function if exists flow.get_custom_sql_text_value(text, boolean, bigint, bigint, bigint);
CREATE OR REPLACE FUNCTION flow.get_custom_sql_text_value(p_custom_field_sql text, p_sql_returns_list boolean,
                                                      p_company_id bigint, p_project_id bigint, p_process_step_id bigint)

RETURNS text AS

$BODY$
DECLARE
v_value text;
v_sql   text;
BEGIN

  if p_custom_field_sql is not null and p_sql_returns_list is false then
    v_sql = REPLACE(p_custom_field_sql, ':projectId', coalesce(p_project_id::text, ''));
    v_sql = REPLACE(v_sql, ':companyId', coalesce(p_company_id::text, ''));
    v_sql = REPLACE(v_sql, ':ppsId', coalesce(p_process_step_id::text, ''));
--     raise notice 'sql is HERE: %', v_sql;
    execute v_sql into v_value;
  end if;

--   raise notice 'VALUE is HERE: %', v_value;

  return v_value;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
