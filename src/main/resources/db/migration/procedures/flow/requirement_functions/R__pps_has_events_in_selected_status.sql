-- drop function if exists  flow.pps_has_events_in_selected_status(integer, int[], int[], int);
CREATE OR REPLACE FUNCTION flow.pps_has_events_in_selected_status(p_project_process_step_id integer,
                                                                  p_company_event_status_type_ids text,
                                                                  p_root_event_status_type_ids text,
                                                                  p_event_id text)
    returns boolean AS
$BODY$
declare
    v_has_events boolean;
BEGIN

  -- the params get passed in as text because sometimes it might be "null" because the ui doesn't allow for empty params (yet)

  select count(1) > 0 into v_has_events
  from flow.project_process_step_event ppse
   inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
   inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
  where ppse.project_process_step_id = p_project_process_step_id
    and ppse.archived is false
    -- if only root statuses is populated then check those
    and case when p_company_event_status_type_ids = 'null' and p_root_event_status_type_ids != 'null' then cest.event_status_type_id = any( string_to_array(p_root_event_status_type_ids, ',')::int[] ) else 1=1 end

    -- if only company statuses is populated then check those
    and case when p_root_event_status_type_ids = 'null' and p_company_event_status_type_ids != 'null' then ppse.company_event_status_type_id = any( string_to_array(p_company_event_status_type_ids, ',')::int[] ) else 1=1 end

    -- if both are populated then check both together.  OR not AND
    and case when p_root_event_status_type_ids != 'null' and p_company_event_status_type_ids != 'null' then
          (ppse.company_event_status_type_id = any( string_to_array(p_company_event_status_type_ids, ',')::int[] )
              OR cest.event_status_type_id = any( string_to_array(p_root_event_status_type_ids, ',')::int[] ))
       else 1=1 end

    -- if the send in an event id then only check for that one
    and case when p_event_id != 'null' then pse.event_id = p_event_id::int else 1=1 end;

  return v_has_events;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
