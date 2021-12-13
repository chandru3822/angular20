drop table if exists brs.ancillary_object_type;
CREATE TABLE if not exists brs.ancillary_object_type
(
  id                       serial  NOT NULL,
  object_type_id       integer NOT NULL,
  ancillary_object_type_id       integer NOT NULL,
  date_created     timestamp without time zone DEFAULT now(),
  date_modified   timestamp without time zone,
  created_by_id    integer      not null,
  modified_by_id  integer,
  archived       boolean not null default false,
  CONSTRAINT brs_ancillary_object_type_pk PRIMARY KEY (id),
  CONSTRAINT brs_aot_object_type_id_fk FOREIGN KEY (object_type_id)
    REFERENCES brs.object_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT brs_aot_ancillary_object_type_id_fk FOREIGN KEY (ancillary_object_type_id)
    REFERENCES flow.object_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT brs_aot_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_aot_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION

);

insert into brs.ancillary_object_type(object_type_id, ancillary_object_type_id, created_by_id)
values (10, 4, 2417170);

insert into brs.ancillary_object_type(object_type_id, ancillary_object_type_id, created_by_id)
values (10, 1, 2417170);

alter table brs.custom_field_group_assignment
add column if not exists ancillary_custom_field_group_assignment_id int references flow.custom_field_group_assignment(id);

alter table brs.custom_field_group_assignment
  add column if not exists use_parent_data boolean not null default false;

