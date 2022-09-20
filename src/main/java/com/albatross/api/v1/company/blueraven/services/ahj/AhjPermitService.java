package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AhjPermitService {
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjPermitDetail> getAhjPermitDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjPermitDetail> permit =
        sqlCache.get(
            "ahj.permit.detailByAhj",
            params,
            new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
    if (permit.isPresent()) {
      return permit;
    }
    User currentUser = securityService.getCurrentUser();
    params.put("currentUser", currentUser.trueUserId());

    // add a blank permit and return that
    var created =
        sqlCache.get("ahj.permit.create", params, new SingleColumnRowMapper<>(Integer.class));

    if (created.isPresent()) {
      return sqlCache.get(
          "ahj.permit.detailByAhj", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
    }
    return Optional.empty();
  }

  @Transactional
  public Optional<AhjPermitDetail> saveAhjPermit(
      Long ahjId, Long permitId, AhjPermit permit, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());

    if (permit.getUpdateAllInState() != null && permit.getUpdateAllInState() && permit.getAhjIds().size() > 0) {
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
          ObjectType.AHJ_PERMIT.textValue(), permit.getCustomFieldGroups(), permit.getPermitIds());
    } else {
      params.put("ahjId", ahjId);

      if (permitId == null) {
        sqlCache.updateReturningId("ahj.permit.create", params, "id").longValue();
      } else {
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
            ObjectType.AHJ_PERMIT.textValue(), permit.getCustomFieldGroups(), permitId);
      }
    }

    return returnValue ? getAhjPermitDetailByAhjId(ahjId) : Optional.empty();
  }

  public List<AhjPermit> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.permit.searchAhjsByState", params, AhjPermit.class);
  }

  // CONTACTS
  public void savePermitContact(Long permitId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjPermitId", permitId);
    params.put("ahjContactId", contactId);

    sqlCache.update("ahj.permit.contact.create", params);
  }

  // PERMIT LINKS
  public Optional<AhjLink> savePermitLink(Long ahjId, Long permitId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjPermitId", permitId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.permit.link.create", params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.permit.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.permit.link.findById", idParam, AhjLink.class);
  }

  public void deletePermitLink(Long ahjId, Long permitId, Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.permit.link.delete", params);
  }

  public static class AhjPermitDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjPermitDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          List.class, "submissionLinks", new JsonCollectionDeserializer(linkRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "followUpLinks", new JsonCollectionDeserializer(linkRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "submissionContacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "followUpContacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));
    }
  }
}
