package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.enums.WhiteListType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ObjectTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<CompanyObjectType> getCompanyObjectTypes() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<CompanyObjectType> result = sqlCache.query("objectType.getCompanyObjectTypes", params, CompanyObjectType.class);
    return result;
  }

  public Optional<CompanyObjectType> getCompanyObjectTypeDetail(Long objectTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("objectTypeId", objectTypeId);
    params.put("ownerReadOnlyTypeId", objectTypeId.equals(ObjectType.PROJECT.id) ? WhiteListType.PROJECT_OWNER_READ_ONLY.id : WhiteListType.CONTACT_OWNER_READ_ONLY.id);
    params.put("statusReadOnlyTypeId", objectTypeId.equals(ObjectType.PROJECT.id) ? WhiteListType.PROJECT_STATUS_READ_ONLY.id : null);
    Optional<CompanyObjectType> result = sqlCache.get("objectType.getCompanyObjectTypeDetail", params, new CompanyObjectTypeMapper<>(CompanyObjectType.class, om));
    return result;
  }

  public void saveTypeAndWhiteList(CompanyObjectType companyObjectType, Boolean savingStatusReadOnly, Boolean savePositions, Long whiteListTypeId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("companyObjectTypeId", companyObjectType.getId());
    params.put("statusReadOnly", companyObjectType.getStatusReadOnly());
    params.put("ownerReadOnly", companyObjectType.getOwnerReadOnly());
    params.put("cfgaId", null);
    params.put("whiteListTypeId", whiteListTypeId);

    if(savingStatusReadOnly) {
      //these all say "customFieldGroupAssignment" but really they are just generic whitelist position functions
      sqlCache.update("objectType.saveStatusReadOnly", params);
    } else {
      sqlCache.update("objectType.saveOwnerReadOnly", params);
    }

    if ((savingStatusReadOnly && !companyObjectType.getStatusReadOnly()) || (!savingStatusReadOnly && !companyObjectType.getOwnerReadOnly())) {
      // if field is not readonly archive any white listed positions for it
      sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositions", params);
    } else if (null != savePositions && savePositions) {
      // if field IS read_only archive any white listed positions no longer in the body sent in
      List<WhiteListedPosition> positionsToUse = savingStatusReadOnly ? companyObjectType.getStatusReadOnlyWhiteListedPositions() : companyObjectType.getOwnerReadOnlyWhiteListedPositions();
      List<Long> positionIdsUsed = positionsToUse.stream().map(WhiteListedPosition::getPositionId).collect(Collectors.toList());
      params.put("positionIdsUsed", positionIdsUsed);
      if (positionIdsUsed.size() > 0) {
        sqlCache.update("customFieldGroupAssignment.archiveWhiteListPositionsNoLongerUsed", params);
      } else {
        //this means they removed ALL white listed positions
        sqlCache.update("customFieldGroupAssignment.archiveAllWhiteListedPositions", params);
      }

      for (WhiteListedPosition wlp : positionsToUse) {
        params.put("positionId", wlp.getPositionId());
        //this insert checks if there is already a non-archived row with the same values
        sqlCache.update("customFieldGroupAssignment.insertWhiteListPosition", params);
      }
    }

  }

  public static class CompanyObjectTypeMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public CompanyObjectTypeMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<WhiteListedPosition>> statusReadOnlyWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "statusReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(statusReadOnlyWhiteListedPositionsRef, objectMapper));

      TypeReference<List<WhiteListedPosition>> ownerReadOnlyWhiteListedPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "ownerReadOnlyWhiteListedPositions",
        new JsonCollectionDeserializer(ownerReadOnlyWhiteListedPositionsRef, objectMapper));
    }
  }
}
