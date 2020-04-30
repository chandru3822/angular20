package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
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
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AvailabilityService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<ResourceSchedule> getResourceAvailability(Long userId, Long orgId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgId", orgId);
    params.put("companyId", user.getCompanyId());

    List<ResourceSchedule> results = sqlCache.query("availability.getAllForResource", params, new ResourceScheduleMapper<>(ResourceSchedule.class, om));
    return results;
  }

  public List<WorkDay> getWorkDays() {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<WorkDay> results = sqlCache.query("availability.getWorkDays", params, WorkDay.class);
    return results;
  }

  public ResourceSchedule getOneResourceAvailability(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ResourceSchedule> result = sqlCache.get("availability.getOne", params, new ResourceScheduleMapper<>(ResourceSchedule.class, om));
    return result.orElse(null);
  }

  public ResourceSchedule saveSchedule(ResourceSchedule ra) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startDate", ra.getStartDate());
    params.put("endDate", ra.getEndDate());
    params.put("companyId", user.getCompanyId());
    params.put("orgId", ra.getOrgId());
    params.put("userId", ra.getUserId());

    Long id = null;

    if(null != ra.getId()) {
      id = ra.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.updateSchedule", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("availability.insertSchedule", params, "id").longValue();
    }

    // handle saving each day's working hours
    if(!ra.getResourceScheduleAvailability().isEmpty()) {
      for(ResourceScheduleAvailability rsa : ra.getResourceScheduleAvailability()) {
        saveAvailability(rsa, id);
      }
    }

    return getOneResourceAvailability(id);
  }

  public void saveAvailability(ResourceScheduleAvailability rsa, Long resourceScheduleId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();

    params.put("startTime", rsa.getStartTime());
    params.put("endTime", rsa.getEndTime());
    params.put("dayOfWeekId", rsa.getDayOfWeekId());
    params.put("companyId", user.getCompanyId());
    params.put("resourceScheduleId", resourceScheduleId);
    params.put("createdById", user.getId());

    if(null != rsa.getId()) {
      params.put("archived", null == rsa.getArchived() ? false : rsa.getArchived());
      params.put("id", rsa.getId());
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.updateHours", params);
    } else {

      sqlCache.update("availability.insertHours", params);
    }

  }

  public static class ResourceScheduleMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ResourceScheduleMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ResourceScheduleAvailability>> resourceScheduleAvailabilityRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "resourceScheduleAvailability",
        new JsonCollectionDeserializer(resourceScheduleAvailabilityRef, objectMapper));
    }
  }

}
