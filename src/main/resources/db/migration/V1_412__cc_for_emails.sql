alter table flow.email_queue add column if not exists cc_recipients varchar(255);
