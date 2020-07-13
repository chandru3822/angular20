package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.LocationUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.model.Process;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectWriter;
import com.fasterxml.jackson.databind.SequenceWriter;
import com.fasterxml.jackson.dataformat.csv.CsvMapper;
import com.fasterxml.jackson.dataformat.csv.CsvSchema;
import com.google.common.collect.Collections2;
import com.mapbox.geojson.Point;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.function.ObjLongConsumer;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ContactService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  LocationUtils locationUtils;

  @Autowired
  SecurityService securityService;

  @Autowired
  ProjectService projectService;

  @Autowired
  ProcessService processService;

  @Autowired
  ProjectProcessStepService projectProcessStepService;

  @Autowired
  ObjectMapper om;

  public Page<Contact> searchContacts(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    /* TODO: if we have to enable server-side sorting, this was my first attempt that kinda worked
    --  order by case :orderBy is not null
    --     when :orderBy = 'date_created' then c.date_created::text
    --     when :orderBy = 'first_name' then nullif(c.first_name) else c.date_created::text end desc nulls last
     */

    List<Contact> results = sqlCache.query("contact.searchContacts", params, new ContactMapper<>(Contact.class, om));
    Integer count = sqlCache.queryForObject("contact.searchContactCount", params, Integer.class);

    Page<Contact> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }


  public ResponseEntity exportContacts(String query) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);

    List<Contact> results = sqlCache.query("contact.exportContacts", params, new ContactMapper<>(Contact.class, om));

    // set up CSV writing
    CsvMapper mapper = new CsvMapper();
    CsvSchema schema = mapper.typedSchemaFor(ContactExportTemplate.class).withHeader();
    ObjectWriter writer = mapper.writer(schema);
    ByteArrayOutputStream buffer = new ByteArrayOutputStream();

    // get contact deets and write to CSV
    try (SequenceWriter outToBuffer = writer.writeValues(buffer)) {
      // first, get deets
      Collection<ContactExportTemplate> details = Collections2.transform(
          results,
          ContactExportTemplate::from);

      // next, write them to a buffer so we can identify errors before writing across the network
      outToBuffer.writeAll(details);
      outToBuffer.flush();

      // finally, write to network because no errors were encountered
      return ResponseEntity.ok(buffer.toString(StandardCharsets.UTF_8));
    } catch (IOException e) {
      log.error("Encountered error while writing contact export to CSV", e);
      return ResponseEntity.status(500)
          .body("Encountered error while writing contact export to CSV");
    }
  }

  public Contact getContact(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    Optional<Contact> result = sqlCache.get("contact.getById", params, new ContactMapper<>(Contact.class, om));
    return result.orElse(null);
  }

  public Contact getContactByProjectId(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    Optional<Contact> result = sqlCache.get("contact.getByProjectId", params, new ContactMapper<>(Contact.class, om));
    return result.orElse(null);
  }

  public Contact updateContact(Contact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", contact.getFirstName());
    params.put("lastName", contact.getLastName());
    params.put("street1", contact.getStreet1());
    params.put("city", contact.getCity());
    params.put("stateId", contact.getStateId());
    params.put("postalCode", contact.getPostalCode());
    params.put("countryId", contact.getCountryId());
    params.put("phone", contact.getPhone());
    params.put("email", contact.getEmail());
    params.put("mobile", contact.getMobile());
    params.put("companyId", currentUser.getCompanyId());
    params.put("ownerUserPositionId", contact.getOwner() != null ? contact.getOwner().getUserPositionId() : null);

    Long id;

    if(null != contact.getId()) {
      id = contact.getId();
      params.put("contactTypeId", contact.getContactTypeId());
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      //add update when we add that to the UI
       sqlCache.update("contact.updateContact", params);
    } else {
      params.put("contactTypeId", ContactType.LEAD.id);
      params.put("createdById", currentUser.getId());
      id = sqlCache.updateReturningId("contact.insertContact", params, "id").longValue();
    }

    if(null == contact.getId() || contact.getReloadCoordinates()) {
      // if new contact or address changed, reload the coordinates
      getContactCoordinates(contact, id);
    }

    handleSavingCustomFieldValues(contact.getCustomFieldGroups(), id);

    return getContact(id);
  }

  public void getContactCoordinates(Contact contact, Long id) {
    //when the contact is new or the address changes, need to reload/save their lat/long from mapbox
    String contactAddress = getContactAddress(contact);
    locationUtils.getGeocode(contactAddress, id, new CustomGeoFunction());
  }

  public String getContactAddress(Contact contact) {
    StringJoiner sj = new StringJoiner(", ");
    sj.add(contact.getStreet1());
    sj.add(contact.getCity());
    sj.add(contact.getState() + ( null == contact.getPostalCode() ? "" : " " + contact.getPostalCode() ));

    return sj.toString();
  }

  public void updateOwner(Long id, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ownerUserPositionId", owner != null ? owner.getUserPositionId() : null);
    params.put("id", id);
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("contact.updateOwner", params);
  }

  public void updateMailingAddress(Contact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("street1", contact.getMailingStreet1());
    params.put("street2", contact.getMailingStreet2());
    params.put("city", contact.getMailingCity());
    params.put("state", contact.getState());
    params.put("postalCode", contact.getMailingPostalCode());
    params.put("modifiedById", currentUser.getId());
    params.put("id", contact.getId());
    //add update when we add that to the UI
    sqlCache.update("contact.updateMailingAddress", params);
  }

  public List<Owner> getOwnersForContact() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<Owner> results = sqlCache.query("contact.getOwners", params, Owner.class);
    return results;
  }

  public Project convertToContact(Long contactId, Process process) {
    User currentUser = securityService.getCurrentUser();

    //save contact_type_id
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("contactTypeId", ContactType.CUSTOMER.id);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("contact.convertToContact", params);

    //get contact to get their full name for the project
    Contact contact = getContact(contactId);

    //create project (use contact_full_name as project_name)
    Optional<Project> project = projectService.insertProject(contactId, process.getId(), contact.getFullName());

    //get initial process steps including the initial status
    List<ProcessStepProcess> initialProcessSteps = processService.getInitialProcessStepProcesses(process.getId());

    //for now we will insert the owner of the contact as the owner of all initial process steps
    Long ownerUserPositionId = (contact.getOwner() != null) ? contact.getOwner().getUserPositionId() : null;

    if(project.isPresent()) {
      //create all initial project_process_steps - these wont have a userPositionId
      for(ProcessStepProcess step : initialProcessSteps) {
        projectProcessStepService.insertProjectProcessStep(project.get().getId(), step.getProcessStepId(), step.getCompanyProcessStepStatusTypeId(), ownerUserPositionId, true);
      }
    }

    //return project data so the frontend can navigate to project/{id}
    return project.orElse(null);
  }

  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", cfv.getBooleanValue());
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("contactId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateContactCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertContactCustomFieldValue", params);
          }
        }
      }
    }
  }

  public static class ContactMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ContactMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<Owner>() {};

      bw.registerCustomEditor(Object.class, "owner",
          new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<Project>> projectsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "projects",
          new JsonCollectionDeserializer(projectsRef, objectMapper));
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
        //if lat and long then update contact's location
        HashMap<String, Object> params = new HashMap<>();
        params.put("latitude", latitude);
        params.put("longitude", longitude);
        params.put("id", id);

        sqlCache.update("contact.updateGeoLocation", params);
      }

    }
  }
}
