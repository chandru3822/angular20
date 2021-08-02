package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
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
public class StatusService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<StatusType> getStatusTypesForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    List<StatusType> attachmentTypes = sqlCache.query("status.getTypesForCompany", params, StatusType.class);
    return attachmentTypes;
  }

  public Optional<StatusType> getType(Long companyId, Long typeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);
    params.put("typeId", typeId);
    Optional<StatusType> result = sqlCache.get("status.getType", params, StatusType.class);
    return result;
  }

  public void deleteType(Long typeId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("typeId", typeId);

    sqlCache.update("status.deleteType", params);
  }

  public void updateType(StatusType type) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", type.getId());
    params.put("statusType", type.getStatusType());

    sqlCache.update("status.updateType", params);
  }

  public Optional<StatusType> insertType(StatusType type) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", type.getId());
    params.put("statusType", type.getStatusType());
    Long id = sqlCache.updateReturningId("status.insertType", params, "id").longValue();


    return getType(type.getCompanyId(), id);
  }


}
