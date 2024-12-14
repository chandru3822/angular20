package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.controllers.CommunicationController;
import com.albatross.api.v1.flow.controllers.MessagingController;
import com.albatross.api.v1.flow.model.Contact;
import com.albatross.api.v1.flow.model.MessageTeam;
import com.albatross.api.v1.flow.model.TemplateInUse;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.MessageTemplateQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.lang.reflect.Field;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class MessageTemplateService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<Project> getAvailableProjects(String query) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("searchQuery", query);
    List<Project> results = sqlCache.queryBySql(MessageTemplateQuery.getAvailableProjects, params, Project.class);

    return results;
  }

  public List<MessagingController.MessageRecipient> getAvailableUsers() {
    HashMap<String, Object> params = new HashMap<>();
    List<MessagingController.MessageRecipient> results = sqlCache.queryBySql(MessageTemplateQuery.getAvailableUsers, params, MessagingController.MessageRecipient.class);

    return results;
  }

  public List<com.albatross.api.v1.flow.model.MessageTemplate> getTemplates() {
    HashMap<String, Object> params = new HashMap<>();
    List<com.albatross.api.v1.flow.model.MessageTemplate> results = sqlCache.queryBySql(MessageTemplateQuery.getAllTemplates, params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));

    return results;
  }

  public static <T> ArrayList<String> getClassFieldsAsListOfStrings(Class<T> clazz) {
      ArrayList<String> classFieldNames = new ArrayList<>();
      Field[] fields = clazz.getDeclaredFields();
      for(Field field: fields) {
          classFieldNames.add(field.getName());
      }
      return classFieldNames;
  }

    public Map<String, List<String>> getTemplateVariables() {
        ArrayList<String> contact = getClassFieldsAsListOfStrings(Contact.class);
        ArrayList<String> project = getClassFieldsAsListOfStrings(Project.class);
        ArrayList<String> user = getClassFieldsAsListOfStrings(User.class);
        ArrayList<String> projectDetails = getClassFieldsAsListOfStrings(CommunicationController.ProjectDetails.class);
        return Map.of(
                "contact",
                contact,
                "project",
                project,
                "user",
                user,
                "projectDetails",
                projectDetails);
    }

  public List<com.albatross.api.v1.flow.model.MessageTemplate> getTemplatesWithTeamInfo() {
    HashMap<String, Object> params = new HashMap<>();
    List<com.albatross.api.v1.flow.model.MessageTemplate> results = sqlCache.queryBySql(MessageTemplateQuery.getAllTemplatesWithTeamInfo, params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));

    return results;
  }

  public com.albatross.api.v1.flow.model.MessageTemplate getTemplate(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<com.albatross.api.v1.flow.model.MessageTemplate> result = sqlCache.getBySql(MessageTemplateQuery.getTemplate, params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));
    return result.orElse(null);
  }

  public Set<com.albatross.api.v1.flow.model.MessageTemplate> getTemplates(List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    Set<com.albatross.api.v1.flow.model.MessageTemplate> templates = new HashSet<>();
    for (Long teamId: teamIds) {
      params.put("teamId", teamId);
      List<com.albatross.api.v1.flow.model.MessageTemplate> results = sqlCache.queryBySql(MessageTemplateQuery.getTemplates, params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));
      templates.addAll(results);
    }

    return templates;
  }

  public com.albatross.api.v1.flow.model.MessageTemplate saveTemplate(com.albatross.api.v1.flow.model.MessageTemplate mt) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("title", mt.getTitle());
    params.put("message", mt.getMessage());
    params.put("teamIds", mt.getTeamIds());

    Long id;
    if(mt.getId() != null) {
      id = mt.getId();
      params.put("id", id);
      params.put("modifiedById", user.trueUserId());
      sqlCache.updateBySql(MessageTemplateQuery.updateTemplate, params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateBySqlReturningId(MessageTemplateQuery.insertTemplate, params, "id").longValue();
    }

    return getTemplate(id);
  }

  public List<TemplateInUse> getTemplateInUse(Long templateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("templateId", templateId);
    List<TemplateInUse> results = sqlCache.queryBySql(MessageTemplateQuery.getTemplateInUse, params, TemplateInUse.class);

    return results;
  }

  public ResponseEntity<List<TemplateInUse>> deleteTemplate(Long templateId) {
    List<TemplateInUse> templatesInUse = getTemplateInUse(templateId);

    if(!templatesInUse.isEmpty()) {
      return ResponseEntity.badRequest().body(templatesInUse);
    } else {
      User user = securityService.getCurrentUser();
      HashMap<String, Object> params = new HashMap<>();

      params.put("id", templateId);
      params.put("modifiedById", user.trueUserId());
      sqlCache.updateBySql(MessageTemplateQuery.deleteTemplate, params);
      return ResponseEntity.ok().build();
    }
  }

  public static class MessageTemplateMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public MessageTemplateMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Long>> teamIdsTypeRef = new TypeReference<List<Long>>() {};
      bw.registerCustomEditor(List.class, "teamIds",
        new JsonCollectionDeserializer(teamIdsTypeRef, objectMapper));

      TypeReference<List<MessageTeam>> teamsTypeRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "teams",
        new JsonCollectionDeserializer(teamsTypeRef, objectMapper));
    }
  }

}
