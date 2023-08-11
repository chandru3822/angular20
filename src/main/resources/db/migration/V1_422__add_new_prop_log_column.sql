alter table brs.proposal_log_history
  add column if not exists negotiated_discount_amount varchar(100);
