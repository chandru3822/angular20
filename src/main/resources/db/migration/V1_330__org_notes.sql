CREATE TABLE if not exists flow.org_note
(
  id             serial  NOT NULL,
  org_id    integer NOT NULL,
  note_id        integer NOT NULL,
  CONSTRAINT org_note_pk PRIMARY KEY (id),
  CONSTRAINT on_org_id_fk FOREIGN KEY (org_id)
    REFERENCES flow.org (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT un_note_id_fk FOREIGN KEY (note_id)
    REFERENCES flow.note (id)
);

CREATE INDEX if not exists on_org_id_idx ON flow.org_note (org_id);

CREATE INDEX if not exists on_note_id_idx ON flow.org_note (note_id);
