package com.albatross.api;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.services.AttachmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Optional;
import java.util.UUID;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class PublicService {

  private final SecurityService securityService;
  private final AttachmentService attachmentService;

  public void loadPublicAttachment(Long attachmentId, UUID uuid, HttpServletResponse response) throws IOException {
    Optional<Attachment> attachment = attachmentService.getAttachmentForUuid(attachmentId);

    if(attachment.isPresent() && attachment.get().getUuid().equals(uuid)) {
      response.sendRedirect(attachment.get().getPresignedUrl());
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Request", new Exception());
    }
  }

}
