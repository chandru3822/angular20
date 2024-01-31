alter table if exists brs.feat_db_incentive add column if not exists type_id BIGINT default null;
alter table if exists brs.feat_db_incentive add column if not exists status_id BIGINT default null;
