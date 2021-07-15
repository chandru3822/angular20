package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.CallGroup;
import com.albatross.api.v1.company.blueraven.models.CallGroupPhoneNumber;
import com.albatross.api.v1.company.blueraven.models.CallGroupPostalCode;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
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

    List<CallGroup> results = sqlCache.query("callGroup.getGroups", params, CallGroup.class);
    return results;
  }

  public CallGroup getGroupDetails(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroup> result = sqlCache.get("callGroup.getGroup", params, CallGroup.class);
    return result.orElse(null);
  }

  public List<CallGroupPostalCode> getCodesForGroup(Long callGroupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", callGroupId);

    List<CallGroupPostalCode> results = sqlCache.query("callGroup.getCodesForGroup", params, CallGroupPostalCode.class);
    return results;
  }

  public List<CallGroupPhoneNumber> getNumbersForGroup(Long callGroupId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", callGroupId);

    List<CallGroupPhoneNumber> results = sqlCache.query("callGroup.getNumbersForGroup", params, CallGroupPhoneNumber.class);
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
      params.put("modifiedById", user.getId());
      sqlCache.update("callGroup.updateGroup", params);
    } else {
      params.put("maxCallCount", cg.getMaxCallCount());
      params.put("daysPerPeriod", cg.getDaysPerPeriod());
      params.put("createdById", user.getId());
      id = sqlCache.updateReturningId("callGroup.insertGroup", params, "id").longValue();
    }

    return getGroupDetails(id);
  }

  public void saveGroupConfig(CallGroup cg) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("maxCallCount", cg.getMaxCallCount());
    params.put("daysPerPeriod", cg.getDaysPerPeriod());
    params.put("modifiedById", user.getId());
    sqlCache.update("callGroup.updateGroupConfig", params);
  }

  public void deleteGroup(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("callGroup.deleteGroup", params);
  }

  public ResponseEntity addPostalCode(CallGroupPostalCode cgpc) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", cgpc.getCallGroupId());
    params.put("postalCode", cgpc.getPostalCode());
    params.put("createdById", user.getId());

    Optional<CallGroupPostalCode> result = sqlCache.get("callGroup.checkForExisting", params, CallGroupPostalCode.class);
    if(result.isPresent()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Postal Code Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else {
      Long id = sqlCache.updateReturningId("callGroup.addPostalCode", params, "id").longValue();
      return ResponseEntity.ok(getPostalCode(id));
    }
  }

  public void deletePostalCode(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("callGroup.deletePostalCode", params);
  }

  public ResponseEntity addPhoneNumber(CallGroupPhoneNumber cgpn) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("callGroupId", cgpn.getCallGroupId());
    params.put("phoneNumber", cgpn.getPhoneNumber());
    params.put("active", true);
    params.put("createdById", user.getId());

    Optional<CallGroupPhoneNumber> result = sqlCache.get("callGroup.checkForExistingPhone", params, CallGroupPhoneNumber.class);
    if(result.isPresent()) {
      HashMap<String, Object> errorObj = new HashMap<>();
      errorObj.put("message", "Error: Phone Number Already In Use");
      return ResponseEntity.badRequest().body(errorObj);
    } else {
      Long id = sqlCache.updateReturningId("callGroup.addPhoneNumber", params, "id").longValue();
      return ResponseEntity.ok(getPhoneNumber(id));
    }
  }

  public void updatePhoneNumber(CallGroupPhoneNumber cgpn) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("active", cgpn.getActive());
    params.put("id", cgpn.getId());
    params.put("modifiedById", user.getId());

    sqlCache.update("callGroup.updatePhoneNumber", params);
  }

  public void deletePhoneNumber(Long id) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("callGroup.deletePhoneNumber", params);
  }

  public CallGroupPostalCode getPostalCode(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroupPostalCode> result = sqlCache.get("callGroup.getPostalCode", params, CallGroupPostalCode.class);
    return result.orElse(null);
  }

  public CallGroupPhoneNumber getPhoneNumber(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<CallGroupPhoneNumber> result = sqlCache.get("callGroup.getPhoneNumber", params, CallGroupPhoneNumber.class);
    return result.orElse(null);
  }

}
