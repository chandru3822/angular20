package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.flow.model.User;

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
 * Created by Joseph Canto on 2019-07-17.
 */
@Service
public class AhjInspectionService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private ObjectMapper om;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;

  public Optional<AhjInspectionDetail> getAhjInspectionDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjInspectionDetail> inspection = sqlCache.get("ahj.inspection.detailByAhj", params, new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
    if (inspection.isPresent()) {
      return inspection;
    } else {
      User currentUser = securityService.getCurrentUser();
      params.put("currentUser", currentUser.getId());

      //add a blank inspection and return that
      Integer id = sqlCache.get("ahj.inspection.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
      if (id != null) {
        Optional<AhjInspectionDetail> inspection2 = sqlCache.get("ahj.inspection.detailByAhj", params, new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
        return inspection2;
      }
    }
    return null;
  }

  public Optional<AhjInspection> createAhjInspection(Long ahjId, AhjInspection inspection) {
    return saveAhjInspection(ahjId, null, inspection);
  }

  public Optional<AhjInspection> saveAhjInspection(Long ahjId, Long inspectionId, AhjInspection inspection) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("inspectionFee", inspection.getInspectionFee());
    params.put("reInspectionFee", inspection.getReInspectionFee());
    params.put("paymentMethod", inspection.getPaymentMethod());
    params.put("inspectionTimeWindow", inspection.getInspectionTimeWindow());
    params.put("brsInspectionRep", inspection.getBrsInspectionRep());
    params.put("portalUrl", inspection.getPortalUrl());
    params.put("portalUsername", inspection.getPortalUsername());
    params.put("portalPassword", inspection.getPortalPassword());
    params.put("obtainingResultsMethod", inspection.getObtainingResultsMethod());
    params.put("approvalDocumentMethod", inspection.getApprovalDocumentMethod());
    params.put("obtainingResultsPortalUrl", inspection.getObtainingResultsPortalUrl());
    params.put("obtainingResultsPortalUsername", inspection.getObtainingResultsPortalUsername());
    params.put("obtainingResultsPortalPassword", inspection.getObtainingResultsPortalPassword());
    params.put("businessLicense", inspection.getBusinessLicense());
    params.put("contractorLicense", inspection.getContractorLicense());
    params.put("homeownerRequiredOnSite", inspection.getHomeownerRequiredOnSite());
    params.put("currentUser", currentUser.getId());
    params.put("callForTimeWindow", inspection.getCallForTimeWindow());
    params.put("ladderRequired", inspection.getLadderRequired());
    params.put("timeWindow", inspection.getTimeWindow());
    params.put("timeWindowCallTime", inspection.getTimeWindowCallTime());
    params.put("timeWindowPhone", inspection.getTimeWindowPhone());
    params.put("fallProtectionRequired", inspection.getFallProtectionRequired());

    //notes
    params.put("schedulingNote", inspection.getSchedulingNote());
    params.put("technicianInstructionNote", inspection.getTechnicianInstructionNote());
    params.put("schedulingWithCustomerNote", inspection.getSchedulingWithCustomerNote());
    params.put("obtainingResultsNote", inspection.getObtainingResultsNote());
    params.put("reinspectionNote", inspection.getReinspectionNote());
    params.put("documentationNote", inspection.getDocumentationNote());
    params.put("mpuInspectionNote", inspection.getMpuInspectionNote());

    if (inspectionId == null) {
      inspectionId = sqlCache.updateReturningId("ahj.inspection.create", params, "id").longValue();
    } else {
      params.put("id", inspectionId);
      sqlCache.update("ahj.inspection.update", params);
    }

    blueravenCustomFieldGroupService.handleSavingCustomFieldValues(inspection.getCustomFieldGroups(), inspectionId);

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", inspectionId);

    return sqlCache.get("ahj.inspection.findById", keyParam, AhjInspection.class);
  }

  // CONTACTS
  public void saveInspectionContact(Long inspectionId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("ahjInspectionId", inspectionId);
    params.put("ahjContactId", contactId);
    sqlCache.update("ahj.inspection.contact.create", params);
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
  public static class AhjInspectionDetailMapper<T> extends AhjInspectionService.BaseAhjDetailMapper<T> {

    public AhjInspectionDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass, objectMapper);
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjBaseNoteTemplate>> baseNoteTemplateTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "schedulingLinks",
              new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "fotLinks",
              new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "resultsLinks",
              new JsonCollectionDeserializer(linkTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "failureChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "schedulingChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "reinspectionsChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "schedulingWithAhjChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "schedulingWithBrsTechnicianChecklist",
              new JsonCollectionDeserializer(itemRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "installationRequirements",
              new JsonCollectionDeserializer(requirementTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "baseNoteTemplates",
              new JsonCollectionDeserializer(baseNoteTemplateTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "utilityServiceDeptContacts",
              new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "schedulingContacts",
              new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsContacts",
              new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "feeContacts",
              new JsonCollectionDeserializer(contactTypeRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "servicingFots",
              new JsonCollectionDeserializer(userRef, super.objectMapper));
    }
  }
}
