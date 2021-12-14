create table if not exists brs.proposal_version_status
(
  id                           int not null primary key,
  proposal_version_status_code varchar(20) unique
);
insert into brs.proposal_version_status (id, proposal_version_status_code)
values (1, 'DRAFT'),
       (2, 'PUBLISHED')
on conflict (id) do nothing;

create table if not exists brs.proposal_version
(
  id                         serial primary key        not null,
  company_id                 int                       not null references flow.company (id),
  version                    varchar(20),
  proposal_version_status_id int                       not null references brs.proposal_version_status (id),
  notes                      text,

  --     audit cols
  date_created               timestamptz DEFAULT now() not null,
  date_modified              timestamptz DEFAULT now() not null,
  created_by_id              int                       not null references flow.user (id),
  modified_by_id             int                       not null references flow.user (id)
);
create index if not exists proposal_version_company_id_ix on brs.proposal_version (company_id);
create index if not exists proposal_version_proposal_version_status_id_ix on brs.proposal_version (proposal_version_status_id);

create table if not exists brs.primary_company_proposal_version
(
  company_id          int         not null primary key references flow.company (id),
  version_number      int         not null default 1,
  proposal_version_id int         null references brs.proposal_version (id),

  --     audit cols
  date_created        timestamptz not null default now(),
  date_modified       timestamptz not null default now(),
  created_by_id       int         not null references flow.user (id),
  modified_by_id      int         not null references flow.user (id)
);
create index if not exists cpc_active_proposal_version_id_ix on brs.primary_company_proposal_version (proposal_version_id);

create table if not exists brs.proposal_version_custom_field_group
(
  id                  serial      not null primary key,
  proposal_version_id int         not null references brs.proposal_version (id),
  proposal_group_uuid UUID        not null,
  archived            timestamptz null,

  --     audit cols
  date_created        timestamptz not null default now(),
  date_modified       timestamptz not null default now(),
  created_by_id       int         not null references flow.user (id),
  modified_by_id      int         not null references flow.user (id)
);


alter table brs.proposal_version_custom_field_group
  drop constraint if exists pvcfg_excl;
alter table brs.proposal_version_custom_field_group
  add constraint pvcfg_excl
    exclude (proposal_version_id with =, proposal_group_uuid with = ) where (archived is null);

create index if not exists pvcfg_proposal_version_id_ix on brs.proposal_version_custom_field_group (proposal_version_id);
create index if not exists pvcfg_proposal_group_uuid_ix on brs.proposal_version_custom_field_group (proposal_group_uuid);

create table if not exists brs.proposal_version_custom_field_value
(
  id                                     serial primary key,
  proposal_version_custom_field_group_id integer     not null
    references brs.proposal_version_custom_field_group (id) on delete cascade,
  custom_field_group_assignment_id       integer     not null
    references brs.custom_field_group_assignment (id),

  value                                  jsonb,

--     audit cols
  date_created                           timestamptz not null default now(),
  date_modified                          timestamptz not null default now(),
  created_by_id                          int         not null references flow.user (id),
  modified_by_id                         int         not null references flow.user (id),

  constraint proposal_version_custom_field_value_ux
    unique (proposal_version_custom_field_group_id, custom_field_group_assignment_id)
);

create table if not exists brs.proposal_status
(
  id                   int primary key not null,
  proposal_status_code varchar(50) unique
);
insert into brs.proposal_status (id, proposal_status_code)
VALUES (1, 'REQUESTED'),
       (2, 'PENDING'),
       (3, 'APPROVED'),
       (4, 'CANCELED')
on conflict (id) do nothing;

alter table brs.object_type
  add if not exists parent_id int;

alter table brs.object_type
  drop constraint if exists object_type_object_type_id_fk;
alter table brs.object_type
  add constraint object_type_object_type_id_fk
    foreign key (parent_id) references brs.object_type;

create unique index if not exists object_type_ux on brs.object_type (object_code);
create index if not exists object_type_parent_id_ix on brs.object_type (parent_id);

-- insert into brs.object_type (object_type, object_code)
-- VALUES ('Proposal', 'PROPOSAL')
-- on conflict (object_code) do nothing;

insert into brs.object_type (object_type, object_code, parent_id)
VALUES ('Proposal Pricing', 'PROPOSAL_PRICING', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Rebates', 'PROPOSAL_REBATE', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Zone Adders', 'PROPOSAL_ZONE_ADDERS', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Financiers', 'PROPOSAL_FINANCIERS', (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Finance Products', 'PROPOSAL_FINANCE_PRODUCTS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Equipment Adders', 'PROPOSAL_EQUIPMENT_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Miscellaneous Adders', 'PROPOSAL_MISC_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL')),
       ('Proposal Source & State Adders', 'PROPOSAL_SOURCE_STATE_ADDERS',
        (select id from brs.object_type where object_code = 'PROPOSAL'))
on conflict (object_code) do nothing;

alter table brs.custom_field
  add column if not exists custom_field_sql_key varchar(100);
alter table brs.custom_field
  add column if not exists custom_field_sql_reference_table varchar(100);
