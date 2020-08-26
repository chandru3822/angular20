CREATE OR REPLACE FUNCTION brs.no_hoa_app_in_progress(p_project_id integer)
    returns boolean AS
$BODY$
declare
    v_hoa_approved_date date;
    v_hoa_request_for_submitted_date date;

BEGIN

    select ppscfv.date_value
    into v_hoa_approved_date
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 119
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 23;

    select ppscfv.date_value
    into v_hoa_request_for_submitted_date
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 118
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 22;

    return v_hoa_approved_date > v_hoa_request_for_submitted_date;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
