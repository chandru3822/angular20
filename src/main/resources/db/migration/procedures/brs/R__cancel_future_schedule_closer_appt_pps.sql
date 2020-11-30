-- drop function brs.cancel_future_schedule_closer_appt_pps(integer);
CREATE OR REPLACE FUNCTION brs.cancel_future_schedule_closer_appt_pps(p_project_id integer, p_project_process_step_id integer)
    RETURNS void
    LANGUAGE plpgsql
AS
$function$
declare
    v_company_id integer;
BEGIN

    --get the company id from the project
    select cp.company_id
    into v_company_id
    from flow.project p
             inner join flow.company_process cp on cp.id = p.company_process_id
    where p.id = p_project_id;

    -- update all future "completed" schedule closer appts to be cancelled
    update flow.project_process_step
        set company_process_step_status_type_id = (select id
                                                    from flow.company_process_step_status_type
                                                    where company_id = v_company_id
                                                      -- cancelled = 3
                                                    and process_step_status_type_id = 3
                                                )
    where id in (
        select pps.id
        from flow.process_step ps
                 inner join flow.project_process_step pps on ps.id = pps.process_step_id
                 inner join flow.company_process_step_status_type cpsst on pps.company_process_step_status_type_id = cpsst.id
                 inner join flow.project_process_step_custom_field_value cfv on pps.id = cfv.project_process_step_id
                 -- only return the start time
                 inner join flow.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id and cfga.schedule_field_type_id = 1
        where ps.process_step_name = 'Schedule Closer Appointment'
          -- completed = 2   ...not active(1) or already cancelled(3)
          and cpsst.process_step_status_type_id = 2
          and cfv.timestamp_value > now()
          and pps.project_id = p_project_id
            and pps.id != p_project_process_step_id
        );



END
$function$


