alter table flow.import_sp_project
  add column if not exists _snapshot jsonb;
comment on column flow.import_sp_project._snapshot is 'store a copy of the data SunPower is interested in so we can send only updates';

alter table flow.import_sp_project
  add column if not exists _snapshot_date_updated timestamptz;
comment on column flow.import_sp_project._snapshot_date_updated is 'last time the columns were updated via a diff';

alter table flow.import_sp_project
  add column if not exists _snapshot_error_message text;
comment on column flow.import_sp_project._snapshot_error_message is 'last message received while updating'
