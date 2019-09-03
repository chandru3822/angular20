package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentSourceType;
import com.albatross.api.v1.flow.model.User;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.*;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@Slf4j
@Service
public class AttachmentService {
    private String s3Url = "https://%s.s3.amazonaws.com/%s";

    @Autowired
    private AmazonS3 s3;

    @Autowired
    private SqlCache sqlCache;

    @Autowired
    private SecurityService securityService;

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
     * Set the URL to find an Attachment in a custom S3 bucket.
     *
     * @param bucket Name of S3 bucket where the attachment is expected to reside.
     * @param a
     */
    private void setAttachmentPresignedUrl(String bucket, Attachment a) {
        GeneratePresignedUrlRequest request = new GeneratePresignedUrlRequest(bucket, a.getS3Key());

        // Set expiration to 24hrs
        LocalDateTime expiration = LocalDateTime.now().plusDays(1);
        request.setExpiration(Date.from(expiration.toInstant(ZoneOffset.UTC)));

        ResponseHeaderOverrides responseHeaders = new ResponseHeaderOverrides();
        responseHeaders.setCacheControl("No-cache");
        responseHeaders.setContentDisposition("attachment; filename="+a.getFilename());

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
    public List<Attachment> getAttachmentsBySourceIdAndType(Long sourceId, Long attachmentSourceTypeId) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentsBySourceIdAndType", params, Attachment.class);
        attachments.forEach(attachment -> {
            setAttachmentUrl(currentUser.getAwsBucket(), attachment);
            setAttachmentPresignedUrl(currentUser.getAwsBucket(), attachment);
        });

        return attachments;
    }

    /**
     * Find Attachments by source Id and source type Id, using a custom S3 bucket name.
     *
     * @param attachmentSourceTypeId ID of the attachmentSourceType
     * @return
     */
    public List<Attachment> getAttachmentsByType(String bucket, Long attachmentSourceTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentsByType", params, Attachment.class);
        attachments.forEach(attachment -> {
            setAttachmentUrl(bucket, attachment);
            setAttachmentPresignedUrl(bucket, attachment);
        });

        return attachments;
    }

    /**
     * Find Attachment by source Id and source type Id, using a custom S3 bucket name - limit 1.
     *
     * @param sourceId ID of the source
     * @return
     */
    public String getAttachmentPresignedUrl(String bucket, Long sourceId, Long attachmentSourceTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

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
    public Map<Long, String> getAttachmentPresignedUrlForUserList(String bucket, List<Long> sourceIds, Long attachmentSourceTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceIds", sourceIds);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

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
    List<Attachment> getAttachmentPresignedUrls(List<Attachment> attachments, String bucket) {
      if (!attachments.isEmpty()) {
        attachments.forEach(attachment -> setAttachmentPresignedUrl(bucket, attachment));
      }
      return attachments;
    }

    /**
     * Find Attachment by ID, using a custom S3 bucket name.
     *
     * @param bucket Name of S3 bucket where the attachment is expected to reside.
     * @param id     ID of the Attachment to find.
     * @return
     */
    public Attachment findById(String bucket, Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        List<Attachment> attachments = sqlCache.query("attachment.findById", params, Attachment.class);
        if (attachments.isEmpty()) {
            return null;
        }
        Attachment attachment = attachments.get(0);
        setAttachmentUrl(bucket, attachment);
        return attachment;
    }

    /**
     * Return the URL for the Attachment with the specified ID, using a custom S3 bucket name.
     *
     * @param bucket Name of S3 bucket where the attachment is expected to reside.
     * @param id     ID of the Attachment to find.
     * @return
     */
    public String getAttachmentUrl(Long id) {
        User currentUser = securityService.getCurrentUser();

        Attachment attachment = findById(currentUser.getAwsBucket(), id);

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

    public void deleteBySourceAndType(Long sourceId, Long attachmentSourceTypeId) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);
        params.put("modifiedById", currentUser.getId());

        sqlCache.update("attachment.deleteBySourceAndType", params);
    }

    public AttachmentSourceType getAttachmentSourceType (Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        Optional<AttachmentSourceType> result = sqlCache.get("attachment.getAttachmentSourceType", params, AttachmentSourceType.class);
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
    public Attachment create(MultipartFile file, Long sourceId, Long attachmentSourceTypeId, Boolean deleteFirst) throws IOException {
        User currentUser = securityService.getCurrentUser();

        if (file.isEmpty()) {
            throw new RuntimeException("File cannot be empty");
        }

        //get keyPattern from attachmentSourceType
        AttachmentSourceType attachmentSourceType = getAttachmentSourceType(attachmentSourceTypeId);
        String key = String.format(attachmentSourceType.getKeyPattern(), UUID.randomUUID());

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        metadata.setCacheControl("public, max-age=31536000");

        PutObjectRequest objectRequest = new PutObjectRequest(currentUser.getAwsBucket(), key, new ByteArrayInputStream(file.getBytes()), metadata);

        PutObjectResult result = s3.putObject(objectRequest
                .withCannedAcl(CannedAccessControlList.PublicRead));

        String url = s3.getUrl(currentUser.getAwsBucket(), key).toExternalForm();

        HashMap<String, Object> params = new HashMap<>();
        params.put("filename", file.getOriginalFilename());
        params.put("contentType", file.getContentType());
        params.put("key", key);
        params.put("size", file.getSize());
        params.put("createdById", currentUser.getId());

        Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

        //add to join
        addToJoinTable(attachmentId, sourceId, attachmentSourceTypeId, deleteFirst);

        return findById(currentUser.getAwsBucket(), attachmentId);
    }

    public void addToJoinTable(Long attachmentId, Long sourceId, Long attachmentSourceTypeId, boolean deleteFirst) {
        if (deleteFirst){
            deleteBySourceAndType(sourceId, attachmentSourceTypeId);
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("attachmentId", attachmentId);
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        sqlCache.update("attachment.addToJoinTable", params);
    }
}
