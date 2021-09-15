alter table brs.proposal_log_history
  alter column date_created type date using date_created::date;
