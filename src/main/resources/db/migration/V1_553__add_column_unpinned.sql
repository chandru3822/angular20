alter table flow.project_activity
  add column if not exists unpinned boolean not null default false;
