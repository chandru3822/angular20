package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CallGroup;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.company.blueraven.models.CallGroupPostalCode;
import com.albatross.api.v1.company.blueraven.services.queries.CallGroupQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccessLevel('CALL_GROUPS')")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class CallGroupService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<CallGroup> getGroups(String searchQuery) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("searchQuery", searchQuery);

    List<CallGroup> results = sqlCache.queryBySql(CallGroupQuery.getGroups, params, CallGroup.class);
    return results;
  }

  public CallGroup getGroupDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroup> result = sqlCache.getBySql(CallGroupQuery.getGroup, params, CallGroup.class);
    return result.orElse(null);
  }

  public List<CallGroupPostalCode> getCodesForGroup(Long callGroupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", callGroupId);

    List<CallGroupPostalCode> results = sqlCache.queryBySql(CallGroupQuery.getCodesForGroup, params, CallGroupPostalCode.class);
    return results;
  }

  public List<CallGroupPhoneNumber> getNumbersForGroup(Long callGroupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", callGroupId);

    List<CallGroupPhoneNumber> results = sqlCache.queryBySql(CallGroupQuery.getNumbersForGroup, params, CallGroupPhoneNumber.class);
    return results;
  }

  public CallGroup saveGroup(CallGroup cg) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("callGroupName", cg.getCallGroupName());
    params.put("active", cg.getActive());

    Long id;
    if(null != cg.getId()) {
      id = cg.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.updateBySql(CallGroupQuery.updateGroup, params);
    } else {
      params.put("maxCallCount", cg.getMaxCallCount());
      params.put("daysPerPeriod", cg.getDaysPerPeriod());
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateBySqlReturningId(CallGroupQuery.insertGroup, params, "id").longValue();
    }

    return getGroupDetails(id);
  }

  public void saveGroupConfig(CallGroup cg) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("maxCallCount", cg.getMaxCallCount());
    params.put("daysPerPeriod", cg.getDaysPerPeriod());
    params.put("modifiedById", user.trueUserId());
    sqlCache.updateBySql(CallGroupQuery.updateGroupConfig, params);
  }

  public void deleteGroup(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(CallGroupQuery.deleteGroup, params);
  }

  public ResponseEntity addPostalCode(CallGroupPostalCode cgpc) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", cgpc.getCallGroupId());
    params.put("postalCode", cgpc.getPostalCode());
    params.put("createdById", user.trueUserId());

    Optional<CallGroupPostalCode> result = sqlCache.getBySql(CallGroupQuery.checkForExisting, params, CallGroupPostalCode.class);
    if(result.isPresent()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Postal Code Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else {
      Long id = sqlCache.updateBySqlReturningId(CallGroupQuery.addPostalCode, params, "id").longValue();
      return ResponseEntity.ok(getPostalCode(id));
    }
  }

  public void deletePostalCode(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(CallGroupQuery.deletePostalCode, params);
  }

  public ResponseEntity addPhoneNumber(CallGroupPhoneNumber cgpn) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", cgpn.getCallGroupId());
    params.put("phoneNumber", cgpn.getPhoneNumber());
    params.put("active", true);
    params.put("createdById", user.trueUserId());

    Optional<CallGroupPhoneNumber> result = sqlCache.getBySql(CallGroupQuery.checkForExistingPhone, params, CallGroupPhoneNumber.class);
    if(result.isPresent()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Phone Number Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else {
      Long id = sqlCache.updateBySqlReturningId(CallGroupQuery.addPhoneNumber, params, "id").longValue();
      return ResponseEntity.ok(getPhoneNumber(id));
    }
  }

  public void updatePhoneNumber(CallGroupPhoneNumber cgpn) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("active", cgpn.getActive());
    params.put("id", cgpn.getId());
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(CallGroupQuery.updatePhoneNumber, params);
  }

  public void deletePhoneNumber(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.updateBySql(CallGroupQuery.deletePhoneNumber, params);
  }

  public CallGroupPostalCode getPostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroupPostalCode> result = sqlCache.getBySql(CallGroupQuery.getPostalCode, params, CallGroupPostalCode.class);
    return result.orElse(null);
  }

  public CallGroupPhoneNumber getPhoneNumber(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroupPhoneNumber> result = sqlCache.getBySql(CallGroupQuery.getPhoneNumber, params, CallGroupPhoneNumber.class);
    return result.orElse(null);
  }

}
