create table if not exists brs.parts_master_version_status
(
  id bigserial primary key,
  parts_master_version_status_code varchar(50) unique
);

insert into brs.parts_master_version_status (parts_master_version_status_code)
  values('DRAFT')
ON CONFLICT DO NOTHING;
insert into brs.parts_master_version_status (parts_master_version_status_code)
  values('PUBLISHED')
ON CONFLICT DO NOTHING;

create table if not exists brs.parts_master_version
(
  id bigserial primary key,
  company_id bigint not null
    references flow.company,
  version varchar(20),
  parts_master_version_status_id bigint not null
    references brs.parts_master_version_status,
  notes                      text,
  date_created               timestamp with time zone default now() not null,
  date_modified              timestamp with time zone default now() not null,
  created_by_id              bigint                                 not null
    references flow."user",
  modified_by_id             bigint                                 not null
    references flow."user"
);

drop index if exists parts_master_version_company_id_ix;
create index if not exists parts_master_version_company_id_ix
  on brs.parts_master_version (company_id);

drop index if exists parts_master_version_parts_master_version_status_id_ix;
create index if not exists parts_master_version_parts_master_version_status_id_ix
  on brs.parts_master_version (parts_master_version_status_id);

create table if not exists brs.parts_master_version_custom_field_group
(
  id bigserial primary key,
  parts_master_version_id bigint not null references brs.parts_master_version,
  parts_master_group_uuid uuid not null,
  archived timestamp with time zone,
  date_created timestamp with time zone default now() not null,
  date_modified timestamp with time zone default now() not null,
  created_by_id bigint references flow."user" not null,
  modified_by_id bigint references flow."user" not null,
  constraint pmcfg_excl
    exclude (parts_master_version_id with =, parts_master_group_uuid with =)
);

-- alter table brs.parts_master_version_custom_field_group
-- alter column archived drop not null;
drop index if exists pmcfg_parts_master_group_uuid_ix;
create index if not exists pmcfg_parts_master_group_uuid_ix
  on brs.parts_master_version_custom_field_group (parts_master_group_uuid);

drop index if exists pmcfg_parts_master_version_id_ix;
create index if not exists pmcfg_parts_master_version_id_ix
  on brs.parts_master_version_custom_field_group (parts_master_version_id);


create table if not exists brs.parts_master_version_custom_field_value
(
  id bigserial primary key,
  parts_master_version_custom_field_group_id bigint
    constraint pmvcfg_parts_master_version_custom_field_group_id_fk
      references brs.parts_master_version_custom_field_group
      on delete cascade,
  custom_field_group_assignment_id bigint
    constraint pmvcfg_parts_master_version_custom_field_group_assignment_fk
      references brs.custom_field_group_assignment,
  value jsonb,
  date_created timestamp with time zone default now() not null,
  date_modified timestamp with time zone default now() not null,
  created_by_id bigint not null references flow."user",
  modified_by_id bigint not null references flow."user",
  constraint parts_master_version_custom_field_value_ux
    unique (parts_master_version_custom_field_group_id, custom_field_group_assignment_id)
);

drop index if exists pmvcfv_custom_field_group_assignment_id_ix;
create index if not exists pmvcfv_custom_field_group_assignment_id_ix
  on brs.parts_master_version_custom_field_value (custom_field_group_assignment_id);

create table if not exists brs.primary_company_parts_master_version
(
  company_id bigint not null primary key
    constraint pcpmv_payroll_id_fk
      references flow.company
    references flow.company,
  version_number integer default 1 not null,
  parts_master_version_id bigint
    constraint pcpmv_parts_master_version_id_fk
      references brs.parts_master_version,
  date_created timestamp with time zone default now() not null,
  date_modified timestamp with time zone default now() not null,
  created_by_id bigint not null
    constraint pcpmv_created_by_id_fk
      references flow."user",
  modified_by_id bigint not null
    constraint pcpmv_modified_by_id_fk
      references flow."user"
);

drop index if exists pcpmv_active_parts_master_version_id_ix;
create index pcpmv_active_parts_master_version_id_ix
  on primary_company_parts_master_version (parts_master_version_id);

drop view if exists brs.parts_master_version_custom_field_value_vw;
create or replace view brs.parts_master_version_custom_field_value_vw as
(
select pmcfv.id,
       pmcfv.custom_field_group_assignment_id,
       pmvcfg.parts_master_group_uuid,
       pmvcfg.parts_master_version_id,
       pmcfv.value,
       cf.id                                       as field_id,
       cf.field_code,
       cf.field_name,
       ot.object_code,
       ot.object_type,
       pmcfv.modified_by_id,
       concat_ws(' ', mu.first_name, mu.last_name) as modified_by,
       pmcfv.date_modified
from brs.parts_master_version_custom_field_value pmcfv
       inner join brs.parts_master_version_custom_field_group pmvcfg
                  on pmcfv.parts_master_version_custom_field_group_id = pmvcfg.id
       inner join brs.parts_master_version pmv on pmvcfg.parts_master_version_id = pmv.id
       inner join brs.custom_field_group_assignment cfga on pmcfv.custom_field_group_assignment_id = cfga.id
       inner join brs.custom_field cf on cfga.custom_field_id = cf.id
       inner join brs.custom_field_group cfg on cfga.custom_field_group_id = cfg.id
       inner join brs.object_type ot on cfg.object_type_id = ot.id
       inner join flow.company_data_type cdt on cf.company_data_type_id = cdt.id
       inner join flow.data_type dt on cdt.data_type_id = dt.id
       inner join flow.user mu on mu.id = pmcfv.modified_by_id
where pmvcfg.archived is null
  );


-- adding the company feature and access levels
insert into flow.feature (feature_name, feature_code)
VALUES ('Parts Master', 'PARTS_MASTER')
ON CONFLICT DO NOTHING;

INSERT INTO flow.company_feature (feature_name, company_id, feature_id)
values ('Parts Master', 3, (select id from flow.feature where feature_code = 'PARTS_MASTER'))
ON CONFLICT DO NOTHING;

INSERT INTO flow.feature_access_control(feature_id, access_control_id, created_by_id, modified_by_id)
VALUES
  ((select id from flow.feature where feature_code = 'PARTS_MASTER'), (select id from flow.access_control where access_code = 'VIEW'), 99999999, 99999999),
  ((select id from flow.feature where feature_code = 'PARTS_MASTER'), (select id from flow.access_control where access_code = 'EDIT'), 99999999, 99999999),
  ((select id from flow.feature where feature_code = 'PARTS_MASTER'), (select id from flow.access_control where access_code = 'MANAGE'), 99999999, 99999999),
  ((select id from flow.feature where feature_code = 'PARTS_MASTER'), (select id from flow.access_control where access_code = 'ADMIN'), 99999999, 99999999)
ON CONFLICT DO NOTHING;
