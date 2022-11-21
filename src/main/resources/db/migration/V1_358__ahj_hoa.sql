create table if not exists brs.ahj_hoa
(
  id               bigserial
    constraint ahj_hoa_pk
      primary key,
  name             varchar(200)            not null,
  archived         boolean   default false not null,
  date_created     timestamp,
  created_by_id    bigint
    constraint ahj_hoa_created_by_id_fk
      references flow."user",
  date_modified    timestamp default now(),
  modified_by_id   bigint
    constraint ahj_hoa_modified_by_id_fk
      references flow."user",
  management_company_id    bigint
    constraint ahj_hoa_management_company_id_fk
      references brs.list_of_value,
  company_state_id bigint
    references flow.company_state
);


create index if not exists ahj_hoa_name_idx
  on brs.ahj_hoa (name);

create index if not exists ahj_hoa_company_state_id_idx
  on brs.ahj_hoa (company_state_id);


create index if not exists ahj_hoa_management_company_id_idx
  on brs.ahj_hoa (management_company_id);



create table  if not exists brs.ahj_hoa_contact
(
  ahj_hoa_id bigint not null
    references brs.ahj_hoa,
  ahj_contact_id bigint not null
    references brs.ahj_contact
    constraint auc4_ahj_hoa_contact_id_fk
      references brs.ahj_contact,
  unique (ahj_hoa_id, ahj_contact_id)
);


create index if not exists ahj_hoa_contact_ahj_contact_id_idx
  on brs.ahj_hoa_contact (ahj_contact_id);



create table if not exists brs.ahj_hoa_link
(
  id             bigserial
    primary key,
  ahj_hoa_id bigint                  not null
    references brs.ahj_hoa,
  name           varchar(2048)            not null,
  link           varchar(2048)            not null,
  username       varchar(255),
  password       varchar(255),
  notes          text,
  link_type_id   bigint not null
    references brs.ahj_link_type,
  archived       boolean   default false not null,
  date_created   timestamp,
  created_by_id  bigint
    references flow."user",
  date_modified  timestamp default now(),
  modified_by_id bigint
    references flow."user"
);



create index if not exists ahj_hoa_link_ahj_hoa_id_idx
  on brs.ahj_hoa_link (ahj_hoa_id);

create index if not exists ahj_hoa_link_link_type_id_idx
  on brs.ahj_hoa_link (link_type_id);


create table if not exists brs.ahj_hoa_custom_field_value
(
  id                               bigserial
    constraint brs_ahj_hoa_custom_field_value_pk
      primary key,
  ahj_hoa_id                   bigint not null
    constraint brs_ahcfv_ahj_hoa_id_fk
      references brs.ahj_hoa,
  date_value                       date,
  custom_field_group_assignment_id bigint not null
    constraint brs_ahcfv_custom_field_id_fk
      references brs.custom_field_group_assignment,
  timestamp_value                  timestamp,
  boolean_value                    boolean,
  text_value                       text,
  numeric_value                    numeric,
  int_value                        bigint,
  int_array_value                  bigint[],
  date_created                     timestamp default now(),
  date_modified                    timestamp default now(),
  created_by_id                    bigint not null
    constraint brs_ahcfv_created_by_id_fk
      references flow."user",
  modified_by_id                   bigint
    constraint brs_ahcfv_modified_by_id_fk
      references flow."user",
  rich_text_value                  text,
  constraint ahcfv_ahj_hoa_id_cfga_id
    unique (ahj_hoa_id, custom_field_group_assignment_id)
);

create index if not exists fki_ahcfv_ahj_hoa_id
  on brs.ahj_hoa_custom_field_value (ahj_hoa_id);

create index if not exists fki_ahcfv_custom_field_group_assignment_id
  on brs.ahj_hoa_custom_field_value (custom_field_group_assignment_id);

-- create trigger ahj_utility_custom_field_value_audit_trg
--   after insert or update or delete
--   on brs.ahj_utility_custom_field_value
--   for each row
-- execute procedure brs.ahj_utility_audit();



create table if not exists brs.ahj_hoa_custom_field_value_audit
(
  id                                bigserial
    constraint ahj_hoa_custom_field_value_audit_pk
      primary key,
  ahj_hoa_custom_field_value_id bigint not null,
  old_value                         text,
  new_value                         text,
  date_modified                     timestamp,
  modified_by_id                    bigint
    constraint ahj_ahcfva_modified_by_id_fk
      references flow."user"
);

