package com.albatross.api.v1.flow.queries;

public class SmsServiceQuery {

  //language=PostgreSQL
  public final static String fetchByProjectId = """
    SELECT sms.message,
           array_to_json(sms.media_urls) AS media_urls,
           created,
           sms.from_phone,
           sms.recipient_type_id,
           sms.message_sent_by_user_id   as user_id,
           case
               when u.first_name is not null or u.last_name is not null then concat(u.first_name, ' ', u.last_name::text)
               end                       as full_name
    FROM flow.sms_queue sms
             inner join flow.user u on sms.message_sent_by_user_id = u.id
             inner join flow.contact c on c.search_phones = sms.search_to_phone and c.archived is false
             inner join flow.project p on c.id = p.contact_id and p.id = :projectId and p.archived is false
        AND (error_message IS NULL OR
             (LOWER(error_message) IN
              ('api.twilio.com:443 failed to respond') AND
                 -- so we don't retry very very old texts
              created >= '2017-11-08'
                 ))
        AND sms.recipient_type_id = 2
    UNION ALL
    SELECT body          as message,
           array_to_json(media_urls),
           date_received as created,
           from_phone,
           1             as recipient_type_id,
           null::bigint     as user_id,
           null::text    as full_name
    from flow.sms_reply sr
             inner join flow.contact c on c.search_phones = sr.search_from_phone and c.archived is false
             inner join flow.project p on c.id = p.contact_id and p.id = :projectId and p.archived is false
        where sr.to_phone = '+18014480212'
    ORDER BY created ASC
        """;

  //language=PostgreSQL
  public final static String fetchByUserId = """
    SELECT sms.message,
           array_to_json(sms.media_urls) AS media_urls,
           created,
           sms.from_phone,
           sms.recipient_type_id,
           sms.message_sent_by_user_id   as user_id,
           case
               when u.first_name is not null or u.last_name is not null then concat(u.first_name, ' ', u.last_name::text)
               end                       as full_name
    FROM flow.sms_queue sms
             inner join flow.user u on sms.message_sent_by_user_id = u.id
        AND (error_message IS NULL OR
             (LOWER(error_message) IN
              ('api.twilio.com:443 failed to respond') AND
                 -- so we don't retry very very old texts
              created >= '2017-11-08'
                 ))
        AND sms.search_to_phone = (select u2.search_phone from flow.user u2 where u2.id = :userId)
        AND sms.recipient_type_id = 1
    UNION ALL
    SELECT body          as message,
           array_to_json(media_urls),
           date_received as created,
           from_phone,
           1             as recipient_type_id,
           null::bigint     as user_id,
           null::text    as full_name
    from flow.sms_reply sr
    where sr.search_from_phone = (select u3.search_phone from flow.user u3 where u3.id = :userId)
          AND sr.to_phone = '+18014480029'
    ORDER BY created ASC
        """;

  //language=PostgreSQL
  public final static String insert = """
    WITH sq AS (INSERT INTO flow.sms_queue (
                           message_group,user_id,contact_id, project_id, message,media_urls,to_phone,recipient_type_id,message_sent_by_user_id,sms_team_id, priority_level
                ) VALUES (
                           :messageGroup,:userId,:contactId, :projectId,:message,:mediaUrls,:toPhone,:recipientTypeId,:messageSentByUserId,:sentBySmsTeamId, :priorityLevel
                         )
                RETURNING id,user_id,contact_id, project_id,message,media_urls,
                  message_group,message_sid,message_status,error_message,
                  from_phone,to_phone,twilio_created,twilio_sent,twilio_delivered,
                  updated,created,recipient_type_id, message_sent_by_user_id, sms_team_id)
              SELECT sq.id,
                     sq.user_id,
                     sq.contact_id,
                     sq.project_id,
                     sq.message,
                     array_to_json(sq.media_urls)       AS media_urls,
                     sq.message_group,
                     sq.message_sid,
                     sq.message_status,
                     sq.error_message,
                     sq.from_phone,
                     sq.to_phone,
                     sq.twilio_created,
                     sq.twilio_sent,
                     sq.twilio_delivered,
                     sq.updated,
                     sq.created,
                     sq.recipient_type_id,
                     sq.message_sent_by_user_id,
                     sq.sms_team_id
              FROM sq
        """;

