package com.albatross.api.v1.company.blueraven.services.ApiConfigTypeService;

import com.albatross.api.v1.company.blueraven.controllers.ApiConfigController;
import com.albatross.api.v1.company.blueraven.services.queries.ApiConfigQuery;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ApiConfigTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  /**
   * Get all API configuration types (non-archived)
   */
  public List<ApiConfigController.ApiConfigType> getApiConfigTypes() {
    Map<String, Object> params = new HashMap<>();

    return sqlCache.queryBySql(
      ApiConfigQuery.getApiConfigTypes,
      params,
      ApiConfigController.ApiConfigType.class
    );
  }

  /**
   * Save or update an API configuration type
   */
  public Optional<ApiConfigController.ApiConfigType> saveApiConfigType(ApiConfigController.ApiConfigType type) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();

    params.put("id", type.getId());
    params.put("name", type.getName());
    params.put("code", type.getCode());
    params.put("listOfValuesId", type.getListOfValuesId());

    Long id;
    if (type.getId() != null) {
      // Update existing
      id = type.getId();
      params.put("id", id);
      params.put("modifiedById", currentUser.trueUserId());
      sqlCache.updateBySql(ApiConfigQuery.updateApiConfigType, params);
    } else {
      // Insert new
      params.put("createdById", currentUser.trueUserId());
      id = sqlCache.updateBySqlReturningId(ApiConfigQuery.insertApiConfigType, params, "id").longValue();
    }

    return getApiConfigTypeById(id);
  }

  /**
   * Get API configuration type by ID
   */
  public Optional<ApiConfigController.ApiConfigType> getApiConfigTypeById(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      ApiConfigQuery.getApiConfigTypeById,
      params,
      ApiConfigController.ApiConfigType.class
    );
  }
}
