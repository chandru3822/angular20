--add system level read-only that BR cannot access
alter table flow.custom_field
  add column if not exists system_readonly boolean not null default false;

--add the new data type for system readonly stuff
insert into flow.data_type(data_type, custom_behavior, system_list)
select 'System Read-Only', true, false
where not exists(
  select id from flow.data_type where data_type = 'System Read-Only'
  );;

insert into flow.company_data_type(company_id, company_data_type, data_type_id)
select 3, 'System Read-Only', (select id from flow.data_type where data_type = 'System Read-Only')
where not exists(
  select id from flow.company_data_type where company_data_type = 'System Read-Only'
  );

--add object type exclusion table
create table flow.custom_field_excluded_object_type
(
  id                     serial not null,
  custom_field_id        integer not null,
  company_object_type_id integer not null,
  archived               boolean   default false,
  date_created           timestamp default now(),
  date_modified          timestamp default now(),
  created_by_id          integer not null,
  modified_by_id         integer,
  CONSTRAINT flow_custom_field_excluded_object_type_pk PRIMARY KEY (id),
  CONSTRAINT flow_cfeot_custom_field_id_fk FOREIGN KEY (custom_field_id)
    REFERENCES flow.custom_field (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cfeot_company_object_type_id_fk FOREIGN KEY (company_object_type_id)
    REFERENCES flow.company_object_type (id) MATCH SIMPLE
    ON UPDATE RESTRICT ON DELETE RESTRICT,
  CONSTRAINT flow_cfeot_created_by_id_fk FOREIGN KEY (created_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT flow_cfeot_modified_by_id_fk FOREIGN KEY (modified_by_id)
    REFERENCES flow.user (id) MATCH SIMPLE
    ON UPDATE NO ACTION ON DELETE NO ACTION
);

create index cfeot_custom_field_id_idx
  on flow.custom_field_object_type (custom_field_id);

create unique index cfeot_field_object_type_index
  on flow.custom_field_excluded_object_type (custom_field_id, company_object_type_id)
  where (archived IS NOT TRUE);

create index cfeot_object_type_id_idx
  on flow.custom_field_excluded_object_type (company_object_type_id);
