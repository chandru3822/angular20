alter table brs.proposal
  add column if not exists name varchar(255);

comment on column brs.proposal.name is 'friendly name to associate with the project';

alter table brs.proposal
  add column if not exists credit_check_submitted_tsz timestamptz;
comment on column brs.proposal.credit_check_submitted_tsz is 'initial date credit check was submitted';

alter table brs.proposal
  add column if not exists finance_docs_sent_tsz timestamptz;
comment on column brs.proposal.finance_docs_sent_tsz is 'initial date finance docs was sent';

alter table brs.proposal
  add column if not exists installation_agreement_sent_tsz timestamptz;
comment on column brs.proposal.installation_agreement_sent_tsz is 'initial date installation agreement was sent';

alter table brs.proposal
  add column if not exists proposal_nbr int not null default nextval('brs.proposal_excel_id_seq');

alter table brs.proposal
  add column if not exists locked_tsz timestamptz;

comment on column brs.proposal.locked_tsz is 'indicates when the proposal was locked';

alter table brs.proposal
  add column if not exists processed_tsz timestamptz;

comment on column brs.proposal.processed_tsz is 'indicates when the proposal pdf was generated';

