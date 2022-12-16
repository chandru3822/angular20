alter table brs.proposal_template_block
  add if not exists visibility text;

alter table brs.proposal_template_block
  add if not exists block_uuid uuid not null default uuid_generate_v4();
