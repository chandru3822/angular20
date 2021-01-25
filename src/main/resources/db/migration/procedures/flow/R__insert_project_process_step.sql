-- drop function if exists flow.insert_project_process_step(integer, integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION flow.insert_project_process_step(p_project_id integer, p_process_step_id integer, p_user_position_id integer, p_user_id integer, p_company_id integer, p_parent_project_process_step_id integer)
-- i am leaving p_user_position_id as a param in case they ask us to put it back. just needs added to the insert at the bottom
RETURNS integer
LANGUAGE plpgsql AS
$$
DECLARE
p_project_process_step_id integer;
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
    where status.company_id = p_company_id and status.process_step_status_type_id = 3
)
update flow.project_process_step pps
set
    company_process_step_status_type_id = cpsst.id,
    date_modified = now(),
    modified_by_id = p_user_id
from pps1, cpsst
where pps.id = pps1.id;

-- Insert new active and main pps
with cpsst as (
    select id
    from flow.company_process_step_status_type
    where
        company_id = p_company_id and
        is_default = true
)
insert into flow.project_process_step(project_id, process_step_id, company_process_step_status_type_id, created_by_id, main, user_position_id, parent_project_process_step_id)
select
    p_project_id,
    p_process_step_id,
    cpsst.id,
    p_user_id,
    true,
    p_user_position_id,
    p_parent_project_process_step_id
from cpsst
returning id into p_project_process_step_id;

RETURN p_project_process_step_id;
END;
$$
