package com.albatross.api.v1.flow.services;

import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.JodaDateTimeEditor;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.RecipientType;
import com.albatross.api.v1.flow.enums.SmsPriority;
import com.albatross.api.v1.flow.model.Owner;
import com.albatross.api.v1.flow.model.smsQueue.SMSQueueItem;
import com.albatross.api.v1.flow.model.smsQueue.SmsQueueRow;
import com.albatross.api.v1.flow.model.smsQueue.TwilioMessageRequest;
import com.albatross.api.v1.flow.model.smsQueue.TwilioSMSResponse;
import com.albatross.api.v1.flow.model.smsTeam.SmsConversation;
import com.albatross.api.v1.flow.queries.SmsServiceQuery;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.util.concurrent.RateLimiter;
import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.twilio.Twilio;
import com.twilio.exception.ApiException;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.rest.api.v2010.account.MessageCreator;
import com.twilio.twiml.MessagingResponse;
import com.twilio.type.PhoneNumber;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.joda.time.DateTime;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.ZoneId;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SMSService {

  @Value(value = "${app.env}")
  private String appEnv;

  private final PropertiesConfiguration properties;
  private final SqlCache sqlCache;
  private final NamedParameterJdbcTemplate jdbcTemplate;
  private final DataSource dataSource;
  private final ObjectMapper om;
  private final RedisTemplate<String, String> stringRedisTemplate;
  private final String webhookPayloadKey = "twilio-webhook-payload";
  private final String webhookPayloadErrorsKey = "twilio-webhook-payload:errors";
  private final PhoneNumberUtil phoneNumberUtil = PhoneNumberUtil.getInstance();
  private final SecurityService securityService;
  private final MessagingService messagingService;
  private final ObjectMapper objectMapper;

  public Page<SmsQueueRow> getSmsQueue(Pageable pageable, Long objectTypeId, Boolean messageRead) {
    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);
    params.put("messageRead", messageRead);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    int total = 10000;
    List<SmsQueueRow> results =
      sqlCache.queryBySql(SmsServiceQuery.getSmsQueue, params, new SMSQueuePageMapper<>(SmsQueueRow.class, om));
    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }



  public SMSQueueItem getThreadInfo(Long smsThreadId) {
    Map<String, Object> params = new HashMap<>();
    params.put("smsThreadId", smsThreadId);

    Optional<SMSQueueItem> result = sqlCache.getBySql(SmsServiceQuery.getThreadInfo, params, SMSQueueItem.class);
    return result.orElse(null);
  }

  public List<SMSQueueItem> getSmsByProjectId(Long projectId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    Long smsThreadId = messagingService.getThreadId(projectId, null);

    params.put("smsThreadId", smsThreadId);
    return sqlCache.queryBySql(
      SmsServiceQuery.fetchByThreadId, params, new SMSQueueMapper<>(SMSQueueItem.class, om));
  }

  public List<SMSQueueItem> getSmsByUserId(Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("userId", userId);

    Long smsThreadId = messagingService.getThreadId(null, userId);

    params.put("smsThreadId", smsThreadId);

    return sqlCache.queryBySql(
      SmsServiceQuery.fetchByThreadId, params, new SMSQueueMapper<>(SMSQueueItem.class, om));
  }

  public List<SMSQueueItem> getSmsByThreadId(Long smsThreadId) {
    Map<String, Object> params = new HashMap<>();
    params.put("smsThreadId", smsThreadId);

    return sqlCache.queryBySql(
      SmsServiceQuery.fetchByThreadId, params, new SMSQueueMapper<>(SMSQueueItem.class, om));
  }

  public SMSQueueItem queueMessageForThread(String messageGroup,
                                            Long smsThreadId,
                                            String message,
                                            List<URI> mediaURLs,
                                            Long sentByUserId,
                                            Long sentBySmsTeamId) {

    SmsConversation thread = messagingService.getThread(smsThreadId, null, null, sentByUserId);

    Integer priorityLevel = SmsPriority.PROJECT.level;

    if(!thread.isExternal()) {
      //if intenal set that priority level
      priorityLevel = SmsPriority.USER.level;
    }

    return queueMessage(messageGroup,
      smsThreadId,
      null,
      null,
      null,
      thread.getSearchExternalPhone(),
      message,
      mediaURLs,
      thread.getRecipientTypeId().intValue(),
      sentByUserId,
      sentBySmsTeamId,
      priorityLevel);
  }

  public SMSQueueItem queueMessage(
    String messageGroup,
    Long smsThreadId,
    Long userId,
    Long contactId,
    Long projectId,
    String toPhone,
    String message,
    List<URI> mediaURLs,
    Integer recipientTypeId,
    Long sentByUserId,
    Long sentBySmsTeamId,
    Integer priorityLevel) {

    if (null != toPhone && !toPhone.isBlank()) {
      Long threadId = smsThreadId;

      if(threadId == null) {
        threadId = messagingService.getThreadId(projectId, userId);
      }

      String queueInsert = SmsServiceQuery.insert;

      MapSqlParameterSource source = new MapSqlParameterSource();
      source.addValue("messageGroup", messageGroup);
      source.addValue("userId", userId);
      source.addValue("contactId", contactId);
      source.addValue("projectId", projectId);
      source.addValue("threadId", threadId);
      source.addValue("message", message);
      source.addValue("toPhone", toPhone);
      source.addValue("mediaUrls", null);
      source.addValue("recipientTypeId", recipientTypeId);
      source.addValue("messageSentByUserId", sentByUserId);
      source.addValue("sentBySmsTeamId", sentBySmsTeamId);
      source.addValue("priorityLevel", priorityLevel);

      if (mediaURLs != null && !mediaURLs.isEmpty()) {

        try (Connection connection = dataSource.getConnection()) {
          String[] mediaUrls = mediaURLs.stream().map(URI::toString).toArray(String[]::new);
          Array varchar = connection.createArrayOf("varchar", mediaUrls);
          source.addValue("mediaUrls", varchar);
        } catch (SQLException e) {
          log.error("TWILIO_WEBHOOK_ERROR: media url problems, error={}", e.getMessage());
        }
      }

      List<SMSQueueItem> items =
        jdbcTemplate.query(queueInsert, source, new SMSQueueMapper<>(SMSQueueItem.class, om));
      return items.get(0);
    } else {
      return null;
    }
  }

  @Transactional
  public void processMessages() {

    String queueNext = SmsServiceQuery.next;
    String queueUpdate = SmsServiceQuery.updateById;

    RateLimiter limiter = RateLimiter.create(1);

    List<SMSQueueItem> query =
      jdbcTemplate.query(queueNext, new SMSQueueMapper<>(SMSQueueItem.class, om));
    for (SMSQueueItem sms : query) {

      limiter.acquire();

      List<URI> uris =
        sms.getMediaUrls().stream()
          .map(
            s -> {
              try {
                return new URI(s);
              } catch (URISyntaxException e) {
                log.error("TWILIO_WEBHOOK_ERROR: media urls failed, error={}", e.getMessage());
              }
              return null;
            })
          .filter(Objects::nonNull)
          .collect(Collectors.toList());

      try {
        String messageText = sms.getMessage();
        // For Project messages with attachment(s), the attachment file name is stored as the
        // message
        // which we don't want to send
        if (!uris.isEmpty() && sms.getRecipientType() == RecipientType.PROJECT) {
          messageText = "";
        }

        Message message = sendMessage(sms.getRecipientType(), sms.getSearchExternalPhone(), messageText, uris);

        String status = (message.getStatus() != null) ? message.getStatus().toString() : null;
        String fromPhone = (message.getFrom() != null) ? message.getFrom().toString() : null;

        Date twilioCreated = null;
        if (message.getDateCreated() != null) {
          twilioCreated =
            Date.from(message.getDateCreated().withZoneSameInstant(ZoneId.of("UTC")).toInstant());
        }

        Map<String, Object> params = new HashMap<>();
        params.put("id", sms.getId());
        params.put("messageSid", message.getSid());
        params.put("messageStatus", status);
        params.put("internalPhone", fromPhone);
        params.put("errorMessage", message.getErrorMessage());
        params.put("created", twilioCreated);

        jdbcTemplate.update(queueUpdate, params);

        // turning off this log for now.  the cron logs get long because of this one
        //        log.info("TWILIO: SUCCESS: Message SID={} successfully submitted to Twilio. ",
        // message.getSid());
      } catch (ApiException e) {

        Map<String, Object> params = new HashMap<>();
        params.put("id", sms.getId());
        params.put("messageSid", null);
        params.put("messageStatus", "error");
        params.put("fromPhone", null);
        params.put("errorMessage", e.getMessage());
        params.put("created", null);

        jdbcTemplate.update(queueUpdate, params);
        String errorMsg = e.toString();
        if (!errorMsg.contains("violates a blacklist rule")
            && !errorMsg.contains("is not a valid phone number")
            && !errorMsg.contains("Attempt to send to unsubscribed recipient")) {
          // cron logs are noisy. only log error if not one we are expecting
          log.error("TWILIO: error={}", e.toString());
        }
      }
    }
  }

  /**
   * Handle a status update from Twilio.
   *
   * @param msg
   */
  public void saveTwilioStatusUpdate(TwilioSMSResponse msg) {
    log.debug(
      "TWILIO: WEBHOOK: Message SID: {} From: {} Status: {} | received webhook update",
      msg.getMessageSid(),
      msg.getFrom(),
      msg.getMessageStatus());

    updateOrQueueSMSStatusUpdate(msg);
  }

  /**
   * Mock twilio reply, inserts "reply" into flow sms_reply table and processes notifications
   */
  public String processMockInboundMessage(Long projectId, Long userId, Long smsThreadId) {
    //todo: this
    if(null != appEnv && appEnv.equals("prod")) {
      return "Cannot mock replies in production environment";
    } else if(null != projectId || null != userId || null != smsThreadId) {

      //if the thread is null (meaning it came from project or user screen) get a thread id (it will create one if needed)
      if(smsThreadId == null) {
        smsThreadId = messagingService.getThreadId(projectId, userId);
      }

      SMSQueueItem threadInfo = getThreadInfo(smsThreadId);

      String toPhone = threadInfo.getRecipientType() == RecipientType.PROJECT
        ? properties.getTwilioPhoneNumber() : properties.getTwilioInternalPhoneNumber();

      if(!threadInfo.getSearchExternalPhone().isBlank()) {

        //maybe we can make a prop for this down the road, but I don't see a reason they need the ability to reply with specific text
        String mockInboundMessage = "MOCK REPLY: Auto Generated Test Reply";

        //(db limit 35 chars) does this value matter? starting with MOCK to easily dif
        String mockMessageSid = "MOCK" + RandomStringUtils.randomAlphanumeric(28);

        TwilioMessageRequest twilioMsg = TwilioMessageRequest.builder()
          .messageSid(mockMessageSid)
          //.smsSid(not sure which prop this is or if it matters)
          .accountSid(properties.getTwilioAccountSID())
          .messagingServiceSid(properties.getTwilioMessageServiceSID())
          .from(threadInfo.getSearchExternalPhone())
          .to(toPhone)
          .body(mockInboundMessage)
          .numMedia(0)
          .mediaUrls(null)
          .build();

        return receiveInboundMessage(twilioMsg);
      } else {
        return "Missing Valid From Phone Number";
      }

    } else {
      return "Project ID or User ID is required.";
    }

  }

  /**
   * Receive an inbound message from twilio as json, map to Java object, process message
   */
  public String receiveInboundMessage(Map<String, Object> req) {
    final TwilioMessageRequest twilioSMS = objectMapper.convertValue(req, TwilioMessageRequest.class);
    return receiveInboundMessage(twilioSMS);
  }

  /**
   * Process a mapped twilio inbound message
   */
  public String receiveInboundMessage(TwilioMessageRequest twilioSMS) {
    saveReply(twilioSMS);
    messagingService.addNotifications(twilioSMS);
    return new MessagingResponse.Builder().build().toXml();
  }

  /**
   * Process up to 50 queue status updates from Twilio.
   */
  public void processTwilioWebhookPayloads() {
    processTwilioWebhookPayloads(50);
  }

  /**
   * Process up to [limit] Twilio webhook payloads that have been queued up.
   */
  private void processTwilioWebhookPayloads(int limit) {

    final var opsForList = stringRedisTemplate.opsForList();

    Long waitingPayloads = opsForList.size(webhookPayloadKey);
    for (int i = 0; i < Math.min(waitingPayloads.intValue(), limit); i++) {

      String payload = opsForList.rightPop(webhookPayloadKey);
      if (payload == null) {
        break;
      }

      log.debug("TWILIO_WEBHOOK: processing payload: {}", payload);
      try {
        TwilioSMSResponse msg = TwilioSMSResponse.fromJSON(payload);
        updateOrQueueSMSStatusUpdate(msg);
      } catch (IOException ex) {
        log.error("TWILIO_WEBHOOK_ERROR: failed to load JSON: {}", payload);
        opsForList.leftPush(webhookPayloadErrorsKey, payload);
      }
    }
  }

  /**
   * Update the status for the record in sms_queue that corresponds with the specified sid.
   *
   * @param sid          the unique identifier of the text on Twilio's end
   * @param status       the status of the text on Twilio's end
   * @param fromPhone    the phone number Twilio used to send the requested text message
   * @param dateReceived the time the status update arrived from Twilio
   * @return
   */
  private boolean updateMessageBySid(
    String sid, String status, String fromPhone, String errorMessage, Date dateReceived) {
    log.debug(
      "TWILIO: WEBHOOK: Message SID: {} From: {} Status: {} | updating", sid, fromPhone, status);

    Map<String, Object> params = new HashMap<>();
    params.put("messageSid", sid);
    params.put("messageStatus", status);
    params.put("fromPhone", fromPhone);
    params.put("errorMessage", errorMessage);
    params.put("dateReceived", dateReceived);

    return jdbcTemplate.update(SmsServiceQuery.updateByMessageSid, params) > 0;
  }

  /**
   * Attempt to update the sms_queue table with the status update appropriately. If no updates can
   * be made immediately, queue the update to be processed at a later time.
   *
   * @param msg
   */
  private void updateOrQueueSMSStatusUpdate(TwilioSMSResponse msg) {
    boolean recordUpdated =
      updateMessageBySid(
        msg.getMessageSid(), msg.getMessageStatus(), msg.getFrom(), msg.getErrorMessage(), msg.getDateReceived());

    if (!recordUpdated) {
      msg.addAttempt();

      if (msg.getAttempts() >= 3) {
        log.warn(
          "TWILIO: WEBHOOK_ERROR: SID: {} too many failed attempts to update status",
          msg.getMessageSid());

        try {
          stringRedisTemplate.opsForList().leftPush(webhookPayloadErrorsKey, msg.toJSON());
        } catch (JsonProcessingException ex) {
          log.error("TWILIO_WEBHOOK_ERROR: failed to serialize, error={}", ex.getMessage());
        }

        return;
      }

      queueTwilioWebhookPayload(msg);
    }
  }

  /**
   * Queue up a webhook payload received from Twilio containing status information for a text we
   * asked Twilio to send.
   *
   * @param msg
   */
  private void queueTwilioWebhookPayload(TwilioSMSResponse msg) {
    log.debug(
      "TWILIO: WEBHOOK: Message SID: {} From: {} Status: {} | queuing update Attempts: {}",
      msg.getMessageSid(),
      msg.getFrom(),
      msg.getMessageStatus(),
      msg.getAttempts());

    try {
      String json = msg.toJSON();
      log.debug("TWILIO_WEBHOOK: payload {}", json);
      stringRedisTemplate.opsForList().leftPush(webhookPayloadKey, json);
    } catch (JsonProcessingException ex) {
      log.error(
        "TWILIO_WEBHOOK_ERROR: failed to serialize payload: {}, message: {}",
        msg,
        ex.getMessage());
    }
  }

  private Message sendMessage(
    RecipientType recipientType, String phoneNumber, String messageText, List<URI> mediaURLs) {
    Twilio.init(properties.getTwilioAccountSID(), properties.getTwilioAuthToken());

    PhoneNumber toPhoneNumber = new PhoneNumber(phoneNumber);
    MessageCreator creator = null;
    String twilioMessageServiceSID = getMessageServiceSID(recipientType);

    switch (recipientType) {
      case PROJECT:
        creator = Message.creator(toPhoneNumber, new PhoneNumber(properties.getTwilioPhoneNumber()), messageText);
        creator.setMessagingServiceSid(twilioMessageServiceSID);
        break;
      case USER:
        creator = Message.creator(toPhoneNumber, new PhoneNumber(properties.getTwilioInternalPhoneNumber()), messageText);
        creator.setMessagingServiceSid(twilioMessageServiceSID);
        break;
      default:
        if (StringUtils.hasText(twilioMessageServiceSID)) {
          creator = Message.creator(toPhoneNumber, twilioMessageServiceSID, messageText);
        }
    }

    if (mediaURLs != null && !mediaURLs.isEmpty()) {
      creator.setMediaUrl(mediaURLs);
    }

    return creator.create();
  }

  private String getMessageServiceSID(RecipientType recipientType) {
    return recipientType == RecipientType.CUSTOMER
      ? properties.getTwilioCustomersMessageServiceSID()
      : properties.getTwilioMessageServiceSID();
  }

  private RecipientType getRecordTypeByMessagingServiceSID(String mssid) {
    RecipientType type = RecipientType.NONE;

    if (mssid.equals(properties.getTwilioCustomersMessageServiceSID())) {
      type = RecipientType.CUSTOMER;
    } else if (mssid.equals(properties.getTwilioMessageServiceSID())) {
      type = RecipientType.USER;
    }

    return type;
  }

  public void updateSms(SMSQueueItem smsQueueItem) {
    Map<String, Object> params = new HashMap<>();
    params.put("smsId", smsQueueItem.getId());
    params.put("messageRead", smsQueueItem.isMessageRead());
    sqlCache.updateBySql(SmsServiceQuery.update, params);
  }

  public void saveReply(TwilioMessageRequest sms) {
    log.debug("TWILIO: saving Twilio SMS reply: {}", sms.getMessageSid());

//    todo this now needs to check for an existing sms thread and add one if there isn't one
    Map<String, Object> params = new HashMap<>();
    params = sms.toHashMap();
    params.put("recipientTypeId",
      Objects.equals(sms.getTo(), properties.getTwilioPhoneNumber()) ? RecipientType.PROJECT.ordinal() : RecipientType.USER.ordinal());

    sqlCache.queryBySql(SmsServiceQuery.saveReply, params, String.class);
  }

  public String cleanPhoneNumber(String input, String region) throws NumberParseException {
    return phoneNumberUtil.format(
      phoneNumberUtil.parse(input, region), PhoneNumberUtil.PhoneNumberFormat.E164);
  }

  public String cleanPhoneNumber(String input) throws NumberParseException {
    return cleanPhoneNumber(input, "US");
  }

  public String safeCleanPhoneNumber(String input) throws NumberParseException {
    String output;
    output = cleanPhoneNumber(input);
    return output;
  }

//
//  public Optional<TwilioMessageRequest> getReply(String phone, Date since)
//    throws NumberParseException {
//    String phoneE164 = cleanPhoneNumber(phone);
//
//    log.debug("TWILIO: input phone: {}; clean phone: {}", phone, phoneE164);
//    Map<String, Object> params =
//      Map.of(
//        "phone", phoneE164,
//        "since", since);
//
//    return sqlCache.getBySql(SmsServiceQuery.fetchReply, params, TwilioMessageRequest.class);
//  }

  public static class SMSQueueMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper om;

    public SMSQueueMapper(Class<T> mappedClass, ObjectMapper om) {
      super(mappedClass);
      this.om = om;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<String>> listTypeReference = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "mediaUrls", new JsonCollectionDeserializer(listTypeReference, om));
      bw.registerCustomEditor(DateTime.class, new JodaDateTimeEditor());

      super.initBeanWrapper(bw);
    }
  }

  public static class SMSQueuePageMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper om;

    public SMSQueuePageMapper(Class<T> mappedClass, ObjectMapper om) {
      super(mappedClass);
      this.om = om;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(Object.class, "owner", new JsonCollectionDeserializer(ownerRef, om));
    }
  }
}
