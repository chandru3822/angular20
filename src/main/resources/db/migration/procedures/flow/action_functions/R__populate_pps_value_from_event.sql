-- drop function if exists flow.populate_pps_value_from_event(integer, integer, text);
CREATE OR REPLACE FUNCTION flow.populate_pps_value_from_event(p_project_id integer, p_pps_event_id integer, p_property_to_save text)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_value_to_save text;
BEGIN

    if(p_property_to_save = 'start_time') then
      select start_time::text into v_value_to_save from flow.project_process_step_event where id = p_pps_event_id;
    elseif(p_property_to_save = 'end_time') then
      select end_time::text into v_value_to_save from flow.project_process_step_event where id = p_pps_event_id;
    elseif(p_property_to_save = 'resource_id') then
      select resource_id::text into v_value_to_save from flow.project_process_step_event where id = p_pps_event_id;
    elseif(p_property_to_save = 'resource_name') then
      select case when sl.system_list_type_id = 1 then o.org_name::text else concat(u.first_name, ' ', u.last_name)::text end into v_value_to_save
      from flow.project_process_step_event ppse
      inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
      inner join flow.event e on pse.event_id = e.id
      inner join flow.custom_field cf on e.resource_custom_field_id = cf.id
      inner join flow.company_system_list csl on csl.id = cf.company_system_list_id
      inner join flow.system_list sl on sl.id = csl.system_list_id
      left join flow.org o on o.id = ppse.resource_id
      left join flow.user_position up on up.id = ppse.resource_id
      left join flow.user u on up.user_id = u.id
      where ppse.id = p_pps_event_id;
    elseif(p_property_to_save = 'status_id') then
      select company_event_status_type_id::text into v_value_to_save from flow.project_process_step_event where id = p_pps_event_id;
    elseif(p_property_to_save = 'status_type') then
      select cest.event_status_type::text into v_value_to_save
      from flow.project_process_step_event ppse
      inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
      where ppse.id = p_pps_event_id;
    end if;

    IF(v_value_to_save is not null)
      THEN
        -- 22680 = cfga for proposal due date on the Schedule Closer Appt process step
        perform flow.set_pps_cfv(p_project_id, 99999999, 22680::integer, v_value_to_save::text);
    END IF;


END
$function$


