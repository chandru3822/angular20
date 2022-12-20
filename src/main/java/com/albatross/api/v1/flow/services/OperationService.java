package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.OperationType;
import com.albatross.api.v1.flow.queries.OperationQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class OperationService {

  private final SqlCache sqlCache;

  public List<OperationType> getOperationTypes() {
    return sqlCache.queryBySql(OperationQuery.getTypes, Collections.emptyMap(), OperationType.class);
  }
}
