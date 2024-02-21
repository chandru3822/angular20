alter table if exists flow.user_announcement
add column if not exists message_alerted_tsz timestamptz;
