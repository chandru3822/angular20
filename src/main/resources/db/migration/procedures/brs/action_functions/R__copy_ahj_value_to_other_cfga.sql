drop function if exists brs.copy_ahj_value_to_other_cfga(p_project_id bigint, p_ppse_id bigint,
                                                         p_user_id bigint,
                                                         p_cfga_copy_from bigint, p_cfga_copy_to bigint,
                                                         p_override_existing boolean);
CREATE OR REPLACE FUNCTION brs.copy_ahj_value_to_other_cfga(p_project_id bigint, p_ppse_id bigint,
                                                            p_user_id bigint,
                                                            p_cfga_copy_from bigint, p_cfga_copy_to bigint,
                                                            p_override_existing boolean)
  returns boolean AS
$BODY$
declare
  v_from_object_type_id       bigint;
  v_from_company_data_type_id bigint;
  v_from_has_list_of_values   boolean;
  v_from_data_type_id         bigint;
  v_to_object_type_id         bigint;
  v_to_matching_int_value_as_text     text;
  v_to_matching_int_array_value_as_text     text;
  v_to_company_data_type_id   bigint;
  v_text_value_to_save        text;
  v_rich_text_value_to_save   text;
  v_feat_db_table             text;
  v_event_id                  bigint;
  v_event_request_valid       boolean default true;

BEGIN

  --check that both cfga's share the same data type - using company_data_type_id also ensures they are from the same company
  --and get the object type for each cfga
  select cf.company_data_type_id,
         cdt.data_type_id,
         ot.id,
         case
           when ot.id = 1 then 'design'
           when ot.id = 2 then 'utility'
           when ot.id = 3 then 'inspection'
           when ot.id = 4 then 'permit' end,
         cdt.has_list_values
  into v_from_company_data_type_id, v_from_data_type_id, v_from_object_type_id, v_feat_db_table, v_from_has_list_of_values
  from brs.custom_field_group_assignment cfga
         inner join brs.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.company_data_type cdt on cdt.id = cf.company_data_type_id
         inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join brs.object_type ot on ot.id = cfg.object_type_id
  where cfga.id = p_cfga_copy_from;

  -- 1,AHJ Design
  -- 2,AHJ Utility
  -- 3,AHJ Inspection
  -- 4,AHJ Permit
  -- 24,AHJ HOA

  select cf.company_data_type_id, cot.object_type_id, cfg.event_id
  into v_to_company_data_type_id, v_to_object_type_id, v_event_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
  where cfga.id = p_cfga_copy_to;

  if (v_to_object_type_id = 6) then
    --if copying TO an event cfga then the calling event must be the same as the TO event.
    --v_event_id is the event id for the TO_CFGA, need to ensure that the event of the ppse is the same
    select v_event_id is not null and v_event_id = pse.event_id
    into v_event_request_valid
    from flow.project_process_step_event ppse
           inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
    where ppse.id = p_ppse_id;
  end if;

--   raise notice 'to object type = % ',v_to_object_type_id;
--   raise notice 'TO company_data_type = % ',v_to_company_data_type_id;
--   raise notice 'from object type = % ',v_from_object_type_id;
--   raise notice 'from data_type = % ',v_from_data_type_id;
--   raise notice 'from company_data_type = % ',v_from_company_data_type_id;
--   raise notice 'from table = % ',v_feat_db_table;
--   raise notice 'from has list of values = % ',v_from_has_list_of_values;

  --dont allow if data types aren't the same or if copy_to_cfga is for an event, or no v_feat_db_table
  if v_from_company_data_type_id != v_to_company_data_type_id OR v_event_request_valid is false OR
     v_feat_db_table is null then
    return false;
  else
    --get the value for the first cfga
    select value_as_text, rich_text_value
    into v_text_value_to_save, v_rich_text_value_to_save
    from brs.get_brs_feat_db_value_for_copy(p_project_id::bigint, v_feat_db_table::text,
                                            p_cfga_copy_from::bigint, v_from_data_type_id::bigint,
                                            v_from_has_list_of_values::boolean);


    --if there was a value then, set the value for the second cfga
    -- todo: do the override if existing thing
    if v_text_value_to_save is not null then
      if v_from_has_list_of_values is true and v_from_data_type_id = 6 then
        --special handling for list of values - dropdown
        select (select lov.id::text
                from flow.list_of_value lov
                where lov.parent_id = cf.list_of_value_id
                and lov.archived is false
                and lov.name = v_text_value_to_save)
        into v_to_matching_int_value_as_text
        from flow.custom_field_group_assignment cfga
          inner join flow.custom_field cf on cf.id = cfga.custom_field_id
        where cfga.id = p_cfga_copy_to;
      elseif v_from_has_list_of_values is true and v_from_data_type_id = 7 then
        --special handling for list of values - multiselect
        select (select array_agg(lov.id)::text
                from flow.list_of_value lov
                where lov.parent_id = cf.list_of_value_id
                  and lov.archived is false
                  and lov.name::text = any(v_text_value_to_save::text[]))
        into v_to_matching_int_array_value_as_text
        from flow.custom_field_group_assignment cfga
               inner join flow.custom_field cf on cf.id = cfga.custom_field_id
        where cfga.id = p_cfga_copy_to;
      end if;

      --do normal copy using the matching values if that works
      if v_to_object_type_id = 1 then -- PROJECT
        perform flow.set_project_cfv(p_project_id, p_user_id, p_cfga_copy_to, coalesce(v_to_matching_int_value_as_text,v_to_matching_int_array_value_as_text,v_text_value_to_save)::text,
                                     p_override_existing);
      elseif v_to_object_type_id = 2 then -- CONTACT
        perform flow.set_contact_cfv((select contact_id from flow.project p where p.id = p_project_id), p_user_id,
                                     p_cfga_copy_to, coalesce(v_to_matching_int_value_as_text,v_to_matching_int_array_value_as_text,v_text_value_to_save)::text,
                                     p_override_existing, v_rich_text_value_to_save);
      elseif v_to_object_type_id = 4 then -- PPS
        perform flow.set_pps_cfv(p_project_id, p_user_id, p_cfga_copy_to, coalesce(v_to_matching_int_value_as_text,v_to_matching_int_array_value_as_text,v_text_value_to_save)::text, p_override_existing);
      elseif v_to_object_type_id = 6 then -- PPS EVENT
        perform flow.set_pps_event_cfv(p_ppse_id, p_user_id, p_cfga_copy_to, coalesce(v_to_matching_int_value_as_text,v_to_matching_int_array_value_as_text,v_text_value_to_save)::text,
                                       p_override_existing);
      end if;
    end if;
  end if;

  --i dont even know what this return is for. ...
  return true;

--   end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
