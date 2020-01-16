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
    params.put("companyId", user.getCompanyId());

    List<WorkQueueCategory> results = sqlCache.query("workQueueCategory.getCategoriesForCompany", params, WorkQueueCategory.class);
    return results;
  }

  public Optional<WorkQueueCategory> getCategory(Long companyId, Long id) {
    return sqlCache.get("workQueueCategory.getCategory",
        ImmutableMap.of("companyId", companyId,
            "id", id),
        WorkQueueCategory.class);
  }

  public void deleteCategory(Long categoryId) {
    User user = securityService.getCurrentUser();
    sqlCache.update("workQueueCategory.deleteCategory",
        ImmutableMap.of("id", categoryId,
            "modifiedById", user.getId()));
  }

  public void updateCategory(WorkQueueCategory category) {
    User user = securityService.getCurrentUser();
    sqlCache.update("workQueueCategory.updateCategory",
        ImmutableMap.of("companyId", category.getCompanyId(),
            "modifiedById", user.getId(),
            "id", category.getId(),
            "workQueueCategory", category.getWorkQueueCategory()));
  }

  public Optional<WorkQueueCategory> insertCategory(WorkQueueCategory category) {
    User user = securityService.getCurrentUser();
    Long id = sqlCache.updateReturningId("workQueueCategory.insertCategory",
        ImmutableMap.of("workQueueCategory", category.getWorkQueueCategory(),
            "createdById", user.getId(),
            "companyId", category.getCompanyId()),
        "id").longValue();

    return getCategory(category.getCompanyId(), id);
  }


}
