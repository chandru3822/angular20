insert into flow.notification_topic (id, topic_key)
values (3, 'sms_ownership')
on conflict (id) do nothing;
