-- V1_171__add_reopen_primary_if_applicable_column.sql
ALTER TABLE flow.process_step_action_child_process
  ADD COLUMN IF NOT EXISTS reopen_primary_if_applicable BOOLEAN DEFAULT FALSE;
