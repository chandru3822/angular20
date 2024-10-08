-- actual queue
create table if not exists flow.message_queue
(
  id           bigint generated always as identity primary key,
  message_id   uuid        default uuid_generate_v4() not null,
  status       varchar(50) default 'new'              not null,
  topic        varchar(128)                           not null,
  attempt      integer     default 1                  not null,
  payload      jsonb,
  date_created timestamp   default now()              not null,
  created_by   bigint                                 not null
    constraint mq_created_by_id__fk
      references flow."user"
);

create unique index mq_message_id_idx
  on flow.message_queue (message_id);

create index mq_status_topic_created_idx
  on flow.message_queue (status asc, topic asc, date_created desc);

create index mq_topic_idx
  on flow.message_queue (topic);


-- queue log
create table if not exists flow.message_queue_log
(
  id           bigint generated always as identity primary key,
  message_id   uuid                    not null,
  action       varchar(50)             not null,
  status       varchar(50)             not null,
  topic        varchar(128)            not null,
  attempt      integer                 not null,
  payload      jsonb,
  date_created timestamp default now() not null,
  created_by   bigint                  not null
    constraint mql_created_by_id__fk
      references flow."user"
);

create index mql_message_id_idx
  on flow.message_queue_log (message_id);
