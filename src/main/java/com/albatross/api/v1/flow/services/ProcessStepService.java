package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.processStep.*;
import com.albatross.api.v1.flow.queries.ProcessStepQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@PreAuthorize("hasFeatureAccess('PROCESS_STEPS')")
@RequiredArgsConstructor
public class ProcessStepService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldGroupService customFieldGroupService;
  private final ObjectMapper om;

  public List<ProcessStep> getProcessStepsForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(
      ProcessStepQuery.getAllForCompany, params, new ProcessStepMapper<>(ProcessStep.class, om));
  }

  public Optional<ProcessStep> getProcessStep(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("companyId", currentUser.getCompanyId());

    Optional<ProcessStep> result = sqlCache.getBySql(ProcessStepQuery.get, params, new ProcessStepMapper<>(ProcessStep.class, om));

    if(result.isPresent()) {
      return result;
    } else {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Process Step Not Found.", new Exception());
    }
  }

  public void saveReadOnlyAndWhiteList(ProcessStep processStep, Boolean savePositions) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("readOnly", processStep.getReadonly());
    params.put("psId", processStep.getId());
    params.put("whiteListTypeId", WhiteListType.PROCESS_STEP_READ_ONLY.id);

    sqlCache.updateBySql(ProcessStepQuery.saveReadOnly, params);

    if (!processStep.getReadonly()) {
      // if ps is not readonly archive any white listed positions for it
      sqlCache.updateBySql(ProcessStepQuery.archiveWhiteListPositions, params);
    } else if (null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<WhiteListedPosition> positionsToUse = processStep.getWhiteListedPositions();
      List<Long> positionIdsUsed = processStep.getWhiteListedPositions().stream()
                   .map(WhiteListedPosition::getPositionId)
                   .collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if (positionIdsUsed.size() > 0) {
        sqlCache.updateBySql(ProcessStepQuery.archiveWhiteListPositionsNoLongerUsed, params);
      } else {
        // this means they removed ALL white listed positions
        sqlCache.updateBySql(ProcessStepQuery.archiveWhiteListPositions, params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        // this insert checks if there is already a non-archived row with the same values
        sqlCache.updateBySql(ProcessStepQuery.insertWhiteListPosition, params);
      }
    }
  }

  public List<FieldInUse> deleteStep(Long id) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("processStepId", id);
    params.put("modifiedById", currentUser.trueUserId());

    List<FieldInUse> fields = customFieldGroupService.getFieldsInUse(id, null, null);
    if (!fields.isEmpty()) {
      return fields;
    } else {
      sqlCache.updateBySql(ProcessStepQuery.delete, params);
      return null;
    }
  }

  public void updateStep(ProcessStep processStep) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", processStep.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("name", processStep.getProcessStepName());
    params.put("nonAdminAdd", processStep.getNonAdminAdd());
    sqlCache.updateBySql(ProcessStepQuery.update, params);
  }

  public Optional<ProcessStep> insertStep(ProcessStep processStep) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());
    params.put("createdById", currentUser.trueUserId());
    params.put("name", processStep.getProcessStepName());
    params.put("nonAdminAdd", processStep.getNonAdminAdd() != null && processStep.getNonAdminAdd());
    Long id = sqlCache.updateBySqlReturningId(ProcessStepQuery.insert, params, "id").longValue();

    return getProcessStep(id);
  }

  public List<ProcessStep> getParentObjects(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    return sqlCache.queryBySql(ProcessStepQuery.getParentObjects, params, ProcessStep.class);
  }

  public List<CombinedStepAndType> getParentObjectsIncludingTypes(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    return sqlCache.queryBySql(
      ProcessStepQuery.getParentObjectsIncludingTypes, params, CombinedStepAndType.class);
  }

  public List<ProcessStep> getByCompanyId() {
    return sqlCache.queryBySql(
      ProcessStepQuery.getProcessStepProcessByCompanyId,
        Map.of("companyId", securityService.getCurrentUser().getCompanyId()),
        ProcessStep.class);
  }

  public List<Owner> getOwners(Long id) {
    User user = securityService.getCurrentUser();
    Boolean inParentCompany = user.getCompanyId().equals(user.getHighestParentCompanyId());
    return sqlCache.queryBySql(
      ProcessStepQuery.getOwners,
        Map.of("id", id, "companyId", user.getCompanyId(), "inParentCompany", inParentCompany),
        Owner.class);
  }

  public static class ProcessStepMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProcessStepMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> customFieldGroupRef =
          new TypeReference<List<CustomFieldGroup>>() {};
      TypeReference<List<ProcessStepAttachmentType>> processStepAttachmentTypeRef =
          new TypeReference<List<ProcessStepAttachmentType>>() {};
      TypeReference<List<ProcessStepLink>> processStepLinkRef =
          new TypeReference<List<ProcessStepLink>>() {};
      TypeReference<List<ProcessStepWorkQueueType>> workQueueTypeRef =
          new TypeReference<List<ProcessStepWorkQueueType>>() {};
      TypeReference<List<ProcessStepCompanyProcessStepStatusType>> companyProcessStepStatusTypeRef =
          new TypeReference<List<ProcessStepCompanyProcessStepStatusType>>() {};
      TypeReference<List<WhiteListedPosition>> whiteListedPositionsRef =
        new TypeReference<List<WhiteListedPosition>>() {};

      bw.registerCustomEditor(
          List.class,
          "customFieldGroups",
          new JsonCollectionDeserializer(customFieldGroupRef, objectMapper));

      bw.registerCustomEditor(
        List.class,
        "whiteListedPositions",
        new JsonCollectionDeserializer(whiteListedPositionsRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "attachmentTypes",
          new JsonCollectionDeserializer(processStepAttachmentTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "links", new JsonCollectionDeserializer(processStepLinkRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "workQueueTypes",
          new JsonCollectionDeserializer(workQueueTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "companyProcessStepStatusTypes",
          new JsonCollectionDeserializer(companyProcessStepStatusTypeRef, objectMapper));
    }
  }
}
