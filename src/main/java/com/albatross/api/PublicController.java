package com.albatross.api;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.UUID;

/**
 * Created by Joseph Canto on 2019-08-01.
 */
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/public")
public class PublicController {

  private final PublicService publicService;

  @GetMapping(value = "/attachment/{id}/{uuid}")
  public void loadPublicAttachment(@PathVariable Long id,
                                   @PathVariable UUID uuid,
                                   HttpServletResponse response) throws IOException {
    publicService.loadPublicAttachment(id, uuid, response);
  }

}
