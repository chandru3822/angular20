alter table flow.email_queue
add column if not exists attachment_ids bigint[];
