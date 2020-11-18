package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class ProcessStepService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  @Autowired
  CustomFieldGroupService customFieldGroupService;

  @Autowired
  ObjectMapper om;

  public List<ProcessStep> getProcessStepsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<ProcessStep> results = sqlCache.query("processStep.getAllForCompany", params, new ProcessStepMapper<>(ProcessStep.class, om));
    return results;
  }

  public ProcessStep getProcessStep(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStep> result = sqlCache.get("processStep.get", params,  new ProcessStepMapper<>(ProcessStep.class, om));
    return result.orElse(null);
  }

  public List<FieldInUse> deleteStep(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", id);
    params.put("modifiedById", currentUser.getId());

    List<FieldInUse> fields = customFieldGroupService.getFieldsInUse(id, null, null);
    if(!fields.isEmpty()) {
      return fields;
    } else {
      sqlCache.update("processStep.delete", params);
      return null;
    }
  }

  public void updateStep(ProcessStep processStep) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", processStep.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("name", processStep.getProcessStepName());
    params.put("nonAdminAdd", processStep.getNonAdminAdd());
    sqlCache.update("processStep.update", params);
  }

  public ProcessStep insertStep(ProcessStep processStep) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.getId());
    params.put("name", processStep.getProcessStepName());
    params.put("nonAdminAdd", processStep.getNonAdminAdd() != null && processStep.getNonAdminAdd());
    Long id = sqlCache.updateReturningId("processStep.insert", params, "id").longValue();

    return getProcessStep(id);
  }

  public List<ProcessStep> getParentObjects(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    List<ProcessStep> results = sqlCache.query("processStep.getParentObjects", params, ProcessStep.class);
    return results;
  }

  public List<CombinedStepAndType> getParentObjectsIncludingTypes(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    List<CombinedStepAndType> results = sqlCache.query("processStep.getParentObjectsIncludingTypes", params, CombinedStepAndType.class);
    return results;
  }

  public List<ProcessStep> getByCompanyId() {
    return sqlCache.query("processStep.getProcessStepProcessByCompanyId", Map.of("companyId", securityService.getCurrentUser().getCompanyId()), ProcessStep.class);
  }

  public List<Owner> getOwners(Long id) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    return sqlCache.query("processStep.getOwners", Map.of("id", id, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany), Owner.class);
  }

  public static class ProcessStepMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef = new TypeReference<List<CustomFieldGroup>>() {};
      TypeReference<List<ProcessStepAttachmentType>> processStepAttachmentTypeRef = new TypeReference<List<ProcessStepAttachmentType>>() {};
      TypeReference<List<ProcessStepLink>> processStepLinkRef = new TypeReference<List<ProcessStepLink>>() {};
      TypeReference<List<ProcessStepWorkQueueType>> workQueueTypeRef = new TypeReference<List<ProcessStepWorkQueueType>>() {};

      bw.registerCustomEditor(List.class, "customFieldGroups",
          new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));

      bw.registerCustomEditor(List.class, "attachmentTypes",
          new JsonCollectionDeserializer(processStepAttachmentTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "links",
          new JsonCollectionDeserializer(processStepLinkRef, objectMapper));

      bw.registerCustomEditor(List.class, "workQueueTypes",
          new JsonCollectionDeserializer(workQueueTypeRef, objectMapper));
    }
  }

}
