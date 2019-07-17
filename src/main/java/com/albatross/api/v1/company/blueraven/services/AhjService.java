package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.*;

import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-12.
 */
@Service
public class AhjService {
  @Autowired
  private SqlCache sqlCache;
  private ObjectMapper om;

  public List<AhjSummary> getAhjList() {
    return sqlCache.query("ahj.list", new HashMap<>(), AhjSummary.class);
  }

  @Transactional
  public Optional<AhjSummary> createAhj(AhjSummary ahjSummary, Long userId) {
    return saveAhj(ahjSummary.getId(), userId, ahjSummary);
  }

  @Transactional
  public Optional<AhjSummary> saveAhj(Long id, Long userId, AhjSummary ahjSummary) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", userId);
    params.put("name", ahjSummary.getName());
    params.put("metroAreaId", ahjSummary.getMetroAreaId());

    if (id == null) {
      Optional<AhjSummary> ahj = sqlCache.get("ahj.checkForDuplicate", params, AhjSummary.class);

      if (!ahj.isPresent()) {
        id = sqlCache.updateReturningId("ahj.create", params, "id").longValue();

        //create an empty permit and inspection tied to the ahj - only required for new
//        createAhjPermit(id, userId, new AhjPermit());
//        createAhjInspection(id, userId, new AhjInspection());
      } else {
        return Optional.empty();
      }
    } else {
      params.put("id", id);
      sqlCache.update("ahj.update", params);
    }

    return getAhjById(id);
  }

  @Transactional
  public void deleteAhj(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    sqlCache.update("ahj.delete", params);
  }

  public Optional<AhjSummary> getAhjById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get("ahj.findById", params, AhjSummary.class);
  }
}