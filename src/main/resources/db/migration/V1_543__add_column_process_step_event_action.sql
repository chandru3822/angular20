ALTER TABLE flow.process_step_event_action
ADD COLUMN if not exists autotrigger BOOLEAN DEFAULT FALSE;