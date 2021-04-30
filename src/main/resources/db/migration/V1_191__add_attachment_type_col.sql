alter table flow.project_attachment_type add column if not exists read_only boolean default false;
