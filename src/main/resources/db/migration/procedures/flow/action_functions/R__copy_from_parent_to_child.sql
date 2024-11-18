drop function if exists flow.copy_from_parent_to_child(p_project_id bigint,
                                                       p_pps_id bigint,
                                                       p_user_id bigint,
                                                       p_cfga_copy_from bigint, p_cfga_copy_to bigint,
                                                       p_override_existing boolean,
                                                       p_copy_to_parent boolean);
CREATE OR REPLACE FUNCTION flow.copy_from_parent_to_child(p_project_id bigint,
                                                          p_pps_id bigint,
                                                          p_user_id bigint,
                                                          p_cfga_copy_from bigint, p_cfga_copy_to bigint,
                                                          p_override_existing boolean,
                                                          p_copy_all_children boolean default false)
  returns boolean AS
$BODY$
declare
  v_parent_project_id         bigint;
  v_project_id                bigint;
  v_child_ids                 bigint[];
  v_from_object_type_id       bigint;
  v_from_list_of_value_id     bigint;
  v_from_company_data_type_id bigint;
  v_from_data_type_id         bigint;
  v_to_object_type_id         bigint;
  v_to_list_of_value_id       bigint;
  v_to_company_data_type_id   bigint;
  v_to_data_type_id           bigint;
  v_value_to_save             text;

BEGIN

  --check that both cfga's share the same data type - using company_data_type_id also ensures they are from the same company
  --and get the object type for each cfga
  select cf.company_data_type_id, cdt.data_type_id, cot.object_type_id, cf.list_of_value_id
  into v_from_company_data_type_id, v_from_data_type_id, v_from_object_type_id, v_from_list_of_value_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
  where cfga.id = p_cfga_copy_from;
  select cf.company_data_type_id, cdt.data_type_id, cot.object_type_id, cf.list_of_value_id
  into v_to_company_data_type_id, v_to_data_type_id, v_to_object_type_id, v_to_list_of_value_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
  where cfga.id = p_cfga_copy_to;

  --we are not doing this on events for now
  if v_from_company_data_type_id != v_to_company_data_type_id or
     v_to_object_type_id = 6 or
     (coalesce(v_to_list_of_value_id, 0) != coalesce(v_from_list_of_value_id, 0)) then
    return false;
  else

    if p_copy_all_children is true then
      v_parent_project_id = p_project_id;
      select array_agg(p.id)
      into v_child_ids
      from flow.project p
      where parent_id = p_project_id;
    else
      select parent_id
      into v_parent_project_id
      from flow.project p2
      where p2.id = p_project_id;
      select array_agg(p_project_id)
      into v_child_ids;
    end if;

    select *
    into v_value_to_save
    from flow.get_cfv_value_as_text(v_parent_project_id, null, p_cfga_copy_from);

    FOR v_project_id IN SELECT unnest(v_child_ids)
      LOOP
        if v_to_object_type_id = 1 then
          perform flow.set_project_cfv(v_project_id, p_user_id, p_cfga_copy_to, v_value_to_save, p_override_existing);
        elsif v_to_object_type_id = 4 then
          perform flow.set_pps_cfv(v_project_id, p_user_id, p_cfga_copy_to, v_value_to_save, p_override_existing);
        end if;
      END LOOP;
    return true;
  end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;



