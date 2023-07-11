alter table flow.sms_queue
add column if not exists priority integer default 5 not null;

-- 1 - project and contacts
-- 2 - direct user stuff john is doing
-- 3 - mentions in notes
-- 4 - user "mass text" feature but fewer than 10 users
-- 5 - more than 10 users at a time
