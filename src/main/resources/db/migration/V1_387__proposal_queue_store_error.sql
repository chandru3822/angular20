alter table brs.proposal
  add if not exists error_msg text;

comment on column brs.proposal.error_msg is 'Shows error that occurred while locking the proposal or generating the PDF';
