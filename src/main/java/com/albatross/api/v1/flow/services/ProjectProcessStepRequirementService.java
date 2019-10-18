package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.model.RequirementParamDynamicValue;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ProjectProcessStepRequirementService {

  private final SqlCache sqlCache;

  private final ObjectMapper om;

  public List<ProjectProcessStepRequirement> getByIds(List<Long> ids) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ids", ids);

    return sqlCache.query("processStepRequirement.getRequirementsWithValuesByIds", params, new ProjectProcessStepRequirementMapper<>(ProjectProcessStepRequirement.class, om));
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
    }
  }
}
