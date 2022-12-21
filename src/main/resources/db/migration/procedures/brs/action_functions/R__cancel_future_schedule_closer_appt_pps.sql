drop function if exists brs.cancel_future_schedule_closer_appt_pps(bigint);
CREATE OR REPLACE FUNCTION brs.cancel_future_schedule_closer_appt_pps(p_project_id bigint)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
BEGIN

    -- update all future "active" OR "complete" closer appt EVENTS to be cancelled
    update flow.project_process_step_event
        set company_event_status_type_id = 4
    where id in (
        select ppse.id
        from flow.project_process_step_event ppse
              inner join flow.project_process_step pps on ppse.project_process_step_id = pps.id
              inner join flow.company_event_status_type cest on ppse.company_event_status_type_id = cest.id
        where cest.event_status_type_id in (1,2) --active and complete
          and ppse.start_time > now() -- that are in the future
          and pps.project_id = p_project_id -- on this project
        );

        insert into flow.company_function_log(function_name, db_function_id, parameters)
        values ('Cancel Future Schedule Closer Appointments', 15, 'p_project_id: ' || p_project_id);

END
$function$


