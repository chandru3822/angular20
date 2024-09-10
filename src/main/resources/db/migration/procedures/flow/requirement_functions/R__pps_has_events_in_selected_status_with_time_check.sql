drop function if exists  flow.pps_has_events_in_selected_status_with_time_check(p_project_process_step_id bigint,
                                                               p_use_end_time boolean,
                                                               p_operation int,
                                                               p_time_adjustment int,
                                                               p_company_event_status_type_ids text,
                                                               p_root_event_status_type_ids text,
                                                               p_event_id int);

create or replace function flow.pps_has_events_in_selected_status_with_time_check(p_project_process_step_id bigint,
                                                                                  p_use_end_time boolean,
                                                                                  p_operation int,
                                                                                  p_time_adjustment int default null,
                                                                                  p_company_event_status_type_ids text default null,
                                                                                  p_root_event_status_type_ids text default null,
                                                                                  p_event_id int default null)
    returns boolean as
$BODY$
declare
    v_has_events boolean;
    v_valid_time_adjustment integer;
BEGIN

    select coalesce(p_time_adjustment, 0) into v_valid_time_adjustment;

    with time_check as (
        select
            ppse.id,
            (case when p_use_end_time::boolean then ppse.end_time else ppse.start_time end)::timestamp as referenced_time
        from flow.project_process_step_event ppse
                 inner join flow.process_step_event pse on ppse.process_step_event_id = pse.id
                 inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
        where ppse.project_process_step_id = p_project_process_step_id
          and ppse.archived is not true
          -- if only root statuses is populated then check those
          and case when p_company_event_status_type_ids is null and p_root_event_status_type_ids is not null then cest.event_status_type_id = any( string_to_array(p_root_event_status_type_ids, ',')::bigint[] ) else true end

          -- if only company statuses is populated then check those
          and case when p_root_event_status_type_ids is null and p_company_event_status_type_ids is not null then ppse.company_event_status_type_id = any( string_to_array(p_company_event_status_type_ids, ',')::bigint[] ) else true end

          -- if both are populated then check both together.  OR not AND
          and case when p_root_event_status_type_ids is not null and p_company_event_status_type_ids is not null then
                       (ppse.company_event_status_type_id = any( string_to_array(p_company_event_status_type_ids, ',')::bigint[] )
                           OR cest.event_status_type_id = any( string_to_array(p_root_event_status_type_ids, ',')::bigint[] ))
                   else true end

          -- if the send in an event id then only check for that one
          and case when p_event_id is not null then pse.event_id = p_event_id::bigint else true end
    )
-- 1 = not null, 2 = <= current timestamp, 3 = <= current date
     select count(1) > 0 into v_has_events
     from time_check
     where case
               when p_operation = 1 then referenced_time is not null
               when p_operation = 2 then referenced_time is not null and referenced_time <= current_timestamp + (v_valid_time_adjustment || ' hours')::interval
               when p_operation = 3 then referenced_time is not null and (referenced_time at time zone 'utc' at time zone 'America/Denver')::date <= (current_date at time zone 'utc' at time zone 'America/Denver') + (v_valid_time_adjustment || ' days')::interval
               else true end;

    return v_has_events;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
