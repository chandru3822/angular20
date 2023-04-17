package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Hashtag;
import com.albatross.api.v1.flow.services.HashtagService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn 10/1/19
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/hashtag")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class HashtagController {

  private final HashtagService hashtagService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Hashtag> getHashtags() {
    return hashtagService.getHashtags();
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Hashtag> saveHashTag(@RequestBody Hashtag tag) {
    return hashtagService.saveHashtag(tag);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteHashTag(@PathVariable Long id) {
    hashtagService.deleteHashtag(id);
  }

}
