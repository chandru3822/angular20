alter table flow."user"
  add column if not exists test_user boolean not null default false;
