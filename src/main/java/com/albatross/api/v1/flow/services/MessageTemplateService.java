package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class MessageTemplateService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final ObjectMapper om;

  public List<com.albatross.api.v1.flow.model.MessageTemplate> getTemplates() {
    HashMap<String, Object> params = new HashMap<>();
    List<com.albatross.api.v1.flow.model.MessageTemplate> results = sqlCache.query("messageTemplate.getAllTemplates", params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));

    return results;
  }

  public com.albatross.api.v1.flow.model.MessageTemplate getTemplate(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<com.albatross.api.v1.flow.model.MessageTemplate> result = sqlCache.get("messageTemplate.getTemplate", params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));
    return result.orElse(null);
  }

  public Set<com.albatross.api.v1.flow.model.MessageTemplate> getTemplates(List<Long> teamIds) {
    HashMap<String, Object> params = new HashMap<>();
    Set<com.albatross.api.v1.flow.model.MessageTemplate> templates = new HashSet<>();
    for (Long teamId: teamIds) {
      params.put("teamId", teamId);
      List<com.albatross.api.v1.flow.model.MessageTemplate> results = sqlCache.query("messageTemplate.getTemplates", params, new MessageTemplateService.MessageTemplateMapper<>(com.albatross.api.v1.flow.model.MessageTemplate.class, om));
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
      sqlCache.update("messageTemplate.updateTemplate", params);
    } else {
      params.put("createdById", user.trueUserId());
      id = sqlCache.updateReturningId("messageTemplate.insertTemplate", params, "id").longValue();
    }

    return getTemplate(id);
  }

  public void deleteTemplate(Long templateId) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();

    params.put("id", templateId);
    params.put("modifiedById", user.trueUserId());
    sqlCache.update("messageTemplate.deleteTemplate", params);
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
    }
  }

}
