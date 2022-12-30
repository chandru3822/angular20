package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.model.function.CompanyFunctionParam;
import com.albatross.api.v1.flow.model.projectProcessStep.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.queries.ProcessStepRequirementQuery;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ProjectProcessStepRequirementService {

  private final SqlCache sqlCache;
  private final SecurityService securityService;

  private final ObjectMapper om;

  public List<ProjectProcessStepRequirement> getByProjectProcessStepId(Long projectProcessStepId, List<Long> requirementIds) {
    return getByProjectProcessStepId(projectProcessStepId, requirementIds, false);
  }

  public List<ProjectProcessStepRequirement> getByProjectProcessStepId(Long projectProcessStepId, List<Long> requirementIds, Boolean getEventRequirements) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    params.put("requirementIds", "{" + requirementIds.stream().map(String::valueOf).collect(Collectors.joining(",")) + "}");

    List<ProjectProcessStepRequirement> requirements;
    if(getEventRequirements) {
       requirements = sqlCache.queryBySql(ProcessStepRequirementQuery.getEventActionRequirementsWithValuesByProjectProcessStepId, params, new ProjectProcessStepRequirementMapper<>(ProjectProcessStepRequirement.class, om));
    } else {
      requirements = sqlCache.queryBySql(ProcessStepRequirementQuery.getRequirementsWithValuesByProjectProcessStepId, params, new ProjectProcessStepRequirementMapper<>(ProjectProcessStepRequirement.class, om));
    }

    // todo: this is duplicated from custom field value service but didn't quite match up, probably could re-write to combine the two
    for (ProjectProcessStepRequirement req : requirements) {
      if(null != req.getCustomFieldSql()) {
        String sql = req.getCustomFieldSql();
        if(null != sql) {
          req.setHasListValues(true);
          User user = securityService.getCurrentUser();
          //i think we can get away with not passing project_id here because they can never set up a requirement for a specific value for a specific project they can only check null/not null etc
          HashMap<String, Object> params2 = new HashMap<>();
          params2.put("projectId", null);
          params2.put("userId", user.getId());
          List<ListOfValue> listOfValues = sqlCache.queryBySql(sql, params2, ListOfValue.class);
          req.setAvailableListOfValues(listOfValues);
        }
      }
    }

    return requirements;
  }

  public static class ProjectProcessStepRequirementMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    ProjectProcessStepRequirementMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {

      TypeReference<List<RequirementParamDynamicValue>> requirementParamDynamicValuesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "requirementParamDynamicValues", new JsonCollectionDeserializer(requirementParamDynamicValuesRef, objectMapper));

      TypeReference<DataTypeRequirement> dataTypeRequirementRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "dataTypeRequirement", new JsonCollectionDeserializer(dataTypeRequirementRef, objectMapper));

      TypeReference<ListOfValue> listOfValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "listOfValue", new JsonCollectionDeserializer(listOfValueRef, objectMapper));

      TypeReference<List<ListOfValue>> listOfValuesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValues", new JsonCollectionDeserializer(listOfValuesRef, objectMapper));

      TypeReference<List<Integer>> listOfValueIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "listOfValueIds", new JsonCollectionDeserializer(listOfValueIdsRef, objectMapper));

      TypeReference<List<Integer>> intArrayValueRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "intArrayValue", new JsonCollectionDeserializer(intArrayValueRef, objectMapper));

      TypeReference<List<CompanyFunctionParam>> companyFunctionParamsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "companyFunctionParams", new JsonCollectionDeserializer(companyFunctionParamsRef, objectMapper));

      TypeReference<List<Long>> systemListOptionIdsRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "systemListOptionIds", new JsonCollectionDeserializer(systemListOptionIdsRef, objectMapper));

      TypeReference<List<ListOfValue>> availableListOfValuesRef = new TypeReference<>() {};
      bw.registerCustomEditor(List.class, "availableListOfValues", new JsonCollectionDeserializer(availableListOfValuesRef, objectMapper));
    }
  }
}
