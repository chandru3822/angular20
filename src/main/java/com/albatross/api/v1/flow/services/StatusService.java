package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.StatusType;
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
public class StatusService {

  @Autowired
  SqlCache sqlCache;

  @Autowired
  SecurityService securityService;

  public List<StatusType> getStatusTypesForCompany(Long companyId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", companyId);

    List<StatusType> attachmentTypes = sqlCache.query("status.getTypesForCompany", params, StatusType.class);
    return attachmentTypes;
  }

  public Optional<StatusType> getType(Long companyId, Long typeId) {
    return sqlCache.get("status.getType",
        ImmutableMap.of("companyId", companyId,
            "typeId", typeId),
        StatusType.class);
  }

  public void deleteType(Long typeId) {
    sqlCache.update("status.deleteType",
        ImmutableMap.of("id", typeId));
  }

  public void updateType(StatusType type) {
    sqlCache.update("status.updateType",
//        ImmutableMap.of("companyId", type.getCompanyId(),
//            "id", type.getId(),
//            "statusType", type.getStatusType()));
    ImmutableMap.of("id", type.getId(),
        "statusType", type.getStatusType()));
  }

  public Optional<StatusType> insertType(StatusType type) {
    Long id = sqlCache.updateReturningId("status.insertType",
//        ImmutableMap.of("statusType", type.getStatusType(),
//            "companyId", type.getCompanyId()),
//        "id").longValue();
    ImmutableMap.of("statusType", type.getStatusType()),
        "id").longValue();

    return getType(type.getCompanyId(), id);
  }


}
