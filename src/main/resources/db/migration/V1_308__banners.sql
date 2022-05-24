insert into flow.action_type(action_type)
select 'Banner'
where not exists (
  select id from flow.action_type where action_type = 'Banner'
  );

alter table flow.process_step_action
  add column if not exists color varchar(10);

alter table flow.process_step_event_action
  add column if not exists color varchar(10);

alter table flow.process_step_action
  add column if not exists content text;

alter table flow.process_step_event_action
  add column if not exists content text;

alter table flow.process_step_event_action
  add column if not exists action_type_id int references flow.action_type(id);

update flow.process_step_event_action
set action_type_id = 2
where action_type_id is null;

alter table flow.process_step_event_action alter column action_type_id set not null;
