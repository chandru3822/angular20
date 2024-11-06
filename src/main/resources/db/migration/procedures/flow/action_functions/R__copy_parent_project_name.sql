drop function if exists flow.copy_parent_project_name(p_project_id bigint,
                                                      p_user_id bigint,
                                                      p_cfga_copy_to bigint,
                                                      p_override_existing boolean);
CREATE OR REPLACE FUNCTION flow.copy_parent_project_name(p_project_id bigint,
                                                         p_user_id bigint,
                                                         p_cfga_copy_to bigint,
                                                        p_override_existing boolean)
  returns boolean AS
$BODY$
declare
  v_parent_project_id         bigint;
  v_parent_project_name              text;
  v_to_data_type_id           bigint;

BEGIN

  --check that the cfga_id data type is text
  select cdt.data_type_id
  into v_to_data_type_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
  where cfga.id = p_cfga_copy_to;

  --only allow this function to run if the cfga data type to copy to is TEXT
  if(v_to_data_type_id = 5) then
      select parent_id
      into v_parent_project_id
      from flow.project p
      where p.id = p_project_id;

      select pp.project_name
      into v_parent_project_name
      from flow.project pp
      where pp.id = v_parent_project_id;



      if(v_parent_project_name is not null) then
        perform flow.set_project_cfv(p_project_id, p_user_id, p_cfga_copy_to, v_parent_project_name, p_override_existing);
      end if;

    return true;
  else
      return false;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



