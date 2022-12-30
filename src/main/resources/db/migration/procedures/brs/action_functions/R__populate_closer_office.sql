drop function if exists brs.populate_closer_office(bigint, bigint);
CREATE OR REPLACE FUNCTION brs.populate_closer_office(p_project_id bigint, p_user_id bigint)
  RETURNS void
  LANGUAGE plpgsql
AS
$function$
declare
  v_value_to_save text;
  v_org_id bigint;
  v_org_type_id bigint;
BEGIN
  --get the closer office for the user
  --if closer = use closer sales office of the owner of the project
  --if district or regional manager use value from the Closer Office cfga from their org
  --if they dont have one then leave blank

  select up.org_id::text, up.org_id, o.org_type_id
  into v_value_to_save, v_org_id, v_org_type_id
  from flow.project p
         inner join flow.user_position up on up.id = p.user_position_id
         inner join flow.org o on up.org_id = o.id
  where p.id = p_project_id;

  if(v_org_type_id != 3) then --closer sales office
    select int_value::text into v_value_to_save
    from flow.organization_custom_field_value ocfv
    where org_id = v_org_id
      and custom_field_group_assignment_id = 23201
    ;
  end if;

  if(v_value_to_save is not null) then
    --only save if we found a value
    perform flow.set_project_cfv(p_project_id, p_user_id, 23202, v_value_to_save, true);
  end if;

  insert into flow.company_function_log(function_name, db_function_id, parameters, run_by_id)
  values ('Populate Closer Office', 68, 'p_project_id: ' || p_project_id ||
                                        ' p_user_id: '|| p_user_id,
          p_user_id);

END
$function$


