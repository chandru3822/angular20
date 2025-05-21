-- V1_541__add_custom_values_column.sql

-- Add custom_values column to work_queue_type_filters table
ALTER TABLE flow.work_queue_type_filters
  ADD COLUMN IF NOT EXISTS custom_values TEXT;

-- Add an index on custom_values for better query performance
CREATE INDEX IF NOT EXISTS work_queue_type_filters_custom_values_idx
  ON flow.work_queue_type_filters (custom_values)
  WHERE custom_values IS NOT NULL;
