alter table flow.process_step
add column if not exists non_admin_add boolean not null default false;
