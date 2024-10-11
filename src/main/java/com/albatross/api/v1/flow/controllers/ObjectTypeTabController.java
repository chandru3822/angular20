package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.ObjectTypeTab;
import com.albatross.api.v1.flow.services.ObjectTypeTabService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/flow/objectTypeTab", produces = MediaType.APPLICATION_JSON_VALUE)
public class ObjectTypeTabController {

  private final ObjectTypeTabService objectTypeTabService;

  @GetMapping(value = "/project")
  public List<ObjectTypeTab> getTabs(@RequestParam(required = false) Long projectId) {
    return objectTypeTabService.getTabs(ObjectType.PROJECT.id, projectId);
  }

  @PostMapping(value = "/project")
  public ObjectTypeTab saveProjectTab(@RequestBody ObjectTypeTab tab) {
    return objectTypeTabService.saveTab(tab, ObjectType.PROJECT.id);
  }

  @PutMapping(value = "/order")
  public void saveTabOrder(@RequestBody List<ObjectTypeTab> tabs) {
    objectTypeTabService.updateTabOrder(tabs);
  }

  @DeleteMapping(value = "/{id}")
  public void deleteTab(@PathVariable Long id) {
    objectTypeTabService.deleteTab(id);
  }

}
