alter table brs.custom_field
  add if not exists lazy_load_values bool default false not null;
