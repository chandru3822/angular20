package com.albatross.api;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PublicService {

  private final SecurityService securityService;
  private final AttachmentService attachmentService;

  public void loadPublicAttachment(Long attachmentId, UUID uuid, HttpServletResponse response)
      throws IOException {
    Optional<Attachment> attachment = attachmentService.getAttachmentForUuid(attachmentId);

    if (attachment.isPresent() && attachment.get().getUuid().equals(uuid)) {
      response.sendRedirect(attachment.get().getPresignedUrl());
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Request", new Exception());
    }
  }

  public List<Attachment> loadMaintenanceAttachments() {
    return attachmentService.getAttachmentsByTypeWithoutSource(938L);
  }
}
