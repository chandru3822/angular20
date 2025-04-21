-- Create table for storing work queue type filters
CREATE TABLE if not exists flow.work_queue_type_filters(
  id                       serial  NOT NULL,
  work_queue_type_id       integer NOT NULL,
  process_step_id          integer,
  event_id                 integer,
  filter_id                integer NOT NULL,
  operator_id              integer,
  value_id                 integer,
  date_created             timestamp without time zone DEFAULT now(),
  date_modified            timestamp without time zone,
  created_by_id            integer      not null,
  modified_by_id           integer,
  archived                 boolean not null default false,
  CONSTRAINT flow_work_queue_type_filters_pk PRIMARY KEY (id),
  CONSTRAINT flow_work_queue_type_id_fk FOREIGN KEY (work_queue_type_id)
  REFERENCES flow.work_queue_type (id) MATCH SIMPLE
                                     ON UPDATE RESTRICT ON DELETE RESTRICT
  );

-- Add indexes for performance
CREATE INDEX if not exists work_queue_type_filters_wqt_id_idx ON flow.work_queue_type_filters (work_queue_type_id);
CREATE INDEX if not exists work_queue_type_filters_process_step_id_idx ON flow.work_queue_type_filters (process_step_id);
CREATE INDEX if not exists work_queue_type_filters_event_id_idx ON flow.work_queue_type_filters (event_id);
