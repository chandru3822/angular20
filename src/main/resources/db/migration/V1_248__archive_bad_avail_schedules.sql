update flow.resource_schedule
set archived = true
where start_date > end_date
  and archived is false;
