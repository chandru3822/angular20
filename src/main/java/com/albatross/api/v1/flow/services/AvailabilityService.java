package com.albatross.api.v1.flow.services;

import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.io.InputStream;
import java.sql.Array;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.TimeZone;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AvailabilityService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final DataSource dataSource;
  private final ObjectMapper om;
  private final CommunicationService communicationService;
  private final ProjectService projectService;

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
    params.put("modifiedById", user.getId());
    params.put("createdById", user.getId());

    Long id = null;

    if(null != ra.getId()) {
      id = ra.getId();
      params.put("id", id);
      sqlCache.update("availability.updateSchedule", params);
    } else {
      id = sqlCache.updateReturningId("availability.insertSchedule", params, "id").longValue();
    }

    if(null == ra.getEndDate()) {
      params.put("id", id);
      sqlCache.update("availability.updateScheduleWithoutEndDate", params);
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
  public Page<ResourceAppointment> getResourceAppointments(Long userId, Long orgId, Pageable pageable) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", userId);
    params.put("orgId", orgId);
    params.put("companyId", user.getCompanyId());
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ResourceAppointment> results = sqlCache.query("availability.getAppointmentsForResource", params, ResourceAppointment.class);
    Integer count = sqlCache.queryForObject("availability.getAppointmentsForResourceCount", params, Integer.class);

    Page<ResourceAppointment> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
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

  public ResponseEntity<Object> setCloserAppointment(CloserAppointmentRequest request) throws Exception {
      if (null != request.getProjectId() && null != request.getAppointmentTime() && null != request.getProjectProcessStepId() && null != request.getUsers()) {

        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", request.getProjectId());
        params.put("projectProcessStepId", request.getProjectProcessStepId());
        params.put("appointmentTime", request.getAppointmentTime());
        params.put("users", createSqlArrayOfType("int", request.getUsers()));


        List<CloserAppointmentResult> results = sqlCache.query("availability.setCloserAppointment", params, CloserAppointmentResult.class);

        if (!results.isEmpty()) {
          if (null != results.get(0) && results.get(0).getSuccess()) {
            //on success send email to the closer
            String closerEmail = results.get(0).getUserEmail();
            if(null != closerEmail) {
              //send email to closer
              InputStream inputStream = ScheduledConfig.class.getResourceAsStream("/communication/templates/closer-appointment.ftl.html");
              String template = IOUtils.toString(inputStream);
              Optional<Project> project = projectService.getProject(request.getProjectId());
              String projectAddress = "";
              String timeZoneAbbreviation = "";
              String startTime = "";

              // until we do time zones off of postal codes we have to ensure that the project had a state and a timezone assigned to the state
              if(project.isPresent() && !project.get().getTimeZoneAbbreviation().isEmpty()) {
                // todo: time zones.... this is not 100% accurate. there are states that have multiple time zones that we dont account for
                projectAddress = project.get().getStreet1() + ", " + project.get().getCity() + ", " + project.get().getState() + " " + project.get().getPostalCode();
                timeZoneAbbreviation = project.get().getTimeZoneAbbreviation();

                SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy h:mm a");
                TimeZone tz = TimeZone.getTimeZone(timeZoneAbbreviation);
                dateFormat.setTimeZone(tz);
                startTime = dateFormat.format(results.get(0).getAppointmentStartTime());
              }


              HashMap context = new HashMap();
              context.put("startTime", startTime);
              context.put("from", "Blue Raven Solar Sales HR");
              context.put("projectAddress", projectAddress);

              communicationService.sendEmail("New Customer Appointment Scheduled on " + startTime, StringUtils.trimWhitespace(closerEmail), template, context, "SalesOps@blueravensolar.com");
            }

            return ResponseEntity.ok(results.get(0));
          } else {
            //todo: handle other types of errors from function
            // Appointment no longer available. Please select another time.
            // Appointment is already scheduled.
            //          errorObj.put("message", "Appointment no longer available. Please select another time.");
            //          return new ResponseEntity<>(errorObj, HttpStatus.CONFLICT);
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Appointment no longer available. Please select another time.", new Exception());
          }
        } else {
          throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unknown Error Occurred", new Exception());
        }
        //todo: error handling
      } else {
        throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "Missing Parameters", new Exception());
      }

  }

  private Array createSqlArrayOfType(String typeName, List<?> array) throws SQLException {
    if (array != null && !array.isEmpty()) {
      try (Connection connection = dataSource.getConnection()) {
        return connection.createArrayOf(typeName, array.toArray());
      }
    }
    return null;
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
