alter table flow.user_company
    add column  if not exists default_appointment_length int;

alter table flow.org
    add column if not exists default_appointment_length int;
