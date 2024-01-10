package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.MessageTypeController;
import com.albatross.api.v1.company.blueraven.services.queries.MessageTypeQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;


/**
 * Created by Randa Nunn on 2019-10-22.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class MessageTypeService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  public List<MessageTypeController.MessageType> getMessageTypes() {
    return sqlCache.queryBySql(MessageTypeQuery.getMessageTypes, Collections.emptyMap(), MessageTypeController.MessageType.class);
  }

  public Optional<MessageTypeController.MessageType> getOneMessageType(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.getBySql(MessageTypeQuery.getOneMessageType, params, MessageTypeController.MessageType.class);
  }

  public Optional<MessageTypeController.MessageType> saveMessageType(MessageTypeController.MessageType mt) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("title", mt.getTitle());
    params.put("description", mt.getDescription());
    params.put("content", mt.getContent());
    params.put("includeManager", null != mt.getIncludeManager() ? mt.getIncludeManager() : false);
    params.put("userId", user.trueUserId());
    Long id;
    if (null == mt.getId()) {
      id = sqlCache.updateBySqlReturningId(MessageTypeQuery.insertMessageType, params, "id").longValue();
    } else {
      id = mt.getId();
      params.put("id", id);
      sqlCache.updateBySql(MessageTypeQuery.updateMessageType, params);
    }
    //update the db param description any time a message type changes so they know which ones they can use when adding the child fn
    updateDbParamDesc();
    return getOneMessageType(id);
  }

  public void updateDbParamDesc() {
    sqlCache.updateBySql(MessageTypeQuery.updateDbParamDesc, Collections.emptyMap());
  }

  public void deleteMessageType(Long id) {
    User user = securityService.getCurrentUser();

    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("userId", user.trueUserId());

    sqlCache.updateBySql(MessageTypeQuery.deleteMessageType, params);

    //update the db param description any time a message type gets deleted so they know which ones they can use when adding the child fn
    updateDbParamDesc();
  }

}
