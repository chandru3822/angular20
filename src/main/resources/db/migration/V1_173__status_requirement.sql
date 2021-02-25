insert into flow.process_step_requirement_type(process_step_requirement_type)
select 'Process Step - Status' where not exists (select * from flow.process_step_requirement_type where process_step_requirement_type = 'Process Step - Status');

alter table flow.process_step_requirement
add column if not exists reference_process_step_id int references flow.process_step(id);

alter table flow.process_step_requirement
    add column if not exists fail_if_no_reference_step_found boolean not null default false;

drop function if exists flow.get_project_process_step_requirements_with_values(INTEGER, INTEGER[]);
-- 2350550
-- 2845
-- 1
;

select pps.*
from flow.project_process_step pps
         inner join flow.company_process_step_status_type cpsst on cpsst.id = pps.company_process_step_status_type_id
where pps.project_id = (select pps2.project_id from flow.project_process_step pps2 where id = 2350550)
  and pps.main is true
  and pps.archived is not true
  and pps.process_step_id = :referenceProcessStepId
  and pps.company_process_step_status_type_id = any(array[ 1 ]::integer[])
