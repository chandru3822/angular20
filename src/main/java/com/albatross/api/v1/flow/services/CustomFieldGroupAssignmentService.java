package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.queries.CustomFieldGroupAssignmentQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * Created by randanunn on 2019-05-20. !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CustomFieldGroupAssignmentService {

  private final SqlCache sqlCache;

  //i had to make this service to avoid an annoying circular reference issue
  public List<Long> getIdsByPPSId(Long ppsId) {
    return sqlCache.queryBySql(CustomFieldGroupAssignmentQuery.getIdsByPPSId, Map.of("ppsId", ppsId), new SingleColumnRowMapper<>(Long.class));
  }
}