  //language=PostgreSQL
  public final static String next = """
    SELECT
                  sms.id,
                  sms.user_id,
                  sms.message,
                  array_to_json(sms.media_urls) AS media_urls,
                  sms.recipient_type_id,
                  sms.error_message,
                  sms.message_group,
                  sms.message_sid,
                  sms.message_status,
                  sms.from_phone,
                  sms.to_phone,
                  sms.twilio_created,
                  sms.twilio_sent,
                  sms.twilio_delivered,
                  sms.updated,
                  sms.created
                FROM flow.sms_queue sms
                WHERE message_sid IS NULL
                      AND sms.to_phone IS NOT NULL
                      AND (
                        error_message IS NULL OR (
                          LOWER(error_message) IN (
                            'api.twilio.com:443 failed to respond'
                          ) AND

                          -- so we don't retry very very old texts
                          created >= '2017-11-08'
                        )
                      )
                ORDER BY sms.priority_level, sms.created ASC
                LIMIT 10
                FOR UPDATE SKIP LOCKED
        """;

  //language=PostgreSQL
  public final static String updateById = """
            UPDATE flow.sms_queue
            SET
                message_sid = :messageSid,
                message_status = :messageStatus,
                from_phone = :fromPhone,
                error_message = :errorMessage,
                twilio_created = :created,
                updated = now()
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String updateByMessageSid = """
    UPDATE flow.sms_queue SET
                  updated          = now(),
                  from_phone       = :fromPhone,
                  error_message    = :errorMessage,
                  message_status   = (
                    -- don't set the message status to a previous state (for updates that
                    -- arrive out of order)
                    CASE
                    WHEN :messageStatus = 'queued' AND message_status IN ('sent', 'delivered')
                      THEN message_status
                    WHEN :messageStatus = 'sent' AND message_status = 'delivered'
                      THEN message_status
                    ELSE :messageStatus
                    END
                  ),
                  twilio_sent      = (
                    CASE WHEN :messageStatus = 'sent'
                      THEN :dateReceived
                    ELSE twilio_sent
                    END
                  ),
                  twilio_delivered = (
                    CASE WHEN :messageStatus = 'delivered'
                      THEN :dateReceived
                    ELSE twilio_delivered
                    END
                  )
                WHERE message_sid = :messageSid
        """;

  //language=PostgreSQL
  public final static String saveReply = """
        INSERT INTO flow.sms_reply (
            message_sid, account_sid, messaging_service_sid,
            from_phone, to_phone, body, num_media, media_urls
        ) VALUES (
            :messageSid,
            :accountSid,
            :messagingServiceSid,
            :from,
            :to,
            :body,
            :numMedia,
            :mediaUrls
        )
    """;

  //language=PostgreSQL
  public final static String getProjects = """
    select p.id from flow.project p
      inner join flow.contact c on p.contact_id = c.id
     where c.search_phones = :from
     and p.archived is false
     """;

  //language=PostgreSQL
  public final static String getUsers = """
    select u.id from flow.user u
     where u.search_phone = :from
     and u.archived is false
     """;

//  //language=PostgreSQL
//  public final static String fetchReply = """
//      SELECT *
//      FROM flow.sms_reply
//      WHERE from_phone = :phone
//        AND date_received > :since
//      ORDER BY date_received DESC
//      LIMIT 1
//    """;

  //language=PostgreSQL
  public final static String getSmsQueue = """
    select sms.id,
            sms.user_id,
            sms.to_phone,
            sms.message,
            sms.created,
            sms.message_read,
            sms.twilio_delivered,
            sms.user_id                                                  as sent_to_user_id,
            concat(sent_to_user.first_name, ' ', sent_to_user.last_name) as sent_to_user_name,
            concat(sent_by_user.first_name, ' ', sent_by_user.last_name) as sent_by_user_name,
            sms.project_id,
            sms.contact_id,
            p.project_name,
            cpst.project_status_type,
            case
                when sms.project_id is not null then 1
                when sms.contact_id is not null then 2
                else 3 end                                               as object_type_id,
            concat(c.first_name, ' ', c.last_name)                       as contact_name
     from flow.sms_queue sms
              LEFT JOIN flow.contact c ON sms.contact_id = c.id
              LEFT JOIN flow.project p on p.id = sms.project_id
              LEFT join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
              LEFT JOIN flow.user sent_to_user on sent_to_user.id = sms.user_id
              INNER JOIN flow.user sent_by_user on sent_by_user.id = sms.message_sent_by_user_id
     where case when :objectTypeId = 1 then sms.project_id is not null
                when :objectTypeId = 3 then sms.user_id is not null else true end
        and case when :messageRead::boolean is not null then sms.message_read = :messageRead::boolean else true end
     order by sms.id desc
     limit :limit offset :offset
        """;

  //language=PostgreSQL
  public final static String update = """
          update flow.sms_queue
          set message_read = :messageRead,
              updated = now()
            where id = :smsId
    """;

//  //language=PostgreSQL
//  public final static String getOwners = """
//    select * from flow.get_sms_available_owners(:companyId::bigint, :parentCompanyId::bigint, :isParent::bool)
//        """;

}
