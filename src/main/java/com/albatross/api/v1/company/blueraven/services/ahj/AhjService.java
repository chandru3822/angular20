package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.flow.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Service
public class AhjService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private AhjPermitService ahjPermitService;

  @Autowired
  private AhjInspectionService ahjInspectionService;

  @Autowired
  private AhjDesignService ahjDesignService;

  public List<AhjSummary> getAhjList() {
    return sqlCache.query("ahj.list", new HashMap<>(), AhjSummary.class);
  }

  @Transactional
  public Optional<AhjSummary> saveAhj(Long id, AhjSummary ahjSummary) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("name", ahjSummary.getName());
    params.put("metroAreaId", ahjSummary.getMetroAreaId());
    params.put("companyStateId", ahjSummary.getCompanyStateId());

    if (id == null) {
      Optional<AhjSummary> ahj = sqlCache.get("ahj.checkForDuplicate", params, AhjSummary.class);

      if (ahj.isEmpty()) {
        id = sqlCache.updateReturningId("ahj.create", params, "id").longValue();

        // create an empty permit, inspection, and design tied to the ahj - only required for new
        ahjPermitService.saveAhjPermit(id, null, new AhjPermit(), false);
        ahjInspectionService.saveAhjInspection(id, null, new AhjInspection(), false);
        ahjDesignService.saveAhjDesign(id, null, new AhjDesign(), false);
      } else {
        return Optional.empty();
      }
    } else {
      params.put("id", id);
      sqlCache.update("ahj.update", params);
    }

    return getAhjById(id);
  }

  @Transactional
  public void deleteAhj(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("ahj.delete", params);
  }

  public Optional<AhjSummary> getAhjById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("ahj.findById", params, AhjSummary.class);
  }

  // CHECKLISTS
  private Optional<AhjChecklistItem> getChecklistItemById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("ahj.checklist.findById", params, AhjChecklistItem.class);
  }

  @Transactional
  public Optional<AhjChecklistItem> saveChecklistItem(Long ahjId, Long ahjItemTypeId, Long itemId, AhjChecklistItem item, AhjType ahjType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("description", item.getDescription());
    params.put("displayOrder", item.getDisplayOrder());
    params.put("checklistTypeId", item.getChecklistTypeId());
    params.put("currentUser", currentUser.trueUserId());
    params.put("failedInspectionResourceId", item.getFailedInspectionResourceId());
    params.put("failedInspectionDate", item.getFailedInspectionDate());
    params.put("failedInspectionProject", item.getFailedInspectionProject());

    if (itemId == null) {
      itemId = sqlCache.updateReturningId("ahj.checklist.create", params, "id").longValue();

      if (AhjType.PERMIT.equals(ahjType)) {
        ahjPermitService.createPermitChecklistItem(ahjItemTypeId, itemId);
      } else {
        ahjInspectionService.createInspectionChecklistItem(ahjItemTypeId, itemId);
      }
    } else {
      params.put("id", itemId);
      sqlCache.update("ahj.checklist.update", params);
    }

    return getChecklistItemById(itemId);
  }

  public void deleteChecklistItem(Long ahjId, Long permitId, Long itemId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", itemId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.checklist.delete", params);
  }

  // CONTACTS
  public Optional<AhjContact> getAhjContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.get("ahj.contact.findById", params, AhjContact.class);
  }

  @Transactional
  public Optional<AhjContact> saveAhjContact(Long id, Long contactId, AhjContact contact, AhjType ahjType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("name", contact.getName());
    params.put("title", contact.getTitle());
    params.put("email", contact.getEmail());
    params.put("phoneNumber", contact.getPhoneNumber());
    params.put("address", contact.getAddress());
    params.put("notes", contact.getNotes());
    params.put("hours", contact.getHours());
    params.put("contactTypeId", contact.getContactTypeId());

    if (contactId == null) {
      contactId = sqlCache.updateReturningId("ahj.contact.create", params, "id").longValue();

      if (AhjType.PERMIT.equals(ahjType)) {
        ahjPermitService.savePermitContact(id, contactId);
      } else if (AhjType.INSPECTION.equals(ahjType)) {
        ahjInspectionService.saveInspectionContact(id, contactId);
      } else {
        ahjDesignService.saveDesignContact(id, contactId);
      }

    } else {
      params.put("contactId", contactId);
      sqlCache.update("ahj.contact.update", params);
    }

    return getAhjContactById(contactId);
  }

  public void deleteAhjContact(Long id, Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.contact.delete", params);
  }
}
