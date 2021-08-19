package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.WorkQueueCategory;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class WorkQueueCategoryService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<WorkQueueCategory> getWorkQueueCategories() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());

    List<WorkQueueCategory> results = sqlCache.query("workQueueCategory.getCategoriesForCompany", params, WorkQueueCategory.class);
    return results;
  }

  public Optional<WorkQueueCategory> getCategory(Long id) {
    return sqlCache.get("workQueueCategory.getCategory",
        ImmutableMap.of("id", id),
        WorkQueueCategory.class);
  }

  public void deleteCategory(Long categoryId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("workQueueCategory.deleteCategory",
        ImmutableMap.of("id", categoryId,
            "modifiedById", user.trueUserId()));
  }

  public Optional<WorkQueueCategory> updateCategory(WorkQueueCategory category) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("modifiedById", user.trueUserId());
    params.put("color", category.getColor());
    params.put("id", category.getId());
    params.put("workQueueCategory", category.getWorkQueueCategory());
    params.put("displayOrder", category.getDisplayOrder());
    sqlCache.update("workQueueCategory.updateCategory", params);

    return getCategory(category.getId());
  }

  public List<WorkQueueCategory> updateCategoryDisplayOrders(List<WorkQueueCategory> categories) {
    for(WorkQueueCategory cat : categories) {
      //save each display_order (i guess i can just call the full update - will do the same thing)
      updateCategory(cat);
    }
    return getWorkQueueCategories();
  }

  public Optional<WorkQueueCategory> insertCategory(WorkQueueCategory category) {
    User user = securityService.getCurrentUser();
    Long id = sqlCache.updateReturningId("workQueueCategory.insertCategory",
        ImmutableMap.of("workQueueCategory", category.getWorkQueueCategory(),
            "createdById", user.trueUserId(),
            "color", category.getColor(),
            "companyId", user.getCompanyId()),
        "id").longValue();

    return getCategory(id);
  }


}
