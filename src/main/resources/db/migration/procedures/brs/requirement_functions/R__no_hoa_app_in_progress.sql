drop function if exists brs.no_hoa_app_in_progress(p_project_id bigint);
CREATE OR REPLACE FUNCTION brs.no_hoa_app_in_progress(p_project_id bigint)
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
        inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 23;
      and pps.process_step_id = (select ps2.id
          from flow.process_step ps2
          where ps2.company_id = ps.company_id
          and ps2.parent_process_step_id = 3117
          and ps2.archived is not true);

    select ppscfv.date_value
    into v_hoa_request_for_submitted_date
    from flow.project_process_step pps
             inner join flow.project_process_step_custom_field_value ppscfv on ppscfv.project_process_step_id = pps.id and ppscfv.custom_field_group_assignment_id = 118
             inner join flow.process_step ps on ps.id = pps.process_step_id
    where pps.project_id = p_project_id
      and pps.main is true
--       and pps.process_step_id = 22;
    and pps.process_step_id = (select ps2.id
        from flow.process_step ps2
        where ps2.company_id = ps.company_id
        and ps2.parent_process_step_id = 3116
        and ps2.archived is not true);

    return v_hoa_approved_date > v_hoa_request_for_submitted_date;
END
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;
