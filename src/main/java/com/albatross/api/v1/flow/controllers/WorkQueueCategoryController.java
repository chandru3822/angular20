package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.workQueue.WorkQueueCategory;
import com.albatross.api.v1.flow.services.WorkQueueCategoryService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
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
  public List<WorkQueueCategory> getWorkQueueCategoriesFiltered () throws SQLException {
    return workQueueCategoryService.getWorkQueueCategories(true);
  }

  @GetMapping(value = "/admin", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueCategory> getWorkQueueCategories () throws SQLException {
    return workQueueCategoryService.getWorkQueueCategories(false);
  }

  @DeleteMapping(value = "/{categoryId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteCategory(@PathVariable Long categoryId) {
    workQueueCategoryService.deleteCategory(categoryId);
  }

  @PutMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueCategory> updateCategory(@RequestBody WorkQueueCategory category) {
    return workQueueCategoryService.updateCategory(category);
  }

  @PutMapping(value = "/saveHiddenAndWhiteList", produces = MediaType.APPLICATION_JSON_VALUE)
  public void saveHiddenAndWhiteList(@RequestParam(required = false) Boolean savePositions,
                                     @RequestBody WorkQueueCategory workQueueCategory) {
    //will only savePositions if they changed
    workQueueCategoryService.saveHiddenAndWhiteList(workQueueCategory, savePositions);
  }

  @PutMapping(value = "/order", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<WorkQueueCategory> updateCategoryDisplayOrders(@RequestBody List<WorkQueueCategory> categories) throws SQLException {
    return workQueueCategoryService.updateCategoryDisplayOrders(categories);
  }

  @PostMapping(value = "", produces = MediaType.APPLICATION_JSON_VALUE)
  public Optional<WorkQueueCategory> insertCategory(@RequestBody WorkQueueCategory category) {
    return workQueueCategoryService.insertCategory(category);
  }

}
