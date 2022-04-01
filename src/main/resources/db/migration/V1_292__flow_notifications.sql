create table if not exists flow.notification_topic
(
  id           int primary key not null,
  topic_key    varchar(200)    not null unique,
  date_created timestamptz     not null default now()
);

insert into flow.notification_topic (id, topic_key)
values (1, 'ping'),
       (2, 'sms_reply')
on conflict (id) do nothing;

create table if not exists flow.notification
(
  id                    bigserial primary key not null,
  user_id               integer               not null references flow."user" (id),
  notification_topic_id integer               not null references flow.notification_topic (id),
  title                 varchar(100),
  body                  text                  not null,
  priority              numeric               not null default 0
    check ( priority >= 0 and priority <= 100 ),
  metadata              jsonb,
  message_read_tsz      timestamptz,

  created_by_id         integer references flow."user" (id),
  date_created          timestamptz           not null default now(),
  modified_by_id        integer references flow."user" (id),
  date_modified         timestamptz           not null default now()
);

comment on column flow.notification.user_id is 'The user for which the notification is intended';

create index if not exists flow_notification_notification_topic_id_ix on flow.notification (notification_topic_id);
create index if not exists flow_notification_unread_ix on flow.notification (user_id) where message_read_tsz is null;

