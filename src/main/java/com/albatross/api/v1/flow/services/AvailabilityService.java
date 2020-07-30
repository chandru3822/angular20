package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
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
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", user.getCompanyId());

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
//      todo
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

  public void deleteSchedule(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("availability.deleteSchedule", params);
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
  // appt length
  public Long getResourceAppointmentLength(Long userId, Long orgId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgId", orgId);
    params.put("companyId", user.getCompanyId());

    Long result;
    if(orgId != null) {
      result = sqlCache.queryForObject("availability.getOrgAppointmentLength", params, Long.class);
    } else {
      result = sqlCache.queryForObject("availability.getUserAppointmentLength", params, Long.class);
    }
    return result;
  }

  @Data
  public static class AppointmentLength {
    private Long userId, orgId, defaultAppointmentLength;
  }

  public void saveResourceAppointmentLength(AppointmentLength al) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", al.getUserId());
    params.put("appointmentLength", al.getDefaultAppointmentLength());
    params.put("orgId", al.getOrgId());
    params.put("companyId", user.getCompanyId());

    if(al.getOrgId() != null) {
      sqlCache.update("availability.saveOrgAppointmentLength", params);
    } else {
      sqlCache.update("availability.saveUserAppointmentLength", params);
    }

  }

//  appointments
  public List<ResourceAppointment> getResourceAppointments(Long userId, Long orgId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgId", orgId);
    params.put("companyId", user.getCompanyId());

    List<ResourceAppointment> results = sqlCache.query("availability.getAppointmentsForResource", params, ResourceAppointment.class);
    return results;
  }

  public ResourceAppointment saveAppointment(ResourceAppointment ra) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("startTime", ra.getStartTime());
    params.put("endTime", ra.getEndTime());
    params.put("description", ra.getDescription());
    params.put("allDay", ra.getAllDay() == null ? false : ra.getAllDay());
    params.put("companyId", user.getCompanyId());
    params.put("orgId", ra.getOrgId());
    params.put("userId", ra.getUserId());

    Long id = null;

    if(null != ra.getId()) {
      id = ra.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.updateAppointment", params);
    } else {
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("availability.insertAppointment", params, "id").longValue();
    }

    return getOneResourceAppointment(id);
  }

  public void deleteAppointment(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("availability.deleteAppointment", params);
  }

  public List<TimeSlot> getTimeSlots(Long projectId, String startTime, String endTime, String availableDate) {

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("startTime", startTime);
    params.put("endTime", endTime);
    params.put("availableDate", availableDate);

    List<TimeSlot> results = sqlCache.query("availability.getTimeSlots", params, new TimeSlotMapper<>(TimeSlot.class, om));
    return results;
  }

  public ResourceAppointment getOneResourceAppointment(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ResourceAppointment> result = sqlCache.get("availability.getAppointment", params, ResourceAppointment.class);
    return result.orElse(null);
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

  public static class TimeSlotMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public TimeSlotMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Integer>> usersRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "users",
        new JsonCollectionDeserializer(usersRef, objectMapper));
    }
  }

}
