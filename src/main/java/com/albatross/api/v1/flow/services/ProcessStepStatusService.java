package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.StatusType;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class ProcessStepStatusService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<ProcessStepStatusType> getStatusTypesForCompany(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    List<ProcessStepStatusType> attachmentTypes = sqlCache.query("processStepStatus.getTypesForCompany", params, ProcessStepStatusType.class);
    return attachmentTypes;
  }

  public Optional<ProcessStepStatusType> getType(Long companyId, Long typeId) {
    return sqlCache.get("processStepStatus.getType",
        ImmutableMap.of("companyId", companyId,
            "typeId", typeId),
        ProcessStepStatusType.class);
  }

  public void deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("processStepStatus.deleteType",
        ImmutableMap.of("id", typeId,
            "modifiedById", currentUser.getId()));
  }

  public void updateType(ProcessStepStatusType type) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update("processStepStatus.updateType",
        ImmutableMap.of("companyId", type.getCompanyId(),
            "id", type.getId(),
            "modifiedById", currentUser.getId(),
            "statusType", type.getProcessStepStatusType()));
  }

  public Optional<ProcessStepStatusType> insertType(StatusType type) {
    User currentUser = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("processStepStatus.insertType",
        ImmutableMap.of("statusType", type.getStatusType(),
            "companyId", type.getCompanyId(),
            "createdById", currentUser.getId()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
