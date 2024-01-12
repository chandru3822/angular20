alter table brs.cached_appointment add column if not exists schedule_date date;
alter table brs.cached_appointment drop constraint if exists  user_id_uk;
create index if not exists  cached_appointment_user_id_idx
  on brs.cached_appointment (user_id);

create index if not exists cached_appointment_schedule_date_idx
  on brs.cached_appointment (schedule_date);

create unique index if not exists cached_appointment_user_id_schedule_date_idx
  on brs.cached_appointment (user_id,schedule_date);
