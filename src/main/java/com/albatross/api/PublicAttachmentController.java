package com.albatross.api;

import com.albatross.api.exception.NotFoundException;
import com.albatross.api.model.ImageOptions;
import com.albatross.api.v1.flow.model.Attachment;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import javax.servlet.http.HttpServletResponse;
import javax.validation.Valid;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/public")
public class PublicAttachmentController {

  private final PublicAttachmentService publicAttachmentService;

  @GetMapping(value = "/attachment/{id}/{uuid}")
  public void loadPublicAttachment(
      @PathVariable Long id, @PathVariable UUID uuid, HttpServletResponse response)
      throws IOException {
    final Attachment attachment =
        publicAttachmentService
            .loadPublicAttachment(id, uuid)
            .orElseThrow(
                () -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid Request"));

    response.sendRedirect(attachment.getPresignedUrl());
  }

  @GetMapping(value = "/maintenanceAttachments")
  public List<Attachment> loadMaintenanceAttachments() {
    return publicAttachmentService.loadMaintenanceAttachments();
  }

  @GetMapping("/image/{uuid}")
  public ResponseEntity<?> getImageByUUID(@PathVariable UUID uuid, @Valid ImageOptions stuff) {
    return publicAttachmentService
        .findAttachmentURIByUUID(uuid, stuff)
        .map(url -> ResponseEntity.status(HttpStatus.FOUND).location(url).build())
        .orElseThrow(NotFoundException::new);
  }

}
