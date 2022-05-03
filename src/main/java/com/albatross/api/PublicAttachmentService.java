package com.albatross.api;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PublicAttachmentService {

  private final SecurityService securityService;
  private final AttachmentService attachmentService;

  public Optional<Attachment> loadPublicAttachment(Long attachmentId, UUID uuid) {
    return attachmentService
        .getAttachmentForUuid(attachmentId)
        .filter(attachment -> attachment.getUuid().equals(uuid));
  }

  public List<Attachment> loadMaintenanceAttachments() {
    return attachmentService.getAttachmentsByTypeWithoutSource(938L);
  }
}
