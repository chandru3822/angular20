drop function if exists  flow.pps_has_no_other_active_events(bigint, bigint, text);

create function flow.pps_has_no_other_active_events(p_project_process_step_id bigint,
                                                    p_project_process_step_event_id bigint,
                                                    p_excluded_event_ids text default null)
    returns boolean as
$BODY$
declare
    v_has_no_other_active_events boolean;
BEGIN

    select count(1) = 0 into v_has_no_other_active_events
    from flow.project_process_step_event ppse
             inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
             inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
    where ppse.project_process_step_id = p_project_process_step_id
      and ppse.id != p_project_process_step_event_id
      and case when p_excluded_event_ids is not null then not(pse.event_id = any( string_to_array(p_excluded_event_ids, ',')::bigint[] )) else 1=1 end
      and cest.event_status_type_id = 1
      and ppse.archived is not true;

    return v_has_no_other_active_events;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;