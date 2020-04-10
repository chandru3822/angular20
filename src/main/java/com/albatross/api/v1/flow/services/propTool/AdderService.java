package com.albatross.api.v1.flow.services.propTool;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.propTool.Adder;
import com.albatross.api.v1.flow.model.propTool.AdderState;
import com.albatross.api.v1.flow.model.propTool.AdderType;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collections;
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
public class AdderService {

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  @Autowired
  ObjectMapper om;

  public List<Adder> getAddersForCompany() {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    List<Adder> results = sqlCache.query("propToolAdder.getAllForCompany", params, new AdderMapper<>(Adder.class, om));
    return results;
  }

  public List<AdderType> getAdderTypes() {
    List<AdderType> results = sqlCache.query("propToolAdder.getAdderTypes", Collections.emptyMap(), AdderType.class);
    return results;
  }

  public Optional<Adder> getAdder(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    Optional<Adder> results = sqlCache.get("propToolAdder.getOne", params, new AdderMapper<>(Adder.class, om));
    return results;
  }

  public Optional<Adder> saveAdder(Adder adder) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("adderName", adder.getAdderName());
    params.put("adderTypeId", adder.getAdderTypeId());
    params.put("active", adder.getActive());
    Long id;

    if(null != adder.getId()) {
      id = adder.getId();
      params.put("modifiedById", user.getId());
      params.put("id", id);
      sqlCache.update("propToolAdder.update", params);
    } else {
      params.put("createdById", user.getId());
      params.put("companyId", user.getCompanyId());
      id = sqlCache.updateReturningId("propToolAdder.insert", params, "id").longValue();
    }

    for (AdderState adderState: adder.getAdderStates()) {
      params.put("adderId", id);
      params.put("companyStateId", adderState.getCompanyStateId());
      params.put("adderAmount", adderState.getAdderAmount());

      if(null != adderState.getId()) {
        params.put("adderStateId", adderState.getId());
        sqlCache.update("propToolAdder.updateAdderState", params);
      } else {
        if (!params.containsKey("createdById")) {
          params.put("createdById", user.getId());
        }

        sqlCache.update("propToolAdder.insertAdderState", params);
      }
    }

    return getAdder(id);
  }

  public void deleteAdder(Long id) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);
    params.put("modifiedById", user.getId());

    sqlCache.update("propToolAdder.delete", params);
  }

  public static class AdderMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AdderMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AdderState>> adderStateRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(List.class, "adderStates",
          new JsonCollectionDeserializer(adderStateRef, objectMapper));
    }
  }

}
