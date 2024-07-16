-- UPDATE AHJ
alter table if exists brs.feat_db_ahj
  add column if not exists active boolean not null DEFAULT false;

update brs.feat_db_ahj
set active = not archived;

-- UPDATE UTILITY
alter table if exists brs.feat_db_utility
  add column if not exists active boolean not null DEFAULT false;

update brs.feat_db_utility
  set active = not archived;

-- UPDATE HOA
alter table if exists brs.feat_db_hoa
  add column if not exists active boolean not null DEFAULT false;

update brs.feat_db_hoa
  set active = not archived;

-- UPDATE SUPPLIER
alter table if exists brs.feat_db_supplier
  add column if not exists active boolean not null DEFAULT false;

update brs.feat_db_supplier
  set active = not archived;

-- UPDATE INCENTIVE
alter table if exists brs.feat_db_incentive
  add column if not exists active boolean not null DEFAULT false;

update brs.feat_db_incentive
  set active = not archived;

-- SET ACTIVE COLUMNS
update brs.feat_db_ahj
set archived = false,
    active = false
where archived = true and name not ilike '%test%';

update brs.feat_db_utility
set archived = false,
    active = false
where archived = true and name not ilike '%test%';

update brs.feat_db_hoa
set archived = false,
    active = false
where archived = true and name not ilike '%test%';

update brs.feat_db_supplier
set archived = false,
    active = false
where archived = true and name not ilike '%test%';

update brs.feat_db_incentive
set archived = false,
    active = false
where archived = true and name not ilike '%test%';

-- UPDATE CUSTOM FIELDS WITH CUSTOM SQL REFERENCING THE DATABASES
UPDATE flow.custom_field
SET custom_field_sql = REPLACE(custom_field_sql, 'archived is not true', 'active is true')
WHERE custom_field_sql IS NOT NULL AND custom_field_sql ILIKE '%feat_db_%' AND archived = FALSE;

-- SET ACTIVE = FALSE WHEN ARCHIVED IS TRUE
UPDATE brs.feat_db_ahj
SET active = false
WHERE archived = true;

UPDATE brs.feat_db_utility
SET active = false
WHERE archived = true;

UPDATE brs.feat_db_hoa
SET active = false
WHERE archived = true;

UPDATE brs.feat_db_supplier
SET active = false
WHERE archived = true;

UPDATE brs.feat_db_incentive
SET active = false
WHERE archived = true;

