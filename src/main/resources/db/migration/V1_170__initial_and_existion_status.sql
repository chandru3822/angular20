-- randa is going to forget to reset the name back to the original before she pushes this to stage.  so run this commented out part in stage then try again
-- ALTER TABLE flow.process_step_action_child_process
--     RENAME COLUMN exisiting_company_process_step_status_type_id TO company_process_step_status_type_id;

ALTER TABLE flow.process_step_action_child_process
    RENAME COLUMN company_process_step_status_type_id TO exisiting_company_process_step_status_type_id;

alter table flow.process_step_action_child_process
    add column if not exists initial_company_process_step_status_type_id int references flow.company_process_step_status_type(id);

-- set all existing child processes to use the initial company process step status type
update flow.process_step_action_child_process psacp
set initial_company_process_step_status_type_id = (select id
                                                    from flow.company_process_step_status_type cpsst
                                                    where cpsst.is_default is true and cpsst.company_id = ps.company_id)
from flow.process_step ps
where ps.id = psacp.process_step_id;

-- lol, not really sure how many there were. covering my bases
drop function if exists flow.insert_project_process_step(integer, integer, integer, integer, integer, integer);
drop function if exists flow.insert_project_process_step(integer, integer, integer, integer, integer, integer, integer);
