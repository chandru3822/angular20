package com.albatross.api.v1.flow.services;

import com.albatross.api.config.CachingConfig;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.User;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.GeneratePresignedUrlRequest;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.ResponseHeaderOverrides;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttachmentService {
  private final AmazonS3 s3;
  private final SqlCache sqlCache;
  private final SecurityService securityService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  @Value("${app.host}")
  private String hostUrl;

  /**
   * Set the URL to find an Attachment in a custom S3 bucket.
   *
   * @param bucket Name of S3 bucket where the attachment is expected to reside.
   * @param a
   */
  private void setAttachmentUrl(String bucket, Attachment a) {
    String s3Url = "https://%s.s3.amazonaws.com/%s";
    a.setUrl(String.format(s3Url, bucket, a.getS3Key()));
  }

  /**
   * Set the URL to public url.
   *
   * @param attachment
   */
  private void setAttachmentPublicUrl(Attachment attachment) {
    attachment.setPublicUrl(
        hostUrl + "/public/attachment/" + attachment.getId() + "/" + attachment.getUuid());
  }

  /**
   * Set the URL to public url.
   *
   * @param a
   */
  public void setAttachmentPresignedUrl(Attachment a) {
    setAttachmentPresignedUrl(storageBucket, a);
  }

  /** Overload the setAttachmentPresignedUrl function for mobile */
  private void setAttachmentPresignedUrl(String bucket, Attachment a) {
    setAttachmentPresignedUrl(bucket, a, false);
  }

  /**
   * Set the URL to find an Attachment in a custom S3 bucket.
   *
   * @param bucket Name of S3 bucket where the attachment is expected to reside.
   * @param a
   */
  private void setAttachmentPresignedUrl(String bucket, Attachment a, Boolean isMobile) {
    getPresignedUrl(bucket, a, isMobile).ifPresent(uri -> a.setPresignedUrl(uri.toString()));
  }

  public Optional<URI> getPresignedUrl(@NonNull Attachment attachment, boolean isMobile) {
    return getPresignedUrl(storageBucket, attachment, isMobile);
  }

  private Optional<URI> getPresignedUrl(
      @NonNull String bucket, @NonNull Attachment attachment, boolean isMobile) {
    try {

      if (attachment.getS3Key() == null) {
        return Optional.empty();
      }
      GeneratePresignedUrlRequest request =
          new GeneratePresignedUrlRequest(bucket, attachment.getS3Key());

      // Set expiration to 24hrs
      LocalDateTime expiration = LocalDateTime.now().plusDays(1);
      request.setExpiration(Date.from(expiration.toInstant(ZoneOffset.UTC)));

      ResponseHeaderOverrides responseHeaders = new ResponseHeaderOverrides();
      responseHeaders.setCacheControl("No-cache");
      if (isMobile) {
        responseHeaders.setContentDisposition("inline");
        responseHeaders.setContentType(attachment.getContentType());
      } else {
        responseHeaders.setContentDisposition("attachment; filename=" + attachment.getFilename());
      }

      // Add the ResponseHeaderOverrides to the request.
      request.setResponseHeaders(responseHeaders);

      return Optional.of(s3.generatePresignedUrl(request).toURI());
    } catch (URISyntaxException e) {
      log.error("[Attachment] Error generating URI for presigned URL", e);
      return Optional.empty();
    }
  }

  /**
   * Find Attachments by source Id and source type Id, using a custom S3 bucket name.
   *
   * @param sourceId ID of the source
   * @return
   */
  public List<Attachment> getAttachmentsBySourceIdAndType(Long sourceId, Long attachmentTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);

    List<Attachment> attachments =
        sqlCache.query("attachment.getAttachmentsBySourceIdAndType", params, Attachment.class);
    attachments.forEach(
        attachment -> {
          setAttachmentUrl(storageBucket, attachment);
          setAttachmentPresignedUrl(storageBucket, attachment);
          setAttachmentPublicUrl(attachment);
        });

    return attachments;
  }

  /**
   * Find One Attachment by source Id and source type Id, using a custom S3 bucket name.
   *
   * @param sourceId ID of the source
   * @return
   */
  public Attachment getOneBySourceIdAndType(Long sourceId, Long attachmentTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);

    Optional<Attachment> result =
        sqlCache.get("attachment.getAttachmentBySourceAndType", params, Attachment.class);

    if (result.isPresent()) {
      Attachment attachment = result.get();
      setAttachmentUrl(storageBucket, attachment);
      setAttachmentPresignedUrl(storageBucket, attachment);
      setAttachmentPublicUrl(attachment);

      return attachment;
    }
    return null;
  }

  /**
   * Find Attachments by source Id and source type Id, using a custom S3 bucket name.
   *
   * @param attachmentTypeId ID of the attachmentType
   * @return
   */
  public List<Attachment> getAttachmentsByType(Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentTypeId", attachmentTypeId);

    List<Attachment> attachments =
        sqlCache.query("attachment.getAttachmentsByType", params, Attachment.class);
    attachments.forEach(
        attachment -> {
          setAttachmentUrl(storageBucket, attachment);
          setAttachmentPresignedUrl(storageBucket, attachment);
          setAttachmentPublicUrl(attachment);
        });

    return attachments;
  }

  /**
   * Find Attachments by attachment type that dont have a source id. used more for system level type
   * stuff
   *
   * @param attachmentTypeId ID of the attachmentType
   * @return
   */
  public List<Attachment> getAttachmentsByTypeWithoutSource(Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentTypeId", attachmentTypeId);

    List<Attachment> attachments =
        sqlCache.query("attachment.getAttachmentsByTypeNoSource", params, Attachment.class);
    attachments.forEach(
        attachment -> {
          setAttachmentUrl(storageBucket, attachment);
          setAttachmentPresignedUrl(storageBucket, attachment);
          setAttachmentPublicUrl(attachment);
        });

    return attachments;
  }

  /**
   * Find Attachment by source Id and source type Id, using a custom S3 bucket name - limit 1.
   *
   * @param sourceId ID of the source
   * @return
   */
  public String getAttachmentPresignedUrl(Long sourceId, Long attachmentTypeId) {
    return getAttachmentPresignedUrl(storageBucket, sourceId, attachmentTypeId);
  }

  public String getAttachmentPresignedUrl(String bucket, Long sourceId, Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);

    Optional<Attachment> attachment =
        sqlCache.get("attachment.getAttachmentBySourceAndType", params, Attachment.class);

    String preSignedUrl = null;

    if (attachment.isPresent()) {
      setAttachmentPresignedUrl(bucket, attachment.get());
      preSignedUrl = attachment.get().getPresignedUrl();
    }

    return preSignedUrl;
  }

  /**
   * Find Attachment UUID
   *
   * @param attachmentId ID of the attachment
   * @return
   */
  public Optional<Attachment> getAttachmentForUuid(Long attachmentId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", attachmentId);

    // when setting type as UUID got NoSuchMethodException for returning a UUID
    Optional<Attachment> attachment =
        sqlCache.get("attachment.getAttachmentForUuidCheck", params, Attachment.class);
    attachment.ifPresent(value -> setAttachmentPresignedUrl(storageBucket, value));
    return attachment;
  }

  /**
   * Find Attachment by source Id and source type Id, using a custom S3 bucket name - limit 1.
   *
   * @param id ID of the attachment
   * @return
   */
  public String getAttachmentPresignedUrlById(String bucket, Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<Attachment> attachment =
        sqlCache.get("attachment.getAttachmentById", params, Attachment.class);

    String preSignedUrl = null;

    if (attachment.isPresent()) {
      setAttachmentPresignedUrl(bucket, attachment.get());
      preSignedUrl = attachment.get().getPresignedUrl();
    }

    return preSignedUrl;
  }

  /**
   * Find Attachment by source Id and source type id, using a custom S3 bucket name - for user
   * array.
   *
   * @param sourceIds ID of the source
   * @return
   */
  public Map<Long, String> getAttachmentPresignedUrlsForUserList(
      List<Long> sourceIds, Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceIds", sourceIds);
    params.put("attachmentTypeId", attachmentTypeId);

    List<Attachment> attachments =
        sqlCache.query(
            "attachment.getAttachmentBySourceAndTypeForUserList", params, Attachment.class);

    Map<Long, String> preSignedUrls = new HashMap<>();

    if (!attachments.isEmpty()) {
      attachments.stream()
          .forEach(
              a -> {
                setAttachmentPresignedUrl(storageBucket, a);

                preSignedUrls.put(a.getSourceId(), a.getPresignedUrl());
              });
    }

    return preSignedUrls;
  }

  /**
   * Generate presigned URLs for the given attachments
   *
   * @param attachments
   * @param bucket
   * @return List<Attachment> attachments
   */
  List<Attachment> getAttachmentPresignedUrls(
      List<Attachment> attachments, String bucket, Boolean isMobile) {
    // mobile requires different headers
    if (!attachments.isEmpty()) {
      attachments.forEach(
          attachment -> {
            setAttachmentPresignedUrl(bucket, attachment, isMobile);
            setAttachmentPublicUrl(attachment);
          });
    }
    return attachments;
  }

  /**
   * Find Attachment by ID, using a custom S3 bucket name.
   *
   * @param id ID of the Attachment to find.
   * @return
   */
  public Attachment findById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    List<Attachment> attachments = sqlCache.query("attachment.findById", params, Attachment.class);
    if (attachments.isEmpty()) {
      return null;
    }
    Attachment attachment = attachments.get(0);
    setAttachmentUrl(storageBucket, attachment);
    setAttachmentPresignedUrl(storageBucket, attachment);
    setAttachmentPublicUrl(attachment);
    attachment.setLinked(false);
    return attachment;
  }

  @Cacheable(value = CachingConfig.ATTACHMENT)
  public Optional<Attachment> findAttachmentByUUID(@NonNull UUID uuid) {
    return sqlCache.get("attachment.getAttachmentByUUID", Map.of("uuid", uuid), Attachment.class);
  }

  /**
   * Return the URL for the Attachment with the specified ID, using a custom S3 bucket name.
   *
   * @param id ID of the Attachment to find.
   * @return
   */
  public String getAttachmentUrl(Long id) {
    User currentUser = securityService.getCurrentUser();
    Attachment attachment = findById(id);
    return s3.getUrl(currentUser.getAwsBucket(), attachment.getS3Key()).toExternalForm();
  }

  public void delete(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("attachment.deleteById", params);
  }

  public void deleteBySourceAndType(Long sourceId, Long attachmentTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.update("attachment.deleteBySourceAndType", params);
  }

  public AttachmentType getAttachmentType(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("attachment.getAttachmentType", params, AttachmentType.class).orElse(null);
  }

  public Attachment update(Long id, Attachment attachment) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("displayName", attachment.getDisplayName().length() > 100 ? attachment.getDisplayName().substring(0, 100) : attachment.getDisplayName());
    params.put("userId", currentUser.trueUserId());

    sqlCache.update("attachment.update", params);

    return findById(id);
  }

  /**
   * Upload a new Attachment to S3 using a custom S3 bucket name and key pattern.
   *
   * @param file
   * @return
   * @throws IOException
   * @todo Generate a pre-signed URL
   */
  public Attachment create(
      MultipartFile file, Long sourceId, Long attachmentTypeId, String displayName, Boolean deleteFirst)
      throws IOException {
    User currentUser = securityService.getCurrentUser();
    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    // get keyPattern from attachmentType
    AttachmentType attachmentType = getAttachmentType(attachmentTypeId);
    String key =
        String.format(
            currentUser.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());

    s3.putObject( new PutObjectRequest(
      storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata));

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("displayName", displayName.length() > 100 ? displayName.substring(0, 100) : displayName);
    params.put("createdById", currentUser.trueUserId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", currentUser.getCompanyId());

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();
    // add to join - only if they sent in a sourceId (sometimes we have to upload the attachment
    // first before having the source id (i.e. reimbursement requests)
    if (null != sourceId) {
      addToJoinTable(attachmentId, sourceId, attachmentTypeId, deleteFirst);
    }

    return findById(attachmentId);
  }

  private String cleanFilename(String filename) {
    if (filename == null) {
      return null;
    }
    String cleanFilename = filename.replace(",", "");
    cleanFilename = cleanFilename.replace("’", "'");
    return cleanFilename;
  }

  public void addToJoinTable(
      Long attachmentId, Long sourceId, Long attachmentTypeId, boolean deleteFirst) {
    if (deleteFirst) {
      deleteBySourceAndType(sourceId, attachmentTypeId);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("attachmentId", attachmentId);
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);

    sqlCache.update("attachment.addToJoinTable", params);
  }
}
