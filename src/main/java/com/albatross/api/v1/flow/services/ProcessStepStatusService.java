package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.CompanyProcessStepStatusType;
import com.albatross.api.v1.flow.model.StatusType;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
public class ProcessStepStatusService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<CompanyProcessStepStatusType> getStatusTypesForCompany(Long projectId, Long projectProcessStepId) {
    User user = securityService.getCurrentUser();
    Long companyId = user.getCompanyId();
    Boolean isParent = user.getCompanyId().equals(user.getHighestParentCompanyId());

    if(null != projectId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p1 = new HashMap<>();
      p1.put("projectId", projectId);
      companyId = sqlCache.queryForObject("project.getCompanyId", p1, Long.class);
    } else if(null != projectProcessStepId) {
      //had to change this so that a parent looking at a child project process step could will get the right statuses back
      HashMap<String, Object> p2 = new HashMap<>();
      p2.put("projectProcessStepId", projectProcessStepId);
      companyId = sqlCache.queryForObject("projectProcessStep.getCompanyId", p2, Long.class);
    }

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", isParent);
    //if a projectId or projectProcessStepId is sent in, use that company even if isParent is true
    params.put("parentOverride", null != projectId || null != projectProcessStepId);

    List<CompanyProcessStepStatusType> companyProcessStepStatusTypes = sqlCache.query("processStepStatus.getTypesForCompany", params, CompanyProcessStepStatusType.class);
    return companyProcessStepStatusTypes;
  }

  public Optional<CompanyProcessStepStatusType> getType(Long companyId, Long typeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("typeId", typeId);
    return sqlCache.get("processStepStatus.getType", params, CompanyProcessStepStatusType.class);
  }

  public Optional<CompanyProcessStepStatusType> getActiveType() {
      return sqlCache.get("processStepStatus.getActiveTypeForCompany", Map.of("companyId", securityService.getCurrentUser().getCompanyId()), CompanyProcessStepStatusType.class);
  }

  public Optional<CompanyProcessStepStatusType> getCancelledType(Long companyId) {
    return sqlCache.get("processStepStatus.getCancelledTypeForCompany", Map.of("companyId", companyId), CompanyProcessStepStatusType.class);
  }

  public void deleteType(Long typeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", typeId);
    params.put("modifiedById", currentUser.getId());
    sqlCache.update("processStepStatus.deleteType", params);
  }

  public void updateType(CompanyProcessStepStatusType type) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", type.getCompanyId());
    params.put("id", type.getId());
    params.put("statusType", type.getProcessStepStatusType());
    params.put("modifiedById", currentUser.getId());

    sqlCache.update("processStepStatus.updateType", params);
  }

  public Optional<CompanyProcessStepStatusType> insertType(StatusType type) {
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
