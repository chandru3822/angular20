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
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AhjInspectionService {
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjInspectionDetail> getAhjInspectionDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjInspectionDetail> inspection =
        sqlCache.get(
            "ahj.inspection.detailByAhj",
            params,
            new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
    if (inspection.isPresent()) {
      return inspection;
    }

    User currentUser = securityService.getCurrentUser();
    params.put("currentUser", currentUser.trueUserId());

    // add a blank inspection and return that
    var created =
        sqlCache.get(
            "ahj.inspection.create", params, new SingleColumnRowMapper<>(Integer.class));

    if (created.isPresent()) {
      return sqlCache.get(
          "ahj.inspection.detailByAhj",
          params,
          new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
    }
    return Optional.empty();
  }

  public Optional<AhjInspection> saveAhjInspection(
      Long ahjId, Long inspectionId, AhjInspection inspection, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());

    if (inspection.getUpdateAllInState() != null && inspection.getUpdateAllInState() && inspection.getAhjIds().size() > 0) {
      params.put("ahjIds", inspection.getAhjIds());
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
          ObjectType.AHJ_INSPECTION.textValue(),
          inspection.getCustomFieldGroups(),
          inspection.getInspectionIds());
    } else {
      params.put("ahjId", ahjId);

      if (inspectionId == null) {
        inspectionId = sqlCache.updateReturningId("ahj.inspection.create", params, "id").longValue();
      } else {
        params.put("id", inspectionId);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
            ObjectType.AHJ_INSPECTION.textValue(), inspection.getCustomFieldGroups(), inspectionId);
      }
    }

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", inspectionId);
    return returnValue
        ? sqlCache.get("ahj.inspection.findById", keyParam, AhjInspection.class)
        : Optional.empty();
  }

  public List<AhjInspection> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.inspection.searchAhjsByState", params, AhjInspection.class);
  }

  // CONTACTS
  public void saveInspectionContact(Long inspectionId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("ahjInspectionId", inspectionId);
    params.put("ahjContactId", contactId);
    sqlCache.update("ahj.inspection.contact.create", params);
  }

  // LINKS
  public Optional<AhjLink> saveInspectionLink(
      Long ahjId, Long inspectionId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjInspectionId", inspectionId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.inspection.link.create", params, "id").longValue();

    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.inspection.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.inspection.link.findById", idParam, AhjLink.class);
  }

  public void deleteInspectionLink(Long ahjId, Long inspectionId, Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.inspection.link.delete", params);
  }

  public static class AhjInspectionDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjInspectionDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          List.class, "schedulingLinks", new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "fotLinks", new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "resultsLinks", new JsonCollectionDeserializer(linkTypeRef, objectMapper));


      bw.registerCustomEditor(
          List.class,
          "utilityServiceDeptContacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "schedulingContacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "obtainingResultsContacts",
          new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "feeContacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "servicingFots", new JsonCollectionDeserializer(userRef, objectMapper));
    }
  }
}
