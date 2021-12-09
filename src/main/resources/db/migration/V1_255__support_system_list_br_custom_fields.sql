alter table brs.custom_field
  add if not exists company_system_list_id int;

alter table brs.custom_field
  add if not exists system_list_option_ids int[];

alter table brs.custom_field
  drop constraint if exists brs_custom_field_company_system_list_id_fk;

alter table brs.custom_field
  add constraint brs_custom_field_company_system_list_id_fk
    foreign key (company_system_list_id) references flow.company_system_list;

create index if not exists brs_cf_company_system_list_id_ix
  on brs.custom_field (company_system_list_id);
