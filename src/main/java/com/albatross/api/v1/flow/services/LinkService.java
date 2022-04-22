package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.Link;
import com.albatross.api.v1.flow.model.processStep.ProcessStepLink;
import com.albatross.api.v1.flow.model.User;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class LinkService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<Link> getLinksForCompany() {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    return sqlCache.query("link.getLinksForCompany", params, Link.class);
  }

  public void updateOrderInProcessStep(List<ProcessStepLink> links) {
    for (ProcessStepLink l : links) {
      updateTypeOrderInProcessStep(l);
    }
  }

  public void updateTypeOrderInProcessStep(ProcessStepLink link) {
    User currentUser = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", link.getId());
    params.put("modifiedById", currentUser.trueUserId());
    params.put("displayOrder", link.getDisplayOrder());

    sqlCache.update("link.updateOrderInProcessStep", params);
  }

  public List<ProcessStepLink> getLinksForProcessStep(Long processStepId) {
    Map<String, Object> params = new HashMap<>();
    params.put("processStepId", processStepId);

    return sqlCache.query("link.getLinksForProcessStep", params, ProcessStepLink.class);
  }

  public List<Link> getAvailableLinksForProcessStep(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    return sqlCache.query("link.getAvailableLinksForProcessStep", params, Link.class);
  }

  public Optional<Link> getLink(Long companyId, Long linkId) {
    return sqlCache.get(
        "link.getLink", ImmutableMap.of("companyId", companyId, "linkId", linkId), Link.class);
  }

  public void deleteProcessStepLink(Long id) {
    User currentUser = securityService.getCurrentUser();

    sqlCache.update(
        "link.deleteProcessStepLink",
        ImmutableMap.of("id", id, "modifiedById", currentUser.trueUserId()));
  }

  public Optional<ProcessStepLink> getProcessStepLink(Long id) {
    return sqlCache.get(
        "link.getProcessStepLink", ImmutableMap.of("id", id), ProcessStepLink.class);
  }

  public Optional<ProcessStepLink> insertProcessStepLink(ProcessStepLink link) {
    User currentUser = securityService.getCurrentUser();

    Long id =
        sqlCache
            .updateReturningId(
                "link.insertProcessStepLink",
                ImmutableMap.of(
                    "createdById",
                    currentUser.trueUserId(),
                    "linkId",
                    link.getLinkId(),
                    "processStepId",
                    link.getProcessStepId()),
                "id")
            .longValue();

    return getProcessStepLink(id);
  }

  public void deleteLink(Long linkId) {
    sqlCache.update("link.deleteLink", ImmutableMap.of("id", linkId));
  }

  public void updateLink(Link link) {
    sqlCache.update(
        "link.updateLink",
        ImmutableMap.of(
            "companyId",
            link.getCompanyId(),
            "id",
            link.getId(),
            "link",
            link.getLink(),
            "url",
            link.getUrl()));
  }

  public Optional<Link> insertLink(Link link) {
    Long id =
        sqlCache
            .updateReturningId(
                "link.insertLink",
                ImmutableMap.of(
                    "link", link.getLink(), "companyId", link.getCompanyId(), "url", link.getUrl()),
                "id")
            .longValue();

    return getLink(link.getCompanyId(), id);
  }

  public List<Link> getAvailableLinksForAction(Long id) {
    User user = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("id", id);

    return sqlCache.query("link.getAvailableLinksForAction", params, Link.class);
  }
}
