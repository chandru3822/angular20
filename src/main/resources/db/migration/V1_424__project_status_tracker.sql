alter table flow.company_project_status_type
drop column if exists color;

alter table flow.company_project_status_type
  add column if not exists is_milestone boolean not null default false;

drop table if exists flow.company_project_status_field_assignment;
CREATE TABLE if not exists flow.company_project_status_field_assignment
(
  id             bigserial NOT NULL,
  company_project_status_type_id bigint not null,
  data_view_field_config_id bigint,
  data_view_child_field_config_id bigint,
  display_order int not null,
  date_created   timestamp without time zone DEFAULT now(),
  date_modified  timestamp without time zone DEFAULT now(),
  created_by_id  integer   not null,
  modified_by_id integer not null,
  archived       boolean   not null          default false,
  CONSTRAINT flow_company_project_status_field_assignment_pk PRIMARY KEY (id),
  CONSTRAINT flow_cpsfa_company_project_status_type_id_fk FOREIGN KEY (company_project_status_type_id)
    REFERENCES flow.company_project_status_type (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cpsfa_data_view_field_config_id_fk FOREIGN KEY (data_view_field_config_id)
    REFERENCES flow.data_view_field_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cpsfa_data_view_child_field_config_id_fk FOREIGN KEY (data_view_child_field_config_id)
    REFERENCES flow.data_view_child_field_config (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cpsfa_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cpsfa_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists cpsfa_company_project_status_type_id_idx ON flow.company_project_status_field_assignment (company_project_status_type_id);
CREATE INDEX if not exists cpsfa_data_view_field_config_id_id_idx ON flow.company_project_status_field_assignment (data_view_field_config_id);
CREATE INDEX if not exists cpsfa_data_view_child_field_config_id_idx ON flow.company_project_status_field_assignment (data_view_child_field_config_id);

ALTER TABLE flow.company_project_status_field_assignment
  ADD CONSTRAINT null_default_field_and_child
    CHECK (
        data_view_field_config_id is not null
        OR data_view_child_field_config_id is not null
      );
