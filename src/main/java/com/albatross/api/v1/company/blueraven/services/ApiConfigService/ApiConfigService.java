package com.albatross.api.v1.company.blueraven.services.ApiConfigService;

import com.albatross.api.v1.company.blueraven.controllers.ApiConfigController;
import com.albatross.api.v1.company.blueraven.services.queries.ApiConfigQuery;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.utils.SqlCache;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ApiConfigService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  /**
   * Get API configurations by config type ID
   */
  public List<ApiConfigController.ListOfValues> getApiConfigsByTypeId(Long listOfValuesId) {
    Map<String, Object> params = new HashMap<>();
    params.put("listOfValuesId", listOfValuesId);

    return sqlCache.queryBySql(
      ApiConfigQuery.getApiConfigsByTypeId,
      params,
      ApiConfigController.ListOfValues.class
    );
  }

  /**
   * Get API configuration by ID
   */
  public Optional<ApiConfigController.ApiConfig> getApiConfigById(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      ApiConfigQuery.getApiConfigById,
      params,
      ApiConfigController.ApiConfig.class
    );
  }

  /**
   * Save or update an API configuration
   */
  public Optional<ApiConfigController.ApiConfig> saveApiConfig(ApiConfigController.ListOfValues config) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();

    params.put("value", config.getValues());
    params.put("apiConfigTypeId", config.getApiConfigTypeId());
    params.put("listOfValuesId", config.getListOfValuesId());

    Long id;
    if (config.getId() != null) {
      // Update existing
      id = config.getId();
      params.put("id", id);
      params.put("modifiedById", currentUser.trueUserId());
      sqlCache.updateBySql(ApiConfigQuery.updateApiConfig, params);
    } else {
      // Insert new
      params.put("createdById", currentUser.trueUserId());
      id = sqlCache.updateBySqlReturningId(ApiConfigQuery.insertApiConfig, params, "id").longValue();
    }

    return getApiConfigById(id);
  }

  public List<ApiConfigController.ApiConfig> getAllApiConfigs() {
    return sqlCache.queryBySql(
      ApiConfigQuery.getAllApiConfigs,
      new HashMap<>(),
      ApiConfigController.ApiConfig.class
    );
  }
}
