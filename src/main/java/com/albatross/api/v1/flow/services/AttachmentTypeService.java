package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.KeyPattern;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.event.EventAttachmentType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttachmentTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<AttachmentType> getAttachmentTypesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<AttachmentType> attachmentTypes =
        sqlCache.query("attachmentType.getTypesForCompany", params, AttachmentType.class);
    return attachmentTypes;
  }

  public List<AttachmentType> getSystemAttachmentTypes() {
    return sqlCache.query(
        "attachmentType.getSystemTypes", Collections.emptyMap(), AttachmentType.class);
  }

  public Optional<AttachmentType> getType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    return sqlCache.get(
        "attachmentType.getType",
        ImmutableMap.of("companyId", currentUser.getCompanyId(), "typeId", typeId),
      new AttachmentTypeMapper<>(AttachmentType.class, om));
  }

  public List<ProcessStepAttachmentType> getProcessStepTypesByPps(Long projectId, Long ppsId) {
    User user = securityService.getCurrentUser();

    //using all 3 params verifies that the call is coming from the right company and that the project and pps match
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("ppsId", ppsId);
    params.put("companyId", user.getCompanyId());
    return sqlCache.query(
      "attachmentType.getProcessStepTypesByPps", params, ProcessStepAttachmentType.class);
  }

  public ResponseEntity<List<FieldInUse>> deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    List<FieldInUse> fields = getAllUsingAttachmentType(typeId);

    if (!fields.isEmpty()) {
      return ResponseEntity.badRequest().body(fields);
    } else {
      sqlCache.update(
        "attachmentType.deleteType",
        ImmutableMap.of("id", typeId, "modifiedById", currentUser.trueUserId()));
      return ResponseEntity.ok().build();
    }
  }

  public List<FieldInUse> getAllUsingAttachmentType(Long typeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);
    List<FieldInUse> fieldsInUse = sqlCache.query("attachmentType.getAllUsingType", params, FieldInUse.class);
    return fieldsInUse;
  }

  public void updateType(AttachmentType type) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update(
        "attachmentType.updateType",
        ImmutableMap.of(
            "companyId",
            type.getCompanyId(),
            "id",
            type.getId(),
            "attachmentType",
            type.getAttachmentType(),
            "modifiedById",
            currentUser.trueUserId()));
  }

  public Optional<AttachmentType> insertType(AttachmentType type) {
    User currentUser = securityService.getCurrentUser();

    // all user added attachment types use the uploads key pattern (id = 9)

    Long id =
        sqlCache
            .updateReturningId(
                "attachmentType.insertType",
                ImmutableMap.of(
                    "attachmentType",
                    type.getAttachmentType(),
                    "companyId",
                    type.getCompanyId(),
                    "keyPatternId",
                    KeyPattern.UPLOADS.id,
                    "createdById",
                    currentUser.trueUserId()),
                "id")
            .longValue();

    return getType(id);
  }

  public List<EventAttachmentType> getEventTypesByPpsEventId(Long ppsEventId) {
    Map<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    return sqlCache.query(
        "attachmentType.getEventTypesByPpsEventId", params, EventAttachmentType.class);
  }

  //doing this ensures that the frontend cant load mismatched details via the url
  public List<EventAttachmentType> getEventTypesByPpsEventIdAndPps(Long projectId, Long ppsId, Long ppsEventId) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("ppsId", ppsId);
    params.put("ppsEventId", ppsEventId);
    return sqlCache.query(
      "attachmentType.getEventTypesByPpsEventIdAndPps", params, EventAttachmentType.class);
  }

  public List<EventAttachmentType> getEventAndPsTypes(Long psId, Long eventId) {
    Map<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("psId", psId);
    return sqlCache.query("attachmentType.getEventAndPsTypes", params, EventAttachmentType.class);
  }

  public List<EventAttachmentType> getEventAndPsTypesByPpsEventId(Long ppsEventId) {
    Map<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    return sqlCache.query(
        "attachmentType.getEventAndPsTypesByPpsEventId", params, EventAttachmentType.class);
  }

  //these endpoints are for the admin side of things
  public List<ObjectTypeAttachmentType> getTypes(ObjectType objectType, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".getTypes";
    return sqlCache.query(sqlKey, params, ObjectTypeAttachmentType.class);
  }

  public Optional<ObjectTypeAttachmentType> getAttachmentType(Long id, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".get";
    Optional<ObjectTypeAttachmentType> result = sqlCache.get(sqlKey, params, new ObjectTypeAttachmentTypeMapper<>(ObjectTypeAttachmentType.class, om));
    return result;
  }

  public List<ObjectTypeAttachmentType> getAvailableTypes(ObjectType objectType, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".getAvailableTypes";
    return sqlCache.query(sqlKey, params, ObjectTypeAttachmentType.class);
  }

  public Optional<ObjectTypeAttachmentType> addType(ObjectTypeAttachmentType objectTypeAttachmentType, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.trueUserId());
    params.put("attachmentTypeId", objectTypeAttachmentType.getAttachmentTypeId());
    params.put("eventId", objectTypeAttachmentType.getPrimaryId());
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".addType";
    Long id = sqlCache.updateReturningId(sqlKey, params, "id").longValue();
    return getAttachmentType(id, objectType);
  }

  public void updateType(ObjectTypeAttachmentType attachmentType, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("focused", null != attachmentType.getFocused() && attachmentType.getFocused());
    params.put("linkable", null != attachmentType.getLinkable() && attachmentType.getLinkable());
    params.put("allowUpload", null != attachmentType.getAllowUpload() && attachmentType.getAllowUpload());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("id", attachmentType.getId());
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".update";
    sqlCache.update(sqlKey, params);
  }

  public void updateTypeOrder(List<ObjectTypeAttachmentType> attachmentTypes, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ObjectTypeAttachmentType at : attachmentTypes) {
      params.put("displayOrder", at.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", at.getId());
      // save each display_order
      String sqlKey = "attachmentType." + objectType.tablePrefix + ".updateDisplayOrder";
      sqlCache.update(sqlKey, params);
    }
  }

  public void deleteTypeForObjectType(Long id, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());
    params.put("userId", currentUser.trueUserId());
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".deleteType";
    sqlCache.update(sqlKey, params);
  }

  public void updateReadOnly(ObjectTypeAttachmentType attachmentType, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", attachmentType.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("readOnly", attachmentType.getReadOnly());
    String sqlKey = "attachmentType." + objectType.tablePrefix + ".updateReadOnly";
    sqlCache.update(sqlKey, params);
  }

  public static class AttachmentTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AttachmentTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "customFieldGroups",
        new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));
    }
  }

  public static class ObjectTypeAttachmentTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ObjectTypeAttachmentTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<>() {};
      bw.registerCustomEditor(
        List.class,
        "customFieldGroups",
        new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));
    }
  }
}
