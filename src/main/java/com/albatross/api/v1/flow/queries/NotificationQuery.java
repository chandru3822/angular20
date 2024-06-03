package com.albatross.api.v1.flow.queries;

public class NotificationQuery {

  //language=PostgreSQL
  public final static String findByIds = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where id = any (:ids::bigint[])
    """;

  //language=PostgreSQL
  public final static String getUnreadByUserPageable = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where message_read_tsz is null
      and user_id = :userId
    order by priority desc, date_created desc
    limit :limit offset :offset
    """;

  //language=PostgreSQL
  public final static String getUnreadByUser = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where message_read_tsz is null
      and user_id = :userId
    order by priority desc, date_created desc
    """;

  //language=PostgreSQL
  public final static String getUnreadProjectNotificationsByUser = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where message_read_tsz is null
      and user_id = :userId
      and (metadata->>'projectId') is not null
    order by priority desc, date_created desc
    """;

  //language=PostgreSQL
  public final static String getUnreadUserNotificationsByUser = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where message_read_tsz is null
      and user_id = :userId
      and (metadata->>'userId') is not null
    order by priority desc, date_created desc
    """;

  //language=PostgreSQL
  public final static String getUnreadByUserCount = """
    select count(1) from flow.notification where message_read_tsz is null and user_id = :userId
    """;

  //language=PostgreSQL
  public final static String getUnreadByUserAfterId = """
    select id, user_id, notification_topic_id, title, body, priority, metadata, message_read_tsz
    from flow.notification
    where message_read_tsz is null
      and user_id = :userId
      and id > :afterId
    order by priority asc, date_created desc
    """;

  //language=PostgreSQL
  public final static String markAsRead = """
    update flow.notification
    set message_read_tsz   = now(),
        date_modified  = now(),
        modified_by_id = :modifiedById
    where id = any (:ids::bigint[])
      and user_id = :userId
    """;

  //language=PostgreSQL
  public final static String getAllUnprocessedPushNotifications = """
    select *
    from flow.push_notification_queue pnq
    where pnq.processed is false
  """;

  //language=PostgreSQL
  public final static String markPushNotificationProcessed = """
    update flow.push_notification_queue pnq
      set processed = true,
      date_modified = now(),
      date_processed = now()
    where pnq.id = :id
  """;

}
