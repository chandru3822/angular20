alter table flow.note
  add column if not exists follow_up_date date;
