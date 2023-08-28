alter table brs.permit_pack_log_history
  add column if not exists mixed_mounting_hardware varchar;
alter table brs.permit_pack_log_history
  add column if not exists home_is_3_stories varchar;
alter table brs.permit_pack_log_history
  add column if not exists conduit_type varchar;
alter table brs.permit_pack_log_history
  add column if not exists module_part_number varchar;
alter table brs.permit_pack_log_history
  add column if not exists interconnection_interior_exterior varchar;
alter table brs.permit_pack_log_history
  add column if not exists interconnection_supply_side_load_side varchar;
alter table brs.permit_pack_log_history
  add column if not exists interconnection_method varchar;
alter table brs.permit_pack_log_history
  add column if not exists point_of_interconnection varchar;
alter table brs.permit_pack_log_history
  add column if not exists non_standard_interconnection_items varchar;

