package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.flow.model.User;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-20.
 */
@Service
public class AhjDesignService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private ObjectMapper om;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;

  public Optional<AhjDesignDetail> getAhjDesignDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjDesignDetail> design = sqlCache.get("ahj.design.detailByAhj", params, new AhjDesignDetailMapper<>(AhjDesignDetail.class, om));
    if (design.isPresent()) {
      return design;
    } else {
      User currentUser = securityService.getCurrentUser();
      params.put("currentUser", currentUser.getId());

      // add a blank design and return that
      Integer id = sqlCache.get("ahj.design.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
      if (id != null) {
        Optional<AhjDesignDetail> design2 = sqlCache.get("ahj.design.detailByAhj", params, new BaseAhjDetailMapper<>(AhjDesignDetail.class, om));
        return design2;
      }
    }
    return null;
  }

  @SuppressWarnings("Duplicates")
  public Optional<AhjDesign> saveAhjDesign(Long ahjId, Long designId, AhjDesign design) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("codes", design.getCodes());
    params.put("note", design.getNote());
    params.put("currentUser", currentUser.getId());

    params.put("referenceStandards", design.getReferenceStandards());
    params.put("groundSnowLoad", design.getGroundSnowLoad());
    params.put("windSpeed", design.getWindSpeed());
    params.put("roofSnowLoad", design.getRoofSnowLoad());

    if (design.getUpdateAllInState() != null && !design.getUpdateAllInState()) {
      params.put("ahjId", ahjId);

      if (designId == null) {
        designId = sqlCache.updateReturningId("ahj.design.create", params, "id").longValue();
      } else {
        params.put("id", designId);
        sqlCache.update("ahj.design.update", params);
      }
      blueravenCustomFieldGroupService.handleSavingCustomFieldValues(design.getCustomFieldGroups(), designId);
    } else {
      params.put("ahjIds", design.getAhjIds());
      sqlCache.update("ahj.design.updateAllAhjDesignsInState", params);
      blueravenCustomFieldGroupService.bulkHandleSavingCustomFieldValues(design.getCustomFieldGroups(), design.getDesignIds());
    }

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", designId);
    return sqlCache.get("ahj.design.findById", keyParam, AhjDesign.class);
  }

  public List<AhjDesign> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.design.searchAhjsByState", params, AhjDesign.class);
  }

  // CONTACTS
  public void saveDesignContact(Long designId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("ahjDesignId", designId);
    params.put("ahjContactId", contactId);
    sqlCache.update("ahj.design.contact.create", params);
  }

  @SuppressWarnings({"WeakerAccess"})
  public static class BaseAhjDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public BaseAhjDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }
  }

  @SuppressWarnings({"Duplicates", "unchecked", "WeakerAccess"})
  public static class AhjDesignDetailMapper<T> extends AhjDesignService.BaseAhjDetailMapper<T> {

    public AhjDesignDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass, objectMapper);
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "contacts",
              new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "designRequirements",
              new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "electricalRequirements",
              new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "structuralRequirements",
              new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "utilityRequirements",
              new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));
    }
  }
}
