select *
from flow.process_step_requirement_type;

alter table flow.process_step_requirement_type
add column if not exists use_by_event boolean not null default false;

alter table flow.process_step_requirement_type
  add column if not exists use_by_process_step boolean not null default false;

alter table flow.process_step_requirement_type
  add column if not exists display_order int;

update flow.process_step_requirement_type
set use_by_event = true,
    use_by_process_step = true
where process_step_requirement_type != 'Event Status';

insert into flow.process_step_requirement_type(process_step_requirement_type, use_by_event, use_by_process_step)
select 'Event Status', true, false
where not exists (select id from flow.process_step_requirement_type
  where process_step_requirement_type = 'Event Status');

update flow.process_step_requirement_type
set display_order = id;
