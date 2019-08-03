package com.albatross.api.v1.flow.services;

import com.albatross.api.v1.flow.model.Attachment;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import com.albatross.api.utils.SqlCache;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.support.GeneratedKeyHolder;
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
    public List<Attachment> getAttachmentsBySourceIdAndType(String bucket, Long sourceId, Long attachmentSourceTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        List<Attachment> attachments = sqlCache.query("attachment.getAttachmentsBySourceIdAndType", params, Attachment.class);
        attachments.forEach(attachment -> {
            setAttachmentUrl(bucket, attachment);
            setAttachmentPresignedUrl(bucket, attachment);
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
    public String getAttachmentUrl(String bucket, Long id) {
        Attachment attachment = findById(bucket, id);

        String url = s3.getUrl(bucket, attachment.getS3Key()).toExternalForm();
        return url;
    }

    public void delete(Long id) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("id", id);

        sqlCache.update("attachment.deleteById", params);
    }

    public void deleteBySourceAndType(Long sourceId, Long attachmentSourceTypeId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        sqlCache.update("attachment.deleteBySourceAndType", params);
    }

    /**
     * Upload a new Attachment to S3 using a custom S3 bucket name and key pattern.
     *
     * @param bucket     Name of S3 bucket where the Attachment will be stored.
     * @param keyPattern Pattern for the Attachment's S3 key. It should have a single %s for the Attachment's name.
     * @param file
     * @return
     * @throws IOException
     * @todo Generate a pre-signed URL
     */
    public Attachment create(String bucket, String keyPattern, MultipartFile file) throws IOException {
        if (file.isEmpty()) {
            throw new RuntimeException("File cannot be empty");
        }

        String key = String.format(keyPattern, UUID.randomUUID());

        ObjectMetadata metadata = new ObjectMetadata();
        metadata.setContentLength(file.getSize());
        metadata.setContentType(file.getContentType());
        metadata.setCacheControl("public, max-age=31536000");

        PutObjectRequest objectRequest = new PutObjectRequest(bucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

        PutObjectResult result = s3.putObject(objectRequest
                .withCannedAcl(CannedAccessControlList.PublicRead));

        String url = s3.getUrl(bucket, key).toExternalForm();

        HashMap<String, Object> params = new HashMap<>();
        params.put("filename", file.getOriginalFilename());
        params.put("contentType", file.getContentType());
        params.put("size", file.getSize());
        params.put("key", key);

        GeneratedKeyHolder keyHolder = new GeneratedKeyHolder();
        sqlCache.update("attachment.create", params);

        return findById(bucket, keyHolder.getKey().longValue());
    }

    public void addToJoinTable(Long attachmentId, Long sourceId, Long attachmentSourceTypeId, boolean deleteFirst) {
        if(deleteFirst){
            // When coming from the reimbursement controller there can only be one, delete it first then re-add
            // Tried to use upsert but can't add unique constraint because most other tables are not limited to one
            HashMap<String, Object> params = new HashMap<>();
            params.put("sourceId", sourceId);
            params.put("attachmentSourceTypeId", attachmentSourceTypeId);

            sqlCache.update("attachment.deleteReimbursementBySourceAndType", params);
        }

        HashMap<String, Object> params = new HashMap<>();
        params.put("attachmentId", attachmentId);
        params.put("sourceId", sourceId);
        params.put("attachmentSourceTypeId", attachmentSourceTypeId);

        sqlCache.update("attachment.addToJoinTable", params);
    }
}