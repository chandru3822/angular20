--drop table brs.birdeye_survey;
create table if not exists brs.birdeye_survey
(
  id                    serial primary key,
  birdeye_survey_id     varchar                                        not null,
  custom_field_group_id bigint references flow.custom_field_group (id) not null,
  enabled               boolean                                        not null default true,
  date_modified         timestamptz                                    not null default now()
);

comment on table brs.birdeye_survey is 'Stores which surveys are enabled for BirdEye sync';

create index if not exists idx_birdeye_survey_id on brs.birdeye_survey (birdeye_survey_id) where (enabled is true);
create index if not exists idx_custom_field_group_id on brs.birdeye_survey (custom_field_group_id);
