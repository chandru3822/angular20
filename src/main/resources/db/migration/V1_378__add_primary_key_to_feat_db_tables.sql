alter table brs.feat_db_ahj_inspection_contact
  drop constraint if exists ahj_inspection_contact_ahj_inspection_id_ahj_contact_id_key;

alter table brs.feat_db_ahj_inspection_contact
  add constraint ahj_inspection_contact_ahj_inspection_id_ahj_contact_id_key
    primary key (ahj_inspection_id, ahj_contact_id);

alter table brs.feat_db_ahj_permit_contact
  drop constraint if exists ahj_permit_contact_ahj_permit_id_ahj_contact_id_key;

alter table brs.feat_db_ahj_permit_contact
  add constraint ahj_permit_contact_ahj_permit_id_ahj_contact_id_key
    primary key (ahj_permit_id, ahj_contact_id);

alter table brs.feat_db_hoa_contact
  drop constraint if exists ahj_hoa_contact_ahj_hoa_id_ahj_contact_id_key;

alter table brs.feat_db_hoa_contact
  add constraint ahj_hoa_contact_ahj_hoa_id_ahj_contact_id_key
    primary key (hoa_id, feat_db_contact_id);

alter table brs.feat_db_utility_contact
  drop constraint if exists ahj_utility_contact_ahj_utility_id_ahj_contact_id_key;

alter table brs.feat_db_utility_contact
  add constraint ahj_utility_contact_ahj_utility_id_ahj_contact_id_key
    primary key (utility_id, feat_db_contact_id);

