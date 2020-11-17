package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.MobileAttachment;
import com.albatross.api.v1.flow.model.User;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class AttachmentService {
    private String s3Url = "https://%s.s3.amazonaws.com/%s";

    private final AmazonS3 s3;

    private final SqlCache sqlCache;

    private final SecurityService securityService;

    @Value("${aws.storageBucket}")
    private String storageBucket;

    /**
     * Set the URL to find an Attachment in a custom S3 bucket.
     *
     * @param bucket Name of S3 bucket where the attachment is expected to reside.
     * @param a
     */
    private void setAttachmentUrl(String bucket, Attachment a) {
        a.setUrl(String.format(s3Url, bucket, a.getS3Key()));
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
     * Find Attachments by source Id and source type Id, using a custom S3 bucket name.
     *
     * @param sourceId ID of the source
     * @return
     */
    public List<Attachment> getAttachmentsBySourceIdAndType(Long sourceId, Long attachmentTypeId) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentTypeId", attachmentTypeId);

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentsBySourceIdAndType", params, Attachment.class);
        attachments.forEach(attachment -> {
            setAttachmentUrl(currentUser.getAwsBucket(), attachment);
            setAttachmentPresignedUrl(currentUser.getAwsBucket(), attachment);
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
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentTypeId", attachmentTypeId);

        Optional<Attachment> result = sqlCache.get("attachment.getAttachmentBySourceAndType", params, Attachment.class);

        if(result.isPresent()){
            Attachment attachment = result.get();
            setAttachmentUrl(storageBucket, attachment);
            setAttachmentPresignedUrl(storageBucket, attachment);

            return attachment;
        } else {
            return null;
        }
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

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentsByType", params, Attachment.class);
        attachments.forEach(attachment -> {
            setAttachmentUrl(storageBucket, attachment);
            setAttachmentPresignedUrl(storageBucket, attachment);
        });

        return attachments;
    }

    /**
     * Find Attachment by source Id and source type Id, using a custom S3 bucket name - limit 1.
     *
     * @param sourceId ID of the source
     * @return
     */
    public String getAttachmentPresignedUrl(String bucket, Long sourceId, Long attachmentTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentTypeId", attachmentTypeId);

        Optional<Attachment> attachment = sqlCache.get("attachment.getAttachmentBySourceAndType", params, Attachment.class);

        String preSignedUrl = null;

        if(attachment.isPresent()){
            setAttachmentPresignedUrl(bucket, attachment.get());
            preSignedUrl = attachment.get().getPresignedUrl();
        }

        return preSignedUrl;
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

        Optional<Attachment> attachment = sqlCache.get("attachment.getAttachmentById", params, Attachment.class);

        String preSignedUrl = null;

        if(attachment.isPresent()){
            setAttachmentPresignedUrl(bucket, attachment.get());
            preSignedUrl = attachment.get().getPresignedUrl();
        }

        return preSignedUrl;
    }

    /**
     * Find Attachment by source Id and source type id, using a custom S3 bucket name - for user array.
     *
     * @param sourceIds ID of the source
     * @return
     */
    public Map<Long, String> getAttachmentPresignedUrlForUserList(String bucket, List<Long> sourceIds, Long attachmentTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceIds", sourceIds);
        params.put("attachmentTypeId", attachmentTypeId);

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentBySourceAndTypeForUserList", params, Attachment.class);


        Map<Long, String> preSignedUrls = new HashMap<>();

        if(!attachments.isEmpty()){
            attachments.stream().forEach(a -> {

                setAttachmentPresignedUrl(bucket, a);

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
    List<Attachment> getAttachmentPresignedUrls(List<Attachment> attachments, String bucket, Boolean isMobile) {
      // mobile requires different headers
      if (!attachments.isEmpty()) {
        attachments.forEach(attachment -> setAttachmentPresignedUrl(bucket, attachment, isMobile));
      }
      return attachments;
    }

    /**
     * Find Attachment by ID, using a custom S3 bucket name.
     *
     * @param id     ID of the Attachment to find.
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
        return attachment;
    }

    /**
     * Return the URL for the Attachment with the specified ID, using a custom S3 bucket name.
     *
     * @param id     ID of the Attachment to find.
     * @return
     */
    public String getAttachmentUrl(Long id) {
        User currentUser = securityService.getCurrentUser();

        Attachment attachment = findById(id);

        String url = s3.getUrl(currentUser.getAwsBucket(), attachment.getS3Key()).toExternalForm();
        return url;
    }

    public void delete(Long id) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);
        params.put("modifiedById", currentUser.getId());

        sqlCache.update("attachment.deleteById", params);
    }

    public void deleteBySourceAndType(Long sourceId, Long attachmentTypeId) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentTypeId", attachmentTypeId);
        params.put("modifiedById", currentUser.getId());

        sqlCache.update("attachment.deleteBySourceAndType", params);
    }

    public AttachmentType getAttachmentType (Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<AttachmentType> result = sqlCache.get("attachment.getAttachmentType", params, AttachmentType.class);
        return result.orElse(null);
    }

    /**
     * Upload a new Attachment to S3 using a custom S3 bucket name and key pattern.
     *
     * @param file
     * @return
     * @throws IOException
     * @todo Generate a pre-signed URL
     */
    public Attachment create(MultipartFile file, Long sourceId, Long attachmentTypeId, Boolean deleteFirst) throws IOException {
        User currentUser = securityService.getCurrentUser();

        if (file.isEmpty()) {
            throw new RuntimeException("File cannot be empty");
        }

        //get keyPattern from attachmentType
        AttachmentType attachmentType = getAttachmentType(attachmentTypeId);
        String key = String.format( currentUser.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        metadata.setCacheControl("public, max-age=31536000");

        PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

        PutObjectResult result = s3.putObject(objectRequest
                .withCannedAcl(CannedAccessControlList.PublicRead));

        String url = s3.getUrl(currentUser.getAwsBucket(), key).toExternalForm();

        HashMap<String, Object> params = new HashMap<>();
        params.put("filename", file.getOriginalFilename());
        params.put("contentType", file.getContentType());
        params.put("key", key);
        params.put("size", file.getSize());
        params.put("createdById", currentUser.getId());
        params.put("attachmentTypeId", attachmentTypeId);
        params.put("companyId", currentUser.getCompanyId());

        Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

        //add to join
        addToJoinTable(attachmentId, sourceId, attachmentTypeId, deleteFirst);

        return findById(attachmentId);
    }

    public void addToJoinTable(Long attachmentId, Long sourceId, Long attachmentTypeId, boolean deleteFirst) {
        if (deleteFirst){
            deleteBySourceAndType(sourceId, attachmentTypeId);
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("attachmentId", attachmentId);
        params.put("sourceId", sourceId);
        params.put("attachmentTypeId", attachmentTypeId);

        sqlCache.update("attachment.addToJoinTable", params);
    }

    public void showOrHideAttachment(Attachment attachment) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("id", attachment.getId());
        params.put("show", attachment.getShow());
        params.put("userId", currentUser.getId());

        sqlCache.update("attachment.showOrHideAttachment", params);
    }

    //endpoint for automating mobile build uploads
    public Attachment insertAttachmentRecord(MobileAttachment ma) throws IOException {

        if (null == ma || null == ma.getAttachment()) {
            throw new RuntimeException("Attachment cannot be null");
        }

        String key = String.format(ma.getKeyPattern(), ma.getAttachment().getS3Key());

        HashMap<String, Object> params = new HashMap<>();
        params.put("filename", ma.getAttachment().getFilename());
        params.put("contentType", ma.getAttachment().getContentType());
        params.put("size", ma.getAttachment().getSize());
        params.put("key", key);

        Long id = sqlCache.updateReturningId("attachment.insertAttachmentRecord", params, "id").longValue();

        return findById(id);
    }
}
