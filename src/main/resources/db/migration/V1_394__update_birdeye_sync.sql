alter table if exists brs.birdeye_survey_sync
  rename to birdeye_sync;

alter table if exists brs.birdeye_sync
  rename column survey_id to sync_key;

alter table brs.birdeye_sync
  add if not exists sync_type varchar;

alter table brs.birdeye_sync
  drop constraint birdeye_survey_sync_pkey;

create unique index if not exists birdeye_sync_pkey
  on brs.birdeye_sync (business_id, sync_key, sync_type);

alter index if exists brs.idx_birdeye_survey_sync_last_sync_survey_id rename to idx_birdeye_sync_key;

create index if not exists ids_birdeye_sync_type
  on brs.birdeye_sync (sync_type);

-- update all rows to original/default type
update brs.birdeye_sync
set sync_type = 'surveys';

alter table brs.birdeye_sync
  alter column sync_type set not null;

