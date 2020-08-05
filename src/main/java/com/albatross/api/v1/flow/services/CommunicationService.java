package com.blueraven.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.ObjectTagging;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3ObjectId;
import com.amazonaws.services.s3.model.Tag;
import com.blueraven.dto.UserMessage;
import com.blueraven.model.RecordType;
import com.blueraven.model.User;
import com.blueraven.repository.UserRepository;
import com.blueraven.scheduler.ScheduledMessage;
import com.blueraven.utils.SendMessageJob;
import com.blueraven.utils.SqlCache;
import com.blueraven.view.api.v1.dto.admin.SendEmailsRequest;
import com.blueraven.view.api.v1.dto.admin.SendTextsRequest;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Lists;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.digest.DigestUtils;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.JobKey;
import org.quartz.RecurrenceRuleScheduleBuilder;
import org.quartz.Scheduler;
import org.quartz.Trigger;
import org.quartz.TriggerBuilder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.BeanPropertySqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.inject.Inject;
import java.io.*;
import javax.mail.internet.InternetAddress;
import javax.sql.DataSource;
import java.net.URI;
import java.net.URL;
import java.sql.Connection;
import java.util.*;

import static org.quartz.JobBuilder.newJob;
import static org.quartz.RecurrenceRuleScheduleBuilder.recurrenceRuleSchedule;
import static org.quartz.TriggerBuilder.newTrigger;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @_(@Inject))
public class UserCommunicationService {

  // TODO: 4/11/17 simplify this
  private final TemplatingEngineService templatingEngineService;
  private final UserRepository userRepository;
  private final MailService mailService;
  private final SMSService smsService;
  private final SqlCache sqlCache;
  private final NamedParameterJdbcTemplate jdbc;
  private final DataSource dataSource;
  private final AmazonS3 s3client;
  private final Scheduler scheduler;


  @Value(value = "${scheduled-messages.email-attachments.s3.bucket}")
  private String scheduledMessageEmailAttachmentS3Bucket;

  @Async
  public void sendEmails(String subject, List<Long> userIDs, String templateContent, Map<String, javax.activation.DataSource> attachments, URL emailUnsubscribeURL, String sentByEmail) {
    for (Long userID : userIDs) {
      User user = userRepository.findOne(userID);
      //do not send email if they have opted out or if they are terminated
      if (user.getEmailOptOutDate() == null && (user.getUserStatusType() != null && user.getUserStatusType().getId() != 3)) {
        sendEmail(subject, user.getEmail(), user, templateContent, attachments, emailUnsubscribeURL, sentByEmail);
      }
    }
  }

  @Async
  public void sendEmail(EmailMessage msg) {
    sendEmail(msg.getSubject(),
            msg.getRecipientEmailAddr(),
            msg.getRecipientUser(),
            msg.getTemplate(),
            msg.getAttachments(),
            msg.getUnsubscribeUrl(),
            msg.getSenderEmailAddr());
  }

  @Async
  public void sendEmail(String subject, String emailAddress, User user, String templateContent, Map<String, javax.activation.DataSource> attachments, URL emailUnsubscribeURL, String sentByEmail) {

    //don't send email if user is terminated
    if (user != null && user.getUserStatusType() != null && user.getUserStatusType().getId() != 3){

      try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {

        Map<String, Object> contextMap = new HashMap<>();
        contextMap.put("unsubscribeURL", emailUnsubscribeURL + "?emailAddress=" + emailAddress);
        contextMap.put("user", new UserWrapper(user));

        renderTemplate(templateContent, output, contextMap);
        mailService.sendMessage(emailAddress, subject, output.toString(), attachments, sentByEmail);

      } catch (Exception ex) {
        log.error("EMAIL_ERROR: Error sending email to address={}", emailAddress, ex);
      }
    }
  }

  @Async
  public void sendEmail(String subject, String email, String template, Map<String, Object> context, String sentByEmail) {

    try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {

      renderTemplate(template, baos, context);
      // log.info("RENDERED EMAIL: to:{} subject:{}\n{}", email, subject, baos.toString());
      mailService.sendMessage(email, subject, baos.toString(), null, sentByEmail);
    } catch (Exception e) {
      e.printStackTrace();
      log.error("EMAIL_ERROR: Error sending email to address={}", email, e);
    }
  }
  
