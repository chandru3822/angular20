alter table flow.company
add column if not exists api_path varchar(50);

-- for now just set the api path for blueraven solar
update flow.company
set api_path = 'blueraven'
where id = 3;

--drop table brs.custom_field_object_type;
CREATE TABLE if NOT EXISTS brs.custom_field_object_type
(
  id  serial  NOT NULL,
  custom_field_id integer NOT NULL,
  object_type_id integer NOT NULL,
  archived boolean default false,
  show_on_insert       boolean not null default false,
  date_created       timestamp without time zone default now(),
  created_by_id      integer,
  date_modified      timestamp without time zone,
  modified_by_id     integer,
  CONSTRAINT brs_custom_field_object_type_pk PRIMARY KEY (id),
  CONSTRAINT brs_cf_object_type_id_fk FOREIGN KEY (object_type_id)
    REFERENCES brs.object_type (id),
  CONSTRAINT brs_cf_custom_field_id_fk FOREIGN KEY (custom_field_id)
    REFERENCES brs.custom_field (id),
  CONSTRAINT brs_cfot_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT brs_cfot_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow."user" (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE INDEX if not exists brs_cfot_object_type_id_idx ON brs.custom_field_object_type (object_type_id);
CREATE INDEX if not exists brs_cfot_custom_field_id_idx ON brs.custom_field_object_type (custom_field_id);

alter table brs.custom_field_group add column date_created       timestamp without time zone default now();
alter table brs.custom_field_group add column date_modified       timestamp without time zone;
alter table brs.custom_field_group add column created_by_id  integer references flow."user"(id);
alter table brs.custom_field_group add column modified_by_id  integer references flow."user"(id);

update brs.custom_field_group
set created_by_id = 2350555;

alter table brs.custom_field_group alter column created_by_id set not null;

-- delete all these records so i can re-insert them and not break stage cuz im not doing local like a huge hypocrite
delete from brs.custom_field_object_type;

-- populate the cfot table
insert into brs.custom_field_object_type(custom_field_id, object_type_id, created_by_id)
select cfga.custom_field_id, cfg.object_type_id, 2350555
from brs.custom_field_group_assignment cfga
       inner join brs.custom_field cf on cfga.custom_field_id = cf.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id;

-- mark the Installation Safety and Quality Form object type as archived, i'm pretty sure we dont use it anymore
update brs.object_type set archived = true where object_code = 'INSTALLATION_SAFETY';
