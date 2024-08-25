package com.albatross.api.v1.flow.queries;

public class SmsServiceQuery {

  //language=PostgreSQL
  public final static String fetchByThreadId = """
    SELECT st.message,
           array_to_json(st.media_urls) AS media_urls,
           st.date_created,
           st.external_phone,
           st.internal_phone,
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
    WITH sq AS (INSERT INTO flow.sms_thread (
                           message_group,sent_to_user_id, sent_to_project_id, message,media_urls,external_phone,recipient_type_id,message_sent_by_user_id,sms_team_id, priority_level, parent_id
                ) VALUES (
                           :messageGroup,:userId,:projectId,:message,:mediaUrls,:toPhone,:recipientTypeId,:messageSentByUserId,:sentBySmsTeamId, :priorityLevel, :threadId
                         )
                RETURNING id,sent_to_user_id, sent_to_project_id,message,media_urls,
                  message_group,message_sid,message_status,error_message,
                  internal_phone,external_phone,twilio_created,twilio_sent,twilio_delivered,
                  date_modified,date_created,recipient_type_id, message_sent_by_user_id, sms_team_id)
              SELECT sq.id,
                     sq.sent_to_user_id,
                     sq.sent_to_project_id,
                     sq.message,
                     array_to_json(sq.media_urls)       AS media_urls,
                     sq.message_group,
                     sq.message_sid,
                     sq.message_status,
                     sq.error_message,
                     sq.internal_phone,
                     sq.external_phone,
                     sq.twilio_created,
                     sq.twilio_sent,
                     sq.twilio_delivered,
                     sq.date_modified,
                     sq.date_created,
                     sq.recipient_type_id,
                     sq.message_sent_by_user_id,
                     sq.sms_team_id
              FROM sq
    """;

  //language=PostgreSQL
  public final static String next = """
    SELECT
                  sms.id,
                  sms.sent_to_user_id,
                  sms.message,
                  array_to_json(sms.media_urls) AS media_urls,
                  sms.recipient_type_id,
                  sms.error_message,
                  sms.message_group,
                  sms.message_sid,
                  sms.message_status,
                  sms.internal_phone,
                  sms.external_phone,
                  sms.twilio_created,
                  sms.twilio_sent,
                  sms.twilio_delivered,
                  sms.date_modified,
                  sms.date_created
                FROM flow.sms_thread sms
                WHERE message_sid IS NULL
                      AND sms.external_phone IS NOT NULL
                      AND sms.inbound is false
                      and sms.archived is false
                      AND (
                        error_message IS NULL OR (
                          LOWER(error_message) IN (
                            'api.twilio.com:443 failed to respond'
                          ) AND

                          -- so we don't retry very very old texts
                          date_created >= '2017-11-08'
                        )
                      )
                ORDER BY sms.priority_level, sms.date_created ASC
                LIMIT 10
                FOR UPDATE SKIP LOCKED
    """;

  //language=PostgreSQL
  public final static String updateById = """
            UPDATE flow.sms_thread
            SET
                message_sid = :messageSid,
                message_status = :messageStatus,
                internal_phone = :internalPhone,
                error_message = :errorMessage,
                twilio_created = :created,
                date_modified = now()
            WHERE id = :id
    """;

  //language=PostgreSQL
  public final static String updateByMessageSid = """
    UPDATE flow.sms_thread SET
                  date_modified          = now(),
                  internal_phone   = :internalPhone,
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
           rt.external,
           st.search_internal_phone,
           st.search_external_phone
    from flow.sms_thread st
    inner join flow.recipient_type rt on st.recipient_type_id = rt.id
    where st.id = :smsThreadId
    """;

  //language=PostgreSQL
  public final static String getThreads = """
    select st.parent_id
    from flow.sms_thread st
     where st.is_last_inserted is true
     and st.external_phone = :phoneNumber
    """;

  //language=PostgreSQL
  public final static String getSmsQueue = """
    select sms.id,
            sms.message_sent_by_user_id,
            sms.internal_phone,
            sms.external_phone,
            sms.message,
            sms.date_created,
            sms.message_read,
            sms.twilio_delivered,
            sms.sent_to_user_id                                                  as sent_to_user_id,
            concat(sent_to_user.first_name, ' ', sent_to_user.last_name) as sent_to_user_name,
            concat(sent_by_user.first_name, ' ', sent_by_user.last_name) as sent_by_user_name,
            sms.sent_to_project_id,
            p.contact_id,
            p.project_name,
            cpst.project_status_type,
            case
                when sms.sent_to_project_id is not null then 1
                when p.contact_id is not null then 2
                else 3 end                                               as object_type_id,
            concat(c.first_name, ' ', c.last_name)                       as contact_name
     from flow.sms_thread sms
              LEFT JOIN flow.project p on p.id = sms.sent_to_project_id
              LEFT JOIN flow.contact c ON p.contact_id = c.id
              LEFT join flow.company_project_status_type cpst on cpst.id = p.company_project_status_type_id
              LEFT JOIN flow.user sent_to_user on sent_to_user.id = sms.sent_to_user_id
              INNER JOIN flow.user sent_by_user on sent_by_user.id = sms.message_sent_by_user_id
     where case when :objectTypeId = 1 then sms.sent_to_project_id is not null
                when :objectTypeId = 3 then sms.sent_to_user_id is not null else true end
        and case when :messageRead::boolean is not null then sms.message_read = :messageRead::boolean else true end
     order by sms.id desc
     limit :limit offset :offset
    """;

  //language=PostgreSQL
  public final static String update = """
          update flow.sms_thread
          set message_read = :messageRead,
              date_modified = now()
            where id = :smsId
    """;

//  //language=PostgreSQL
//  public final static String getOwners = """
//    select * from flow.get_sms_available_owners(:companyId::bigint, :parentCompanyId::bigint, :isParent::bool)
//        """;

}
