package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.OperationType;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
//@RequiredArgsConstructor(onConstructor = @_(@Autowired))
public class OperationService {

  @Autowired
  SqlCache sqlCache;

  public List<OperationType> getOperationTypes() {
    List<OperationType> results = sqlCache.query("operation.getTypes", Collections.emptyMap(), OperationType.class);
    return results;
  }


}
