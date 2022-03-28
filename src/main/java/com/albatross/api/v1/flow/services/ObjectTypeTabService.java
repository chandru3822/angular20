package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ObjectTypeTab;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ObjectTypeTabService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<ObjectTypeTab> getTabs(Long objectTypeId, Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Long companyId = currentUser.getCompanyId();
    Map<String, Object> params = new HashMap<>();

    if (null != projectId) {
      // had to change this so that a parent looking at a child project could still see project tabs
      params.put("projectId", projectId);
      Optional<Long> overrideCompanyId =
          sqlCache.queryForObjectOptional("project.getCompanyId", params, Long.class);
      if (overrideCompanyId.isPresent()) {
        companyId = overrideCompanyId.get();
      } else {
        log.error("OTT: No Company ID found for project. {}", projectId);
        throw new ResponseStatusException(
            HttpStatus.NOT_FOUND, "No Company ID found for that project", new Exception());
      }
    }

    params.put("objectTypeId", objectTypeId);
    params.put("companyId", companyId);

    return sqlCache.query("objectTypeTab.getProjectTabs", params, ObjectTypeTab.class);
  }

  public ObjectTypeTab getTab(Long tabId) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", tabId);

    return sqlCache.get("objectTypeTab.getTab", params, ObjectTypeTab.class).orElse(null);
  }

  public ObjectTypeTab saveTab(ObjectTypeTab tab, Long objectTypeId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("tabName", tab.getTabName());
    params.put("userId", currentUser.trueUserId());
    params.put("companyId", currentUser.getCompanyId());
    params.put("objectTypeId", objectTypeId);

    Long id;
    if (null != tab.getId()) {
      id = tab.getId();
      params.put("id", id);
      sqlCache.update("objectTypeTab.updateTab", params);
    } else {
      id = sqlCache.updateReturningId("objectTypeTab.insertTab", params, "id").longValue();
    }

    return getTab(id);
  }

  public void updateTabOrder(List<ObjectTypeTab> tabs) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    for (ObjectTypeTab tab : tabs) {
      params.put("displayOrder", tab.getDisplayOrder());
      params.put("userId", currentUser.trueUserId());
      params.put("id", tab.getId());
      // save each display_order
      sqlCache.update("objectTypeTab.updateTabDisplayOrder", params);
    }
  }

  public void deleteTab(Long tabId) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.trueUserId());
    params.put("id", tabId);
    sqlCache.update("objectTypeTab.deleteTab", params);
  }
}
