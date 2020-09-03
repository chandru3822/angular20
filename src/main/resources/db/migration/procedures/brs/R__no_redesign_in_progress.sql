CREATE OR REPLACE FUNCTION brs.no_redesign_in_progress(p_project_id integer)
    returns boolean AS
$BODY$
declare
    v_final_design_signed date;
    v_final_design_created date;

BEGIN

    select ppscfv.date_value
    into v_final_design_signed
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 459
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 9;

    select ppscfv.timestamp_value::date
    into v_final_design_created
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 413
    where pps.project_id = p_project_id  and pps.main is true and pps.process_step_id = 89;

    return v_final_design_signed > v_final_design_created;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
