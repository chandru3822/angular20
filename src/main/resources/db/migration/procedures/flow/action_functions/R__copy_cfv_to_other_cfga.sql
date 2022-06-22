CREATE OR REPLACE FUNCTION flow.copy_cfv_to_other_cfga(p_project_id integer, p_pps_id integer, p_ppse_id integer,
                                                       p_user_id integer,
                                                       p_cfga_copy_from integer, p_cfga_copy_to integer,
                                                       p_override_existing boolean)
  returns boolean AS
$BODY$
declare
  v_from_object_type_id int;
  v_from_data_type_id   int;
  v_to_object_type_id   int;
  v_to_data_type_id     int;
  v_value_to_save       text;
  v_event_id            int;
  v_event_request_valid boolean default true;

BEGIN
  --check that both cfga's share the same data type - using company_data_type_id also ensures they are from the same company
  --and get the object type for each cfga
  select cf.company_data_type_id, cot.object_type_id
  into v_from_data_type_id, v_from_object_type_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
  where cfga.id = p_cfga_copy_from;
  select cf.company_data_type_id, cot.object_type_id, cfg.event_id
  into v_to_data_type_id, v_to_object_type_id, v_event_id
  from flow.custom_field_group_assignment cfga
         inner join flow.custom_field cf on cfga.custom_field_id = cf.id
         inner join flow.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
         inner join flow.company_object_type cot on cfg.company_object_type_id = cot.id
  where cfga.id = p_cfga_copy_to;

  if(v_to_object_type_id = 6) then
    --if copying TO an event cfga then the calling event must be the same as the TO event.
    --v_event_id is the event id for the TO_CFGA, need to ensure that the event of the ppse is the same
    select v_event_id is not null and v_event_id = pse.event_id into v_event_request_valid
    from flow.project_process_step_event ppse
      inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
    where ppse.id = p_ppse_id;
  end if;


  --dont allow if data types aren't the same or if copy_to_cfga is for an event
  if v_from_data_type_id != v_to_data_type_id OR v_event_request_valid is false then
    return false;
  else
    --get the value for the first cfga
    select *
    into v_value_to_save
    from flow.get_cfv_value_as_text(p_project_id::int, p_ppse_id::int, p_cfga_copy_from);

    raise notice 'from object type = % ',v_to_object_type_id;
    raise notice 'value to save = % ',v_value_to_save;

    --if there was a value then, set the value for the second cfga
    -- todo: add param for only saving if doesn't already have a value
--     if v_value_to_save is not null then
      if v_to_object_type_id = 1 then -- PROJECT
        perform flow.set_project_cfv(p_project_id, p_user_id, p_cfga_copy_to, v_value_to_save, p_override_existing);
      elseif v_to_object_type_id = 2 then -- CONTACT
        perform flow.set_contact_cfv((select contact_id from flow.project p where p.id = p_project_id), p_user_id,
                                     p_cfga_copy_to, v_value_to_save, p_override_existing);
      elseif v_to_object_type_id = 4 then -- PPS
        perform flow.set_pps_cfv(p_project_id, p_user_id, p_cfga_copy_to, v_value_to_save, p_override_existing);
      elseif v_to_object_type_id = 6 then -- PPS EVENT
        perform flow.set_pps_event_cfv(p_ppse_id, p_user_id, p_cfga_copy_to, v_value_to_save, p_override_existing);
      end if;
    end if;

    --i dont even know what this return is for. ...
    return true;

--   end if;

END
$BODY$
  LANGUAGE plpgsql VOLATILE
                   COST 100;
