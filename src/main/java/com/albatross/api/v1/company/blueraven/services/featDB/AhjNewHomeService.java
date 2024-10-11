package com.albatross.api.v1.company.blueraven.services.featDB;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.featDB.ahj.query.*;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.featDB.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AhjNewHomeService {
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjNewHomeDetail> getAhjNewHomeDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjNewHomeDetail> newHome =
        sqlCache.getBySql(
          AhjNewHomeQuery.detailByAhj,
            params,
            new AhjNewHomeDetailMapper<>(AhjNewHomeDetail.class, om));
    if (newHome.isPresent()) {
      return newHome;
    }

    User currentUser = securityService.getCurrentUser();
    params.put("currentUser", currentUser.trueUserId());

    // add a blank new home and return that
    var created =
        sqlCache.getBySql(
          AhjNewHomeQuery.create, params, new SingleColumnRowMapper<>(Integer.class));

    if (created.isPresent()) {
      return sqlCache.getBySql(
        AhjNewHomeQuery.detailByAhj,
          params,
          new AhjNewHomeDetailMapper<>(AhjNewHomeDetail.class, om));
    }
    return Optional.empty();
  }

  public Optional<AhjNewHome> saveAhjNewHome(
      Long ahjId, Long newHomeId, AhjNewHome newHome, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());

    if (newHome.getUpdateAllInState() != null && newHome.getUpdateAllInState() && newHome.getAhjIds().size() > 0) {
      params.put("ahjIds", newHome.getAhjIds());
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
          ObjectType.AHJ_NEW_HOME,
          newHome.getCustomFieldGroups(),
          newHome.getNewHomeIds());
    }else if(newHome.getUpdateAllInArea() != null && newHome.getUpdateAllInArea().length() > 0 && newHome.getAhjIds().size() > 0){
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
        ObjectType.AHJ_NEW_HOME, newHome.getCustomFieldGroups(), newHome.getNewHomeIds());
    } else {
      params.put("ahjId", ahjId);

      if (newHomeId == null) {
        newHomeId = sqlCache.updateBySqlReturningId(AhjNewHomeQuery.create, params, "id").longValue();
      } else {
        params.put("id", newHomeId);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
            ObjectType.AHJ_NEW_HOME, newHome.getCustomFieldGroups(), newHomeId);
      }
    }

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", newHomeId);
    return returnValue
        ? sqlCache.getBySql(AhjNewHomeQuery.findById, keyParam, AhjNewHome.class)
        : Optional.empty();
  }

  public List<AhjNewHome> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.queryBySql(AhjNewHomeQuery.searchAhjsByState, params, AhjNewHome.class);
  }

  public List<AhjNewHome> searchAhjsByMetro(Long metroId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("metroId", metroId);
    return sqlCache.queryBySql(AhjNewHomeQuery.searchAhjsByMetro, params, AhjNewHome.class);
  }

  // CONTACTS
  public void saveNewHomeContact(Long newHomeId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("ahjNewHomeId", newHomeId);
    params.put("ahjContactId", contactId);
    sqlCache.updateBySql(AhjNewHomeContactQuery.create, params);
  }

  // LINKS
  public Optional<FeatDbLink> saveNewHomeLink(
      Long ahjId, Long newHomeId, Long linkId, FeatDbLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjNewHomeId", newHomeId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateBySqlReturningId(AhjNewHomeLinkQuery.create, params, "id").longValue();

    } else {
      params.put("id", linkId);
      sqlCache.updateBySql(AhjNewHomeLinkQuery.update, params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.getBySql(AhjNewHomeLinkQuery.findById, idParam, FeatDbLink.class);
  }

  public void deleteNewHomeLink(Long ahjId, Long newHomeId, Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.updateBySql(AhjNewHomeLinkQuery.delete, params);
  }

  public List<DatabaseHistory> getAhjNewHomeHistory(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    return sqlCache.queryBySql(AhjNewHomeQuery.getAhjHistory, params, DatabaseHistory.class);
  }

  public static class AhjNewHomeDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjNewHomeDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<FeatDbLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<FeatDbContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          List.class, "links", new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "contacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));
    }
  }
}
