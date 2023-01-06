package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.ApiException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.KeyPattern;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.event.EventAttachmentType;
import com.albatross.api.v1.flow.model.processStep.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.queries.AttachmentTypeQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepEventQuery;
import com.albatross.api.v1.flow.queries.ProjectProcessStepQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AttachmentTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<AttachmentType> getAttachmentTypesForCompany() {
    User user = securityService.getCurrentUser();
    return sqlCache.queryBySql(AttachmentTypeQuery.getTypesForCompany, Map.of("companyId", user.getCompanyId()), AttachmentType.class);
  }

  public List<AttachmentType> getSystemAttachmentTypes() {
    return sqlCache.queryBySql(
      AttachmentTypeQuery.getSystemTypes, Map.of(), AttachmentType.class);
  }

  public Optional<AttachmentType> getType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    return sqlCache.getBySql(
      AttachmentTypeQuery.getType,
      Map.of("companyId", currentUser.getCompanyId(), "typeId", typeId),
      new AttachmentTypeMapper<>(AttachmentType.class, om));
  }

  public List<ProcessStepAttachmentType> getProcessStepTypesByPps(Long ppsId, Boolean allowUpload, Boolean focused, Boolean linkable) {
    User user = securityService.getCurrentUser();

    //using all 3 params verifies that the call is coming from the right company and that the project and pps match
    Map<String, Object> params = new HashMap<>();
    params.put("ppsId", ppsId);
    params.put("allowUpload", allowUpload);
    params.put("linkable", linkable);
    params.put("focused", focused);
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(
      AttachmentTypeQuery.getProcessStepTypesByPps, params, ProcessStepAttachmentType.class);
  }

  public ResponseEntity<List<FieldInUse>> deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    List<FieldInUse> fields = getAllUsingAttachmentType(typeId);

    if (!fields.isEmpty()) {
      return ResponseEntity.badRequest().body(fields);
    } else {
      sqlCache.updateBySql(
        AttachmentTypeQuery.deleteAttachmentType,
        Map.of("id", typeId, "modifiedById", currentUser.trueUserId()));
      return ResponseEntity.ok().build();
    }
  }

  public List<FieldInUse> getAllUsingAttachmentType(Long typeId) {
    return sqlCache.queryBySql(AttachmentTypeQuery.getAllUsingType, Map.of("typeId", typeId), FieldInUse.class);
  }

  public void updateType(AttachmentType type) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.updateBySql(
      AttachmentTypeQuery.updateType,
      Map.of(
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
        .updateBySqlReturningId(
          AttachmentTypeQuery.insertType,
          Map.of(
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

  public List<EventAttachmentType> getEventTypesByPpsEventId(Long ppsEventId, Boolean allowUpload, Boolean focused, Boolean linkable) {
    Map<String, Object> params = new HashMap<>();
    params.put("ppsEventId", ppsEventId);
    params.put("allowUpload", allowUpload);
    params.put("focused", focused);
    params.put("linkable", linkable);
    return sqlCache.queryBySql(
      AttachmentTypeQuery.getEventTypesByPpsEventId, params, EventAttachmentType.class);
  }

  //these endpoints are for the admin side of things
  public List<ObjectTypeAttachmentType> getTypes(ObjectType objectType, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);

    String sql = "";
    switch (objectType) {
      case PROJECT -> sql = AttachmentTypeQuery.projectGetTypes;
      case CONTACT -> sql = AttachmentTypeQuery.contactGetTypes;
      case USER -> sql = AttachmentTypeQuery.userGetTypes;
      case ORGANIZATION -> sql = AttachmentTypeQuery.orgGetTypes;
      case EVENT -> sql = AttachmentTypeQuery.eventGetTypes;
      default -> throw new ApiException("Unsupported attachment type");
    }

    return sqlCache.queryBySql(sql, params, ObjectTypeAttachmentType.class);
  }

  public Optional<ObjectTypeAttachmentType> getAttachmentType(Long id, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();
    String sql = objectType.getAttachmentTypeQuery;
    return sqlCache.getBySql(sql, Map.of("id", id, "companyId", currentUser.getCompanyId()), new ObjectTypeAttachmentTypeMapper<>(ObjectTypeAttachmentType.class, om));
  }

  public List<ObjectTypeAttachmentType> getAvailableTypes(ObjectType objectType, Long eventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("eventId", eventId);

    String sql = "";
    switch (objectType) {
      case PROJECT -> sql = AttachmentTypeQuery.projectGetAvailableTypes;
      case CONTACT -> sql = AttachmentTypeQuery.contactGetAvailableTypes;
      case USER -> sql = AttachmentTypeQuery.userGetAvailableTypes;
      case ORGANIZATION -> sql = AttachmentTypeQuery.orgGetAvailableTypes;
      case EVENT -> sql = AttachmentTypeQuery.eventGetAvailableTypes;
      default -> throw new ApiException("Unsupported attachment type");
    }
    return sqlCache.queryBySql(sql, params, ObjectTypeAttachmentType.class);
  }

  public Optional<ObjectTypeAttachmentType> addType(ObjectTypeAttachmentType objectTypeAttachmentType, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.trueUserId());
    params.put("attachmentTypeId", objectTypeAttachmentType.getAttachmentTypeId());
    params.put("eventId", objectTypeAttachmentType.getPrimaryId());
    String sql = "";
    switch (objectType) {
      case PROJECT -> sql = AttachmentTypeQuery.projectAddType;
      case CONTACT -> sql = AttachmentTypeQuery.contactAddType;
      case USER -> sql = AttachmentTypeQuery.userAddType;
      case ORGANIZATION -> sql = AttachmentTypeQuery.orgAddType;
      case EVENT -> sql = AttachmentTypeQuery.eventAddType;
      default -> throw new ApiException("Unsupported attachment type");
    }
    Long id = sqlCache.updateBySqlReturningId(sql, params, "id").longValue();
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
    String sql = AttachmentTypeQuery.update(objectType.tablePrefix);
    sqlCache.updateBySql(sql, params);
  }

  public void updateTypeOrder(List<ObjectTypeAttachmentType> attachmentTypes, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    for (ObjectTypeAttachmentType at : attachmentTypes) {
      params.put("displayOrder", at.getDisplayOrder());
      params.put("modifiedById", currentUser.trueUserId());
      params.put("id", at.getId());
      // save each display_order
      String sql = AttachmentTypeQuery.updateDisplayOrder(objectType.tablePrefix);
      sqlCache.updateBySql(sql, params);
    }
  }

  public void deleteTypeForObjectType(Long id, ObjectType objectType) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());
    params.put("userId", currentUser.trueUserId());
    String sql = AttachmentTypeQuery.deleteType(objectType.tablePrefix);
    sqlCache.updateBySql(sql, params);
  }

  //this endpoint is specifically for mobile. they want all attachment types back and they will parse them as needed
  public List<ObjectTypeAttachmentType> getAssignedTypesToObject(Long ppsId, Long ppsEventId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("ppsId", ppsId);
    params.put("ppsEventId", ppsEventId);

    //dumb. the project query needs these 3 params hardcoded as false
    params.put("allowUpload", false);
    params.put("focused", false);
    params.put("linkable", false);

    //because we don't have to pass in any of the 3 variables, this AttachmentTypeQuery.projectGetAssignedTypes should return them all
    String sql = null != ppsEventId
      ? ProjectProcessStepEventQuery.getEventAttachmentTypes
      : null != ppsId
      ? ProjectProcessStepQuery.getStepAttachmentTypes
      : AttachmentTypeQuery.projectGetAssignedTypes;

    return sqlCache.queryBySql(sql, params, ObjectTypeAttachmentType.class);
  }

  //these endpoints are for the non-admin side of things
  public List<ObjectTypeAttachmentType> getCombinedTypesForProject(Long ppsId, Long ppsEventId, Boolean focused) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("ppsId", ppsId);
    params.put("ppsEventId", ppsEventId);
    String sql = AttachmentTypeQuery.getCombinedTypesForProject;
    if (focused) {
      sql = null != ppsEventId
        ? AttachmentTypeQuery.getFocusedTypesForPpsEvent
        : null != ppsId
        ? AttachmentTypeQuery.getFocusedTypesForPps
        : AttachmentTypeQuery.getFocusedTypesForProject;
    }
    return sqlCache.queryBySql(sql, params, ObjectTypeAttachmentType.class);
  }


  public List<ObjectTypeAttachmentType> getAssignedTypes(ObjectType objectType, Boolean allowUpload, Boolean focused, Boolean linkable) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("allowUpload", null != allowUpload ? allowUpload : false);
    params.put("focused", null != focused ? focused : false);
    params.put("linkable", null != linkable ? linkable : false);

    String sql = "";
    switch (objectType) {
      case PROJECT -> sql = AttachmentTypeQuery.projectGetAssignedTypes;
      case CONTACT -> sql = AttachmentTypeQuery.contactGetAssignedTypes;
      case USER -> sql = AttachmentTypeQuery.userGetAssignedTypes;
      case ORGANIZATION -> sql = AttachmentTypeQuery.orgGetAssignedTypes;
      default -> throw new ApiException("Unsupported attachment type");
    }
    return sqlCache.queryBySql(sql, params, ObjectTypeAttachmentType.class);
  }

  public static class AttachmentTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AttachmentTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<>() {
      };
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
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class,
        "customFieldGroups",
        new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));
    }
  }
}