  public void sendEmail(String subject, List<String> emails, String template, Map<String, Object> context, InternetAddress sentByEmail, List<String> cc) throws Exception {
      ByteArrayOutputStream baos = new ByteArrayOutputStream();
      renderTemplate(template, baos, context);
      // log.info("RENDERED EMAIL: to:{} subject:{}\n{}", email, subject, baos.toString());
      mailService.sendMessage(emails, subject, baos.toString(), null, sentByEmail, cc);
  }

    @Async
  public void queueTextMessages(String messageGroupId, List<Long> userIDs, String templateContent, List<URI> mediaURLs) {

    for (Long userID : userIDs) {

      User user = userRepository.findOne(userID);
      //dont try to send text if there is no phone number or the user is terminated
      if (user.getPhoneNumber() != null && user.getUserStatusType() != null && user.getUserStatusType().getId() != 3) {

        try (ByteArrayOutputStream output = new ByteArrayOutputStream()) {
          Map<String, Object> contextMap = new HashMap<>();
          contextMap.put("user", new UserWrapper(user));

          renderTemplate(templateContent, output, contextMap);

          smsService.queueMessage(messageGroupId, userID, user.getPhoneNumber(), output.toString(), mediaURLs, RecordType.USER);

        } catch (Exception ex) {

          log.error("MESSAGING: Error queueing SMS ", ex);
        }
      }
    }
  }

  public void renderTemplate(String templateContent, OutputStream output, Map<String, Object> contextMap) throws Exception {
    templatingEngineService.applyFreemarkerTemplate(templateContent, contextMap, output);
  }

  public List<UserMessage> getUsersToMessage(Long dealId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("dealId", dealId);
    List<UserMessage> usersToMessage = sqlCache.query("user.getUsersToMessage", params, UserMessage.class);
    return usersToMessage;
  }

  public String getDefaultEmailTemplate() throws IOException {
    try (InputStream input = UserCommunicationService.class.getResourceAsStream("/communication/templates/email.ftl.txt")) {
      return new Scanner(input, "UTF-8").useDelimiter("\\A").next();
    }
  }

  public UUID scheduleMessage(List<Long> userIds, SendEmailsRequest emailsRequest, SendTextsRequest textsRequest,
                              String rrule, URL unsubscribeUrl, List<MultipartFile> emailAttachments) {
    try {
      UUID uuid = UUID.randomUUID();

      // persist attachments to S3
      List<S3ObjectId> emailAttachmentS3Refs = new ArrayList<>();
      for (int i = 0 ; i < emailAttachments.size(); i++) {
        MultipartFile file = emailAttachments.get(i);
        S3ObjectId s3Ref = persistToS3(uuid, i, file);
        emailAttachmentS3Refs.add(s3Ref);
      }

      // persist job info to database
      ScheduledMessage msg = new ScheduledMessage().builder()
              .uuid(uuid)
              .userIds(userIds)
              .rrule(rrule)
              .email(emailsRequest)
              .text(textsRequest)
              .unsubscribeUrl(unsubscribeUrl)
              .emailAttachmentS3Refs(emailAttachmentS3Refs)
              .build();
      try (Connection connection = dataSource.getConnection()) {
        msg.setStupid(connection);  // it's stupid that I must inject a connection here
        SqlParameterSource params = new BeanPropertySqlParameterSource(msg);
        sqlCache.update("scheduledMsgs.save", params);
      }

      // start the job
      JobDetail job = newJob(SendMessageJob.class)
              .withIdentity(getScheduledMesageJobKey(uuid))
              .usingJobData("uuid", uuid.toString())
              .usingJobData("emailJson", msg.getEmailJson())
              .usingJobData("textJson", msg.getTextJson())
              .usingJobData("unsubscribeUrl", msg.getUnsubscribeUrlStr())
              .usingJobData("emailAttachmentS3RefsJson", msg.getEmailAttachmentS3UrisJson())
              .build();
      Trigger trigger = newTrigger()
              .withSchedule(recurrenceRuleSchedule(rrule, TimeZone.getTimeZone("America/Denver")))
              .forJob(job)
              .build();
      scheduler.scheduleJob(job, trigger);

      return uuid;
    } catch (Exception e) {
      log.error("Something failed while scheduling message to employees.", e);
      throw new RuntimeException("Something failed while scheduling message to employees.", e);
    }
  }

