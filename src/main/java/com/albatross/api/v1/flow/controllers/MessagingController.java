package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.model.smsTeam.SmsConversation;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.services.MessageTemplateService;
import com.albatross.api.v1.flow.services.MessagingService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
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

  @GetMapping(value = "/availableProjects")
  public List<Project> getAvailableProjects(@RequestParam String query) {
    return messageTemplateService.getAvailableProjects(query);
  }

  @GetMapping(value = "/availableUsers")
  public List<MessageRecipient> getAvailableUsers() {
    return messageTemplateService.getAvailableUsers();
  }

  @GetMapping(value = "/templatesWithTeams")
  public List<MessageTemplate> getTemplatesWithTeamInfo() {
    return messageTemplateService.getTemplatesWithTeamInfo();
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
  public ResponseEntity<List<TemplateInUse>> deleteTemplate(@PathVariable Long templateId) {
    return messageTemplateService.deleteTemplate(templateId);
  }

  @PostMapping(value = "/addTeam/project/{projectId}")
  public void addProjectTeam(
      @PathVariable Long projectId,
      @RequestBody SmsTeam request,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addTeamForProject(
        projectId, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PostMapping(value = "/addTeam/user/{userId}")
  public void addUserTeam(
    @PathVariable Long userId,
    @RequestBody SmsTeam request,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addTeamForUser(
      userId, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/project/{projectId}/{smsTeamId}")
  public void removeProjectTeam(
      @PathVariable Long projectId,
      @PathVariable Long smsTeamId,
      @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeProjectTeam(projectId, smsTeamId, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/user/{userId}/{smsTeamId}")
  public void removeUserTeam(
    @PathVariable Long userId,
    @PathVariable Long smsTeamId,
    @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeUserTeam(userId, smsTeamId, details.getTrueUserId());
  }

  @PostMapping(value = "/conversations")
  public Page<SmsConversation> getConversations(
      @RequestParam(required = false, defaultValue = "") String query,
      @RequestBody FilterData filterData,
      Pageable pageable) {

    return messagingService.getConversations(
        query,
        filterData.getOwnerUserIds(),
        filterData.getSmsTeamIds(),
        filterData.getNotifConversationIds(),
        filterData.getNotifUserIds(),
        filterData.getShowExternal(),
        filterData.getShowInternal(),
        filterData.getShowInbox(),
        pageable);
  }

  @GetMapping(value = "/project/{projectId}")
  public SmsConversation getProject(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getProject(projectId, details.getTrueUserId());
  }

  @GetMapping(value = "/user/{userId}")
  public SmsConversation getUser(
    @PathVariable Long userId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getUser(userId, details.getTrueUserId());
  }

  @GetMapping(value = "/history/project/{projectId}")
  public String getProjectHistory(@PathVariable Long projectId) {
    return messagingService.getProjectHistory(projectId);
  }

  @GetMapping(value = "/history/user/{userId}")
  public String getHistory(@PathVariable Long userId) {
    return messagingService.getUserHistory(userId);
  }

  @PutMapping(value = "/setLastSent/project/{projectId}")
  public void setLastSentForProject(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.setLastSentForProject(projectId, details.getTrueUserId());
  }

  @PutMapping(value = "/setLastSent/user/{userId}")
  public void setLastSentForUser(
    @PathVariable Long userId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.setLastSentForUser(userId, details.getTrueUserId());
  }

  @PutMapping(value = "/removeOwner/project/{projectId}")
  public void removeProjectOwner(
      @PathVariable Long projectId,
      @RequestBody ProjectMessageOwner owner,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeProjectOwner(projectId, owner, details.getTrueUserId());
  }

  @PutMapping(value = "/removeOwner/user/{userId}")
  public void removeUserOwner(
    @PathVariable Long userId,
    @RequestBody UserMessageOwner owner,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeUserOwner(userId, owner, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/project/{projectId}")
  public void createProjectNotification(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsProjectOwnershipNotification(projectId, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/user/{userId}")
  public void createUserNotification(
    @PathVariable Long userId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsUserOwnershipNotification(userId, details.getTrueUserId());
  }

  @Data
  public static class FilterData {
    private Set<Long> ownerUserIds;
    private Set<Long> smsTeamIds;
    private Set<Long> notifConversationIds;
    private Set<Long> notifUserIds;
    private Boolean showExternal;
    private Boolean showInternal;
    private Boolean showInbox;
  }

  @Data
  public static class MessageRecipient {
    private String name;
    private Long userId;
  }
}
