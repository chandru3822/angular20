package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.services.ApiConfigService.ApiConfigService;
import com.albatross.api.v1.company.blueraven.services.ApiConfigTypeService.ApiConfigTypeService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/company/blueraven/flow")
@RequiredArgsConstructor
public class ApiConfigController {

  private final ApiConfigTypeService apiConfigTypeService;
  private final ApiConfigService apiConfigService;

  @GetMapping(value = "/api-config-type")
  public List<ApiConfigType> getApiConfigTypes() {
    return apiConfigTypeService.getApiConfigTypes();
  }

  @PostMapping(value = "/api-config-type")
  public Optional<ApiConfigType> saveApiConfigType(@RequestBody ApiConfigType type) {
    return apiConfigTypeService.saveApiConfigType(type);
  }

  @GetMapping(value = "/api-config")
  public List<ListOfValues> getApiConfigs(@RequestParam(required = false) Long listOfValuesId) {
    if (listOfValuesId != null) {
      return apiConfigService.getApiConfigsByTypeId(listOfValuesId);
    }
    return null;
  }

  @GetMapping(value = "/api-config/all")
  public List<ApiConfig> getAllApiConfigs() {
    return apiConfigService.getAllApiConfigs();
  }

  @PostMapping(value = "/api-config")
  public Optional<ApiConfig> saveApiConfig(@RequestBody ListOfValues config) {
    return apiConfigService.saveApiConfig(config);
  }

  @Data
  public static class ApiConfigType {
    private Long id;
    private String name;
    private String code;
    private Long listOfValuesId;
  }

  @Data
  public static class ListOfValues {
    private Long id;
    private Long parentId;
    private String name;
    private String code;
    private String values;
    private Long apiConfigTypeId;
    private Long listOfValuesId;
  }

  @Data
  public static class ApiConfig {
    private Long id;
    private Long apiConfigTypeId;
    private Long listOfValuesId;
    private String value;
  }
}