  private S3ObjectId persistToS3(UUID uuid, int ordinal, MultipartFile file) throws IOException {
    try {
      byte[] contents = file.getBytes();

      byte[] md5 = DigestUtils.md5(contents);
      String md5Base64 = Base64.encodeBase64String(md5);

      String bucket = scheduledMessageEmailAttachmentS3Bucket,
              key = String.format("%s/%d-%s",
                      uuid.toString(),
                      ordinal,
                      file.getOriginalFilename());

      ObjectMetadata metadata = new ObjectMetadata();
      metadata.setContentType(file.getContentType());
      metadata.setContentDisposition(String.format("filename=\"%s\"", file.getOriginalFilename()));
      metadata.setContentLength(file.getSize());
      metadata.setContentMD5(md5Base64);
      metadata.setUserMetadata(ImmutableMap.of("scheduledMessageUuid", uuid.toString(),
              "originalFilename", file.getOriginalFilename()));

      PutObjectRequest req = new PutObjectRequest(bucket, key, new ByteArrayInputStream(contents), metadata);
      List<Tag> tags = Lists.newArrayList(new Tag("scheduled-message", uuid.toString()));
      req.withTagging(new ObjectTagging(tags));
      s3client.putObject(req);
      // TODO error handling
      return new S3ObjectId(bucket, key);
    } catch (Exception e) {
      String msg = "Something failed when persisting scheduled message email attachments to S3.";
      log.error(msg, e);
      throw new RuntimeException(msg, e);
    }
  }

  public List<ScheduledMessage> getScheduledMessages() {
    return sqlCache.query("scheduledMsgs.loadAll",
            Collections.emptyMap(),
            new BeanPropertyRowMapper(ScheduledMessage.class));
  }

  public Optional<ScheduledMessage> getScheduledMessage(UUID id) {
    return sqlCache.get("scheduledMsgs.load",
                 ImmutableMap.of("id", id),
                 new BeanPropertyRowMapper(ScheduledMessage.class));
  }

  public void deleteScheduledMessage(UUID uuid) {
    try {
      scheduler.deleteJob(getScheduledMesageJobKey(uuid));
      sqlCache.update("scheduledMsgs.delete", ImmutableMap.of("uuid", uuid));
    } catch (Exception e) {
      String msg = "Something went wrong while deleting scheduled message";
      log.error(msg, e);
      throw new RuntimeException(msg, e);
    }
  }

  private JobKey getScheduledMesageJobKey(UUID uuid) {
    return JobKey.jobKey(uuid.toString(), "scheduled-employee-messages");
  }

  public void updateScheduledMessage(UUID uuid, SendEmailsRequest emailsRequest,
                                     SendTextsRequest textsRequest, String rrule,
                                     URL unsubscribeUrl, List<MultipartFile> emailAttachments) {
    try {
      // persist attachments to S3
      List<S3ObjectId> emailAttachmentS3Refs = new ArrayList<>();
      for (int i = 0 ; i < emailAttachments.size(); i++) {
        MultipartFile file = emailAttachments.get(i);
        S3ObjectId s3Ref = persistToS3(uuid, i, file);
        emailAttachmentS3Refs.add(s3Ref);
      }

      // update the database
      ScheduledMessage msg = new ScheduledMessage().builder()
              .uuid(uuid)
              .rrule(rrule)
              .email(emailsRequest)
              .text(textsRequest)
              .unsubscribeUrl(unsubscribeUrl)
              .emailAttachmentS3Refs(emailAttachmentS3Refs)
              .build();
      try (Connection connection = dataSource.getConnection()) {
        msg.setStupid(connection);  // it's stupid that I must inject a connection here
        SqlParameterSource params = new BeanPropertySqlParameterSource(msg);
        sqlCache.update("scheduledMsgs.update", params);
      }

      // update the Quartz job
      JobDetail job = newJob(SendMessageJob.class)
              .withIdentity(getScheduledMesageJobKey(uuid))
              .usingJobData("job-id", uuid.toString())
              .usingJobData("emailJson", msg.getEmailJson())
              .usingJobData("textJson", msg.getTextJson())
              .usingJobData("unsubscribeUrl", msg.getUnsubscribeUrlStr())
              .usingJobData("emailAttachmentS3RefsJson", msg.getEmailAttachmentS3UrisJson())
              .build();
      Trigger trigger = newTrigger()
              .withSchedule(recurrenceRuleSchedule(rrule, TimeZone.getTimeZone("America/Denver")))
              .forJob(job)
              .build();
      scheduler.deleteJob(job.getKey());
      scheduler.scheduleJob(job, trigger);
    } catch (Exception e) {
      log.error("Something failed while scheduling message to employees.", e);
      throw new RuntimeException("Something failed while scheduling message to employees.", e);
    }
  }
}
