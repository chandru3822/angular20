package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.ObjectTypeTab;
import com.albatross.api.v1.flow.services.ObjectTypeTabService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/objectTypeTab")
public class ObjectTypeTabController {

  private final ObjectTypeTabService objectTypeTabService;

  @GetMapping(value = "/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ObjectTypeTab> getTabs () {
    return objectTypeTabService.getTabs(ObjectType.PROJECT.id);
  }

  @PostMapping(value = "/project", produces = MediaType.APPLICATION_JSON_VALUE)
  public ObjectTypeTab saveProjectTab (@RequestBody ObjectTypeTab tab) {
    return objectTypeTabService.saveTab(tab, ObjectType.PROJECT.id);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveTabOrder (@RequestBody List<ObjectTypeTab> tabs) {
    objectTypeTabService.updateTabOrder(tabs);
  }

  @DeleteMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTab (@PathVariable Long id) {
    objectTypeTabService.deleteTab(id);
  }

}
