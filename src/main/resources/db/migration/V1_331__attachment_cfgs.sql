alter table flow.custom_field_group
add column if not exists attachment_type_id int references flow.attachment_type(id);
CREATE INDEX if not exists cfg_attachment_type_id_idx ON flow.custom_field_group (attachment_type_id);

alter table flow.custom_field_group
  add column if not exists process_step_attachment_type_id int references flow.process_step_attachment_type(id);
CREATE INDEX if not exists cfg_process_step_attachment_type_id_idx ON flow.custom_field_group (process_step_attachment_type_id);

alter table flow.custom_field_group
  add column if not exists event_attachment_type_id int references flow.event_attachment_type(id);
CREATE INDEX if not exists cfg_event_attachment_type_id_idx ON flow.custom_field_group (event_attachment_type_id);

CREATE TABLE if not exists flow.user_attachment_type
(
  id              serial  NOT NULL,
  attachment_type_id   integer NOT NULL,
  company_id integer NOT NULL,
  display_order integer not null,
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  archived boolean not null default false,
  CONSTRAINT user_attachment_type_pk PRIMARY KEY (id),
  CONSTRAINT uat_attachment_id_fk FOREIGN KEY (attachment_type_id)
    REFERENCES flow.attachment_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT uat_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT uat_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT uat_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists uat_attachment_id_idx ON flow.user_attachment_type (attachment_type_id);
CREATE INDEX if not exists uat_company_id_idx ON flow.user_attachment_type (company_id);

CREATE TABLE if not exists flow.org_attachment_type
(
  id              serial  NOT NULL,
  attachment_type_id   integer NOT NULL,
  company_id integer NOT NULL,
  display_order integer not null,
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  archived boolean not null default false,
  CONSTRAINT org_attachment_type_pk PRIMARY KEY (id),
  CONSTRAINT oat_attachment_id_fk FOREIGN KEY (attachment_type_id)
    REFERENCES flow.attachment_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT oat_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT oat_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT oat_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists oat_attachment_id_idx ON flow.org_attachment_type (attachment_type_id);
CREATE INDEX if not exists oat_company_id_idx ON flow.org_attachment_type (company_id);

CREATE TABLE if not exists flow.contact_attachment_type
(
  id              serial  NOT NULL,
  attachment_type_id   integer NOT NULL,
  company_id integer NOT NULL,
  display_order integer not null,
  date_created    timestamp without time zone DEFAULT now(),
  date_modified    timestamp without time zone,
  created_by_id   integer not null,
  modified_by_id  integer,
  archived boolean not null default false,
  CONSTRAINT contact_attachment_type_pk PRIMARY KEY (id),
  CONSTRAINT cat_attachment_id_fk FOREIGN KEY (attachment_type_id)
    REFERENCES flow.attachment_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT cat_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT cat_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT cat_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cat_attachment_id_idx ON flow.contact_attachment_type (attachment_type_id);
CREATE INDEX if not exists cat_company_id_idx ON flow.contact_attachment_type (company_id);

alter table flow.custom_field_group
  add column if not exists user_attachment_type_id int references flow.user_attachment_type(id);
CREATE INDEX if not exists cfg_user_attachment_type_id_idx ON flow.custom_field_group (user_attachment_type_id);

alter table flow.custom_field_group
  add column if not exists org_attachment_type_id int references flow.org_attachment_type(id);
CREATE INDEX if not exists cfg_org_attachment_type_id_idx ON flow.custom_field_group (org_attachment_type_id);

alter table flow.custom_field_group
  add column if not exists contact_attachment_type_id int references flow.contact_attachment_type(id);
CREATE INDEX if not exists cfg_contact_attachment_type_id_idx ON flow.custom_field_group (contact_attachment_type_id);

alter table flow.custom_field_group
  add column if not exists project_attachment_type_id int references flow.project_attachment_type(id);
CREATE INDEX if not exists cfg_project_attachment_type_id_idx ON flow.custom_field_group (project_attachment_type_id);
;

drop table if exists flow.company_object_type_attachment_type;


-- drop table if exists flow.user_attachment_type cascade ;
-- drop table if exists flow.org_attachment_type cascade ;
-- drop table if exists flow.contact_attachment_type cascade ;
