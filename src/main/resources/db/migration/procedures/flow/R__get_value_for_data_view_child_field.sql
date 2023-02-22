-- drop function if exists flow.get_value_for_data_view_field(bigint, bigint);
CREATE OR REPLACE FUNCTION flow.get_value_for_data_view_child_field(p_data_view_child_field_config_id bigint, p_project_id bigint)

RETURNS text AS

$BODY$
DECLARE
v_value text;
v_field_to_update text;
v_schema_name text;
v_view_name text;
v_sql text;
BEGIN

  select dvcfc.field_to_update, c.schema_name, dv.view_name
  into v_field_to_update, v_schema_name, v_view_name
  from flow.data_view_child_field_config dvcfc
         inner join flow.data_view_field_config dvfc on dvfc.id = dvcfc.data_view_field_config_id
         inner join flow.data_view dv on dv.id = dvfc.data_view_id
         inner join flow.company c on c.id = dv.company_id
  where dvcfc.id = p_data_view_child_field_config_id;

  if(v_field_to_update is not null and v_schema_name is not null and v_view_name is not null and p_project_id is not null) then
    v_sql = (select concat('select ',v_field_to_update,' from ', v_schema_name,'.',v_view_name,' where project_id = ', p_project_id));
    execute v_sql into v_value;
  end if;


  return v_value;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
