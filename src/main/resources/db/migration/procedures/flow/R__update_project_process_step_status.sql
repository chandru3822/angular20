-- drop function if exists flow.update_project_process_step_status(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION flow.update_project_process_step_status(p_project_id integer, p_process_step_id integer, p_project_process_step_id integer,
                    p_company_process_step_status_typeId integer, p_process_step_status_type_id integer, p_user_id integer, p_cancelled_company_status_id integer)
RETURNS void
LANGUAGE plpgsql AS
$$
DECLARE
    v_count integer;
    v_company_id integer;
BEGIN

-- Get count of active PPS other than the one we're updating
select count(pps.id), cpsst.company_id
       into v_count, v_company_id
from flow.project_process_step pps
inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
where
    pps.id != p_project_process_step_id and
    pps.project_id = p_project_id and
    pps.process_step_id = p_process_step_id and
    pps.archived is not true and
    cpsst.process_step_status_type_id = 1
group by cpsst.id;

-- If updating to active status (process_step_status_type = 1), then cancel all active PPS
IF v_count > 0 and p_process_step_status_type_id = 1
THEN

-- Grab the cancelled status for this company

-- cancel existing pps using the param passed in for p_cancelled_company_status_id -- unless called from an action updating itself which can only happen on active pps so this shouldn't matter
update flow.project_process_step
set
    company_process_step_status_type_id = case when p_cancelled_company_status_id is not null then p_cancelled_company_status_id else
        ( select status.id
            from flow.company_process_step_status_type status
            where status.company_id = v_company_id
              and status.process_step_status_type_id = 3
            limit 1) end, --just in case,
    date_modified = now(),
    modified_by_id = p_user_id
where
    project_id = p_project_id and
    process_step_id = p_process_step_id;

END IF;

-- Update the status and set the completion date if status is set to 2 (complete)
update flow.project_process_step
set
    company_process_step_status_type_id = p_company_process_step_status_typeId,
    modified_by_id = p_user_id,
    date_modified = now(),
    process_step_complete_date = (
    case when p_process_step_status_type_id = 2 then now() end)
where id = p_project_process_step_id;

-- If we just updated the PPS to active status, it must now be the only primary/main PPS
IF p_process_step_status_type_id = 1
THEN

update flow.project_process_step
set main = false,
    date_modified = now(),
    modified_by_id = p_user_id
where
    project_id = p_project_id and
    process_step_id = p_process_step_id and
    main = true;

update flow.project_process_step
set main = true,
    date_modified = now(),
    modified_by_id = p_user_id
where project_process_step.id = p_project_process_step_id;

END IF;

END;
$$
