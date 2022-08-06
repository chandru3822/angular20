insert into flow.flow_type(flow_type)
select 'Attachments' where not exists (select id
from flow.flow_type where flow_type = 'Attachments');

insert into flow.object_type(object_type, object_code, flow_type_id, archived, reference_table)
select 'Attachments', 'ATTACHMENTS', 5, false, null
  where not exists(select id from flow.object_type where object_code = 'ATTACHMENTS');

insert into flow.company_object_type(object_type_id, company_id, archived, date_created, date_modified, created_by_id, status_read_only, owner_read_only)
select (select id from flow.object_type where object_code = 'ATTACHMENTS'), 3, false, now(), now(), 2417170, false, false
  where not exists (select id from flow.company_object_type where company_id = 3 and object_type_id = (select id from flow.object_type where object_code = 'ATTACHMENTS'));

--make project, ps, and event linkable and focusable
alter table flow.project_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.project_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.project_attachment_type
  add column if not exists focused boolean not null default false;
alter table flow.process_step_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.process_step_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.process_step_attachment_type
  add column if not exists focused boolean not null default false;
alter table flow.event_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.event_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.event_attachment_type
  add column if not exists focused boolean not null default false;
alter table flow.contact_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.contact_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.contact_attachment_type
  add column if not exists focused boolean not null default false;
alter table flow.org_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.org_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.org_attachment_type
  add column if not exists focused boolean not null default false;
alter table flow.user_attachment_type
  add column if not exists linkable boolean not null default false;
alter table flow.user_attachment_type
  add column if not exists allow_upload boolean not null default false;
alter table flow.user_attachment_type
  add column if not exists focused boolean not null default false;

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


alter table flow.custom_field_group_assignment
add column if not exists default_field_id integer references flow.default_field(id);
CREATE INDEX if not exists cfga_default_field_id_idx ON flow.custom_field_group_assignment (default_field_id);

ALTER TABLE flow.custom_field_group_assignment
  DROP CONSTRAINT if exists null_custom_and_ancillary_check;
alter table flow.custom_field_group_assignment
add constraint null_custom_ancillary_default_check
    check ((custom_field_id IS NOT NULL) OR (ancillary_custom_field_group_assignment_id IS NOT NULL) OR (default_field_id IS NOT NULL))

--add linked column to all the attachment tables
alter table flow.project_attachment
  add column if not exists linked boolean not null default false;
alter table flow.project_process_step_attachment
  add column if not exists linked boolean not null default false;
alter table flow.project_process_step_event_attachment
  add column if not exists linked boolean not null default false;
alter table flow.contact_attachment
  add column if not exists linked boolean not null default false;
alter table flow.user_attachment
  add column if not exists linked boolean not null default false;
alter table flow.org_attachment
  add column if not exists linked boolean not null default false;
