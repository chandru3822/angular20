package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.AttachmentType;
import com.albatross.api.v1.flow.model.CompanyProcessStepStatusType;
import com.albatross.api.v1.flow.model.User;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.UUID;

@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectProcessStepService {
  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final AttachmentService attachmentService;

  private String s3Url = "https://%s.s3.amazonaws.com/%s";

  private final AmazonS3 s3;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectProcessStepId, Long attachmentTypeId) throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    //get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key = String.format( user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());
    metadata.setCacheControl("public, max-age=31536000");

    PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    PutObjectResult result = s3.putObject(objectRequest
      .withCannedAcl(CannedAccessControlList.PublicRead));

    String url = s3.getUrl(user.getAwsBucket(), key).toExternalForm();

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", file.getOriginalFilename());
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", user.getId());
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.getId());

    sqlCache.update("projectProcessStep.addAttachment", params);

    return attachmentService.findById(storageBucket, attachmentId);
  }

  public void setStatus(Long projectProcessStepId, Long processStepStatusTypeId, Long companyProcessStepStatusTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepStatusTypeId", processStepStatusTypeId);
    params.put("companyProcessStepStatusTypeId", companyProcessStepStatusTypeId);
    params.put("userId", user.getId());

    sqlCache.update("projectProcessStep.setStatus", params);
  }
}
