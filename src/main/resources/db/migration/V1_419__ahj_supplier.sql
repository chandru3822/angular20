create table if not exists brs.feat_db_supplier
(
  id               bigserial
    constraint feat_db_supplier_pk
      primary key,
  name             varchar(200)            not null,
  archived         boolean   default false not null,
  date_created     timestamp,
  created_by_id    bigint
    constraint fds_created_by_id_fk
      references flow."user",
  date_modified    timestamp default now(),
  modified_by_id   bigint
    constraint fds_modified_by_id_fk
      references flow."user",
  company_state_id bigint
    references flow.company_state
);

create index if not exists feat_db_supplier_name_idx
  on brs.feat_db_supplier (name);

create index if not exists feat_db_supplier_company_state_id_idx
  on brs.feat_db_supplier (company_state_id);

create table  if not exists brs.feat_db_supplier_contact
(
  feat_db_supplier_id bigint not null
    references brs.feat_db_supplier,
  feat_db_contact_id bigint not null
    references brs.feat_db_contact
    constraint auc4_feat_db_supplier_contact_id_fk
      references brs.feat_db_contact,
  unique (feat_db_supplier_id, feat_db_contact_id)
);


create index if not exists feat_db_supplier_contact_feat_db_contact_id_idx
  on brs.feat_db_supplier_contact (feat_db_contact_id);


create table if not exists brs.feat_db_supplier_link
(
  id             bigserial
    primary key,
  feat_db_supplier_id bigint                  not null
    references brs.feat_db_supplier,
  name           varchar(2048)            not null,
  link           varchar(2048)            not null,
  username       varchar(255),
  password       varchar(255),
  notes          text,
  link_type_id   bigint not null
    references brs.feat_db_link_type,
  archived       boolean   default false not null,
  date_created   timestamp,
  created_by_id  bigint
    references flow."user",
  date_modified  timestamp default now(),
  modified_by_id bigint
    references flow."user"
);

create index if not exists feat_db_supplier_link_feat_db_supplier_id_idx
  on brs.feat_db_supplier_link (feat_db_supplier_id);

create index if not exists feat_db_supplier_link_link_type_id_idx
  on brs.feat_db_supplier_link (link_type_id);


create table if not exists brs.feat_db_supplier_custom_field_value
(
  id                               bigserial
    constraint brs_feat_db_supplier_custom_field_value_pk
      primary key,
  feat_db_supplier_id                   bigint not null
    constraint brs_fdscfv_feat_db_supplier_id_fk
      references brs.feat_db_supplier,
  date_value                       date,
  custom_field_group_assignment_id bigint not null
    constraint brs_fdscfv_custom_field_id_fk
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
    constraint brs_fdscfv_created_by_id_fk
      references flow."user",
  modified_by_id                   bigint
    constraint brs_fdscfv_modified_by_id_fk
      references flow."user",
  rich_text_value                  text,
  constraint fdscfv_feat_db_supplier_id_cfga_id
    unique (feat_db_supplier_id, custom_field_group_assignment_id)
);

create index if not exists fki_fdscfv_ahj_hoa_id
  on brs.feat_db_supplier_custom_field_value (feat_db_supplier_id);

create index if not exists fki_fdscfv_custom_field_group_assignment_id
  on brs.feat_db_supplier_custom_field_value (custom_field_group_assignment_id);


create table if not exists brs.feat_db_supplier_custom_field_value_audit
(
  id                                bigserial
    constraint feat_db_supplier_custom_field_value_audit_pk
      primary key,
  feat_db_supplier_custom_field_value_id bigint not null,
  old_value                         text,
  new_value                         text,
  date_modified                     timestamp,
  modified_by_id                    bigint
    constraint ahj_fdscfva_modified_by_id_fk
      references flow."user"
);

create index if not exists fdscfva_feat_db_supplier_custom_field_value_audit_idx
  on brs.feat_db_supplier_custom_field_value_audit (feat_db_supplier_custom_field_value_id);

insert into brs.object_type(object_type, object_code, archived, parent_id, allow_required, allow_min_max, custom_columns, allow_conditional, allow_hidden, allow_readonly)
select 'AHJ SUPPLIER','AHJ_SUPPLIER',false,null,false,false,true,false,false,false
  where not exists (select id from brs.object_type where object_code = 'AHJ_SUPPLIER');


insert into brs.feat_db_contact_type(type, archived, object_type_id)
  (select 'FEAT DB Supplier',false, (select id from brs.object_type where object_code = 'AHJ_SUPPLIER')
   where not exists (select id from brs.feat_db_contact_type where type = 'FEAT DB Supplier'));


insert into brs.feat_db_link_type(name, archived, object_type_id)
  (select 'FEAT DB Supplier',false, (select id from brs.object_type where object_code = 'AHJ_SUPPLIER')
   where not exists (select id from brs.feat_db_link_type a where a.name = 'FEAT DB Supplier'));

insert into flow.feature(feature_name, feature_code, feature_path)
select 'Suppliers', 'SUPPLIERS', '/database/supplier'
where not exists (select id from flow.feature where feature_code = 'SUPPLIERS');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page, parent_company_feature_id)
select 'Suppliers', 3, (select id from flow.feature where feature_code = 'SUPPLIERS'), true, 38
where not exists (select id from flow.company_feature where feature_name = 'Suppliers' and company_id = 3);


INSERT INTO flow.feature_access_control (feature_id, access_control_id, date_created, date_modified, created_by_id, modified_by_id, archived)
select (select id from flow.feature where feature_code = 'SUPPLIERS'), 1, '2023-01-06 05:37:15.631465', '2023-01-06 05:37:15.631465', 2453836, 2453836, false
where not exists (select id from flow.feature_access_control where access_control_id = 1 and feature_id = (select id from flow.feature where feature_code = 'SUPPLIERS'));
INSERT INTO flow.feature_access_control (feature_id, access_control_id, date_created, date_modified, created_by_id, modified_by_id, archived)
select (select id from flow.feature where feature_code = 'SUPPLIERS'), 2, '2023-01-06 05:37:15.631465', '2023-01-06 05:37:15.631465', 2453836, 2453836, false
where not exists (select id from flow.feature_access_control where access_control_id = 2 and feature_id = (select id from flow.feature where feature_code = 'SUPPLIERS'));
INSERT INTO flow.feature_access_control (feature_id, access_control_id, date_created, date_modified, created_by_id, modified_by_id, archived)
select (select id from flow.feature where feature_code = 'SUPPLIERS'), 3, '2023-01-06 05:37:15.631465', '2023-01-06 05:37:15.631465', 2453836, 2453836, false
where not exists (select id from flow.feature_access_control where access_control_id = 3 and feature_id = (select id from flow.feature where feature_code = 'SUPPLIERS'));
INSERT INTO flow.feature_access_control (feature_id, access_control_id, date_created, date_modified, created_by_id, modified_by_id, archived)
select (select id from flow.feature where feature_code = 'SUPPLIERS'), 4, '2023-01-06 05:37:15.631465', '2023-01-06 05:37:15.631465', 2453836, 2453836, false
where not exists (select id from flow.feature_access_control where access_control_id = 4 and feature_id = (select id from flow.feature where feature_code = 'SUPPLIERS'));
