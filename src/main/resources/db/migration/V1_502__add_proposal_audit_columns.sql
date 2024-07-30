alter table brs.proposal
  add if not exists locked_by_id bigint references flow."user" (id);
comment on column brs.proposal.locked_by_id is 'user that locked the proposal';

alter table brs.proposal
  add if not exists credit_check_submitted_by_id bigint references flow."user" (id);
comment on column brs.proposal.credit_check_submitted_by_id is 'user that submitted the credit check for the proposal';

alter table brs.proposal
  add if not exists finance_docs_sent_by_id bigint references flow."user" (id);
comment on column brs.proposal.finance_docs_sent_by_id is 'user that sent the finance docs for the proposal';

alter table brs.proposal
  add if not exists installation_agreement_sent_by_id bigint references flow."user" (id);
comment on column brs.proposal.installation_agreement_sent_by_id is 'user that sent the installation agreement for the proposal';
