-- we use priority_level now
alter table flow.sms_queue
drop column if exists priority;
