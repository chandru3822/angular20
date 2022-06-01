package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.MessageTemplate;
import com.albatross.api.v1.flow.model.ProjectMessageOwner;
import com.albatross.api.v1.flow.model.ProjectMessageProperties;
import com.albatross.api.v1.flow.model.smsTeam.SmsTeam;
import com.albatross.api.v1.flow.services.MessageTemplateService;
import com.albatross.api.v1.flow.services.MessagingService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.sql.SQLException;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping(value = "/api/v1/flow/messaging")
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class MessagingController {

  private final MessagingService messagingService;
  private final MessageTemplateService messageTemplateService;

  @GetMapping(value = "/templates", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<MessageTemplate> getTemplates() {
    return messageTemplateService.getTemplates();
  }

  @GetMapping(value = "/templates/{teamIds}", produces = MediaType.APPLICATION_JSON_VALUE)
  public Set<MessageTemplate> getTemplates(@PathVariable List<Long> teamIds) {
    return messageTemplateService.getTemplates(teamIds);
  }

  @PutMapping(value = "/template", produces = MediaType.APPLICATION_JSON_VALUE)
  public MessageTemplate saveTemplate(@RequestBody MessageTemplate mt) {
    return messageTemplateService.saveTemplate(mt);
  }

  @PutMapping(value = "/template/delete/{templateId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void deleteTemplate(@PathVariable Long templateId) {
    messageTemplateService.deleteTemplate(templateId);
  }

  @PostMapping(value = "/addTeam/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void addTeam(@PathVariable Long projectId, @RequestBody SmsTeam request) {
    messagingService.addTeam(projectId, request.getId(), request.getUsers(), false);
  }

  @PutMapping(value = "/removeTeam/{projectId}/{smsTeamId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void removeTeam(@PathVariable Long projectId, @PathVariable Long smsTeamId) throws SQLException {
    messagingService.removeTeam(projectId, smsTeamId);
  }

  @GetMapping(value = "/projects", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProjectMessageProperties> getProjects() {
    return messagingService.getProjects();
  }

  @GetMapping(value = "/projects/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public ProjectMessageProperties getProject(@PathVariable Long projectId) {
    return messagingService.getProject(projectId);
  }

  @GetMapping(value = "/history/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public String getHistory(@PathVariable Long projectId) {
    return messagingService.getHistory(projectId);
  }

  @PutMapping(value = "/setLastSent/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void setLastSent(@PathVariable Long projectId) {
    messagingService.setLastSent(projectId);
  }

  @PutMapping(value = "/removeOwner/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void removeOwner(@PathVariable Long projectId, @RequestBody ProjectMessageOwner owner) {
    messagingService.removeOwner(projectId, owner);
  }

  @PostMapping(value = "/createNotification/{projectId}", produces = MediaType.APPLICATION_JSON_VALUE)
  public void createNotification(@PathVariable Long projectId) {
    messagingService.addSmsOwnershipNotification(projectId);
  }
}
