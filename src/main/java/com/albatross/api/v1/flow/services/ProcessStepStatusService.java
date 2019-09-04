package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.StatusType;
import com.albatross.api.v1.flow.model.User;
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
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("typeId", typeId);
    return sqlCache.get("processStepStatus.getType", params, ProcessStepStatusType.class);
  }

  public void deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", typeId);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("processStepStatus.deleteType", params);
  }

  public void updateType(ProcessStepStatusType type) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", type.getCompanyId());
    params.put("id", type.getId());
    params.put("statusType", type.getProcessStepStatusType());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("processStepStatus.updateType", params);
  }

  public Optional<ProcessStepStatusType> insertType(StatusType type) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", type.getCompanyId());
    params.put("id", type.getId());
    params.put("statusType", type.getStatusType());
    params.put("createdById", currentUser.getId());

    Long id = sqlCache.updateReturningId("processStepStatus.insertType", params, "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