create index if not exists ahcfva_ahj_hoa_custom_field_value_audit_idx
  on brs.ahj_hoa_custom_field_value_audit (ahj_hoa_custom_field_value_id);



drop function if exists brs.ahj_hoa_audit();
CREATE OR REPLACE FUNCTION brs.ahj_hoa_audit()
  RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    insert into brs.ahj_hoa_custom_field_value_audit(ahj_hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(new.id,null,case when new.date_value is not null then new.date_value::text
                            when new.timestamp_value is not null then new.timestamp_value::text
                            when new.text_value is not null then new.text_value
                            when new.numeric_value is not null then new.numeric_value::text
                            when new.int_value is not null then new.int_value::text
                            when new.int_array_value is not null then new.int_array_value::text
                            when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  elsif (TG_OP = 'UPDATE') THEN
    insert into brs.ahj_hoa_custom_field_value_audit(ahj_hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           case when new.date_value is not null then new.date_value::text
                when new.timestamp_value is not null then new.timestamp_value::text
                when new.text_value is not null then new.text_value
                when new.numeric_value is not null then new.numeric_value::text
                when new.int_value is not null then new.int_value::text
                when new.int_array_value is not null then new.int_array_value::text
                when new.boolean_value is not null then new.boolean_value::text end,
           now(),
           new.modified_by_id);
  ELSIF (TG_OP = 'DELETE') THEN
    insert into brs.ahj_hoa_custom_field_value_audit(ahj_hoa_custom_field_value_id, old_value, new_value, date_modified, modified_by_id)
    values(old.id,case when old.date_value is not null then old.date_value::text
                       when old.timestamp_value is not null then old.timestamp_value::text
                       when old.text_value is not null then old.text_value
                       when old.numeric_value is not null then old.numeric_value::text
                       when old.int_value is not null then old.int_value::text
                       when old.int_array_value is not null then old.int_array_value::text
                       when old.boolean_value is not null then old.boolean_value::text end,
           null,
           now(),
           new.modified_by_id);
  end if;

  RETURN NULL;
END
$$
  LANGUAGE plpgsql;


drop trigger if exists ahj_hoa_custom_field_value_audit_trg ON brs.ahj_hoa_custom_field_value;
CREATE TRIGGER ahj_hoa_custom_field_value_audit_trg
  after INSERT or update or delete ON brs.ahj_hoa_custom_field_value
  FOR EACH ROW EXECUTE PROCEDURE brs.ahj_hoa_audit();



insert into brs.ahj_contact_type(type, archived)
  (select 'AHJ HOA',false
   where not exists (select id from brs.ahj_contact_type where type = 'AHJ HOA'));


insert into brs.ahj_link_type(name, archived)
  (select 'AHJ HOA',false
   where not exists (select id from brs.ahj_link_type a where a.name = 'AHJ HOA'));


alter table brs.ahj_contact_type add column  if not exists object_type_id bigint;

alter table brs.ahj_contact_type drop constraint if exists ahj_ct_object_id_fk;
alter table brs.ahj_contact_type add constraint ahj_ct_object_id_fk foreign key (object_type_id)references brs.object_type;


update brs.ahj_contact_type set object_type_id = 4 where type = 'Permit';
update brs.ahj_contact_type set object_type_id = 3 where type = 'Inspection Scheduling';
update brs.ahj_contact_type set object_type_id = 3 where type = 'Inspection Obtaining Results';
update brs.ahj_contact_type set object_type_id = 3 where type = 'Inspection Fees';
update brs.ahj_contact_type set object_type_id = 1, archived = true where type = 'Design';
update brs.ahj_contact_type set object_type_id = 4 where type = 'Follow Up and Delivery';
update brs.ahj_contact_type set object_type_id = 4, archived = true where type = 'Print Locations';
update brs.ahj_contact_type set object_type_id = 2 where type = 'Utility';
update brs.ahj_contact_type set object_type_id = 3 where type = 'Inspection Utility Service Department';
update brs.ahj_contact_type set object_type_id = 24 where type = 'AHJ HOA';

alter table brs.ahj_contact_type alter column object_type_id set not null;
alter table brs.ahj_contact alter column contact_type_id set not null;


