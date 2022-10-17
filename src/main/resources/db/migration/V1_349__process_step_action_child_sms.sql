drop table if exists flow.process_step_action_message_template;
CREATE TABLE if not exists flow.process_step_action_message_template
(
  id                     serial   not null,
  process_step_action_id integer  not null,
  message_template_id    integer  not null,
  sms_team_ids           bigint[] not null,
  date_created           timestamp without time zone DEFAULT now(),
  date_modified          timestamp without time zone,
  created_by_id          integer  not null,
  modified_by_id         integer,
  archived               boolean  not null           default false,
  CONSTRAINT process_step_action_message_template_pk PRIMARY KEY (id),
  CONSTRAINT psamt_process_step_action_id_fk FOREIGN KEY (process_step_action_id)
    REFERENCES flow.process_step_action (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psamt_message_template_id_fk FOREIGN KEY (message_template_id)
    REFERENCES flow.message_template (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT psamt_action_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT psamt_action_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists psamt_process_step_action_id_idx ON flow.process_step_action_message_template (process_step_action_id);
CREATE INDEX if not exists psamt_message_template_id_idx ON flow.process_step_action_message_template (message_template_id);
