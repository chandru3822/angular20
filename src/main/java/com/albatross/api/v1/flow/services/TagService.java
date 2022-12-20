package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProjectTag;
import com.albatross.api.v1.flow.model.Tag;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.queries.TagQuery;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class TagService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<Tag> getTagsByType(Long tagTypeId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tagTypeId", tagTypeId);
    params.put("companyId", user.getCompanyId());
    return sqlCache.queryBySql(TagQuery.getAll, params, Tag.class);
  }

  public Optional<Tag> getTag(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    return sqlCache.getBySql(TagQuery.getOne, params, Tag.class);
  }

  public Optional<Tag> saveTag(Tag tag) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tagName", tag.getTagName());
    params.put("bgColor", tag.getBgColor());
    params.put("fontColor", tag.getFontColor());
    params.put("companyId", user.getCompanyId());
    params.put("userId", user.getId());
    Long id;
    if(null != tag.getId()) {
      id = tag.getId();
      params.put("id", id);
      sqlCache.updateBySql(TagQuery.update, params);

    } else {
      params.put("tagTypeId", tag.getTagTypeId());
      id = sqlCache.updateBySqlReturningId(TagQuery.insert, params, "id").longValue();
    }

    return getTag(id);
  }

  public void deleteTag(Long tagId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("tagId", tagId);
    params.put("userId", user.getId());
    sqlCache.updateBySql(TagQuery.delete, params);
  }

  public List<ProjectTag> getProjectTags(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    return sqlCache.queryBySql(TagQuery.projectTags, params, ProjectTag.class);
  }

}
