alter table brs.permit_pack_log_history
  add column if not exists mixed_orientation_arrays varchar;
