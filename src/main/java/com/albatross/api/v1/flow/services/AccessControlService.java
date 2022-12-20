package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.FeatureAccessControl;
import com.albatross.api.v1.flow.queries.AccessControlQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class AccessControlService {

  private final SqlCache sqlCache;

  public List<FeatureAccessControl> getAccessControlList() {
    return sqlCache.queryBySql(
      AccessControlQuery.getAll, Collections.emptyMap(), FeatureAccessControl.class);
  }
}
