ALTER TABLE IF EXISTS flow.process_step_logic
  RENAME TO process_step_action_logic;

ALTER TABLE IF EXISTS flow.process_step_event_logic
  RENAME TO process_step_event_action_logic;
