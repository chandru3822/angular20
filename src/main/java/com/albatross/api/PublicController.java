package com.albatross.api;

import com.albatross.api.v1.flow.model.Attachment;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/public")
public class PublicController {

  private final PublicService publicService;

  @GetMapping(value = "/attachment/{id}/{uuid}")
  public void loadPublicAttachment(@PathVariable Long id,
                                   @PathVariable UUID uuid,
                                   HttpServletResponse response) throws IOException {
    publicService.loadPublicAttachment(id, uuid, response);
  }

  @GetMapping(value = "/maintenanceAttachments")
  public List<Attachment> loadMaintenanceAttachments() {
    return publicService.loadMaintenanceAttachments();
  }

}
