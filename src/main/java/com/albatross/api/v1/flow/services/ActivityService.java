package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.queries.ActivityQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ActivityService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;

  public List<ActivityType> getActivityTopicsByObject(Long objectTypeId, Long sourceId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getActivityTopicsByProject :
                   null;

    return sqlCache.queryBySql(sql, params, new ActivityTypeMapper<>(ActivityType.class, om));
  }

  public List<Activity> getActivitiesByObject(Long objectTypeId, Long sourceId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("sourceId", sourceId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivities :
                   null;

    return sqlCache.queryBySql(sql, params, new ActivityMapper<>(Activity.class, om));
  }

  public void deleteActivityById(Long objectTypeId, Long activityId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    params.put("userId", user.trueUserId());
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.archiveProjectActivity : null;

    sqlCache.updateBySql(sql, params);
  }

  public Optional<Activity> getOneActivity(Long objectTypeId, Long activityId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", activityId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivity :
                   null;

    return sqlCache.getBySql(sql, params, new ActivityMapper<>(Activity.class, om));
  }

  public void pinActivity(Long objectTypeId, Long activityId, Boolean pinned) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    params.put("pinned", pinned);
    params.put("userId", user.trueUserId());
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.saveProjectActivityPinned : null;

    sqlCache.updateBySql(sql, params);
  }

  public Optional<Activity> addActivityByObject(Long objectTypeId, Long sourceId, Activity newActivity) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("note", newActivity.getNote());
    params.put("sourceId", sourceId);
    params.put("linked", null != newActivity.getLinked() ? newActivity.getLinked() : false);
    params.put("linkedPpsId", newActivity.getLinkedPpsId());
    params.put("linkedPpseId", newActivity.getLinkedPpseId());
    params.put("userId", user.trueUserId());
    //parameterizing for future use
    params.put("activityTypeId", 2);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.addProjectActivity :
                   null;

    Long id = sqlCache.updateBySqlReturningId(sql, params, "id").longValue();

    //handle any activity hashtags
    updateActivityHashtag(objectTypeId, id, newActivity.getActivityHashtags());

    return getOneActivity(objectTypeId, id);
  }

  public Optional<Activity> editActivityByObject(Long objectTypeId, Long activityId, Activity activity) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("note", activity.getNote());
    params.put("activityId", activityId);
    params.put("linked", activity.getLinked());
    params.put("linkedPpsId", activity.getLinkedPpsId());
    params.put("linkedPpseId", activity.getLinkedPpseId());
    params.put("userId", user.trueUserId());
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.editProjectActivity : null;

    sqlCache.updateBySql(sql, params);

    //handle any activity hashtags
    updateActivityHashtag(objectTypeId, activityId, activity.getActivityHashtags());

    return getOneActivity(objectTypeId, activityId);
  }

  public List<ActivityHashtag> updateActivityHashtag(Long objectTypeId, Long activityId, List<ActivityHashtag> activityHashtags) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", user.trueUserId());
    params.put("activityId", activityId);

    if(null != activityHashtags) {
      for(ActivityHashtag activityHashtag : activityHashtags) {
        if(null != activityHashtag.getArchived() && activityHashtag.getArchived()) {
          //archive hashtag
          params.put("id", activityHashtag.getId());
          String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.archiveProjectActivityHashtag : null;
          sqlCache.updateBySql(sql, params);
        } else {
          //handle upsert here
          params.put("hashtagId", activityHashtag.getHashtagId());
          String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.upsertProjectActivityHashtag : null;
          sqlCache.updateBySql(sql, params);
        }
      }
    }

    return getActivityHashtags(objectTypeId, activityId);
  }

  public List<ActivityHashtag> getActivityHashtags(Long objectTypeId, Long activityId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("activityId", activityId);
    String sql = objectTypeId.equals(ObjectType.PROJECT.id) ? ActivityQuery.getProjectActivityHashtags : null;

    return sqlCache.queryBySql(sql, params, ActivityHashtag.class);
  }


  public static class ActivityMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ActivityMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActivityHashtag>> activityHashtagsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "activityHashtags",
        new JsonCollectionDeserializer(activityHashtagsRef, objectMapper));

    }
  }

  public static class ActivityTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ActivityTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ActivityTypeHashtag>> activityHashtagsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "activityTypeHashtags",
        new JsonCollectionDeserializer(activityHashtagsRef, objectMapper));

    }
  }
}
