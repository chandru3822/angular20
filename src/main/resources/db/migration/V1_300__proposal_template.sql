drop table if exists brs.proposal_template_block_type cascade;
drop table if exists brs.proposal_theme cascade;
drop table if exists brs.proposal_theme_value cascade;
drop table if exists brs.proposal_template cascade;
drop table if exists brs.proposal_template_block cascade;

--migration
create table if not exists brs.proposal_template_block_type
(
  id           integer primary key not null,
  block_type   varchar(100)        not null,
  date_created timestamptz         not null default now()
);

insert into brs.proposal_template_block_type (id, block_type)
values (1, 'PageBlock'),
       (2, 'ContainerBlock'),
       (3, 'TextBlock'),
       (4, 'ImageBlock');

create table if not exists brs.proposal_theme
(
  id             serial primary key not null,
  theme_name     varchar(100)       not null,

  created_by_id  integer references flow."user" (id),
  date_created   timestamptz        not null default now(),
  modified_by_id integer references flow."user" (id),
  date_modified  timestamptz        not null default now()
);

insert into brs.proposal_theme(theme_name)
values ('BRS Default');

create table if not exists brs.proposal_theme_value
(
  id                serial primary key not null,
  proposal_theme_id integer            not null references brs.proposal_theme (id),
  theme_key         varchar(100)       not null,
  theme_value       jsonb              not null,

  created_by_id     integer references flow."user" (id),
  date_created      timestamptz        not null default now(),
  modified_by_id    integer references flow."user" (id),
  date_modified     timestamptz        not null default now(),

  unique (proposal_theme_id, theme_key)
);
create index ptv_proposal_theme_id_ix on brs.proposal_theme_value (proposal_theme_id);

create table if not exists brs.proposal_template
(
  id                serial primary key not null,
  template_name     varchar(100)       not null,
  proposal_theme_id integer references brs.proposal_theme (id),

  created_by_id     integer references flow."user" (id),
  date_created      timestamptz        not null default now(),
  modified_by_id    integer references flow."user" (id),
  date_modified     timestamptz        not null default now()
);
create index pt_proposal_theme_id_ix on brs.proposal_template (proposal_theme_id);

insert into brs.proposal_template (template_name, proposal_theme_id)
values ('BRS Default', 1);

create table if not exists brs.proposal_template_block
(
  id                              serial primary key not null,
  proposal_template_id            integer            not null
    references brs.proposal_template (id),
  proposal_theme_value_id         integer
    references brs.proposal_theme_value (id),
  proposal_template_block_type_id integer            not null
    references brs.proposal_template_block_type (id),
  block_style                     jsonb,
  block_value                     jsonb,
  block_order                     integer            not null default 0,
  version                         integer            not null default 0,
  parent_id                       integer
    references brs.proposal_template_block (id)      null,
  date_archived                   timestamptz,
  created_by_id                   integer references flow."user" (id),
  date_created                    timestamptz        not null default now(),
  modified_by_id                  integer references flow."user" (id),
  date_modified                   timestamptz        not null default now()
);

create index ptb_proposal_template_id_ix on brs.proposal_template_block (proposal_template_id);
create index ptb_version_ix on brs.proposal_template_block (version);
create index ptb_parent_id_ix on brs.proposal_template_block (parent_id);
create index ptb_proposal_theme_value_id_ix on brs.proposal_template_block (proposal_theme_value_id);
create index ptb_proposal_template_block_type_id_ix on brs.proposal_template_block (proposal_template_block_type_id);

--initial theme
insert into brs.proposal_theme_value(proposal_theme_id, theme_key, theme_value)
values (1, 'page', '{"display": "flex", "flexDirection": "column"}'::jsonb),
       (1, 'title', '{"textTransform": "uppercase"}'::jsonb),
       (1, 'footer', '{"fontSize": "10px"}'::jsonb);
