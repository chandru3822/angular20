package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.WorkQueueCategory;
import com.albatross.api.v1.flow.services.WorkQueueCategoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/workQueueCategory")
public class WorkQueueCategoryController {

  @Autowired
  private WorkQueueCategoryService workQueueCategoryService;

  @GetMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueCategory> getWorkQueueCategories () {
    return workQueueCategoryService.getWorkQueueCategories();
  }

  @DeleteMapping(value = "/category/{categoryId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCategory(@PathVariable Long categoryId) {
    workQueueCategoryService.deleteCategory(categoryId);
  }

  @PutMapping(value = "/category", produces = MediaType.APPLICATION_JSON_VALUE)
  public void updateCategory(@RequestBody WorkQueueCategory category) {
    workQueueCategoryService.updateCategory(category);
  }

  @PostMapping(value = "/category", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueCategory> insertCategory(@RequestBody WorkQueueCategory category) {
    return workQueueCategoryService.insertCategory(category);
  }

}
