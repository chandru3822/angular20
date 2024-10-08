package com.albatross.api.queue;

public class QueueQuery {

  //language=PostgreSQL
  public final static String enqueue = """
    insert into flow.message_queue(topic, payload, created_by)
    values (:topic, :payload::jsonb, :createdBy)
    returning *
  """;

  //language=PostgreSQL
  public final static String dequeue = """
    delete from flow.message_queue
    where message_id = (
      select message_id
      from flow.message_queue
      where
        topic = :topic and
        status = any(array['new', 'retry'])
      order by date_created
        for update skip locked
      limit 1
    )
    returning *
  """;

  //language=PostgreSQL
  public final static String requeue = """
    insert into flow.message_queue(message_id, status, topic, payload, attempt, created_by)
    values (:messageId, :status, :topic, :payload::jsonb, :attempt, :createdBy)
    returning *
  """;
}
