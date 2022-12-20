package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.model.WhiteListedPosition;
import com.albatross.api.v1.flow.model.workQueue.WorkQueueCategory;
import com.albatross.api.v1.flow.queries.WorkQueueCategoryQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class WorkQueueCategoryService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final UserPositionService userPositionService;
  private final SqlArrayService sqlArrayService;

  public List<WorkQueueCategory> getWorkQueueCategories(Boolean filtered) throws SQLException {
    User user = securityService.getCurrentUser();
    Boolean userIsSuperAdmin = securityService.userIsSuperAdmin(user.getId());

    List<UserPosition> userPositions = null;
    if(filtered) {
     userPositions = userPositionService.getAllActiveUserPositions(user.getId());
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getHighestParentCompanyId());
    params.put("positionIds", null != userPositions && userPositions.size() > 0 ? sqlArrayService.createSqlArrayOfType("int", userPositions.stream().map(UserPosition::getPositionId).collect(Collectors.toList())) : null);
    params.put("hiddenWqcOverride", userIsSuperAdmin);
    params.put("filtered", filtered);

    return sqlCache.queryBySql(
      WorkQueueCategoryQuery.getCategoriesForCompany, params, new WorkQueueCategoryMapper<>(WorkQueueCategory.class, om));
  }

  public Optional<WorkQueueCategory> getCategory(Long id) {
    return sqlCache.getBySql(
      WorkQueueCategoryQuery.getCategory, ImmutableMap.of("id", id), WorkQueueCategory.class);
  }

  public void deleteCategory(Long categoryId) {
    User user = securityService.getCurrentUser();
    sqlCache.updateBySql(
      WorkQueueCategoryQuery.deleteCategory,
        ImmutableMap.of("id", categoryId, "modifiedById", user.trueUserId()));
  }

  public void saveHiddenAndWhiteList(WorkQueueCategory workQueueCategory, Boolean savePositions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("hidden", workQueueCategory.getHidden());
    params.put("wqcId", workQueueCategory.getId());
    params.put("whiteListTypeId", WhiteListType.WORK_QUEUE_CATEGORY_HIDDEN.id);

    sqlCache.updateBySql(WorkQueueCategoryQuery.saveHidden, params);

    if (!workQueueCategory.getHidden()) {
      // if ps is not readonly archive any white listed positions for it
      sqlCache.updateBySql(WorkQueueCategoryQuery.archiveWhiteListPositions, params);
    } else if (null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<WhiteListedPosition> positionsToUse = workQueueCategory.getHiddenWhiteListedPositions();
      List<Long> positionIdsUsed = workQueueCategory.getHiddenWhiteListedPositions().stream()
                                                .map(WhiteListedPosition::getPositionId)
                                                .collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if (positionIdsUsed.size() > 0) {
        sqlCache.updateBySql(WorkQueueCategoryQuery.archiveWhiteListPositionsNoLongerUsed, params);
      } else {
        // this means they removed ALL white listed positions
        sqlCache.updateBySql(WorkQueueCategoryQuery.archiveWhiteListPositions, params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.updateBySql(WorkQueueCategoryQuery.insertWhiteListPosition, params);
      }
    }
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
    sqlCache.updateBySql(WorkQueueCategoryQuery.updateCategory, params);

    return getCategory(category.getId());
  }

  public List<WorkQueueCategory> updateCategoryDisplayOrders(List<WorkQueueCategory> categories) throws SQLException {
    for (WorkQueueCategory cat : categories) {
      // save each display_order (i guess i can just call the full update - will do the same thing)
      updateCategory(cat);
    }
    return getWorkQueueCategories(false);
  }

  public Optional<WorkQueueCategory> insertCategory(WorkQueueCategory category) {
    User user = securityService.getCurrentUser();
    Long id =
        sqlCache
            .updateBySqlReturningId(
              WorkQueueCategoryQuery.insertCategory,
                ImmutableMap.of(
                    "workQueueCategory",
                    category.getWorkQueueCategory(),
                    "createdById",
                    user.trueUserId(),
                    "color",
                    category.getColor(),
                    "companyId",
                    user.getCompanyId()),
                "id")
            .longValue();

    return getCategory(id);
  }

  public static class WorkQueueCategoryMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public WorkQueueCategoryMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<WhiteListedPosition>> whiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "hiddenWhiteListedPositions",
        new JsonCollectionDeserializer(whiteListedPositionsRef, objectMapper));
    }
  }
}
