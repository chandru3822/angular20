alter table brs.proposal_log_history
  add column if not exists solar_below_the_line_rebates varchar(100);
