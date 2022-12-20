package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.FeatDbContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query.AhjQuery;
import com.albatross.api.v1.company.blueraven.enums.AhjType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Service
@RequiredArgsConstructor
public class AhjService {
  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final AhjPermitService ahjPermitService;

  private final AhjInspectionService ahjInspectionService;

  private final AhjDesignService ahjDesignService;

  public List<AhjSummary> getAhjList() {
    return sqlCache.queryBySql(AhjQuery.list, new HashMap<>(), AhjSummary.class);
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
      Optional<AhjSummary> ahj = sqlCache.getBySql(AhjQuery.checkForDuplicate, params, AhjSummary.class);

      if (ahj.isEmpty()) {
        id = sqlCache.updateBySqlReturningId(AhjQuery.create, params, "id").longValue();

        // create an empty permit, inspection, and design tied to the ahj - only required for new
        ahjPermitService.saveAhjPermit(id, null, new AhjPermit(), false);
        ahjInspectionService.saveAhjInspection(id, null, new AhjInspection(), false);
        ahjDesignService.saveAhjDesign(id, null, new AhjDesign(), false);
      } else {
        return Optional.empty();
      }
    } else {
      params.put("id", id);
      sqlCache.updateBySql(AhjQuery.update, params);
    }

    return getAhjById(id);
  }

  @Transactional
  public void deleteAhj(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.updateBySql(AhjQuery.delete, params);
  }

  public Optional<AhjSummary> getAhjById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(AhjQuery.findById, params, AhjSummary.class);
  }

  // CONTACTS
  public Optional<FeatDbContact> getAhjContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.getBySql(FeatDbContactQuery.findById, params, FeatDbContact.class);
  }

  @Transactional
  public Optional<FeatDbContact> saveAhjContact(Long id, Long contactId, FeatDbContact contact, AhjType ahjType) {
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
      contactId = sqlCache.updateBySqlReturningId(FeatDbContactQuery.create, params, "id").longValue();

      if (AhjType.PERMIT.equals(ahjType)) {
        ahjPermitService.savePermitContact(id, contactId);
      } else if (AhjType.INSPECTION.equals(ahjType)) {
        ahjInspectionService.saveInspectionContact(id, contactId);
      }

    } else {
      params.put("contactId", contactId);
      sqlCache.updateBySql(FeatDbContactQuery.update, params);
    }

    return getAhjContactById(contactId);
  }

  public void deleteAhjContact(Long id, Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FeatDbContactQuery.delete, params);
  }
}
