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
             inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 9;
      and pps.process_step_id = (select ps2.id
                                 from flow.process_step ps2
                                 where ps2.company_id = ps.company_id
                                   and ps2.process_step_name = 'Pending Design and Financial Agreement Approval'
                                   and ps2.archived is not true);

    select ppscfv.timestamp_value::date
    into v_final_design_created
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 413
             inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 89;
      and pps.process_step_id = (select ps2.id
                                 from flow.process_step ps2
                                 where ps2.company_id = ps.company_id
                                   and ps2.process_step_name = 'Needs a Redesign'
                                   and ps2.archived is not true);
    return v_final_design_signed > v_final_design_created;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
