package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Inverter;
import com.albatross.api.v1.flow.model.propTool.InverterState;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;


/**
 * Created by randanunn on 2019-05-20.
 * !Describe Purpose!
 */
@Slf4j
@Service
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class InverterService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Inverter> getInvertersForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Inverter> results = sqlCache.query("propToolInverter.getAllForCompany", params, new InverterService.InverterMapper<>(Inverter.class, om));
    return results;
  }

  public Optional<Inverter> getInverter(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Inverter> results = sqlCache.get("propToolInverter.getOne", params, new InverterService.InverterMapper<>(Inverter.class, om));
    return results;
  }

  public Optional<Inverter> saveInverter(Inverter inverter) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("inverterName", inverter.getInverterName());
    params.put("brand", inverter.getBrand());
    params.put("inverterType", inverter.getInverterType());
    params.put("active", inverter.getActive());
    Long id;

    if(null != inverter.getId()) {
      id = inverter.getId();
      params.put("modifiedById", user.trueUserId());
      params.put("id", id);
      sqlCache.update("propToolInverter.update", params);
    } else {
      params.put("createdById", user.trueUserId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolInverter.insert", params, "id").longValue();
    }

    for (InverterState inverterState: inverter.getInverterStates()) {
      params.put("inverterId", id);
      params.put("companyStateId", inverterState.getCompanyStateId());
      params.put("adderAmount", inverterState.getAdderAmount());
      params.put("archived", inverterState.isArchived());

      if(null != inverterState.getId()) {
        params.put("inverterStateId", inverterState.getId());
        sqlCache.update("propToolInverter.updateState", params);
      } else {
        if (!inverterState.isArchived()) {
          if (!params.containsKey("createdById")) {
            params.put("createdById", user.trueUserId());
          }

          sqlCache.update("propToolInverter.insertStates", params);
        }
      }
    }

    return getInverter(id);
  }

  public void deleteInverter(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.trueUserId());

    sqlCache.update("propToolInverter.delete", params);
  }

  public static class InverterMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public InverterMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<InverterState>> inverterStateRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "inverterStates",
        new JsonCollectionDeserializer(inverterStateRef, objectMapper));
    }
  }

}
