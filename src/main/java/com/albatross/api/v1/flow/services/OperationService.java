package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.OperationType;
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
    return sqlCache.query("operation.getTypes", Collections.emptyMap(), OperationType.class);
  }
}
