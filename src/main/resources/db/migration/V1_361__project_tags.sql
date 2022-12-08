drop table if exists flow.project_tag;
drop table if exists flow.tag;
drop table if exists flow.tag_type;

CREATE TABLE if not exists flow.tag_type
(
  id             bigserial NOT NULL,
  tag_type       varchar(255),
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer,
  archived       boolean   not null          default false,
  CONSTRAINT flow_tag_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_tag_type_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_tag_type_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

insert into flow.tag_type (tag_type, created_by_id)
select 'PROJECT', 2417170
where not exists(select id from flow.tag_type where tag_type = 'PROJECT');

CREATE TABLE if not exists flow.tag
(
  id             bigserial NOT NULL,
  tag_name       varchar(255),
  tag_type_id    bigint    NOT NULL,
  bg_color       varchar(10) not null,
  font_color       varchar(10) not null,
  removable       boolean not null default false,
  company_id    bigint    NOT NULL,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer,
  archived       boolean   not null          default false,
  CONSTRAINT flow_tag_pk PRIMARY KEY (id),
  CONSTRAINT flow_tag_type_id_fk FOREIGN KEY (tag_type_id)
    REFERENCES flow.tag_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_tag_company_id_fk FOREIGN KEY (company_id)
    REFERENCES flow.company (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_tag_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_tag_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE if not exists flow.project_tag
(
  id             bigserial NOT NULL,
  project_id     bigint    NOT NULL,
  tag_id         bigint    NOT NULL,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer,
  archived       boolean   not null          default false,
  CONSTRAINT flow_project_tag_pk PRIMARY KEY (id),
  CONSTRAINT flow_pt_project_id_fk FOREIGN KEY (project_id)
    REFERENCES flow.project (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_pt_tag_id_fk FOREIGN KEY (tag_id)
    REFERENCES flow.tag (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_pt_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_pt_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

drop index if exists flow.proj_tag_unique_index;
CREATE unique INDEX proj_tag_unique_index ON flow.project_tag(project_id, tag_id) WHERE archived IS FALSE;


--this is unrelated to the project tags feature but i need this for a future task
alter table flow.system_value
add column if not exists data_type_id integer references flow.data_type(id);
update flow.system_value sv
set data_type_id = 6
where id > 0;
