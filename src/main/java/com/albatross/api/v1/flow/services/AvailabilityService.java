package com.albatross.api.v1.flow.services;

import com.albatross.api.config.ScheduledConfig;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.LocationUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SystemSettings;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapbox.geojson.Point;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.dmfs.rfc5545.DateTime;
import org.dmfs.rfc5545.recur.InvalidRecurrenceRuleException;
import org.dmfs.rfc5545.recur.RecurrenceRule;
import org.dmfs.rfc5545.recur.RecurrenceRuleIterator;
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
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.function.ObjLongConsumer;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AvailabilityService {

  private final SqlCache sqlCache;
  private final LocationUtils locationUtils;
  private final SecurityService securityService;
  private final DataSource dataSource;
  private final ObjectMapper om;
  private final CommunicationService communicationService;
  private final ProjectService projectService;
  private final ProjectProcessStepService projectProcessStepService;
  private final CustomFieldValueService customFieldValueService;

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

  public List<ResourceSchedule> saveSchedule(ResourceSchedule ra) {
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

    //this should account for a new infinite schedule, or a schedule added after an infinite one but that has an end date
    params.put("id", id);
    sqlCache.update("availability.updateScheduleWithoutEndDate", params);

    // handle saving each day's working hours
    if(!ra.getResourceScheduleAvailability().isEmpty()) {
      for(ResourceScheduleAvailability rsa : ra.getResourceScheduleAvailability()) {
        saveAvailability(rsa, id);
      }
    }

    return getResourceAvailability(ra.getUserId(), ra.getOrgId());
  }

  public void deleteSchedule(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("availability.deleteSchedule", params);
  }

  public void saveAvailability(ResourceScheduleAvailability rsa, Long resourceScheduleId) {
    if((null == rsa.getStartTime() && null != rsa.getEndTime()) || (null == rsa.getEndTime() && null != rsa.getStartTime())) {
      String msg = "AVAILABILITY: Daily schedule must have start and end time. ID: " + rsa.getId()
          + ", Day of Week: " + rsa.getDayOfWeekId() + ", Start Time: " + rsa.getStartTime() + ", End Time: " + rsa.getEndTime();
      log.error(msg);
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Daily schedule must have start and end time.", new Exception());
    }
    User user = securityService.getCurrentUser();
    boolean archived = null == rsa.getArchived() ? false : rsa.getArchived();
    boolean hasId = null != rsa.getId();
    HashMap<String, Object> params = new HashMap<>();
    params.put("startTime", rsa.getStartTime());
    params.put("endTime", rsa.getEndTime());
    params.put("dayOfWeekId", rsa.getDayOfWeekId());
    params.put("companyId", user.getCompanyId());
    params.put("resourceScheduleId", resourceScheduleId);
    params.put("createdById", user.getId());

    //if existing and archived, or existing and they send in null start and end time
    if(hasId && (archived || (null == rsa.getStartTime() && null == rsa.getEndTime() ))) {
      params.put("id", rsa.getId());
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.archiveHours", params);
    } else if(hasId) {
      params.put("id", rsa.getId());
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.updateHours", params);
    } else if (null != rsa.getStartTime() && null != rsa.getEndTime()){
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

    Optional<Long> result;
    if(orgId != null) {
      result = sqlCache.queryForObjectOptional("availability.getOrgAppointmentLength", params, Long.class);
    } else {
      result = sqlCache.queryForObjectOptional("availability.getUserAppointmentLength", params, Long.class);
    }
    return result.orElse(null);
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

  @Data
  public static class OverrideAudit {
    private Long userPositionId, projectId, projectProcessStepId;
  }

  public void saveOverrideInfoToAudit(OverrideAudit audit) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("createdById", user.getId());
    params.put("projectId", audit.getProjectId());
    params.put("projectProcessStepId", audit.getProjectProcessStepId());
    params.put("userPositionId", audit.getUserPositionId());

    sqlCache.update("availability.saveOverrideInfoToAudit", params);

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
    //title was added recently and the current mobile app doesn't send it in, it only sends description. will default to use that until the app supports Title
    params.put("title", null != ra.getTitle() ? ra.getTitle() : ra.getDescription());
    params.put("description", ra.getDescription());
    params.put("location", ra.getLocation());
    params.put("allDay", ra.getAllDay() == null ? false : ra.getAllDay());
    params.put("companyId", user.getCompanyId());
    params.put("orgId", ra.getOrgId());
    params.put("userId", ra.getUserId());
    params.put("recurrence", ra.getRecurrence());
    params.put("recurringEventEndType", ra.getRecurringEventEndType());
    params.put("recurringStartTime", ra.getRecurringStartTime());
    params.put("recurringEndTime", ra.getRecurringEndTime());

    Long id = null;

    if(null != ra.getId()) {
      id = ra.getId();
      params.put("id", id);
      params.put("modifiedById", user.getId());
      sqlCache.update("availability.updateAppointment", params);
    } else {
      if(null == ra.getRepeat() || !ra.getRepeat()) {
        params.put("createdById", user.getId());
        params.put("recurringEventId", null);
        id = sqlCache.updateReturningId("availability.insertAppointment", params, "id").longValue();
      } else {
        createRecurringEvents(ra);
      }
    }

    ResourceAppointment appt = getOneResourceAppointment(id);
    if(null != ra.getLocation() && (null == ra.getId() || ra.getReloadCoordinates())) {
      getAppointmentsCoordinates(ra.getLocation(), id);
    }
    return appt;
  }

  public void getAppointmentsCoordinates(String address, Long id) {
    locationUtils.getGeocode(address, id, new CustomGeoFunction());
  }

  public void processFutureRecurringEvents() {
    //list of distinct recurring events for active users with all of the existing events beyond the starting date
    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.MONTH, 11);
    Date startingDate = cal.getTime();
    HashMap<String, Object> params = new HashMap<>();
    params.put("startingDate", startingDate);
    List<RecurringResourceAppointment> recurringAppointments = sqlCache.query("availability.getDistinctRecurringEvents", params, new RecurringAppointmentMapper<>(RecurringResourceAppointment.class, om));

    for(RecurringResourceAppointment rra : recurringAppointments) {
      //create a rule and start saving a months worth of new appts.
      //check if the new appt already exists
      try {
        SimpleDateFormat formatNowDay = new SimpleDateFormat("dd");
        SimpleDateFormat formatNowMonth = new SimpleDateFormat("MM");
        SimpleDateFormat formatNowYear = new SimpleDateFormat("yyyy");
        SimpleDateFormat formatNowHour = new SimpleDateFormat("HH");
        SimpleDateFormat formatNowMinute = new SimpleDateFormat("mm");

        String recurringStartDay = formatNowDay.format(startingDate);
        String recurringStartMonth = formatNowMonth.format(startingDate);
        String recurringStartYear = formatNowYear.format(startingDate);
        String recurringStartHour = formatNowHour.format(rra.getRecurringStartTime());
        String recurringStartMinute = formatNowMinute.format(rra.getRecurringStartTime());

        //convert the start date to a !isFloating() value otherwise it will fail when using a rule with an end date
        DateTime recurringStartDate = new DateTime(TimeZone.getTimeZone("UTC"), Integer.parseInt(recurringStartYear), Integer.parseInt(recurringStartMonth) - 1, Integer.parseInt(recurringStartDay), Integer.parseInt(recurringStartHour), Integer.parseInt(recurringStartMinute), 00);

        RecurrenceRule rule = new RecurrenceRule((rra.getRecurrence()));
        RecurrenceRuleIterator it = rule.iterator(recurringStartDate);

        // Arbitrary limit for recurring events that never end.
        boolean limitReached = false;

        while (it.hasNext() && !limitReached) {
          boolean alreadyExists = false;
          LocalDateTime currentEventStart = LocalDateTime.ofInstant(Instant.ofEpochMilli(it.nextDateTime().getTimestamp()), ZoneOffset.UTC);
          LocalDateTime currentEventEnd = currentEventStart.plusMinutes(rra.getDuration());
          log.info("CRON: recurrence: {}", rra.getRecurrence());
          //if the recurring event start time is greater than 1 year from the cron start, stop adding appointments
          if(currentEventStart.isAfter(LocalDateTime.now().plusYears(1))) {
            limitReached = true;
          } else {
//            check if the appointment trying to be created already exists.
            //i am sick of working on this!!  the startTimeString and endTimeString will both have :00 as the seconds, the currentEventStart and End fields do not
            //i could reformat the dates, do a substring or do contains.  contains seems easier so i am doing that for now
            ResourceAppointment appt = rra.getAppointments().stream().filter(a -> a.getStartTimeString().contains(currentEventStart.toString()) && a.getEndTimeString().contains(currentEventEnd.toString())).findFirst().orElse(null);
            if(null != appt) {
              alreadyExists = true;
            }
          }

          if(!limitReached && !alreadyExists){
            HashMap<String, Object> params2 = new HashMap<>();
            params2.put("startTime", currentEventStart);
            params2.put("endTime", currentEventEnd);
            params.put("title", null != rra.getTitle() ? rra.getTitle() : rra.getDescription());
            params.put("description", rra.getDescription());
            params.put("location", rra.getLocation());
            params2.put("allDay", rra.getAllDay() != null && rra.getAllDay());
            params2.put("companyId", rra.getCompanyId());
            params2.put("createdById", SystemSettings.CRON_USER.getId());
            params2.put("orgId", rra.getOrgId());
            params2.put("userId", rra.getUserId());
            params2.put("recurrence", rra.getRecurrence());
            params2.put("recurringEventEndType", rra.getRecurringEventEndType());
            params2.put("recurringStartTime", rra.getRecurringStartTime());
            params2.put("recurringEndTime", rra.getRecurringEndTime());
            params2.put("recurringEventId", rra.getRecurringEventId());


            insertEvent(params2);
          }
        }


      } catch (InvalidRecurrenceRuleException e) {
        log.error("RECURRENCE: " + e.getMessage());
      }
    }
  }

  public void createRecurringEvents(ResourceAppointment ra) {
    try {
      User user = securityService.getCurrentUser();

      final String newRecurringEventId = UUID.randomUUID().toString();
      //the recurring start time is the same as the start time of the appt they are creating
      ra.setRecurringStartTime(ra.getStartTime());

      SimpleDateFormat formatNowDay = new SimpleDateFormat("dd");
      SimpleDateFormat formatNowMonth = new SimpleDateFormat("MM");
      SimpleDateFormat formatNowYear = new SimpleDateFormat("yyyy");
      SimpleDateFormat formatNowHour = new SimpleDateFormat("HH");
      SimpleDateFormat formatNowMinute = new SimpleDateFormat("mm");

      String recurringStartDay = formatNowDay.format(ra.getRecurringStartTime());
      String recurringStartMonth = formatNowMonth.format(ra.getRecurringStartTime());
      String recurringStartYear = formatNowYear.format(ra.getRecurringStartTime());
      String recurringStartHour = formatNowHour.format(ra.getRecurringStartTime());
      String recurringStartMinute = formatNowMinute.format(ra.getRecurringStartTime());

      //convert the start date to a !isFloating() value otherwise it will fail when using a rule with an end date
      DateTime recurringStartDate = new DateTime(TimeZone.getTimeZone("UTC"), Integer.parseInt(recurringStartYear), Integer.parseInt(recurringStartMonth) - 1, Integer.parseInt(recurringStartDay), Integer.parseInt(recurringStartHour), Integer.parseInt(recurringStartMinute), 00);

      RecurrenceRule rule = new RecurrenceRule((ra.getRecurrence()));
      RecurrenceRuleIterator it = rule.iterator(recurringStartDate);

      // Arbitrary limit for recurring events that never end.
      boolean limitReached = false;

      final long duration = ChronoUnit.MINUTES.between(ra.getStartTime().toInstant(), ra.getEndTime().toInstant());
      //todo: get list of events for the event id
      while (it.hasNext() && !limitReached) {
        LocalDateTime currentEventStart = LocalDateTime.ofInstant(Instant.ofEpochMilli(it.nextDateTime().getTimestamp()), ZoneOffset.UTC);
        LocalDateTime currentEventEnd = currentEventStart.plusMinutes(duration);
        //if the recurring event start time is greater than 1 year from now, stop adding appointments
        if(currentEventStart.isAfter(LocalDateTime.now().plusYears(1))) {
          limitReached = true;
        } else {
          //todo: check if event exists in the list from above
          HashMap<String, Object> params = new HashMap<>();
          params.put("startTime", currentEventStart);
          params.put("endTime", currentEventEnd);
          params.put("title", null != ra.getTitle() ? ra.getTitle() : ra.getDescription());
          params.put("description", ra.getDescription());
          params.put("location", ra.getLocation());
          params.put("allDay", ra.getAllDay() != null && ra.getAllDay());
          params.put("companyId", user.getCompanyId());
          params.put("createdById", user.getId());
          params.put("orgId", ra.getOrgId());
          params.put("userId", ra.getUserId());
          params.put("recurrence", ra.getRecurrence());
          params.put("recurringEventEndType", ra.getRecurringEventEndType());
          params.put("recurringStartTime", ra.getRecurringStartTime());
          params.put("recurringEndTime", ra.getRecurringEndTime());
          params.put("recurringEventId", newRecurringEventId);

          insertEvent(params);
        }
      }

    } catch (InvalidRecurrenceRuleException e) {
      log.error("RECURRENCE: " + e.getMessage());
    }
  }

  public void insertEvent(HashMap<String, Object> params) {
    //insert using the params we created before
    sqlCache.update("availability.insertAppointment", params);
  }

  public void deleteAppointment(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("availability.deleteAppointment", params);
  }

  public void deleteAppointmentsByRecurrence(String recurringEventId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("recurringEventId", recurringEventId);
    params.put("modifiedById", user.getId());

    sqlCache.update("availability.deleteAppointmentsByRecurrence", params);
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
        User user = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("projectId", request.getProjectId());
        params.put("userId", user.getId());
        params.put("projectProcessStepId", request.getProjectProcessStepId());
        params.put("appointmentTime", request.getAppointmentTime());
        params.put("users", createSqlArrayOfType("int", request.getUsers()));


        List<CloserAppointmentResult> results = sqlCache.query("availability.setCloserAppointment", params, CloserAppointmentResult.class);

        if (!results.isEmpty()) {
          if (null != results.get(0) && results.get(0).getSuccess()) {

            projectProcessStepService.performAutoTriggerActions(request.getProjectProcessStepId(), securityService.getCurrentUserDetails());

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

              // only send email if we know the timezone to adjust the start time for
              if(project.isPresent() && null != project.get().getTimeZone()) {
                projectAddress = project.get().getStreet1() + ", " + project.get().getCity() + ", " + project.get().getState() + " " + project.get().getPostalCode();
                timeZoneAbbreviation = project.get().getTimeZone();

                SimpleDateFormat dateFormat = new SimpleDateFormat("MM/dd/yyyy h:mm a");
                TimeZone tz = TimeZone.getTimeZone(timeZoneAbbreviation);
                dateFormat.setTimeZone(tz);
                startTime = dateFormat.format(results.get(0).getAppointmentStartTime());
              }


              HashMap context = new HashMap();
              context.put("startTime", startTime);
              context.put("from", "Blue Raven Solar Sales HR");
              context.put("projectAddress", projectAddress);

              communicationService.sendEmail("New Customer Appointment Scheduled on " + startTime, StringUtils.trimWhitespace(closerEmail), template, context, "SalesOps@blueravensolar.com", "Blue Raven Sales Operation");
            }
            //i need these back the same way we get them for normal cfgs on the frontend
            List<CustomFieldGroup> cfgs = customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.PROCESS_STEP.textValue(), request.getProjectProcessStepId());
            return ResponseEntity.ok(cfgs);
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

  public void cacheAvailability() {

    sqlCache.update("availability.cacheAvailability", Collections.emptyMap());
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

  private class CustomGeoFunction implements ObjLongConsumer {

    @Override
    public void accept(Object geoResult, long id) {
      // note: the coordinates in the returned object are reversed: Long, Lat

      //get the lat and long from point
      Point point = (Point)geoResult;
      Double latitude, longitude;
      List<Double> coordinates = point.coordinates();
      latitude = coordinates.get(1);
      longitude = coordinates.get(0);

      if(null != latitude && null != longitude) {
        //if lat and long then update appts's location
        HashMap<String, Object> params = new HashMap<>();
        params.put("latitude", latitude);
        params.put("longitude", longitude);
        params.put("id", id);

        sqlCache.update("availability.updateGeoLocation", params);
      }
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

  public static class RecurringAppointmentMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public RecurringAppointmentMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<ResourceAppointment>> appointmentsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "appointments",
        new JsonCollectionDeserializer(appointmentsRef, objectMapper));
    }
  }

}
