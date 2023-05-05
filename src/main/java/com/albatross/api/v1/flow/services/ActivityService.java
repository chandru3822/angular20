package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.Activity;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.ActivityQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<Activity> getActivitiesByObject(Long objectTypeId, Long sourceId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivities :
                   null;

    return sqlCache.queryBySql(sql, params, Activity.class);
  }

  public Optional<Activity> getOneActivity(Long objectTypeId, Long activityId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", activityId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivity :
                   null;

    return sqlCache.getBySql(sql, params, Activity.class);
  }

  public Optional<Activity> addActivityByObject(Long objectTypeId, Long sourceId, Activity newActivity) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("note", newActivity.getNote());
    params.put("sourceId", sourceId);
    params.put("userId", user.trueUserId());
    //parameterizing for future use
    params.put("activityTypeId", 2);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.addProjectActivity :
                   null;

    Long id = sqlCache.updateBySqlReturningId(sql, params, "id").longValue();



    return getOneActivity(objectTypeId, id);
  }

}
