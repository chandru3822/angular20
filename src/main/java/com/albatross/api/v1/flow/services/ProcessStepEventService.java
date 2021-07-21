package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ProcessStepEventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<ProcessStepEvent> getStepEvents(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    List<ProcessStepEvent> results = sqlCache.query("processStepEvent.getStepEvents", params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
    return results;
  }

  public List<ProcessStepEvent> getAvailableEventsForStep(Long processStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    List<ProcessStepEvent> results = sqlCache.query("processStepEvent.getAvailableEventsForStep", params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
    return results;
  }

  public Optional<ProcessStepEvent> getProcessStepEvent(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStepEvent> result = sqlCache.get("processStepEvent.get", params, new ProcessStepEventMapper<>(ProcessStepEvent.class, om));
    return result;
  }

  public Optional<ProcessStepEvent> addEventToStep(Long processStepId, ProcessStepEvent processStepEvent) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("createdById", currentUser.getId());
    params.put("eventId", processStepEvent.getEventId());
    params.put("initialCompanyEventStatusTypeId", processStepEvent.getInitialCompanyEventStatusTypeId());
    Long id = sqlCache.updateReturningId("processStepEvent.addEventToStep", params, "id").longValue();
    return getProcessStepEvent(id);
  }

  public void updateStepEvent(Long processStepId, Long eventId, ProcessStepEvent processStepEvent) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);
    params.put("initialCompanyEventStatusTypeId", processStepEvent.getInitialCompanyEventStatusTypeId());
    params.put("userId", currentUser.getId());
    params.put("eventId", eventId);
    sqlCache.update("processStepEvent.updateStepEvent", params);
  }

  public void deleteEventFromStep(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.getId());
    sqlCache.update("processStepEvent.deleteEventFromStep", params);
  }

  public Optional<ProcessStepEventAction> getStepEventAction(Long processStepEventActionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", processStepEventActionId);
    Optional<ProcessStepEventAction> result = sqlCache.get("processStepEvent.getStepEventAction", params, ProcessStepEventAction.class);
    return result;
  }

  public Optional<ProcessStepEventAction> addStepEventAction(Long processStepId, Long eventId, ProcessStepEventAction processStepEventAction) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyEventStatusTypeId", processStepEventAction.getCompanyEventStatusTypeId());
    params.put("companyProcessStepStatusTypeId", processStepEventAction.getCompanyProcessStepStatusTypeId());
    params.put("actionName", processStepEventAction.getActionName());
    params.put("userId", currentUser.getId());
    params.put("processStepEventId", eventId);

    Long id;

    if(null != processStepEventAction.getId()) {
      id = processStepEventAction.getId();
      params.put("id", id);
      sqlCache.update("processStepEvent.updateStepEventAction", params);
    } else {
      id = sqlCache.updateReturningId("processStepEvent.addStepEventAction", params, "id").longValue();
    }
    return getStepEventAction(id);
  }

  public void deleteActionFromEvent(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", currentUser.getId());
    sqlCache.update("processStepEvent.deleteActionFromEvent", params);
  }

  public Optional<ProcessStepEventActionField> addFieldToAction(Long eventId, Long actionId, Long cfgaId, Boolean required) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("actionId", actionId);
    params.put("cfgaId", cfgaId);
    params.put("required", required);
    params.put("userId", currentUser.getId());
    Long id = sqlCache.updateReturningId("processStepEvent.addFieldToAction", params, "id").longValue();
    return getActionField(id);
  }

  public void deleteFieldFromAction(Long eventId, Long actionId, Long fieldId) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("fieldId", fieldId);
    params.put("userId", currentUser.getId());
    sqlCache.update("processStepEvent.deleteFieldFromAction", params);
  }

  public Optional<ProcessStepEventActionField> getActionField(Long fieldId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", fieldId);
    Optional<ProcessStepEventActionField> result = sqlCache.get("processStepEvent.getActionField", params, ProcessStepEventActionField.class);
    return result;
  }

  public List<CustomField> getAvailableFieldsForEvent(Long eventId, Long actionId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("eventId", eventId);
    params.put("actionId", actionId);

    List<CustomField> results = sqlCache.query("processStepEvent.getAvailableCustomFields", params, CustomField.class);
    return results;
  }

  public static class ProcessStepEventMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepEventMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CompanyEventStatusType>> companyEventStatusTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companyEventStatusTypes",
        new JsonCollectionDeserializer(companyEventStatusTypeRef, objectMapper));

      TypeReference<List<ProcessStepEventAction>> processStepEventActionRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "processStepEventActions",
        new JsonCollectionDeserializer(processStepEventActionRef, objectMapper));
    }
  }
}
