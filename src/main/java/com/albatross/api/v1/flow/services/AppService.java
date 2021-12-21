package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.AppAttachment;
import com.albatross.api.v1.flow.model.User;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class AppService {
  private String s3Url = "https://%s.s3.amazonaws.com/%s";
  private final SqlCache sqlCache;
  private final AmazonS3 s3;
  private final SecurityService securityService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  /**
   * Set the URL to find an Attachment in a custom S3 bucket.
   *
   * @param bucket Name of S3 bucket where the attachment is expected to reside.
   * @param a
   */
  private void setAttachmentUrl(String bucket, AppAttachment a) {
    a.setUrl(String.format(s3Url, bucket, a.getS3Key()));
  }

  /**
   * Overload the setAttachmentPresignedUrl function for mobile
   */
  private void setAttachmentPresignedUrl(String bucket, AppAttachment a) {
    setAttachmentPresignedUrl(bucket, a, false);
  }

  /**
   * Set the URL to find an Attachment in a custom S3 bucket.
   *
   * @param bucket Name of S3 bucket where the attachment is expected to reside.
   * @param a
   */
  private void setAttachmentPresignedUrl(String bucket, AppAttachment a, Boolean isMobile) {
    GeneratePresignedUrlRequest request = new GeneratePresignedUrlRequest(bucket, a.getS3Key());

    // Set expiration to 24hrs
    LocalDateTime expiration = LocalDateTime.now().plusDays(1);
    request.setExpiration(Date.from(expiration.toInstant(ZoneOffset.UTC)));

    ResponseHeaderOverrides responseHeaders = new ResponseHeaderOverrides();
    responseHeaders.setCacheControl("No-cache");
    if (isMobile) {
      responseHeaders.setContentDisposition("inline");
      responseHeaders.setContentType(a.getContentType());
    } else {
      responseHeaders.setContentDisposition("attachment; filename="+a.getFilename());
    }

    // Add the ResponseHeaderOverrides to the request.
    request.setResponseHeaders(responseHeaders);

    a.setPresignedUrl(s3.generatePresignedUrl(request).toString());
  }

  /**
   * Find latest mobile build
   *
   * @param appTypeId ID of the source
   * @return
   */
  public AppAttachment getLatestAppByAppTypeIdAndType(Long appTypeId, Long attachmentTypeId) {
    //this is an endpoint for mobile to determine if a user is using the most current app
    HashMap<String, Object> params = new HashMap<>();
    params.put("appTypeId", appTypeId);
    params.put("attachmentTypeId", attachmentTypeId);

    Optional<AppAttachment> result = sqlCache.get("app.getLatestAppByAppTypeIdAndType", params, AppAttachment.class);

    if(result.isPresent()){
      AppAttachment attachment = result.get();
      setAttachmentUrl(storageBucket, attachment);
      setAttachmentPresignedUrl(storageBucket, attachment);

      return attachment;
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "No App Found", new Exception());
    }
  }

  public void delete(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("app.deleteById", params);
  }

  /**
   * Find Attachments by source Id and source type Id, using a custom S3 bucket name.
   *
   * @param attachmentTypeId ID of the attachmentType
   * @return
   */
  public List<AppAttachment> getAttachmentsByAttachmentType(Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentTypeId", attachmentTypeId);

    List<AppAttachment> attachments = sqlCache.query("app.getAttachmentsByAttachmentType", params, AppAttachment.class);
    attachments.forEach(attachment -> {
      setAttachmentUrl(storageBucket, attachment);
      setAttachmentPresignedUrl(storageBucket, attachment);
    });

    return attachments;
  }

  public List<AppAttachment> getAttachmentsByAppAndAttachmentType(Long appTypeId, Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("appTypeId", appTypeId);

    List<AppAttachment> attachments = sqlCache.query("app.getAttachmentsByAppAndAttachmentType", params, AppAttachment.class);
    attachments.forEach(attachment -> {
      setAttachmentUrl(storageBucket, attachment);
      setAttachmentPresignedUrl(storageBucket, attachment);
    });

    return attachments;
  }

  public Long getMinVersionForType(Long appTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("appTypeId", appTypeId);

    Long minVersion = sqlCache.queryForObject("app.getMinVersionForType", params, Long.class);

    return minVersion;
  }

  public List<Long> getBuildNumbersForType(Long appTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("appTypeId", appTypeId);

    List<Long> results = sqlCache.query("app.getBuildNumbersForType", params, new SingleColumnRowMapper<>(Long.class));

    return results;
  }

  public void saveMinVersionForType(Long appTypeId, Long minBuildNumber) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("appTypeId", appTypeId);
    params.put("minBuildNumber", minBuildNumber);

    sqlCache.update("app.saveMinVersionForType", params);
  }

  public void showOrHideAttachment(AppAttachment attachment) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", attachment.getId());
    params.put("show", attachment.getShow());
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("app.showOrHideAttachment", params);
  }

  //endpoint for automating mobile build uploads
  public AppAttachment insertAttachmentRecord(AppAttachment attachment, User currentUser) throws IOException {

    //todo: if used from within the app need to get companyId off of user in those cases
    if (null == attachment) {
      throw new RuntimeException("Attachment cannot be null");
    }

    String key = String.format(attachment.getKeyPattern(), attachment.getS3Key());

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", attachment.getFilename());
    params.put("contentType", attachment.getContentType());
    params.put("size", attachment.getSize());
    params.put("appTypeId", attachment.getAppTypeId());
    params.put("companyId", null != currentUser ? currentUser.getCompanyId() : attachment.getCompanyId());
    params.put("attachmentTypeId", attachment.getAttachmentTypeId());
    params.put("displayName", attachment.getDisplayName());
    params.put("versionNumber", attachment.getVersionNumber());
    params.put("buildNumber", attachment.getBuildNumber());
    params.put("createdById", null != currentUser ? currentUser.getId() : SystemSettings.SYSTEM_USER.getId());
    params.put("key", key);

    Long id = sqlCache.updateReturningId("app.insertAttachmentRecord", params, "id").longValue();

    return findById(id);
  }

  public void uploadApp(String versionNumber, Long buildNumber, Long appTypeId, MultipartFile attachment, MultipartFile secondaryAttachment) throws IOException {
    User currentUser = securityService.getCurrentUser();
    if (attachment.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }
    String keyPattern = "apps/apps/%s";

    //upload the main attachment, for android this is the only one (apk), for ios it is the plist
    String key = uploadToS3(currentUser, keyPattern, attachment);

    //upload the secondary attachment (the ipa for ios)
    if(null != secondaryAttachment && !secondaryAttachment.isEmpty()) {
      String key2 = uploadToS3(currentUser, "apps/apps/%s", secondaryAttachment);
    }

    //add the record to app_attachment
    AppAttachment newApp = new AppAttachment();
    newApp.setFilename(attachment.getOriginalFilename());
    newApp.setContentType(attachment.getContentType());
    newApp.setSize(attachment.getSize());
    newApp.setAppTypeId(appTypeId);
    newApp.setAttachmentTypeId(8L);
    newApp.setVersionNumber(versionNumber);
    newApp.setBuildNumber(buildNumber);
    newApp.setKeyPattern(keyPattern);
    newApp.setS3Key(key);

    insertAttachmentRecord(newApp, currentUser);
  }

  public String uploadToS3(User currentUser, String keyPattern, MultipartFile attachment) throws IOException {
    String key = String.format(currentUser.getAwsBucket() + "/" + keyPattern, UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(attachment.getSize());
    metadata.setContentType(attachment.getContentType());
    metadata.setCacheControl("public, max-age=31536000");

    PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(attachment.getBytes()), metadata);
    s3.putObject(objectRequest.withCannedAcl(CannedAccessControlList.PublicRead));
    return key;
  }


  /**
   * Find Attachment by ID, using a custom S3 bucket name.
   *
   * @param id     ID of the Attachment to find.
   * @return
   */
  public AppAttachment findById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    List<AppAttachment> attachments = sqlCache.query("app.findById", params, AppAttachment.class);
    if (attachments.isEmpty()) {
      return null;
    }
    AppAttachment attachment = attachments.get(0);
    setAttachmentUrl(storageBucket, attachment);
    setAttachmentPresignedUrl(storageBucket, attachment);
    return attachment;
  }

  public void deleteBySourceAndType(Long appTypeId, Long attachmentTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("appTypeId", appTypeId);
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("app.deleteBySourceAndType", params);
  }

}
