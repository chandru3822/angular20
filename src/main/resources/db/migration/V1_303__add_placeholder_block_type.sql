create unique index ptbt_uq
  on brs.proposal_template_block_type (upper(block_type));

insert into brs.proposal_template_block_type (id, block_type)
values (5, 'PlaceholderBlock');

create table if not exists brs.proposal_template_block_kind
(
  id           integer primary key,
  block_kind   varchar(100),
  date_created timestamptz not null default now()
);

create unique index ptbk_uq on brs.proposal_template_block_kind (upper(block_kind));

insert into brs.proposal_template_block_kind (id, block_kind)
values (1, '2D_PROPOSAL_IMAGE'),
       (2, '3D_PROPOSAL_IMAGE');

alter table brs.proposal_template_block
  add column proposal_template_block_kind_id integer references brs.proposal_template_block_kind (id);

