-- drop function if exists brs.populate_setter_office(integer, integer);
CREATE OR REPLACE FUNCTION brs.populate_setter_office(p_project_id integer, p_user_id integer)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_value_to_save text;
  v_secondary_value_to_save text;
  v_org_id integer;
  v_org_type_id integer;
BEGIN
  --get the setter office for the user
  --if org - setter office has a value - use that
  --if it doesnt have one then use user's org

  select up.org_id::text, up.org_id, o.org_type_id
    into v_secondary_value_to_save, v_org_id, v_org_type_id
  from flow.project p
    inner join flow.contact c on p.contact_id = c.id
    inner join flow.user_position up on up.id = c.owner_user_position_id
    inner join flow.org o on up.org_id = o.id
  where p.id = p_project_id;

  --try to get value from Org Custom Field - setter Office
  select int_value::text into v_value_to_save
  from flow.organization_custom_field_value ocfv
  where org_id = v_org_id
  and custom_field_group_assignment_id = 23219;

  if(v_value_to_save is null) then
    --if no Custom Field - setter Office then use the user's org id
    v_value_to_save = v_secondary_value_to_save;
  end if;

  if(v_value_to_save is not null) then
    --this should never be null but i left the check in just in case
    perform flow.set_project_cfv(p_project_id, p_user_id, 23220, v_value_to_save);
  end if;

END
$function$


