package com.albatross.api.v1.flow.services;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CustomFieldGroup;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepAttachmentType;
import com.albatross.api.v1.flow.model.ProcessStepLink;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;


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
  ObjectMapper om;

  public List<ProcessStep> getProcessStepsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<ProcessStep> results = sqlCache.query("processStep.getAllForCompany", params, ProcessStep.class);
    return results;
  }

  public ProcessStep getProcessStep(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<ProcessStep> result = sqlCache.get("processStep.get", params,  new ProcessStepMapper<>(ProcessStep.class, om));
    return result.orElse(null);
  }

  public void deleteStep(Long id) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("processStep.delete", params);
  }

  public void updateStep(ProcessStep processStep) {
    // this is going to have to change when process steps are shared between companies
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", processStep.getId());
    params.put("modifiedById", currentUser.getId());
    params.put("name", processStep.getProcessStepName());
    sqlCache.update("processStep.update", params);
  }

  public ProcessStep insertStep(ProcessStep processStep) {
    // this is going to have to change when process steps are shared between companies
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.getId());
    params.put("name", processStep.getProcessStepName());
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

      bw.registerCustomEditor(List.class, "customFieldGroups",
          new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));

      bw.registerCustomEditor(List.class, "attachmentTypes",
          new JsonCollectionDeserializer(processStepAttachmentTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "links",
          new JsonCollectionDeserializer(processStepLinkRef, objectMapper));
    }
  }

}
