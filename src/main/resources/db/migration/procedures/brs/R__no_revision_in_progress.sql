CREATE OR REPLACE FUNCTION brs.no_revision_in_progress(p_project_id integer)
    returns boolean AS
$BODY$
declare
    v_permit_approved date;
    v_plan_set_created date;

BEGIN

    select ppscfv.date_value
    into v_permit_approved
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 106
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 15;

    select ppscfv.date_value
    into v_plan_set_created
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 872
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 101;

    return v_permit_approved > v_plan_set_created;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
