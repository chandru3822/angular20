package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ProjectTag;
import com.albatross.api.v1.flow.model.Tag;
import com.albatross.api.v1.flow.services.TagService;
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
@RequestMapping(value = "/api/v1/flow/tag")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class TagController {

  private final TagService tagService;

  @GetMapping(value = "/byType/{typeId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<Tag> getTagsByType(@PathVariable Long typeId) {
    //i wrote this to allow for tag types but for now there is only one
    return tagService.getTagsByType(typeId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<Tag> saveTag(@RequestBody Tag tag) {
    return tagService.saveTag(tag);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTag(@PathVariable Long id) {
    tagService.deleteTag(id);
  }

  @GetMapping(value = "/project/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProjectTag> getProjectTags(@PathVariable Long projectId) {
    //i wrote this to allow for tag types but for now there is only one
    return tagService.getProjectTags(projectId);
  }

}
