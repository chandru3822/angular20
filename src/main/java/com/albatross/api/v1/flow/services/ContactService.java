package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ContactService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ProjectService projectService;

  private final ProcessService processService;

  private final UserPositionService userPositionService;

  private final ProjectProcessStepService projectProcessStepService;

  private final ObjectMapper om;

  public Page<Contact> searchContacts(String query, String overrideType, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "CONTACTS", List.of("VIEW_ALL"));
    Boolean viewDownline = false;

    if((!viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) || (null != overrideType && overrideType.equalsIgnoreCase("downline"))) {
      viewDownline = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "CONTACTS", List.of("VIEW_DOWNLINE"));
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

//    String searchSqlKey = viewAll ? "contact.search" : viewDownline ? "contact.searchDownline" : "contact.searchByOwner";
    String searchSqlKey = "contact.searchByOwner";
    if(viewDownline) {
      searchSqlKey = "contact.searchDownline";
    } else if (viewAll && (null == overrideType || !overrideType.equalsIgnoreCase("view"))) {
      searchSqlKey = "contact.search";
    }

    List<Contact> results = sqlCache.query(searchSqlKey, params, new ContactMapper<>(Contact.class, om));

//    Integer count = sqlCache.queryForObject("contact.searchContactsCount", params, Integer.class);
    Integer count = 10000;
    Page<Contact> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public Contact getContact(Long contactId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("contactId", contactId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    Optional<Contact> result = sqlCache.get("contact.getById", params, new ContactMapper<>(Contact.class, om));
    return result.orElse(null);
  }

  public Contact getContactByProjectId(Long projectId) {
    User user = securityService.getCurrentUser();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    params.put("companyId", user.getCompanyId());
    Optional<Contact> result = sqlCache.get("contact.getByProjectId", params, new ContactMapper<>(Contact.class, om));
    return result.orElse(null);
  }

  public void deleteContact(Long contactId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("modifiedById", user.getId());
    params.put("contactId", contactId);
    sqlCache.update("contact.delete", params);
  }

  public Contact updateContact(Contact contact) {
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
    params.put("companyId", null != contact.getCompanyId() ? contact.getCompanyId() : currentUser.getCompanyId());

    Long id;

    if (null != contact.getId()) {
      id = contact.getId();

      Contact existingContact = getContact(id);

      params.put("contactTypeId", contact.getContactTypeId());
      params.put("modifiedById", currentUser.getId());
      params.put("id", id);
      //add update when we add that to the UI
      sqlCache.update("contact.updateContact", params);

      if (!existingContact.getProjects().isEmpty() && !existingContact.getProjects().get(0).getProjectName().equals(contact.getFirstName() + " " + contact.getLastName())) {
        sqlCache.update("project.updateNameByContactId", Map.of("contactId", id, "name", contact.getFirstName() + " " + contact.getLastName(), "userId", currentUser.getId()));
      }
    } else {
      UserPosition userPrimaryPosition = userPositionService.getUserPrimaryPosition(currentUser.getId());
      params.put("ownerUserPositionId", null == userPrimaryPosition || null == userPrimaryPosition.getId() ? null : userPrimaryPosition.getId());
      if (null == userPrimaryPosition || null == userPrimaryPosition.getId()) {
        //todo: come back and remove this at some point
        log.info("RANDA: a contact was added and we didn't find the user position id. this shouldnt happen {} {} {} {}", currentUser.getId(), contact.getFirstName(), contact.getLastName(), contact.getEmail());
      }
      params.put("contactTypeId", ContactType.LEAD.id);
      params.put("createdById", currentUser.getId());
      id = sqlCache.updateReturningId("contact.insertContact", params, "id").longValue();
    }

    return getContact(id);
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
    params.put("stateId", contact.getCompanyStateId());
    params.put("postalCode", contact.getMailingPostalCode());
    params.put("modifiedById", currentUser.getId());
    params.put("id", contact.getId());
    //add update when we add that to the UI
    sqlCache.update("contact.updateMailingAddress", params);
  }

  public List<Owner> getOwnersForContact(Long contactId) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    return sqlCache.query("contact.getOwners", Map.of("companyId", user.getCompanyId(), "inParentCompany", inParentCompany), Owner.class);
  }

  public Project convertToContact(Long contactId, CompanyProcess process) {
    User currentUser = securityService.getCurrentUser();

    //save contact_type_id
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("contactTypeId", ContactType.CUSTOMER.id);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("contact.convertToContact", params);

    //get contact to get their full name for the project and also so a parent can find this contact
    Contact contact = getContact(contactId);

    //create project (use contact_full_name as project_name)
    Optional<Project> project = projectService.insertProject(contact.getId(), process.getId(), contact);

    //get initial process steps including the initial status
    List<ProcessStepProcess> initialProcessSteps = processService.getInitialProcessStepProcesses(process.getId());

    //for now we will insert the owner of the contact as the owner of all initial process steps
    Long ownerUserPositionId = (contact.getOwner() != null) ? contact.getOwner().getUserPositionId() : null;

    if (project.isPresent()) {
      //create all initial project_process_steps - these wont have a userPositionId
      for (ProcessStepProcess step : initialProcessSteps) {
        //the last companyProcessStepStatusTypeId can be null because an initial process step shouldn't need to cancel any pre-existing steps of the same type
        projectProcessStepService.insertProjectProcessStep(project.get().getId(), step.getProcessStepId(), ownerUserPositionId, null, true, step.getCompanyProcessStepStatusTypeId(), null);
      }
    }

    //return project data so the frontend can navigate to project/{id}
    return project.orElse(null);
  }

  public static class ContactMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ContactMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<Owner>() {
      };

      bw.registerCustomEditor(Object.class, "owner",
        new JsonCollectionDeserializer(ownerRef, objectMapper));

      TypeReference<List<Project>> projectsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "projects",
        new JsonCollectionDeserializer(projectsRef, objectMapper));
    }
  }
}
