ALTER TABLE if exists flow.sms_reply
ADD COLUMN if not exists media_urls text[];
