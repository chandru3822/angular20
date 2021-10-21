alter table flow.resource_schedule_availability
  add column if not exists daylight_savings boolean not null default false;

update flow.resource_schedule_availability
set daylight_savings = true
where id > 0;
