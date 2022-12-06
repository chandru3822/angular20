package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.ProcessStepProcess;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.AttachmentQuery;
import com.albatross.api.v1.flow.queries.ContactQuery;
import com.albatross.api.v1.flow.queries.ProjectQuery;
import com.albatross.api.v1.flow.services.mapbox.MapboxApiService;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class ContactService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ProjectService projectService;

  private final ProcessService processService;

  private final UserPositionService userPositionService;

  private final ProjectProcessStepService projectProcessStepService;

  private final ObjectMapper om;

  private final AmazonS3 s3;

  private final AttachmentService attachmentService;

  private final MapboxApiService mapboxApiService;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public Page<Contact> searchContacts(String query, String overrideType, Pageable pageable) {
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

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("viewAll", viewAll);
    params.put("userId", user.getId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    String searchSql = ContactQuery.searchByOwner;
    if (viewCustom) {
      searchSql = ContactQuery.searchDownline;
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSql = ContactQuery.search;
    }

    List<Contact> results =
        sqlCache.queryBySql(searchSql, params, new ContactMapper<>(Contact.class, om));

    Integer count = 10000;
    return new PageImpl<>(
        results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
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
    }

    return contact.orElse(null);
  }

  public Contact getHubspotContact(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", 3L);
    params.put("contactId", contactId);
    params.put("parentCompanyId", 3L);
    params.put("isParent", false);
    return sqlCache
        .getBySql(ContactQuery.getById, params, new ContactMapper<>(Contact.class, om))
        .orElse(null);
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
      List<Double> coordinates =
          mapboxApiService.getLatLong(
              stringifyAddress(
                  contact.getStreet1(),
                  contact.getCity(),
                  contact.getState(),
                  contact.getPostalCode()));
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
        List<Double> coordinates =
            mapboxApiService.getLatLong(
                stringifyAddress(
                    contact.getStreet1(),
                    contact.getCity(),
                    contact.getState(),
                    contact.getPostalCode()));
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
      // add update when we add that to the UI
      sqlCache.updateBySql(ContactQuery.updateContact, params);

      if (!existingContact.getProjects().isEmpty()
          && !existingContact
              .getProjects()
              .get(0)
              .getProjectName()
              .equals(contact.getFirstName() + " " + contact.getLastName())) {
        sqlCache.updateBySql(ProjectQuery.updateNameByContactId,
            Map.of(
                "contactId",
                id,
                "name",
                contact.getFirstName() + " " + contact.getLastName(),
                "userId",
                currentUser.trueUserId()));
      }
    } else {
      // load contact geo location
      List<Double> coordinates =
          mapboxApiService.getLatLong(
              stringifyAddress(
                  contact.getStreet1(),
                  contact.getCity(),
                  contact.getState(),
                  contact.getPostalCode()));
      if (!coordinates.isEmpty() && null != coordinates.get(0) && null != coordinates.get(1)) {
        // 1 = lat, 0 = long
        latitude = coordinates.get(1);
        longitude = coordinates.get(0);
      }

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
      params.put("latitude", latitude);
      params.put("longitude", longitude);
      params.put("contactTypeId", ContactType.LEAD.id);
      params.put("createdById", currentUser.trueUserId());
      id = sqlCache.updateBySqlReturningId(ContactQuery.insertContact, params, "id").longValue();
    }

    return getContact(id);
  }

  public String stringifyAddress(String street1, String city, String state, String postalCode) {
    StringJoiner sj = new StringJoiner(", ");
    sj.add(street1);
    sj.add(city);
    sj.add(state + " " + postalCode);

    return sj.toString();
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
  public Project convertToContact(Long contactId, CompanyProcess process) throws Exception {
    User currentUser = securityService.getCurrentUser();

    // save contact_type_id
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("contactTypeId", ContactType.CUSTOMER.id);
    params.put("modifiedById", currentUser.trueUserId());
    sqlCache.updateBySql(ContactQuery.convertToContact, params);

    // get contact to get their full name for the project and also so a parent can find this contact
    Contact contact = getContact(contactId);

    // create project (use contact_full_name as project_name)
    Optional<Project> project =
        projectService.insertProject(contact.getId(), process.getId(), contact, contact.isActiveState());

    // get initial process steps including the initial status
    List<ProcessStepProcess> initialProcessSteps =
        processService.getInitialProcessStepProcesses(process.getId());

    // for now we will insert the owner of the contact as the owner of all initial process steps
    Long ownerUserPositionId =
        (contact.getOwner() != null) ? contact.getOwner().getUserPositionId() : null;

    if (project.isPresent()) {
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
    return attachmentService.getAttachmentPresignedUrls(
        attachments, storageBucket, null != isMobile ? isMobile : false);
  }

  public void linkAttachment(Long contactId, Long attachmentId, Boolean doLink) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("attachmentId", attachmentId);
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());

    String sql = ContactQuery.linkAttachment;
    if(!doLink) {
      sql = ContactQuery.unlinkAttachment;
    }
    sqlCache.updateBySql(sql, params);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped
  // code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long contactId, Long attachmentTypeId, String displayName)
      throws IOException {
    User user = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    // get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key =
        String.format(
            user.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());

    PutObjectRequest objectRequest =
        new PutObjectRequest(
            storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    s3.putObject(objectRequest.withCannedAcl(CannedAccessControlList.PublicRead));

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", CleanString.cleanFilename(file.getOriginalFilename()));
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("displayName", displayName.length() > 100 ? displayName.substring(0, 100) : displayName);
    params.put("createdById", user.trueUserId());
    params.put("attachmentTypeId", attachmentTypeId);
    params.put("companyId", user.getCompanyId());

    Long attachmentId = sqlCache.updateBySqlReturningId(AttachmentQuery.create, params, "id").longValue();

    params.clear();
    params.put("contactId", contactId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", user.trueUserId());

    sqlCache.updateBySql(ContactQuery.addAttachment, params);

    return attachmentService.findById(attachmentId);
  }

  public static class ContactMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ContactMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<Project>> projectsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "projects", new JsonCollectionDeserializer(projectsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef =
          new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class,
          "ownerReadOnlyWhiteListedPositions",
          new JsonCollectionDeserializer(ownerReadOnlyWhiteListedPositionsRef, objectMapper));
    }
  }
}
