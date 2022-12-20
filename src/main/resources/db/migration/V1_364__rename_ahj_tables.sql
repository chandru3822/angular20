ALTER TABLE IF EXISTS brs.ahj
  RENAME TO feat_db_ahj;

ALTER TABLE IF EXISTS brs.ahj_contact
  RENAME TO feat_db_contact;

ALTER TABLE IF EXISTS brs.ahj_contact_type
  RENAME TO feat_db_contact_type;

ALTER TABLE IF EXISTS brs.ahj_design
  RENAME TO feat_db_ahj_design;

ALTER TABLE IF EXISTS brs.ahj_design_custom_field_value
  RENAME TO feat_db_ahj_design_custom_field_value;

ALTER TABLE IF EXISTS brs.ahj_design_custom_field_value_audit
  RENAME TO feat_db_ahj_design_custom_field_value_audit;

ALTER TABLE IF EXISTS brs.ahj_hoa
  RENAME TO feat_db_hoa;

ALTER TABLE IF EXISTS brs.ahj_hoa_contact
  RENAME TO feat_db_hoa_contact;

alter table brs.feat_db_hoa_contact
  RENAME COLUMN ahj_hoa_id TO hoa_id;

alter table brs.feat_db_hoa_contact
  RENAME COLUMN ahj_contact_id TO feat_db_contact_id;

ALTER TABLE IF EXISTS brs.ahj_hoa_custom_field_value
  RENAME TO feat_db_hoa_custom_field_value;

alter table brs.feat_db_hoa_custom_field_value
  RENAME COLUMN ahj_hoa_id to hoa_id;

ALTER TABLE IF EXISTS brs.ahj_hoa_custom_field_value_audit
  RENAME TO feat_db_hoa_custom_field_value_audit;

alter table brs.feat_db_hoa_custom_field_value_audit
  RENAME COLUMN ahj_hoa_custom_field_value_id TO hoa_custom_field_value_id;

ALTER TABLE IF EXISTS brs.ahj_hoa_link
  RENAME TO feat_db_hoa_link;

alter table brs.feat_db_hoa_link
  RENAME COLUMN ahj_hoa_id TO hoa_id;

ALTER TABLE IF EXISTS brs.ahj_inspection
  RENAME TO feat_db_ahj_inspection;

ALTER TABLE IF EXISTS brs.ahj_inspection_contact
  RENAME TO feat_db_ahj_inspection_contact;

ALTER TABLE IF EXISTS brs.ahj_inspection_custom_field_value
  RENAME TO feat_db_ahj_inspection_custom_field_value;

ALTER TABLE IF EXISTS brs.ahj_inspection_custom_field_value_audit
  RENAME TO feat_db_ahj_inspection_custom_field_value_audit;

ALTER TABLE IF EXISTS brs.ahj_inspection_link
  RENAME TO feat_db_ahj_inspection_link;

ALTER TABLE IF EXISTS brs.ahj_link_type
  RENAME TO feat_db_link_type;

ALTER TABLE IF EXISTS brs.ahj_permit
  RENAME TO feat_db_ahj_permit;

ALTER TABLE IF EXISTS brs.ahj_permit_contact
  RENAME TO feat_db_ahj_permit_contact;

ALTER TABLE IF EXISTS brs.ahj_permit_custom_field_value
  RENAME TO feat_db_ahj_permit_custom_field_value;

ALTER TABLE IF EXISTS brs.ahj_permit_custom_field_value_audit
  RENAME TO feat_db_ahj_permit_custom_field_value_audit;

ALTER TABLE IF EXISTS brs.ahj_permit_link
  RENAME TO feat_db_ahj_permit_link;

ALTER TABLE IF EXISTS brs.ahj_utility
  RENAME TO feat_db_utility;

ALTER TABLE IF EXISTS brs.ahj_utility_contact
  RENAME TO feat_db_utility_contact;

alter table brs.feat_db_utility_contact
  RENAME COLUMN ahj_utility_id TO utility_id;

alter table brs.feat_db_utility_contact
  RENAME COLUMN ahj_contact_id TO feat_db_contact_id;

ALTER TABLE IF EXISTS brs.ahj_utility_custom_field_value
  RENAME TO feat_db_utility_custom_field_value;

alter table brs.feat_db_utility_custom_field_value
  RENAME COLUMN ahj_utility_id to utility_id;

alter table brs.feat_db_utility_custom_field_value
  RENAME COLUMN ahj_utility_id TO utility_id;

ALTER TABLE IF EXISTS brs.ahj_utility_custom_field_value_audit
  RENAME TO feat_db_utility_custom_field_value_audit;

alter table brs.feat_db_utility_custom_field_value_audit
  RENAME COLUMN ahj_utility_custom_field_value_id TO utility_custom_field_value_id;

ALTER TABLE IF EXISTS brs.ahj_utility_link
  RENAME TO feat_db_utility_link;

alter table brs.feat_db_utility_link
  RENAME COLUMN ahj_utility_id TO utility_id;

update flow.feature
set feature_path = '/database/ahj'
where feature_code = 'AHJ_DATABASE';

DROP FUNCTION IF EXISTS brs.get_brs_ahj_cfv(p_project_id bigint, p_brs_ahj_table character varying, p_brs_ahj_cf_id bigint, p_expected_value character varying);

--rename audit stuff
drop function if exists brs.ahj_utility_audit();
drop trigger if exists ahj_utility_custom_field_value_audit_trg ON brs.feat_db_utility_custom_field_value;

drop function if exists brs.ahj_hoa_audit();
drop trigger if exists ahj_hoa_custom_field_value_audit_trg ON brs.feat_db_hoa_custom_field_value;
