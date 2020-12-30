package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjRequirement;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.utils.SqlCache;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class AhjRequirementService {

    private final SqlCache sqlCache;
    private final SecurityService securityService;
    private final NamedParameterJdbcTemplate jdbc;

    public List<AhjRequirement> getRequirementHistory(Long ahjId, Long originalRequirementId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("ahjId", ahjId);
        params.put("originalRequirementId", originalRequirementId);

        return sqlCache.query("ahj.requirement.history", params, AhjRequirement.class);
    }

    public AhjRequirement addRequirement(Long ahjId, AhjRequirement ahjRequirement) {
      User user = securityService.getCurrentUser();

      HashMap<String, Object> params = new HashMap<>();
      params.put("ahjId", ahjId);
      params.put("requirementTypeId", ahjRequirement.getRequirementTypeId());
      params.put("statusId", 1);
      params.put("modifiedById", user.getId());
      params.put("position", ahjRequirement.getPosition());
      params.put("createdById", user.getId());
      params.put("description", ahjRequirement.getDescription());

      Integer id = sqlCache.get("ahj.requirement.add", params, new SingleColumnRowMapper<>(Integer.class)).get();

      params.put("originalRequirementId", id);
      return sqlCache.get("ahj.requirement.active.detail", params, AhjRequirement.class).get();
    }

    public AhjRequirement updateRequirement(Long ahjId, Long requirementId, AhjRequirement ahjRequirement) {
        User user = securityService.getCurrentUser();

        String sqlQuery = "SELECT * FROM brs.ahj_update_requirement(:utilityId::integer, :ahjId::integer, :requirementId::integer, :description::text, :position::integer, :complete::boolean, :statusId::integer, :userId::integer, :archived::boolean)";

        MapSqlParameterSource parameters = new MapSqlParameterSource();
        parameters.addValue("utilityId", null);
        parameters.addValue("ahjId", ahjId);
        parameters.addValue("requirementId", requirementId);
        parameters.addValue("description", ahjRequirement.getDescription());
        parameters.addValue("position", ahjRequirement.getPosition());
        parameters.addValue("complete", ahjRequirement.getComplete());
        parameters.addValue("statusId", ahjRequirement.getStatusId());
        parameters.addValue("userId", user.getId());
        parameters.addValue("archived", ahjRequirement.getArchived());

        jdbc.queryForObject(sqlQuery, parameters, String.class);

        HashMap<String, Object> params = new HashMap<>();
        params.put("originalRequirementId", ahjRequirement.getOriginalRequirementId());
        params.put("ahjId", ahjId);

        return sqlCache.get("ahj.requirement.active.detail", params, AhjRequirement.class).get();
    }

    public void archiveRequirement(Long originalRequirementId) {
      User user = securityService.getCurrentUser();

      HashMap<String, Object> params = new HashMap<>();
      params.put("originalRequirementId", originalRequirementId);
      params.put("modifiedById", user.getId());

      sqlCache.update("ahj.requirement.archive", params);
    }
}
