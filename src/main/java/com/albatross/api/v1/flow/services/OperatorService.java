package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.OperatorType;
import com.albatross.api.v1.flow.queries.OperatorQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class OperatorService {

  private final SqlCache sqlCache;

  public List<OperatorType> getOperatorTypes(Long dataTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("dataTypeId", dataTypeId);
    return sqlCache.queryBySql(OperatorQuery.getTypesByDataType, params, OperatorType.class);
  }
}
