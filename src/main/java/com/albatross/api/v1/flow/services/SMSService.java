package com.albatross.api.v1.flow.services;

import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.JodaDateTimeEditor;
import com.albatross.api.v1.flow.enums.RecordType;
import com.albatross.api.v1.flow.model.*;
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
import com.twilio.type.PhoneNumber;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.joda.time.DateTime;
import org.joda.time.DateTimeZone;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import redis.clients.jedis.Jedis;
import redis.clients.jedis.JedisPool;

import javax.sql.DataSource;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class SMSService {

    private final PropertiesConfiguration properties;
    private final SqlCache sqlCache;
    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final DataSource dataSource;
    private final ObjectMapper om;
    private final JedisPool jedisPool;
    private final String webhookPayloadKey = "twilio-webhook-payload";
    private final String webhookPayloadErrorsKey = "twilio-webhook-payload:errors";
    private final PhoneNumberUtil phoneNumberUtil = PhoneNumberUtil.getInstance();

    public Optional<SMSQueuePage> getSmsQueue(String groupId, Pageable pageable) {
        Map<String, Object> params = new HashMap<>();
        params.put("groupId", groupId);
        params.put("page_size", pageable.getPageSize());
        params.put("page_number", pageable.getPageNumber());
        params.put("offset", pageable.getOffset());

        String where = "(:groupId::varchar IS NULL OR message_group = :groupId)";
        return sqlCache.get(
                "sms.queue.fetch_page",
                params,
                new SMSQueuePageMapper<>(SMSQueuePage.class, om),
                where,
                where
        );
    }

    public List<SMSQueueExportItem> exportSmsQueue() {

        List<SMSQueueExportItem> results = sqlCache.query("sms.queue.exportAll",
                Collections.emptyMap(),
                new SMSQueueMapper<>(SMSQueueExportItem.class, om)
//                SMSQueueExportItem.class
        );
        return results;
    }

    public Optional<SMSQueueItem> getSmsById(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        return sqlCache.get(
                "sms.queue.fetch",
                params,
                new SMSQueueMapper<>(SMSQueueItem.class, om),
                "sms.id = :id"
        );
    }

    public List<SMSQueueItem> getSmsByProjectId(Long projectId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", projectId);

        List<SMSQueueItem> results = sqlCache.query("sms.queue.fetchByProjectId", params, new SMSQueueMapper<>(SMSQueueItem.class, om));
        return results;
    }

    public SMSQueueItem queueMessage(String messageGroup, Long userId, String toPhone, String message, List<URI> mediaURLs, RecordType recipientType) {
        String queueInsert = sqlCache.getByKey("sms.queue.insert");

        MapSqlParameterSource source = new MapSqlParameterSource();
        source.addValue("messageGroup", messageGroup);
        source.addValue("userId", userId);
        source.addValue("message", message);
        source.addValue("toPhone", safeCleanPhoneNumber(toPhone));
        source.addValue("mediaUrls", null);
        source.addValue("recipientTypeId", recipientType.ordinal());

        if (!mediaURLs.isEmpty()) {

            try (Connection connection = dataSource.getConnection()) {
                String[] mediaUrls = mediaURLs.stream().map(p -> p.toString()).toArray(String[]::new);
                Array varchar = connection.createArrayOf("varchar", mediaUrls);
                source.addValue("mediaUrls", varchar);
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        List<SMSQueueItem> items = jdbcTemplate.query(
                queueInsert,
                source,
                new SMSQueueMapper<>(SMSQueueItem.class, om)
        );

        return items.get(0);
    }

    @Transactional
    public void processMessages() {

        String queueNext = sqlCache.getByKey("sms.queue.next");
        String queueUpdate = sqlCache.getByKey("sms.queue.updateById");

        RateLimiter limiter = RateLimiter.create(1);

        List<SMSQueueItem> query = jdbcTemplate.query(queueNext, new SMSQueueMapper<>(SMSQueueItem.class, om));
        for (SMSQueueItem sms : query) {

            limiter.acquire();

            List<URI> uris = sms.getMediaUrls().stream()
                    .map(s -> {
                        try {
                            return new URI(s);
                        } catch (URISyntaxException e) {
                            e.printStackTrace();
                        }
                        return null;
                    })
                    .filter(s -> s != null)
                    .collect(Collectors.toList());

            try {
                String messageText = sms.getMessage();
                // For Project messages with attachment(s), the attachment file name is stored as the message
                // which we don't want to send
                if (!uris.isEmpty() && sms.getRecipientType() == RecordType.PROJECT) {
                    messageText = "";
                }

                Message message = sendMessage(sms.getRecipientType(), sms.getToPhone(), messageText, uris);

                String status = (message.getStatus() != null) ? message.getStatus().toString() : null;
                String fromPhone = (message.getFrom() != null) ? message.getFrom().toString() : null;

                Date twilioCreated = null;
                if (message.getDateCreated() != null) {

                    twilioCreated = message.getDateCreated().withZone(DateTimeZone.UTC).toLocalDateTime().toDate();
                }

                HashMap<String, Object> params = new HashMap<>();
                params.put("id", sms.getId());
                params.put("messageSid", message.getSid());
                params.put("messageStatus", status);
                params.put("fromPhone", fromPhone);
                params.put("errorMessage", message.getErrorMessage());
                params.put("created", twilioCreated);

                jdbcTemplate.update(queueUpdate, params);

                log.info("TWILIO_SUCCESS: Message SID={} successfully submitted to Twilio. ", message.getSid());
            } catch (ApiException e) {

                HashMap<String, Object> params = new HashMap<>();
                params.put("id", sms.getId());
                params.put("messageSid", null);
                params.put("messageStatus", "error");
                params.put("fromPhone", null);
                params.put("errorMessage", e.getMessage());
                params.put("created", null);

                jdbcTemplate.update(queueUpdate, params);

                e.printStackTrace();
            }
        }
    }

    /**
     * Handle a status update from Twilio.
     *
     * @param msg
     */
    public void saveTwilioStatusUpdate(TwilioSMSResponse msg) {
        log.info("TWILIO_WEBHOOK: Message SID: {} From: {} Status: {} | received webhook update",
                msg.getMessageSid(),
                msg.getFrom(),
                msg.getMessageStatus());

        updateOrQueueSMSStatusUpdate(msg);
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
    public void processTwilioWebhookPayloads(int limit) {

        try (Jedis jedis = jedisPool.getResource()) {

            TwilioSMSResponse msg;

            Long waitingPayloads = jedis.llen(webhookPayloadKey);
            for (int i = 0; i < Math.min(waitingPayloads.intValue(), limit); i++) {
                String payload = jedis.rpop(webhookPayloadKey);
                if (payload == null) {
                    break;
                }

                log.debug("TWILIO_WEBHOOK: processing payload: {}", payload);
                try {
                    msg = TwilioSMSResponse.fromJSON(payload);
                } catch (IOException ex) {
                    log.error("TWILIO_WEBHOOK_ERROR: failed to load JSON: {}", payload);
                    jedis.lpush(webhookPayloadErrorsKey, payload);
                    continue;
                }

                updateOrQueueSMSStatusUpdate(msg);
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
    public boolean updateMessageBySid(String sid, String status, String fromPhone, Date dateReceived) {
        log.info("TWILIO_WEBHOOK: Message SID: {} From: {} Status: {} | updating", sid, fromPhone, status);

        HashMap<String, Object> params = new HashMap<>();
        params.put("messageSid", sid);
        params.put("messageStatus", status);
        params.put("fromPhone", fromPhone);
        params.put("dateReceived", dateReceived);

        return jdbcTemplate.update(
                sqlCache.getByKey("sms.queue.updateByMessageSid"),
                params) > 0;
    }

    /**
     * Attempt to update the sms_queue table with the status update appropriately. If no updates
     * can be made immediately, queue the update to be processed at a later time.
     *
     * @param msg
     */
    private void updateOrQueueSMSStatusUpdate(TwilioSMSResponse msg) {
        boolean recordUpdated = updateMessageBySid(
                msg.getMessageSid(),
                msg.getMessageStatus(),
                msg.getFrom(),
                msg.getDateReceived());

        if (!recordUpdated) {
            msg.addAttempt();

            if (msg.getAttempts() >= 3) {
                log.warn("TWILIO_WEBHOOK_ERROR: SID: {} too many failed attempts to update status", msg.getMessageSid());

                try (Jedis jedis = jedisPool.getResource()) {
                    jedis.lpush(webhookPayloadErrorsKey, msg.toJSON());
                } catch (JsonProcessingException ex) {
                    log.error("TWILIO_WEBHOOK_ERROR: failed to serialize");
                    ex.printStackTrace();
                }

                return;
            }

            queueTwilioWebhookPayload(msg);
        }
    }

    /**
     * Queue up a webhook payload received from Twilio containing status information for a
     * text we asked Twilio to send.
     *
     * @param msg
     */
    private void queueTwilioWebhookPayload(TwilioSMSResponse msg) {
        log.info("TWILIO_WEBHOOK: Message SID: {} From: {} Status: {} | queuing update Attempts: {}",
                msg.getMessageSid(),
                msg.getFrom(),
                msg.getMessageStatus(),
                msg.getAttempts());

        try (Jedis jedis = jedisPool.getResource()) {
            String json = msg.toJSON();
            log.debug("TWILIO_WEBHOOK: payload {}", json);
            jedis.lpush(webhookPayloadKey, json);
        } catch (JsonProcessingException ex) {
            log.error("TWILIO_WEBHOOK_ERROR: failed to serialize payload: {}", msg);
            ex.printStackTrace();
        }
    }

    private Message sendMessage(RecordType recipientType, String phoneNumber, String messageText, List<URI> mediaURLs) {
        Twilio.init(properties.getTwilioAccountSID(), properties.getTwilioAuthToken());

        PhoneNumber toPhoneNumber = new PhoneNumber(phoneNumber);
        String twilioMessageServiceSID = getMessageServiceSID(recipientType);
        String twilioPhoneNumber = properties.getTwilioPhoneNumber();

        MessageCreator creator = null;
        // prefer Message Service SID over phone number if available
        if (!StringUtils.isEmpty(twilioMessageServiceSID)) {
            creator = Message.creator(toPhoneNumber, twilioMessageServiceSID, messageText);
        } else if (!StringUtils.isEmpty(twilioPhoneNumber)) {
            creator = Message.creator(toPhoneNumber, new PhoneNumber(twilioPhoneNumber), messageText);
        }

        if (mediaURLs != null && !mediaURLs.isEmpty()) {
            creator.setMediaUrl(mediaURLs);
        }

        return creator.create();
    }

    private String getMessageServiceSID(RecordType recipientType) {
        return recipientType == RecordType.CUSTOMER ?
                properties.getTwilioCustomersMessageServiceSID() :
                properties.getTwilioMessageServiceSID();
    }

    private RecordType getRecordTypeByMessagingServiceSID(String mssid) {
        RecordType type = RecordType.NONE;

        if (mssid.equals(properties.getTwilioCustomersMessageServiceSID())) {
            type = RecordType.CUSTOMER;
        } else if (mssid.equals(properties.getTwilioMessageServiceSID())) {
            type = RecordType.USER;
        }

        return type;
    }

    public void saveReply(TwilioMessageRequest sms) {
        log.info("saving Twilio SMS reply: {}", sms.getMessageSid());

        RecordType type = getRecordTypeByMessagingServiceSID(sms.getMessagingServiceSid());

        sqlCache.update("sms.reply.save", sms.toHashMap());
    }

    public String cleanPhoneNumber(String input, String region) throws NumberParseException {
        return phoneNumberUtil.format(
                phoneNumberUtil.parse(input, region),
                PhoneNumberUtil.PhoneNumberFormat.E164);
    }

    public String cleanPhoneNumber(String input) throws NumberParseException {
        return cleanPhoneNumber(input, "US");
    }

    public String safeCleanPhoneNumber(String input) {
        String output;

        try {
            output = cleanPhoneNumber(input);
        } catch (NumberParseException ex) {
            log.warn("invalid phone number: {}", input);
            output = input;
        }

        return output;
    }

    public Optional<TwilioMessageRequest> getReply(String phone, Date since) throws NumberParseException {
        String phoneE164 = cleanPhoneNumber(phone);

        log.info("input phone: {}; clean phone: {}", phone, phoneE164);
        HashMap<String, Object> params = new HashMap<>();
        params.put("phone", phoneE164);
        params.put("since", since);

        return sqlCache.get(
                "sms.reply.fetch",
                params,
                TwilioMessageRequest.class
        );
    }

    public SMSTemplate getTemplate(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        return sqlCache.get(
                "sms.template.fetch",
                params,
                SMSTemplate.class
        ).get();
    }

    public static class SMSQueueMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper om;

        public SMSQueueMapper(Class<T> mappedClass, ObjectMapper om) {
            super(mappedClass);
            this.om = om;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<String>> listTypeReference = new TypeReference<List<String>>() {
            };
            bw.registerCustomEditor(List.class, "mediaUrls", new JsonCollectionDeserializer(listTypeReference, om));
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
            TypeReference<List<SMSQueueItem>> listTypeRef = new TypeReference<List<SMSQueueItem>>() {
            };
            bw.registerCustomEditor(
                    List.class,
                    "items",
                    new JsonCollectionDeserializer(listTypeRef, om));

        }
    }

}
