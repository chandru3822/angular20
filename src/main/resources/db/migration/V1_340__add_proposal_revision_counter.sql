alter table brs.proposal
  alter column id type bigint;
alter table brs.proposal_custom_field_value
  alter column proposal_id type bigint;

create table if not exists brs.proposal_revision_number
(
  proposal_id     bigserial not null primary key references brs.proposal (id),
  revision_number integer   not null default 0
);

comment on table brs.proposal_revision_number is 'Keep track of the number of revisions for a given proposal ID to generate display name';

alter table brs.proposal
  add column if not exists revision_number int not null default 0;

alter table brs.proposal
  add column if not exists original_proposal_id bigint null references brs.proposal (id);
comment on column brs.proposal.original_proposal_id is 'Proposal ID of the original proposal that has been duplicated not necessarily the direct predecessor (internal use only).'
