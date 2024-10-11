package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ObjectCategory;
import com.albatross.api.v1.flow.queries.ObjectCategoryQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ObjectCategoryService {

  private final SqlCache sqlCache;

  public List<ObjectCategory> getCategories(Long objectTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("objectTypeId", objectTypeId);

    return sqlCache.queryBySql(ObjectCategoryQuery.getAll, params, ObjectCategory.class);
  }
}
