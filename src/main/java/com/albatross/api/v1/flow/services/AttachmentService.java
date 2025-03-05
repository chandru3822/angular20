package com.albatross.api.v1.flow.services;

import com.albatross.api.config.CachingConfig;
import com.albatross.api.pubsub.PubSubService;
import com.albatross.api.pubsub.model.EventChannel;
import com.albatross.api.pubsub.model.ThemeUpdateMessage;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.AttachmentTypeSecondaryKeyPattern;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.AttachmentQuery;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import com.amazonaws.util.IOUtils;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
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
  private final PubSubService pubSubService;
  private final SecondaryKeyPatternService secondaryKeyPatternService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  @Value("${app.host}")
  private String hostUrl;

  @Value(value = "${app.env}")
  private String environment;

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

  /**
   * Overload the setAttachmentPresignedUrl function for mobile
   */
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
      sqlCache.queryBySql(AttachmentQuery.getAttachmentsBySourceIdAndType, params, Attachment.class);
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
      sqlCache.getBySql(AttachmentQuery.getAttachmentBySourceAndType, params, Attachment.class);

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
      sqlCache.queryBySql(AttachmentQuery.getAttachmentsByTypeNoSource, params, Attachment.class);
    attachments.forEach(
      attachment -> {
        setAttachmentUrl(storageBucket, attachment);
        setAttachmentPresignedUrl(storageBucket, attachment);
        setAttachmentPublicUrl(attachment);
      });

    return attachments;
  }

  /**
   * Find Attachment by source Id and source type Id - limit 1.
   *
   * @param sourceId ID of the source
   * @return
   */
  public String getAttachmentPresignedUrl(Long sourceId, Long attachmentTypeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);

    return sqlCache.getBySql(AttachmentQuery.getAttachmentBySourceAndType, params, Attachment.class)
      .flatMap(attachment -> getPresignedUrl(attachment, false))
      .map(URI::toString)
      .orElse(null);
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
      sqlCache.getBySql(AttachmentQuery.getAttachmentForUuidCheck, params, Attachment.class);
    attachment.ifPresent(value -> setAttachmentPresignedUrl(storageBucket, value));
    return attachment;
  }

  /**
   * Find Attachment by source Id and source type Id, using a custom S3 bucket name - limit 1.
   *
   * @param id ID of the attachment
   * @return
   */
  public String getAttachmentPresignedUrlById(@NonNull Long id) {
    return sqlCache.getBySql(AttachmentQuery.getAttachmentById, Map.of("id", id), Attachment.class)
      .flatMap(attachment -> getPresignedUrl(attachment, false))
      .map(URI::toString)
      .orElse(null);
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
      sqlCache.queryBySql(
        AttachmentQuery.getAttachmentBySourceAndTypeForUserList, params, Attachment.class);

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
   * @return List<Attachment> attachments
   */
  List<Attachment> getAttachmentPresignedUrls(
    List<Attachment> attachments, Boolean isMobile) {
    // mobile requires different headers
    if (!attachments.isEmpty()) {
      attachments.forEach(
        attachment -> {
          setAttachmentPresignedUrl(storageBucket, attachment, isMobile);
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
  public Attachment findById(@NonNull Long id) {
    List<Attachment> attachments = sqlCache.queryBySql(AttachmentQuery.findById, Map.of("id", id), Attachment.class);
    if (attachments.isEmpty()) {
      return null;
    }
    Attachment attachment = attachments.getFirst();
    setAttachmentUrl(storageBucket, attachment);
    setAttachmentPresignedUrl(storageBucket, attachment);
    setAttachmentPublicUrl(attachment);
    attachment.setLinked(false);
    return attachment;
  }

  public Optional<Attachment> findSimpleById(Long id) {
    return sqlCache.getBySql(AttachmentQuery.findSimpleById, Map.of("id", id), Attachment.class);
  }

  @Cacheable(value = CachingConfig.ATTACHMENT)
  public Optional<Attachment> findAttachmentByUUID(@NonNull UUID uuid) {
    return sqlCache.getBySql(AttachmentQuery.getAttachmentByUUID, Map.of("uuid", uuid), Attachment.class);
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

    long attachmentTypeId = sqlCache.updateBySqlReturningId(AttachmentQuery.deleteById, params, "attachment_type_id").longValue();
    //todo: PUBSUB if attachment was part of company defaults (theme) then send the theme update pubsub
    if (attachmentTypeId == 987 || attachmentTypeId == 29) {
      ThemeUpdateMessage tum = new ThemeUpdateMessage();
      pubSubService.publish(EventChannel.NOTIFICATION, tum);
    }
  }

  public void deleteBySourceAndType(Long sourceId, Long attachmentTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(AttachmentQuery.deleteBySourceAndType, params);
  }

  public S3Object getS3ObjectByAttachment(Attachment attachment) {
    return s3.getObject(storageBucket, attachment.getS3Key());
  }

  private AttachmentType getAttachmentType(@NonNull Long id) {
    return sqlCache.getBySql(AttachmentQuery.getAttachmentType, Map.of("id", id), AttachmentType.class).orElse(null);
  }

  public Attachment update(Long id, Attachment attachment) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("displayName", attachment.getDisplayName().length() > 100 ? attachment.getDisplayName().substring(0, 100) : attachment.getDisplayName());
    params.put("userId", currentUser.trueUserId());

    sqlCache.updateBySql(AttachmentQuery.update, params);

    return findById(id);
  }

  /**
   * Upload a new Attachment to S3 using a custom S3 bucket name and key pattern.
   *
   * @param file
   * @return
   * @throws IOException
   */
  public Attachment create(
    MultipartFile file, Long sourceId, Long attachmentTypeId, String displayName, Boolean deleteFirst) throws IOException {
    return create(file, sourceId, attachmentTypeId, displayName, deleteFirst, null);
  }

  public Attachment create(
    MultipartFile file, Long sourceId, Long attachmentTypeId, String displayName, Boolean deleteFirst, Long companyId)
    throws IOException {

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    return create(new ByteArrayInputStream(file.getBytes()), sourceId, attachmentTypeId, displayName, file.getOriginalFilename(), file.getContentType(), file.getSize(), deleteFirst, companyId);
  }

  public Attachment create(
    InputStream inputStream, Long sourceId, Long attachmentTypeId,
    String displayName, String filename, String contentType,
    Long contentLength, Boolean deleteFirst, Long companyId) {

    User currentUser = securityService.getCurrentUser();
    AttachmentType attachmentType = getAttachmentType(attachmentTypeId);

    try {
      byte[] inputBytes = IOUtils.toByteArray(inputStream);

      String fileUuid = UUID.randomUUID().toString();
      AttachmentMetadata metadata = new AttachmentMetadata(
        new ByteArrayInputStream(inputBytes), attachmentTypeId, displayName, filename, contentType,
        (long) inputBytes.length, companyId, currentUser, sourceId, fileUuid, deleteFirst
      );

      sendToS3(metadata, attachmentType.getKeyPattern(), false);

      String finalKey = generateS3Key(metadata.currentUser, attachmentType.getKeyPattern(), metadata.uuid, false);

      Long attachmentId = insertAttachment(metadata, finalKey);

      if (metadata.sourceId != null) {
        addToJoinTable(attachmentId, metadata.sourceId, metadata.attachmentTypeId, metadata.deleteFirst);
      }

      handleSecondaryUploads(new ByteArrayInputStream(inputBytes), attachmentTypeId, displayName, filename, contentType,
        (long) inputBytes.length, companyId, currentUser, sourceId, fileUuid, deleteFirst, attachmentType);

      publishThemeUpdateIfNeeded(attachmentTypeId);

      return findById(attachmentId);
    } catch (IOException e) {
      throw new RuntimeException("Error handling input stream for S3 upload", e);
    }
  }

  private static InputStream copyInputStream(InputStream originalStream) throws IOException {
    byte[] byteArray = IOUtils.toByteArray(originalStream);
    return new ByteArrayInputStream(byteArray);
  }

  private void sendToS3(AttachmentMetadata metadata, String keyPattern, Boolean useStage) {
    ObjectMetadata objectMetadata = createS3Metadata(metadata);
    String finalKey = generateS3Key(metadata.currentUser, keyPattern, metadata.uuid, useStage);

    PutObjectRequest objectRequest = new PutObjectRequest(
      storageBucket, finalKey, metadata.inputStream, objectMetadata
    ).withCannedAcl(CannedAccessControlList.PublicRead);

    s3.putObject(objectRequest);
  }

  @NotNull
  private Long insertAttachment(AttachmentMetadata metadata, String keyPattern) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(metadata.filename));
    params.put("contentType", metadata.contentType);
    params.put("key", keyPattern);
    params.put("size", metadata.contentLength);
    params.put("displayName", cleanDisplayName(metadata.displayName));
    params.put("createdById", metadata.currentUser.trueUserId());
    params.put("attachmentTypeId", metadata.attachmentTypeId);
    params.put("companyId", metadata.companyId != null ? metadata.companyId : metadata.currentUser.getCompanyId());
    params.put("processed", false);

    return sqlCache.updateBySqlReturningId(AttachmentQuery.create, params, "id").longValue();
  }

  private ObjectMetadata createS3Metadata(AttachmentMetadata metadata) {
    ObjectMetadata objectMetadata = new ObjectMetadata();
    objectMetadata.setContentLength(metadata.contentLength);
    objectMetadata.setContentType(metadata.contentType);
    objectMetadata.setCacheControl("public, max-age=31536000");
    return objectMetadata;
  }

  private String generateS3Key(User currentUser, String keyPattern, String uuid, Boolean useStage) {
    String baseFolder = (environment.equals("prod") || !useStage) ? "/" : "/stage/";
    return String.format(currentUser.getAwsBucket() + baseFolder + keyPattern, uuid);
  }

  private void handleSecondaryUploads(InputStream inputStream, Long attachmentTypeId, String displayName,
                                      String filename, String contentType, Long contentLength, Long companyId,
                                      User currentUser, Long sourceId, String Uuid, Boolean deleteFirst, AttachmentType attachmentType) {
    List<AttachmentTypeSecondaryKeyPattern> secondaryKeyPatterns = secondaryKeyPatternService.getByAttachmentTypeId(attachmentTypeId);
    for (AttachmentTypeSecondaryKeyPattern secondaryKeyPattern : secondaryKeyPatterns) {
      try {
        AttachmentMetadata amd = new AttachmentMetadata(copyInputStream(inputStream), attachmentTypeId, displayName, filename, contentType, contentLength,
          companyId, currentUser, sourceId, Uuid, deleteFirst);
        if (amd.contentLength > 0) {
          sendToS3(amd, secondaryKeyPattern.getKeyPattern(), true);
        }
      } catch (IOException e) {
        throw new RuntimeException("Error sending input stream for S3 upload", e);
      }
    }
  }

  private void publishThemeUpdateIfNeeded(Long attachmentTypeId) {
    if (attachmentTypeId == 987L || attachmentTypeId == 29) {
      pubSubService.publish(EventChannel.NOTIFICATION, new ThemeUpdateMessage());
    }
  }

  private static class AttachmentMetadata {
    InputStream inputStream;
    Long attachmentTypeId;
    String displayName;
    String filename;
    String contentType;
    Long contentLength;
    Long companyId;
    User currentUser;
    Long sourceId;
    String uuid;
    Boolean deleteFirst;

    public AttachmentMetadata(InputStream inputStream, Long attachmentTypeId, String displayName,
                              String filename, String contentType, Long contentLength, Long companyId,
                              User currentUser, Long sourceId, String uuid, Boolean deleteFirst) {
      this.inputStream = inputStream;
      this.attachmentTypeId = attachmentTypeId;
      this.displayName = displayName;
      this.filename = filename;
      this.contentType = contentType;
      this.contentLength = contentLength;
      this.companyId = companyId;
      this.currentUser = currentUser;
      this.sourceId = sourceId;
      this.uuid = uuid;
      this.deleteFirst = deleteFirst;
    }
  }

  public String cleanDisplayName(String original) {
    if (original == null) {
      return null;
    }

    String clean = CleanString.cleanFilename(original);
    if (clean.length() > 100) {
      return clean.substring(0, 100);
    }
    return clean;
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

    sqlCache.updateBySql(AttachmentQuery.addToJoinTable, params);
  }
}
