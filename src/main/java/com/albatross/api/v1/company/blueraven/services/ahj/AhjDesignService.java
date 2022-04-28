package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjContact;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjDesign;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjDesignDetail;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjRequirement;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AhjDesignService {
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjDesignDetail> getAhjDesignDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjDesignDetail> design =
        sqlCache.get(
            "ahj.design.detailByAhj",
            params,
            new AhjDesignDetailMapper<>(AhjDesignDetail.class, om));

    if (design.isPresent()) {
      return design;
    }

    User currentUser = securityService.getCurrentUser();
    params.put("currentUser", currentUser.trueUserId());

    // add a blank design and return that
    var created =
        sqlCache.get("ahj.design.createBlank", params, new SingleColumnRowMapper<>(Integer.class));

    if (created.isPresent()) {
      return sqlCache.get(
          "ahj.design.detailByAhj", params, new AhjDesignDetailMapper<>(AhjDesignDetail.class, om));
    }
    return Optional.empty();
  }

  public Optional<AhjDesignDetail> saveAhjDesign(
      Long ahjId, Long designId, AhjDesign design, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("codes", design.getCodes());
    params.put("note", design.getNote());
    params.put("currentUser", currentUser.trueUserId());

    params.put("referenceStandards", design.getReferenceStandards());
    params.put("groundSnowLoad", design.getGroundSnowLoad());
    params.put("windSpeed", design.getWindSpeed());
    params.put("roofSnowLoad", design.getRoofSnowLoad());

    if (design.getUpdateAllInState() != null && design.getUpdateAllInState()) {
      params.put("ahjIds", design.getAhjIds());
      sqlCache.update("ahj.design.updateAllAhjDesignsInState", params);
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(
          ObjectType.AHJ_DESIGN.textValue(), design.getCustomFieldGroups(), design.getDesignIds());
    } else {
      params.put("ahjId", ahjId);

      if (designId == null) {
        sqlCache.updateReturningId("ahj.design.create", params, "id").longValue();
      } else {
        params.put("id", designId);
        sqlCache.update("ahj.design.update", params);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
            ObjectType.AHJ_DESIGN.textValue(), design.getCustomFieldGroups(), designId);
      }
    }

    return returnValue ? getAhjDesignDetailByAhjId(ahjId) : Optional.empty();
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

  public static class AhjDesignDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjDesignDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          List.class, "contacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "designRequirements",
          new JsonCollectionDeserializer(requirementTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "electricalRequirements",
          new JsonCollectionDeserializer(requirementTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "structuralRequirements",
          new JsonCollectionDeserializer(requirementTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class,
          "utilityRequirements",
          new JsonCollectionDeserializer(requirementTypeRef, objectMapper));
    }
  }
}
