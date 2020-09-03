drop function if exists flow.update_project_process_step_status(integer, integer, integer, boolean, integer, integer, integer);

CREATE OR REPLACE FUNCTION flow.update_project_process_step_status(p_project_id integer, p_process_step_id integer, p_project_process_step_id integer, p_main boolean, p_company_process_step_status_typeId integer, p_process_step_status_type_id integer, p_user_id integer)
    RETURNS void
    LANGUAGE plpgsql AS
$$
DECLARE
    v_count integer;
BEGIN

    select count(pps.id) into v_count
    from flow.project_process_step pps
             inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    where
            pps.project_id = p_project_id and
            pps.process_step_id = p_process_step_id and
        pps.archived is not true and
            cpsst.process_step_status_type_id = 1;

    IF v_count > 0
    THEN

        update flow.project_process_step
        set
            main = false,
            date_modified = now(),
            modified_by_id = p_user_id
        where
                project_id = p_project_id and
                process_step_id = p_process_step_id;

    END IF;

    update flow.project_process_step
    set
        company_process_step_status_type_id = p_company_process_step_status_typeId,
        main = p_main,
        modified_by_id = p_user_id,
        date_modified = now(),
        process_step_complete_date = (
            case when p_process_step_status_type_id = 2 then now() end)
    where id = p_project_process_step_id;

END;
$$