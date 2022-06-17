package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.MessageTemplate;
import com.albatross.api.v1.flow.model.ProjectMessageOwner;
import com.albatross.api.v1.flow.model.ProjectMessageProperties;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.services.MessageTemplateService;
import com.albatross.api.v1.flow.services.MessagingService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Set;

@RestController
@RequestMapping(value = "/api/v1/flow/messaging", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class MessagingController {

  private final MessagingService messagingService;
  private final MessageTemplateService messageTemplateService;

  @GetMapping(value = "/templates")
  public List<MessageTemplate> getTemplates() {
    return messageTemplateService.getTemplates();
  }

  @GetMapping(value = "/templates/{teamIds}")
  public Set<MessageTemplate> getTemplates(@PathVariable List<Long> teamIds) {
    return messageTemplateService.getTemplates(teamIds);
  }

  @PutMapping(value = "/template")
  public MessageTemplate saveTemplate(@RequestBody MessageTemplate mt) {
    return messageTemplateService.saveTemplate(mt);
  }

  @PutMapping(value = "/template/delete/{templateId}")
  public void deleteTemplate(@PathVariable Long templateId) {
    messageTemplateService.deleteTemplate(templateId);
  }

  @PostMapping(value = "/addTeam/{projectId}")
  public void addTeam(
      @PathVariable Long projectId,
      @RequestBody SmsTeam request,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addTeam(
        projectId, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/{projectId}/{smsTeamId}")
  public void removeTeam(
      @PathVariable Long projectId,
      @PathVariable Long smsTeamId,
      @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeTeam(projectId, smsTeamId, details.getTrueUserId());
  }

  @PostMapping(value = "/projects")
  public Page<ProjectMessageProperties> getProjects(
      @RequestParam(required = false, defaultValue = "") String query,
      @RequestBody FilterData filterData,
      Pageable pageable) {

    return messagingService.getProjects(
        query,
        filterData.getOwnerUserIds(),
        filterData.getSmsTeamIds(),
        filterData.getNotifProjectIds(),
        pageable);
  }

  @GetMapping(value = "/projects/{projectId}")
  public ProjectMessageProperties getProject(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getProject(projectId, details.getTrueUserId());
  }

  @GetMapping(value = "/history/{projectId}")
  public String getHistory(@PathVariable Long projectId) {
    return messagingService.getHistory(projectId);
  }

  @PutMapping(value = "/setLastSent/{projectId}")
  public void setLastSent(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.setLastSent(projectId, details.getTrueUserId());
  }

  @PutMapping(value = "/removeOwner/{projectId}")
  public void removeOwner(
      @PathVariable Long projectId,
      @RequestBody ProjectMessageOwner owner,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeOwner(projectId, owner, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/{projectId}")
  public void createNotification(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsOwnershipNotification(projectId, details.getTrueUserId());
  }

  @Data
  public static class FilterData {
    private List<Long> ownerUserIds;
    private List<Long> smsTeamIds;
    private List<Long> notifProjectIds;
  }
}
