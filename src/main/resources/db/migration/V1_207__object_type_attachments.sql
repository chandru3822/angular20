CREATE TABLE if not exists flow.company_object_type_attachment_type
(
  id                       serial  NOT NULL,
  company_object_type_id       integer NOT NULL,
  attachment_type_id       integer NOT NULL,
  display_order       integer NOT NULL,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT flow_company_object_type_attachment_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_cotat_company_id_fk FOREIGN KEY (company_object_type_id)
    REFERENCES flow.company_object_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cotat_attachment_type_id_fk FOREIGN KEY (attachment_type_id)
    REFERENCES flow.attachment_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cotat_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cotat_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.user_attachment
(
  id             serial  not null,
  attachment_id  integer not null,
  user_id     integer not null,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id  integer not null,
  modified_by_id integer,
  constraint flow_user_attachment_pk primary key (id),
  CONSTRAINT ua_attachment_id_fk FOREIGN KEY (attachment_id)
    REFERENCES flow.attachment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ua_user_id_fk FOREIGN KEY (user_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ua_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ua_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ua_attachment_id_idx ON flow.user_attachment (attachment_id);

CREATE INDEX if not exists ua_user_id ON flow.user_attachment (user_id);

CREATE TABLE if not exists flow.contact_attachment
(
  id             serial  not null,
  attachment_id  integer not null,
  contact_id     integer not null,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id  integer not null,
  modified_by_id integer,
  constraint flow_contact_attachment_pk primary key (id),
  CONSTRAINT ca_attachment_id_fk FOREIGN KEY (attachment_id)
    REFERENCES flow.attachment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ca_contact_id_fk FOREIGN KEY (contact_id)
    REFERENCES flow.contact (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ca_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT ca_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists ca_attachment_id_idx ON flow.contact_attachment (attachment_id);

CREATE INDEX if not exists ca_contact_id ON flow.contact_attachment (contact_id);

CREATE TABLE if not exists flow.org_attachment
(
  id             serial  not null,
  attachment_id  integer not null,
  org_id     integer not null,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id  integer not null,
  modified_by_id integer,
  constraint flow_org_attachment_pk primary key (id),
  CONSTRAINT oa_attachment_id_fk FOREIGN KEY (attachment_id)
    REFERENCES flow.attachment (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT oa_org_id_fk FOREIGN KEY (org_id)
    REFERENCES flow.org (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT oa_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT oa_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists oa_attachment_id_idx ON flow.org_attachment (attachment_id);

CREATE INDEX if not exists oa_org_id ON flow.org_attachment (org_id);
