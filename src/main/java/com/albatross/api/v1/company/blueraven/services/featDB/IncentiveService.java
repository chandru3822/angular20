package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.FeatDbContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.incentive.query.IncentiveContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.incentive.query.IncentiveLinkQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.incentive.query.IncentiveQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.utility.query.UtilityQuery;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Collections;

@Slf4j
@Service
@RequiredArgsConstructor
public class IncentiveService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<Incentive> getAllIncentives() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.queryBySql(IncentiveQuery.list, params, Incentive.class);
  }

  public Optional<IncentiveDetail> getIncentiveById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      IncentiveQuery.detailById, params, new IncentiveDetailMapper<>(IncentiveDetail.class, om));
  }

  public List<IncentiveType> getAllTypes() {
    return sqlCache.queryBySql(IncentiveQuery.listAllType, Collections.emptyMap(), IncentiveType.class);
  }

  public List<IncentiveStatus> getAllStatuses() {
    return sqlCache.queryBySql(IncentiveQuery.getAllStatus, Collections.emptyMap(), IncentiveStatus.class);
  }

  public Optional<IncentiveDetail> simpleUpdate(Incentive incentive) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("incentiveName", incentive.getName());
    params.put("companyStateId", incentive.getCompanyStateId());
    params.put("typeId", incentive.getTypeId());
    params.put("statusId", incentive.getStatusId());
    params.put("archived", incentive.getArchived());
    params.put("id", incentive.getId());

    sqlCache.updateBySql(IncentiveQuery.simpleUpdate, params);
    return getIncentiveById(incentive.getId());
  }

  public Optional<IncentiveDetail> updateIncentive(Incentive incentive) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("incentiveName", incentive.getName());
    params.put("companyStateId", incentive.getCompanyStateId());
    params.put("typeId", incentive.getTypeId());
    params.put("statusId", incentive.getStatusId());
    params.put("archived", incentive.getArchived());

    Long id;

    if (null != incentive.getId()) {
      id = incentive.getId();
      params.put("id", incentive.getId());
      sqlCache.updateBySql(IncentiveQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(IncentiveQuery.insert, params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
      ObjectType.INCENTIVE, incentive.getCustomFieldGroups(), id);

    return getIncentiveById(id);
  }

  public void deleteIncentive(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(IncentiveQuery.delete, params);
  }

  // CONTACTS
  public Optional<FeatDbContact> getIncentiveContactById(Long contactId) {
    return sqlCache.getBySql(FeatDbContactQuery.findById, Map.of("id", contactId), FeatDbContact.class);
  }

  public Optional<FeatDbContact> saveIncentiveContact(
    Long incentiveId, Long contactId, FeatDbContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("incentiveId", incentiveId);
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
      contactId = sqlCache.updateBySqlReturningId(IncentiveContactQuery.add, params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.updateBySql(FeatDbContactQuery.update, params);
    }

    return getIncentiveContactById(contactId);
  }

  public void deleteIncentiveContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FeatDbContactQuery.delete, params);
  }

  // LINKS
  public Optional<FeatDbLink> saveIncentiveLink(Long incentiveId, Long linkId, FeatDbLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("incentiveId", incentiveId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateBySqlReturningId(IncentiveLinkQuery.add, params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.updateBySql(IncentiveLinkQuery.update, params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.getBySql(IncentiveLinkQuery.findById, idParam, FeatDbLink.class);
  }

  public void deleteIncentiveLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(IncentiveLinkQuery.delete, params);
  }

  public List<DatabaseHistory> getIncentiveHistory(Long incentiveId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("incentiveId", incentiveId);

    return sqlCache.queryBySql(IncentiveQuery.getIncentiveHistory, params, DatabaseHistory.class);
  }

  public static class IncentiveDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public IncentiveDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatDbLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<FeatDbContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
        List.class,
        "links",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
        List.class, "contacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));
    }
  }


}
