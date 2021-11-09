CREATE TABLE if not exists brs.proposal
(
  id                       serial  NOT NULL,
  project_process_step_id       integer NOT NULL,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT brs_proposal_pk PRIMARY KEY (id),
  CONSTRAINT brs_p_project_process_step_id_fk FOREIGN KEY (project_process_step_id)
    REFERENCES flow.project_process_step (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT brs_p_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_p_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION

);

CREATE INDEX if not exists fki_proposal_project_process_step_id
  on flow.project_process_step (id);

CREATE TABLE if not exists brs.proposal_custom_field_value
(
  id              serial  not null,
  proposal_id       integer not null,
  custom_field_group_assignment_id integer not null,
  date_value      date,
  timestamp_value timestamp,
  boolean_value   boolean,
  text_value      text,
  numeric_value   numeric,
  int_value       integer,
  int_array_value integer[],
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  CONSTRAINT brs_proposal_custom_field_value_pk PRIMARY KEY (id),
  CONSTRAINT brs_pcfv_proposal_id_fk FOREIGN KEY (proposal_id)
    REFERENCES brs.proposal (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_pcfv_custom_field_id_fk FOREIGN KEY (custom_field_group_assignment_id)
    REFERENCES brs.custom_field_group_assignment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_pcfv_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_pcfv_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists fki_pcfv_proposal_id
  on brs.proposal (id);

CREATE INDEX if not exists fki_pcfv_custom_field_group_assignment_id
  on brs.custom_field_group_assignment (id);
