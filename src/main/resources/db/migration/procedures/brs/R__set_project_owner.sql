CREATE OR REPLACE FUNCTION brs.set_project_owner(p_project_process_step_id int)
    returns boolean AS
$BODY$

BEGIN

    -- update the project owner to match the schedule closer appt resource
    update flow.project p set
        user_position_id = ppscfv.int_value
    from (
             select pps.project_id, int_value
             from flow.project_process_step_custom_field_value cfv
             inner join flow.project_process_step pps on pps.id = cfv.project_process_step_id
             inner join flow.custom_field_group_assignment cfga on cfv.custom_field_group_assignment_id = cfga.id
             inner join flow.custom_field cf on cfga.custom_field_id = cf.id
             where cfv.project_process_step_id = p_project_process_step_id
               and cf.field_name = 'Closer Appointment Resource'
         ) as ppscfv(project_id, int_value)
    where ppscfv.project_id = p.id;

    --     not sure why we are returning anything
    return true;

END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
