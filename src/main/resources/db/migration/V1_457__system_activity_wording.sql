update flow.activity
set note = 'process step status updated to '
where activity_code = 'PS_STATUS_CHANGED';

update flow.company_activity
set note = 'process step status updated to '
where activity_id = (
    select id
    from flow.activity
    where activity_code = 'PS_STATUS_CHANGED'
)
  and company_id = 3;

update flow.activity
set note = 'event status updated to '
where activity_code = 'EVENT_STATUS_CHANGED';

update flow.company_activity
set note = 'event status updated to '
where activity_id = (
    select id
    from flow.activity
    where activity_code = 'EVENT_STATUS_CHANGED'
)
  and company_id = 3;

update flow.activity
set note = 'process step created '
where activity_code = 'PROCESS_STEP_CREATED';

update flow.company_activity
set note = 'process step created '
where activity_id = (
    select id
    from flow.activity
    where activity_code = 'PROCESS_STEP_CREATED'
)
  and company_id = 3;