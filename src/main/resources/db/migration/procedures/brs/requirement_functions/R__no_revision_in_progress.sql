drop function if exists brs.no_revision_in_progress(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.no_revision_in_progress(p_project_id bigint)
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
             inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 15;
      and pps.process_step_id = (select ps2.id
                                 from flow.process_step ps2
                                 where ps2.company_id = ps.company_id
                                   and ps2.parent_process_step_id = 3114
                                   and ps2.archived is not true);


    select ppscfv.date_value
    into v_plan_set_created
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 872
             inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 101;
      and pps.process_step_id = (select ps2.id
                                 from flow.process_step ps2
                                 where ps2.company_id = ps.company_id
                                   and ps2.parent_process_step_id = 3227
                                   and ps2.archived is not true);

    return v_permit_approved > v_plan_set_created;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
