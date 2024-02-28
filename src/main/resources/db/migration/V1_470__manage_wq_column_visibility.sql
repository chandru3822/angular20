alter table if exists flow.work_queue_type
add column if not exists default_column_display jsonb;

update flow.work_queue_type
SET default_column_display = json('[' ||
                                  '{"text": "Project", "value": "Project Name", "show": true}, ' ||
                                  '{"text": "Process Step", "value": "Process Step Name", "show": true},' ||
                                  '{"text": "Status", "value": "Process Step Status Type", "show": true},' ||
                                  '{"text": "Days In Queue", "value": "Days In Queue", "show": true},' ||
                                  '{"text": "State", "value": "State Abbreviation", "show": true},' ||
                                  '{"text": "Owner", "value": "Owner", "show": true},' ||
                                  '{"text": "Active Process Steps", "value": "Active Process Steps", "show": true}]');

-- The text/value/show data is required to match the vuetify headers in the work queue tables

