package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ObjectCategory;
import com.albatross.api.v1.flow.services.ObjectCategoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/objectCategory", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class ObjectCategoryController {

  private final ObjectCategoryService objectCategoryService;

  @GetMapping
  List<ObjectCategory> getObjectCategories(@RequestParam(required = false) Long objectTypeId){
    return objectCategoryService.getCategories(objectTypeId);
  }
}
