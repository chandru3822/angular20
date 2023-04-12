package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Hashtag;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.HashtagQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class HashtagService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<Hashtag> getHashtags() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(HashtagQuery.getAll, params, Hashtag.class);
  }

  public Optional<Hashtag> getHashtag(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(HashtagQuery.getOne, params, Hashtag.class);
  }

  public Optional<Hashtag> saveHashtag(Hashtag tag) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("hashtag", tag.getHashtag());
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    Long id;
    if(null != tag.getId()) {
      id = tag.getId();
      params.put("id", id);
      sqlCache.updateBySql(HashtagQuery.update, params);

    } else {
      params.put("hashtagTypeId", tag.getHashtagTypeId());
      id = sqlCache.updateBySqlReturningId(HashtagQuery.insert, params, "id").longValue();
    }

    return getHashtag(id);
  }

  public void deleteHashtag(Long hashtagId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("hashtagId", hashtagId);
    params.put("userId", user.getId());
    sqlCache.updateBySql(HashtagQuery.delete, params);
  }

}
