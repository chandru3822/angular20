package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.FeatDbContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.utility.query.UtilityContactQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.utility.query.UtilityLinkQuery;
import com.albatross.api.v1.company.blueraven.controllers.featDB.utility.query.UtilityQuery;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.featDB.FeatDbContact;
import com.albatross.api.v1.company.blueraven.models.featDB.FeatDbLink;
import com.albatross.api.v1.company.blueraven.models.featDB.Utility;
import com.albatross.api.v1.company.blueraven.models.featDB.UtilityDetail;
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
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UtilityService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<Utility> getAllUtilities() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.queryBySql(UtilityQuery.list, params, Utility.class);
  }

  public Optional<UtilityDetail> getUtilityById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(
      UtilityQuery.detailById, params, new UtilityDetailMapper<>(UtilityDetail.class, om));
  }

  public Optional<UtilityDetail> simpleUpdate(Utility utility) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("utilityName", utility.getName());
    params.put("metroAreaId", utility.getMetroAreaId());
    params.put("companyStateId", utility.getCompanyStateId());
    params.put("archived", utility.getArchived());
    params.put("id", utility.getId());

    sqlCache.updateBySql(UtilityQuery.simpleUpdate, params);
    return getUtilityById(utility.getId());
  }

  public Optional<UtilityDetail> updateUtility(Utility utility) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("utilityName", utility.getName());
    params.put("metroAreaId", utility.getMetroAreaId());
    params.put("companyStateId", utility.getCompanyStateId());
    params.put("archived", utility.getArchived());

    Long id;

    if (null != utility.getId()) {
      id = utility.getId();
      params.put("id", utility.getId());
      sqlCache.updateBySql(UtilityQuery.update, params);
    } else {
      id = sqlCache.updateBySqlReturningId(UtilityQuery.insert, params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
        ObjectType.UTILITY, utility.getCustomFieldGroups(), id);

    return getUtilityById(id);
  }

  // CONTACTS
  public Optional<FeatDbContact> getUtilityContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.getBySql(FeatDbContactQuery.findById, params, FeatDbContact.class);
  }

  public Optional<FeatDbContact> saveUtilityContact(
      Long utilityId, Long contactId, FeatDbContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("utilityId", utilityId);
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
      contactId = sqlCache.updateBySqlReturningId(UtilityContactQuery.add, params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.updateBySql(FeatDbContactQuery.update, params);
    }

    return getUtilityContactById(contactId);
  }

  public void deleteUtilityContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(FeatDbContactQuery.delete, params);
  }

  // LINKS
  public Optional<FeatDbLink> saveUtilityLink(Long utilityId, Long linkId, FeatDbLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("utilityId", utilityId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateBySqlReturningId(UtilityLinkQuery.add, params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.updateBySql(UtilityLinkQuery.update, params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.getBySql(UtilityLinkQuery.findById, idParam, FeatDbLink.class);
  }

  public void deleteUtilityLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(UtilityLinkQuery.delete, params);
  }

  public static class UtilityDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public UtilityDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
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
