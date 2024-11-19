package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomBehaviorService;
import com.albatross.api.v1.company.blueraven.services.KlaviyoService;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.SystemActivity;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStepProcess;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.ActivityQuery;
import com.albatross.api.v1.flow.queries.ContactQuery;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ContactService {

  private final SqlCache sqlCache;
  private final SqlCacheRO sqlCacheRO;

  private final KlaviyoService klaviyoService;

  private final SecurityService securityService;

  private final ProjectService projectService;

  private final ProcessService processService;

  private final UserPositionService userPositionService;

  private final ProjectProcessStepService projectProcessStepService;

  private final SqlArrayService sqlArrayService;

  private final ObjectMapper om;

  private final AttachmentService attachmentService;

  private final MapboxApiService mapboxApiService;

  private final CustomFieldValueService customFieldValueService;

  private final BlueravenCustomBehaviorService blueravenCustomBehaviorService;

  private final ObjectCategoryService objectCategoryService;

  public Page<Contact> searchContacts(String query, String overrideType, List<Long> objectCategoryIds, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    Boolean viewAll =
      securityService.userHasFeatureAccessLevel(
        user.getId(),
        user.getCompanyId(),
        user.getHighestCompanyId(),
        "CONTACTS",
        List.of("VIEW_ALL"));
    Boolean viewCustom = false;

    if ((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view")))
        || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewCustom =
        securityService.userHasFeatureAccessLevel(
          user.getId(),
          user.getCompanyId(),
          user.getHighestCompanyId(),
          "CONTACTS",
          List.of("VIEW_CUSTOM"));
    }

    try {
      HashMap<String, Object> params = new HashMap<>();
      params.put("companyId", user.getCompanyId());
      params.put("parentCompanyId", user.getHighestParentCompanyId());
      params.put("isParent", isParent);
      params.put("viewAll", viewAll);
      params.put("userId", user.getId());
      params.put("query", query);

      params.put("objectCategoryIds", objectCategoryIds != null ? sqlArrayService.createSqlArrayOfType("int", objectCategoryIds) : null);

      params.put("limit", pageable.getPageSize());
      params.put("offset", pageable.getOffset());
      params.put("partnerIds", user.getPartnerIds());

      String searchSql = ContactQuery.searchByOwner;
      if (viewCustom) {
        searchSql = ContactQuery.searchDownline;
      } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
        searchSql = ContactQuery.search;
      }

      List<Contact> results;
      // move contact searching to replica to help balance DB load
      if (searchSql.equals(ContactQuery.search)) {
          results = sqlCacheRO.queryBySql(searchSql, params, new ContactMapper<>(Contact.class, om));
      } else {
          results = sqlCache.queryBySql(searchSql, params, new ContactMapper<>(Contact.class, om));
      }

      int count = 10000;
      return new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    } catch (SQLException e) {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST, "Could not convert object category ids to sql array.", new Exception());
    }
  }

  public Page<Contact> searchContactsByCategoryIds(Long parentObjectCategoryId, String query, Pageable pageable) {
    List<ObjectCategory> childCategories = objectCategoryService.getChildCategories(parentObjectCategoryId);
    List<Long> contactObjectCategoryIds = null;
    if(childCategories != null && !childCategories.isEmpty()) {
      contactObjectCategoryIds = childCategories.stream().map(ObjectCategory::getId).collect(Collectors.toList());
    }

    Page<Contact> contacts = searchContacts(query, null, contactObjectCategoryIds, pageable);
    return contacts;
  }

  public Contact getContact(Long contactId) {
    User user = securityService.getCurrentUser();
    return getContact(contactId, user);
  }

  public Contact getContact(Long contactId, User user) {
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("contactId", contactId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("partnerIds", (user.getPartnerIds() == null) ? List.of() : user.getPartnerIds());
    Optional<Contact> contact =
      sqlCache.getBySql(ContactQuery.getById, params, new ContactMapper<>(Contact.class, om));

    if (contact.isPresent()
        && null != contact.get().getOwner()
        && null != contact.get().getOwner().getUserId()) {
      String presignedUrl =
        attachmentService.getAttachmentPresignedUrl(
          contact.get().getOwner().getUserId(),
          com.albatross.api.v1.flow.enums.AttachmentType.USER_IMAGE.id);
      contact.get().getOwner().setPresignedUrl(presignedUrl);


      if (contact.get().getOwnerReadOnly()) {
        boolean ownerWhiteListed = false;
        boolean ownerAllowFlag = contact.get().getOwnerReadOnlyAllow();
        boolean breakLoop = false;
        //Checks if the user's position is in the whitelist
        for (int x = 0; x < contact.get().getOwnerReadOnlyWhiteListedPositions().size(); x++) {
          if (!breakLoop) {
            for (int z = 0; z < user.getUserPositions().size(); z++) {
              if (contact.get().getOwnerReadOnlyWhiteListedPositions().get(x).getPositionId().equals(user.getUserPositions().get(z).getPositionId())) {
                ownerWhiteListed = true;
              }

//              Re-enable Below when BR wants to handle multiple position stuff
//              else if (!ownerAllowFlag) {
//                ownerWhiteListed = false;
//                breakLoop = true;
//                break;
//              }
            }
          }
        }

        //If the flag is set to deny, flip the whitelist to be a deny list
        if (!ownerAllowFlag) {
          ownerWhiteListed = !ownerWhiteListed;
        }

        contact.get().getOwnerReadOnlyWhiteListedPositions().clear();
        contact.get().setOwnerReadOnly(!ownerWhiteListed);
      }
    }

    return contact.orElse(null);
  }


  public Contact getContactByProjectId(Long projectId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("companyId", user.getCompanyId());
    return sqlCache
      .getBySql(ContactQuery.getByProjectId, params, new ContactMapper<>(Contact.class, om))
      .orElse(null);
  }

  public void deleteContact(Long contactId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.trueUserId());
    params.put("contactId", contactId);
    sqlCache.updateBySql(ContactQuery.delete, params);
  }


  // todo: take this function away after we update the 1.6 million records geo temp
  public void updateContactLatLong(Integer limit) throws Exception {
    // limit = how many to try and run, is passed in from endpoint
    int limitCount = null == limit ? 100 : limit;
    HashMap<String, Object> params = new HashMap<>();
    params.put("limit", limitCount);
    log.info("*** CONTACTS: attempting to update lat/long for {} contacts ***", limitCount);
    // this list should already only include contacts that had at least a street1 and city
    List<Contact> contactsToUpdate =
      sqlCache.queryBySql(ContactQuery.getContactsToUpdateForLatLong, params, Contact.class);

    for (Contact contact : contactsToUpdate) {
      Double latitude = null, longitude = null;
      List<Double> coordinates = mapboxApiService.getLatLong(contact.getStreet1(), contact.getCity(),
        contact.getState(), contact.getPostalCode());

      // if we found new coordinates then uses those values
      if (!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1)) {
        // 1 = lat, 0 = long
        latitude = coordinates.get(1);
        longitude = coordinates.get(0);
      }

      // do this update even if lat/long are null so that it sets the temp_geo_attempted to true so
      // we know not to try it again
      HashMap<String, Object> params2 = new HashMap<>();
      params2.put("id", contact.getId());
      params2.put("latitude", latitude);
      params2.put("longitude", longitude);
      sqlCache.updateBySql(ContactQuery.updateLatLongTemp, params2);
    }
    log.info("*** CONTACTS: finished updating lat/long for {} contacts ***", limitCount);
  }


  public ResponseEntity<ContactWithCfvs> updateContactCustom(Long cId, ContactWithCfvs request) throws Exception {
    User user = securityService.getCurrentUser();

    //update/insert Contact
    Long contactId = cId;
    Contact newContact = new Contact();
    if (null != request.getContact()) {
      newContact = updateContact(request.getContact());
      contactId = newContact.getId();
    }


    //handle custom field values
    List<CustomFieldGroup> cfgs = customFieldValueService.handleAllContactSaveBehavior(contactId, request.getCfvs(), true);

    //we can check the user_id cuz if they are saving to the contact it should be the same
    if (user.getCompanyId() == 3L) {
      //if BR call blueraven service level stuff
      blueravenCustomBehaviorService.handleCustomContactCreation(contactId, null == cId, request.getCfvs(), cfgs);
    }

    ContactWithCfvs responseBody = new ContactWithCfvs();
    responseBody.setContact(newContact);
    responseBody.setCfgs(cfgs);
    return new ResponseEntity<>(responseBody, HttpStatus.OK);
  }

  public Contact updateContact(Contact contact) throws Exception {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", CleanString.replaceApostrophe(contact.getFirstName()));
    params.put("lastName", CleanString.replaceApostrophe(contact.getLastName()));
    params.put("street1", contact.getStreet1());
    params.put("city", contact.getCity());
    params.put("companyStateId", contact.getCompanyStateId());
    params.put("postalCode", contact.getPostalCode());
    params.put("companyCountryId", contact.getCompanyCountryId());
    params.put("phone", contact.getPhone());
    params.put("email", contact.getEmail());
    params.put("mobile", contact.getMobile());
    params.put(
      "companyId",
      null != contact.getCompanyId() ? contact.getCompanyId() : currentUser.getCompanyId());

    Long id;
    Double latitude = contact.getLatitude();
    Double longitude = contact.getLongitude();

    if (null != contact.getId()) {
      id = contact.getId();

      Contact existingContact = getContact(id);

      // if the contact address changed, reload the coordinates
      if (null != contact.getReloadCoordinates() && contact.getReloadCoordinates()) {
        List<Double> coordinates = new ArrayList<>();
        try {
          coordinates = mapboxApiService.getLatLong(
            contact.getStreet1(),
            contact.getCity(),
            contact.getState(),
            contact.getPostalCode());
        } catch (Exception e) {
          //do nothing because the getTimezone function already logged this error
        }
        // if we found new coordinates then uses those values
        if (!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1)) {
          // 1 = lat, 0 = long
          latitude = coordinates.get(1);
          longitude = coordinates.get(0);
        } else {
          // if the address changed but we didn't find valid coordinates for the new address then
          // set these values to null
          latitude = null;
          longitude = null;
        }
      }

      params.put("latitude", latitude);
      params.put("longitude", longitude);
      params.put("contactTypeId", contact.getContactTypeId());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", id);
      params.put("ownerUserPositionId", (contact.getOwnerUserPositionId() != null) ? contact.getOwnerUserPositionId() : existingContact.getOwnerUserPositionId());

      // add update when we add that to the UI
      sqlCache.updateBySql(ContactQuery.updateContact, params);

    } else {
      // load contact geo location
      List<Double> coordinates = new ArrayList<>();
      try {
        coordinates = mapboxApiService.getLatLong(
          contact.getStreet1(),
          contact.getCity(),
          contact.getState(),
          contact.getPostalCode());
      } catch (Exception e) {
        //do nothing because the getTimezone function already logged this error
      }
      if (!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1)) {
        // 1 = lat, 0 = long
        latitude = coordinates.get(1);
        longitude = coordinates.get(0);
      }

      if (contact.getOwnerUserPositionId() != null) {
        params.put("ownerUserPositionId", contact.getOwnerUserPositionId());
      } else {
        UserPosition userPrimaryPosition =
          userPositionService.getUserPrimaryPosition(currentUser.getId(), currentUser.getCompanyId());
        params.put(
          "ownerUserPositionId",
          null == userPrimaryPosition || null == userPrimaryPosition.getId()
            ? null
            : userPrimaryPosition.getId());
        if (null == userPrimaryPosition || null == userPrimaryPosition.getId()) {
          // todo: come back and remove this at some point
          log.warn(
            "RANDA: a contact was added and we didn't find the user position id. this shouldnt happen {} {} {} {}",
            currentUser.getId(),
            contact.getFirstName(),
            contact.getLastName(),
            contact.getEmail());
        }
      }
      params.put("latitude", latitude);
      params.put("longitude", longitude);
      params.put("contactTypeId", ContactType.LEAD.id);
      params.put("createdById", currentUser.trueUserId());
      params.put("objectCategoryId", contact.getObjectCategoryId()); //TODO?

      id = sqlCache.updateBySqlReturningId(ContactQuery.insertContact, params, "id").longValue();
    }

    return getContact(id);
  }

  public void insertContactFromChildProject(Long projectId, Contact contact) {
    User user = securityService.getCurrentUser();
    Long newContactId = contact.getId();

    if(null == newContactId) {
      //create the new contact
      Map<String, Object> params = new HashMap<>();
      params.put("firstName", contact.getFirstName());
      params.put("lastName", contact.getLastName());
      params.put("phone", contact.getPhone());
      params.put("email", contact.getEmail());
      params.put("postalCode", contact.getPostalCode());
      params.put("userId", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      params.put("objectCategoryId", contact.getObjectCategoryId());

      //for now this just uses the default object category cuz i didnt know how to solve for configurability
      newContactId = sqlCache.updateBySqlReturningId(ContactQuery.insertContactFromChildProject, params, "id").longValue();
    }

    projectService.updateProjectContactId(projectId, newContactId);
  }

  public void updateOwner(Long id, Owner owner) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ownerUserPositionId", owner != null ? owner.getUserPositionId() : null);
    params.put("id", id);
    params.put("modifiedById", currentUser.trueUserId());

    sqlCache.updateBySql(ContactQuery.updateOwner, params);
  }

  public void updateMailingAddress(Contact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("street1", contact.getMailingStreet1());
    params.put("street2", contact.getMailingStreet2());
    params.put("city", contact.getMailingCity());
    params.put("stateId", contact.getCompanyStateId());
    params.put("postalCode", contact.getMailingPostalCode());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", contact.getId());
    // add update when we add that to the UI
    sqlCache.updateBySql(ContactQuery.updateMailingAddress, params);
  }

  public List<Owner> getOwnersForContact(Long contactId) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    return sqlCache.queryBySql(
      ContactQuery.getOwners,
      Map.of("companyId", user.getCompanyId(), "inParentCompany", inParentCompany),
      Owner.class);
  }

  @Transactional
  public Project convertToContact(Long contactId, CompanyProcessDTO process) throws Exception {
    User currentUser = securityService.getCurrentUser();

    // save contact_type_id
    Map<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("contactTypeId", ContactType.CUSTOMER.id);
    params.put("modifiedById", currentUser.trueUserId());
    sqlCache.updateBySql(ContactQuery.convertToContact, params);

    // get contact to get their full name for the project and also so a parent can find this contact
    Contact contact = getContact(contactId);

    Long ownerUserPositionId = process.getOwnerUserPositionId();

    // create project (use contact_full_name as project_name)
    Optional<Project> project = projectService.insertProject(contact.getId(), process.getId(), contact, contact.isActiveState(), ownerUserPositionId);

    if (project.isPresent()) {
      //this will only add the activity if the company has it enabled
      Map<String, Object> actParams = new HashMap<>();
      actParams.put("activityId", SystemActivity.PROJECT_CREATED.id);
      actParams.put("objectTypeId", ObjectType.PROJECT.id);
      actParams.put("userId", currentUser.trueUserId());
      actParams.put("sourceId", project.get().getId());
      actParams.put("ppsId", null);
      actParams.put("ppseId", null);
      actParams.put("oldStatusId", null);
      actParams.put("newStatusId", null);
      sqlCache.queryBySql(ActivityQuery.addSystemActivity, actParams, String.class);

      List<ProcessStepProcess> initialProcessSteps = process.getProcessStepProcesses();

      // if no initial PS is specified by the public API, fetch stored PSs from the process
      if (initialProcessSteps == null || initialProcessSteps.isEmpty()) {
        initialProcessSteps = processService.getInitialProcessStepProcesses(process.getId());
      }

      // if no owner is specified default to the contact owner, else null
      if (ownerUserPositionId == null) {
        ownerUserPositionId = (contact.getOwner() != null) ? contact.getOwner().getUserPositionId() : null;
      }

      // create all initial project_process_steps - these wont have a userPositionId
      for (ProcessStepProcess step : initialProcessSteps) {
        // the last companyProcessStepStatusTypeId can be null because an initial process step
        // shouldn't need to cancel any pre-existing steps of the same type
        projectProcessStepService.insertProjectProcessStep(
          project.get().getId(),
          step.getProcessStepId(),
          ownerUserPositionId,
          null,
          true,
          step.getCompanyProcessStepStatusTypeId(),
          null);
      }

      // Set the project ID for the contact in Klaviyo
      klaviyoService.updateProjectId(contactId, project.get().getId());
    }

    // return project data so the frontend can navigate to project/{id}
    return project.orElse(null);
  }

  public List<Attachment> getContactAttachments(Long contactId, Boolean isMobile, Boolean linked) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("linked", linked);
    params.put("companyId", currentUser.getCompanyId());
    List<Attachment> attachments =
      sqlCache.queryBySql(ContactQuery.getContactAttachments, params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long contactId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = ContactQuery.linkAttachment;
    if (!doLink) {
      sql = ContactQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  public Attachment addAttachment(MultipartFile file, Long contactId, Long attachmentTypeId, String displayName)
    throws IOException {
    User user = securityService.getCurrentUser();
    Attachment attachment = attachmentService.create(file, null, attachmentTypeId, displayName, false);

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("attachmentId", attachment.getId());
    params.put("createdById", user.trueUserId());

    sqlCache.updateBySql(ContactQuery.addAttachment, params);

    return attachment;
  }

  public static class ContactMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ContactMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<>() {
      };

      bw.registerCustomEditor(
        Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<Project>> projectsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "projects", new JsonCollectionDeserializer(projectsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef =
        new TypeReference<>() {
        };
      bw.registerCustomEditor(
        List.class,
        "ownerReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(ownerReadOnlyWhiteListedPositionsRef, objectMapper));
    }
  }
}
