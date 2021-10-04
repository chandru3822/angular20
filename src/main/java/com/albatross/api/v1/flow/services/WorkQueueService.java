package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.utils.SqlCacheRO;
import com.albatross.api.v1.flow.enums.ProcessStepStatusType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.ColumnMapRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class WorkQueueService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;
  private final SmartlistService smartlistService;
  private final SqlCacheRO sqlCacheRO;


  public List<WorkQueue> getWorkQueues(Long workQueueCategoryId, Long userId, Boolean unassigned, Boolean filterFutureFollowUps) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueCategoryId", workQueueCategoryId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    params.put("filterFutureFollowUps", null != filterFutureFollowUps && filterFutureFollowUps);
    params.put("unassigned", null != unassigned && unassigned);
    //currently we only show active process steps. but sending in as a list in case that changes
    params.put("processStepStatusTypeIds", new ArrayList<>(Arrays.asList(ProcessStepStatusType.ACTIVE.id)));

    List<WorkQueue> results = sqlCache.query("workQueue.getWorkQueues", params, WorkQueue.class);
    return results;
  }

//  public Page<WorkQueueDetail> getWorkQueueDetails(Long workQueueTypeId, Long userPositionId, Boolean unassigned, Pageable pageable) {
//    User user = securityService.getCurrentUser();
//    HashMap<String, Object> params = new HashMap<>();
//    params.put("workQueueTypeId", workQueueTypeId);
//    params.put("parentCompanyId", user.getHighestParentCompanyId());
//    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
//    params.put("companyId", user.getCompanyId());
//    params.put("userPositionId", userPositionId);
//    params.put("unassigned", null == unassigned ? false : unassigned);
//    params.put("limit", pageable.getPageSize());
//    params.put("offset", pageable.getOffset());
//
//    String sqlKey = "workQueue.getProcessStepsByTypeId";
//
//    //todo: this is a total whack-a-hack, need to remove this after we do a more configurable work queue in a future release
//    if(workQueueTypeId == 98 || workQueueTypeId == 99 || workQueueTypeId == 106) {
//      sqlKey = "workQueue.getProcessStepsByTypeIdForHack";
//    }
//
//    List<WorkQueueDetail> results = sqlCache.query(sqlKey, params, new WorkQueueDetailMapper<>(WorkQueueDetail.class, om));
//    //count should be the same regardless of the hack or not
//    Integer count = sqlCache.queryForObject("workQueue.getProcessStepsByTypeIdCount", params, Integer.class);
//
//    Page<WorkQueueDetail> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
//    return page;
//  }

  public SmartlistResult getWorkQueueDetails(Long workQueueTypeId, Long smartlistId, Long userId, Boolean unassigned, String timezone, Pageable pageable,
                                             List<Long> installationCrewIds) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("workQueueTypeId", workQueueTypeId);
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("userId", userId);
    params.put("unassigned", null == unassigned ? false : unassigned);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    Smartlist smartlist = smartlistService.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }
    log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
    List<SmartlistFieldAssignment> fields = smartlistService.getAssignedFields(smartlistId);

    final String query = smartlistService.buildSql(smartlist, fields, timezone, installationCrewIds, false);
    List<Map<String, Object>> results = sqlCacheRO.queryBySql(query, null, new ColumnMapRowMapper());

    List<Map<String, Object>> randasResults = new ArrayList<>();

    for (Map<String, Object> result: results) {

      Map<String, Object> newResult = new HashMap<>();

      for(Map.Entry<String, Object> entry: result.entrySet()) {
        if (result.get(entry.getKey()) != null) {
          if (Objects.equals(entry.getValue().getClass(), PGobject.class)) {
            newResult.put(entry.getKey(), ((PGobject) entry.getValue()).getValue());
          } else {
            newResult.put(entry.getKey(), entry.getValue());
          }
        } else {
          newResult.put(entry.getKey(), entry.getValue());
        }

      }

      randasResults.add(newResult);
    }

    return new SmartlistResult(fields, randasResults);
  }

  public String buildSql(Long smartlistId) {
    Smartlist smartlist = smartlistService.getSmartlist(smartlistId);
    if (smartlist == null) {
      throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Smartlist not found", new RuntimeException());
    }

    log.info("SMARTLIST: Running smartlist ID: " + smartlistId);
    List<SmartlistFieldAssignment> fields = smartlistService.getAssignedFields(smartlistId);
    String query = smartlistService.buildSql(smartlist, fields);
    return query;
  }

  public List<WorkQueueOwner> getWorkQueueOwners() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());

    List<WorkQueueOwner> results = sqlCache.query("workQueue.getWorkQueueOwners", params, WorkQueueOwner.class);
    return results;
  }

  public static class WorkQueueDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public WorkQueueDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<OwningPosition>> owningPositionsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "owningPositions",
          new JsonCollectionDeserializer(owningPositionsRef, objectMapper));

      TypeReference<List<ProjectProcessStep>> activeProcessStepsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "activeProcessSteps",
        new JsonCollectionDeserializer(activeProcessStepsRef, objectMapper));

      TypeReference<List<Note>> notesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "notes",
        new JsonCollectionDeserializer(notesRef, objectMapper));
    }
  }
}
