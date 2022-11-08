create table if not exists brs.birdeye_survey_sync
(
  business_id         varchar not null,
  survey_id           varchar not null,
  last_sync_timestamp timestamptz,
  primary key (business_id, survey_id)
);
create index if not exists idx_birdeye_survey_sync_last_sync_survey_id on brs.birdeye_survey_sync (survey_id);
