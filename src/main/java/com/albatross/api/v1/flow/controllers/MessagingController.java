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

  @PostMapping(value = "/addTeam/thread/{smsThreadId}")
  public void addThreadTeam(
    @PathVariable Long smsThreadId,
    @RequestBody SmsTeam request,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsTeam(
      smsThreadId, null, null, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PostMapping(value = "/addTeam/project/{projectId}")
  public void addThreadTeamByProject(
      @PathVariable Long projectId,
      @RequestBody SmsTeam request,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsTeam(
       null, projectId, null, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PostMapping(value = "/addTeam/user/{userId}")
  public void addThreadTeamByUser(
    @PathVariable Long userId,
    @RequestBody SmsTeam request,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsTeam(
      null, null, userId, request.getId(), request.getUsers(), false, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/thread/{smsThreadId}/{smsTeamId}")
  public void removeThreadTeam(
    @PathVariable Long smsThreadId,
    @PathVariable Long smsTeamId,
    @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeThreadTeam(smsThreadId, null, null, smsTeamId, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/project/{projectId}/{smsTeamId}")
  public void removeProjectTeam(
      @PathVariable Long projectId,
      @PathVariable Long smsTeamId,
      @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeThreadTeam(null, projectId, null, smsTeamId, details.getTrueUserId());
  }

  @PutMapping(value = "/removeTeam/user/{userId}/{smsTeamId}")
  public void removeUserTeam(
    @PathVariable Long userId,
    @PathVariable Long smsTeamId,
    @AuthenticationPrincipal UserAccountDetails details) {

    messagingService.removeThreadTeam(null, null, userId, smsTeamId, details.getTrueUserId());
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
        filterData.getNotifThreadIds(),
        filterData.getShowExternal(),
        filterData.getShowInternal(),
        filterData.getShowInbox(),
        filterData.getSortAscending(),
        pageable);
  }

  @GetMapping(value = "/thread/{smsThreadId}")
  public SmsConversation getThread(
      @PathVariable Long smsThreadId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getThread(smsThreadId, null, null, details.getTrueUserId());
  }

  @GetMapping(value = "/thread/project/{projectId}")
  public SmsConversation getThreadByProject(
    @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getThread(null, projectId, null, details.getTrueUserId());
  }

  @GetMapping(value = "/thread/user/{userId}")
  public SmsConversation getThreadByUser(
    @PathVariable Long userId, @AuthenticationPrincipal UserAccountDetails details) {
    return messagingService.getThread(null, null, userId, details.getTrueUserId());
  }

  @GetMapping(value = "/history/thread/{smsThreadId}")
  public String getThreadHistory(@PathVariable Long smsThreadId) {
    return messagingService.getThreadHistory(smsThreadId, null, null);
  }

  @GetMapping(value = "/history/project/{projectId}")
  public String getProjectHistory(@PathVariable Long projectId) {
    return messagingService.getThreadHistory(null, projectId, null);
  }

  @GetMapping(value = "/history/user/{userId}")
  public String getHistory(@PathVariable Long userId) {
    return messagingService.getThreadHistory(null, null, userId);
  }

  @PutMapping(value = "/removeOwner/thread/{smsThreadId}")
  public void removeThreadOwner(
    @PathVariable Long smsThreadId,
    @RequestBody SmsThreadOwner owner,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeThreadOwner(smsThreadId, null, null, owner, details.getTrueUserId());
  }

  @PutMapping(value = "/removeOwner/project/{projectId}")
  public void removeProjectOwner(
      @PathVariable Long projectId,
      @RequestBody SmsThreadOwner owner,
      @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeThreadOwner(null, projectId, null, owner, details.getTrueUserId());
  }

  @PutMapping(value = "/removeOwner/user/{userId}")
  public void removeUserOwner(
    @PathVariable Long userId,
    @RequestBody SmsThreadOwner owner,
    @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.removeThreadOwner(null, null, userId, owner, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/thread/{smsThreadId}")
  public void createThreadNotification(
    @PathVariable Long smsThreadId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsThreadOwnershipNotification(smsThreadId, null, null, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/project/{projectId}")
  public void createProjectNotification(
      @PathVariable Long projectId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsThreadOwnershipNotification(null, projectId, null, details.getTrueUserId());
  }

  @PostMapping(value = "/createNotification/user/{userId}")
  public void createUserNotification(
    @PathVariable Long userId, @AuthenticationPrincipal UserAccountDetails details) {
    messagingService.addSmsThreadOwnershipNotification(null, null, userId, details.getTrueUserId());
  }

  @Data
  public static class FilterData {
    private Set<Long> ownerUserIds;
    private Set<Long> smsTeamIds;
    private Set<Long> notifThreadIds;
    private Boolean showExternal;
    private Boolean showInternal;
    private Boolean showInbox;
    private Boolean sortAscending;
  }

  @Data
  public static class MessageRecipient {
    private String name;
    private Long userId;
  }
}
