 drop function if exists flow.insert_project_process_step(p_project_id bigint, p_process_step_id bigint, p_user_position_id bigint, p_user_id bigint,
                                                          p_company_id bigint, p_parent_project_process_step_id bigint,
                                                          p_initial_company_process_step_status_type_id bigint, p_existing_company_process_step_status_type_id bigint,
                                                          p_parent_project_process_step_event_id bigint);
CREATE OR REPLACE FUNCTION flow.insert_project_process_step(p_project_id bigint, p_process_step_id bigint, p_user_position_id bigint, p_user_id bigint,
                                                            p_company_id bigint, p_parent_project_process_step_id bigint,
                                                            p_initial_company_process_step_status_type_id bigint, p_existing_company_process_step_status_type_id bigint default null,
                                                            p_parent_project_process_step_event_id bigint default null)
-- i am leaving p_user_position_id as a param in case they ask us to put it back. just needs added to the insert at the bottom
RETURNS bigint
LANGUAGE plpgsql AS
$$
DECLARE
p_project_process_step_id bigint;
BEGIN

-- Mark current main pps as false
update flow.project_process_step
set
    main = false,
    date_modified = now(),
    modified_by_id = p_user_id
where
    project_id = p_project_id and
    process_step_id = p_process_step_id;

--  Set currently active project process steps in the same project and process step to cancelled before creating new project process step
with pps1 as (
    select pps.id
    from flow.project_process_step pps
    inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
    where
        cpsst.company_id = p_company_id and
        cpsst.process_step_status_type_id = 1 and
        pps.project_id = p_project_id and
        pps.process_step_id = p_process_step_id
),
cpsst as (
    select status.id
    from flow.company_process_step_status_type status
--     where status.company_id = p_company_id and status.process_step_status_type_id = 3
    where status.company_id = p_company_id
        and case when p_existing_company_process_step_status_type_id is not null then
          -- we now allow the user to select which cancelled status to use to when adding a new project process step, but sometimes like when creating a project for the first time we wont send this in, but there also shouldn't be any of the same type in this scenario
            status.id = p_existing_company_process_step_status_type_id else status.process_step_status_type_id = 3 end
    limit 1 --just in case
)
update flow.project_process_step pps
set
    company_process_step_status_type_id = cpsst.id,
    date_modified = now(),
    modified_by_id = p_user_id
from pps1, cpsst
where pps.id = pps1.id;

-- Insert new active and main pps
insert into flow.project_process_step(project_id, process_step_id, company_process_step_status_type_id, main, user_position_id, parent_project_process_step_id, created_by_id, date_created, modified_by_id, date_modified, parent_project_process_step_event_id)
values (p_project_id, p_process_step_id, p_initial_company_process_step_status_type_id, true, p_user_position_id, p_parent_project_process_step_id, p_user_id, now(), p_user_id, now(), p_parent_project_process_step_event_id)
returning id into p_project_process_step_id;

insert into flow.company_function_log(function_name, parameters, run_by_id)
values ('Insert Project Process Step', 'p_project_id: ' || p_project_id ||
                                       ' p_process_step_id: ' || p_process_step_id ||
                                       ' p_user_position_id: ' || p_user_position_id ||
                                       ' p_company_id: ' || p_company_id ||
                                       ' p_user_id: ' || p_user_id ||
                                       ' p_parent_project_process_step_id: ' || p_parent_project_process_step_id ||
                                       ' p_initial_company_process_step_status_type_id: ' || p_initial_company_process_step_status_type_id ||
                                       ' p_existing_company_process_step_status_type_id: ' || p_existing_company_process_step_status_type_id ||
                                       ' p_parent_project_process_step_event_id: ' || p_parent_project_process_step_event_id,
        p_user_id);

RETURN p_project_process_step_id;
END;
$$
