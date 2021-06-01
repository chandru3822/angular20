package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.ProcessStepEvent;
import com.albatross.api.v1.flow.model.ProjectProcessStepEvent;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Optional;


//@TODO: Had to make private functions public in this class to be able to unit test due to this issue. https://github.com/powermock/powermock/issues/929
// I don't like it and would rather have them be private. Change back if/when possible

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectProcessStepEventService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final CustomFieldValueService customFieldValueService;

  public Optional<ProjectProcessStepEvent> insertPpsEvent(Long projectProcessStepId, ProcessStepEvent processStepEvent) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("processStepEventId", processStepEvent.getId());
    params.put("companyEventStatusTypeId", processStepEvent.getId());
    params.put("createdById", user.getId());

    Long id = sqlCache.updateReturningId("projectProcessStepEvent.insertEvent", params, "id").longValue();
    return getPpsEvent(id);
  }

  public Optional<ProjectProcessStepEvent> getPpsEvent(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    Optional<ProjectProcessStepEvent> result = sqlCache.get("projectProcessStepEvent.get", params, ProjectProcessStepEvent.class);
    if(result.isPresent()) {
      result.get().setCustomFieldGroups(customFieldValueService.getCustomFieldGroupsAndValues(ObjectType.EVENT.toString(), id));
    }
    return result;
  }

}
