package com.albatross.api.v1.flow.queries;

public class SmsServiceQuery {

  //language=PostgreSQL
  public final static String fetchByThreadId = """
    SELECT st.message,
           array_to_json(st.media_urls) AS media_urls,
           st.date_created,
           st.from_phone,
           st.inbound,
           st.recipient_type_id,
           st.message_sent_by_user_id   as user_id,
           concat(u.first_name, ' ', u.last_name::text) as full_name
    FROM flow.sms_thread st
             left join flow.user u on st.message_sent_by_user_id = u.id
    where error_message IS NULL
        AND st.parent_id = :smsThreadId
        and st.archived is false
    ORDER BY st.date_created ASC
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
        select from flow.sms_save_reply(
            :messageSid,
            :accountSid,
            :messagingServiceSid,
            :from,
            :to,
            :body,
            :numMedia,
            :mediaUrls::text[],
            :recipientTypeId
        )
    """;

  //language=PostgreSQL
  public final static String getThreadId = """
    select * from flow.get_thread_id(:projectId::int, :userId::int, :fromPhoneNumber::text)
    """;

  //language=PostgreSQL
  public final static String getThreadInfo = """
    select st.parent_id,
           st.recipient_type_id,
           st.inbound,
           st.search_from_phone,
           st.search_to_phone
    from flow.sms_thread st
    where st.id = :smsThreadId
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
