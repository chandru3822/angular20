update flow.work_queue_type
SET default_column_display = json('[' ||
                                  '{"text": "Project", "value": "Project Name", "show": true}, ' ||
                                  '{"text": "Project ID", "value": "Project ID", "show": true}, ' ||
                                  '{"text": "Process Step", "value": "Process Step Name", "show": true},' ||
                                  '{"text": "Status", "value": "Process Step Status Type", "show": true},' ||
                                  '{"text": "Days In Queue", "value": "Days In Queue", "show": true},' ||
                                  '{"text": "State", "value": "State Abbreviation", "show": true},' ||
                                  '{"text": "Owner", "value": "Owner", "show": true},' ||
                                  '{"text": "Active Process Steps", "value": "Active Process Steps", "show": true}]')
where use_event_data is false;

update flow.work_queue_type
SET default_column_display = json('[' ||
                                  '{"value": "Project Name", "text": "Project Name", "show": true},' ||
                                  '{"value": "Project ID", "text": "Project ID", "show": true}, ' ||
                                  '{"value": "Event Name", "text": "Event Name", "show": true},' ||
                                  '{"value": "Event Status", "text": "Event Status", "show": true},' ||
                                  '{"value": "Process Step Name", "text": "Process Step Name", "show": true},' ||
                                  '{"value": "Process Step Status", "text": "Process Step Status", "show": true},' ||
                                  '{"value": "Days In Queue", "text": "Days In Queue", "show": true},' ||
                                  '{"value": "Event Start Time", "text": "Event Start Time", "show": true}]' )
where use_event_data is true;
