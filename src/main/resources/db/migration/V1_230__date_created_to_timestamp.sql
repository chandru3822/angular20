alter table brs.proposal_log_history
  alter column date_created type timestamp using date_created::timestamp;
