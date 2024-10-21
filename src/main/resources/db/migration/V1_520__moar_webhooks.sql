create table if not exists flow.message_queue_topics
(
  id    bigint generated always as identity primary key,
  topic text not null
);

create unique index if not exists mqt_topic_uidx
  on flow.message_queue_topics (topic);

insert into flow.message_queue_topics (topic) values ('webhook:project_milestone') on conflict do nothing;

do $$
  begin
    if !exists(
      select column_name
      from information_schema.columns
      where
        table_schema = 'flow' and
        table_name = 'message_queue' and
        column_name = 'topic'
    )
    then
      alter table if exists flow.message_queue rename column topic to topic_id;
      alter table if exists flow.message_queue alter column topic_id type bigint using topic_id::bigint;
    end if;
  end
$$;

alter table if exists flow.message_queue drop constraint if exists mq_topic_id__fk;
alter table if exists flow.message_queue
  add constraint mq_topic_id__fk
    foreign key (topic_id) references flow.message_queue_topics;


do $$
  begin
    if !exists(
      select column_name
      from information_schema.columns
      where
        table_schema = 'flow' and
        table_name = 'message_queue_log' and
        column_name = 'topic'
    )
    then
      alter table if exists flow.message_queue_log rename column topic to topic_id;
      alter table if exists flow.message_queue_log alter column topic_id type bigint using topic_id::bigint;
    end if;
  end
$$;

alter table if exists flow.message_queue_log drop constraint if exists mql_topic_id__fk;
alter table if exists flow.message_queue_log
  add constraint mql_topic_id__fk
    foreign key (topic_id) references flow.message_queue_topics;