insert into flow.feature(feature_name, feature_code, feature_path)
values ('SMS Queue', 'SMS_QUEUE', '/smsQueue');

insert into flow.company_feature(feature_name, company_id, feature_id, home_page)
values ('SMS Queue', 3, (select id from flow.feature where feature_code = 'SMS_QUEUE'), true);

alter table if exists flow.sms_queue add if not exists priority boolean default false not null;
alter table if exists flow.sms_queue add if not exists message_read boolean default false not null;
alter table if exists flow.sms_queue add if not exists owner_user_position_id integer;
alter table if exists flow.sms_queue add if not exists message_sent_by_user_id integer;

alter table if exists flow.position add if not exists sms_owner boolean default false not null;
