package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.AttachmentTypeSecondaryKeyPattern;
import com.albatross.api.v1.flow.queries.SecondaryKeyPatternQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class SecondaryKeyPatternService {

  private final SqlCache sqlCache;

  public List<AttachmentTypeSecondaryKeyPattern> getByAttachmentTypeId(Long attachmentTypeId) {
    Map<String, Object> params = new HashMap<>();
    params.put("attachmentTypeId", attachmentTypeId);
    return sqlCache.queryBySql(
      SecondaryKeyPatternQuery.getByAttachmentTypeId, params, AttachmentTypeSecondaryKeyPattern.class);
  }
}
