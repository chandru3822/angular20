package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.flow.model.User;
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
  private BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjInspectionDetail> getAhjInspectionDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjInspectionDetail> inspection = sqlCache.get("ahj.inspection.detailByAhj", params, new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
    if (inspection.isPresent()) {
      return inspection;
    } else {
      User currentUser = securityService.getCurrentUser();
      params.put("currentUser", currentUser.trueUserId());

      // add a blank inspection and return that
      Integer id = sqlCache.get("ahj.inspection.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
      if (id != null) {
        Optional<AhjInspectionDetail> inspection2 = sqlCache.get("ahj.inspection.detailByAhj", params, new AhjInspectionDetailMapper<>(AhjInspectionDetail.class, om));
        return inspection2;
      }
    }
    return null;
  }

  public Optional<AhjInspection> saveAhjInspection(Long ahjId, Long inspectionId, AhjInspection inspection, Boolean returnValue) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
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
    params.put("currentUser", currentUser.trueUserId());
    params.put("ladderRequired", inspection.getLadderRequired());
    params.put("timeWindow", inspection.getTimeWindow());
    params.put("timeWindowCallTime", inspection.getTimeWindowCallTime());
    params.put("timeWindowPhone", inspection.getTimeWindowPhone());
    params.put("requiredInspectionTypes", inspection.getRequiredInspectionTypes());

    // NOTES
    params.put("schedulingNote", inspection.getSchedulingNote());
    params.put("technicianInstructionNote", inspection.getTechnicianInstructionNote());
    params.put("schedulingWithCustomerNote", inspection.getSchedulingWithCustomerNote());
    params.put("obtainingResultsNote", inspection.getObtainingResultsNote());
    params.put("reinspectionNote", inspection.getReinspectionNote());
    params.put("documentationNote", inspection.getDocumentationNote());
    params.put("mpuInspectionNote", inspection.getMpuInspectionNote());

    if (inspection.getUpdateAllInState() != null && inspection.getUpdateAllInState()) {
      params.put("ahjIds", inspection.getAhjIds());
      sqlCache.update("ahj.inspection.updateAllAhjInspectionsInState", params);
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(ObjectType.AHJ_INSPECTION.textValue(), inspection.getCustomFieldGroups(), inspection.getInspectionIds());
    } else {
      params.put("ahjId", ahjId);

      if (inspectionId == null) {
        inspectionId = sqlCache.updateReturningId("ahj.inspection.create", params, "id").longValue();
      } else {
        params.put("id", inspectionId);
        sqlCache.update("ahj.inspection.update", params);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(ObjectType.AHJ_INSPECTION.textValue(), inspection.getCustomFieldGroups(), inspectionId);
      }
    }

    HashMap<String, Object> keyParam = new HashMap<>();
    keyParam.put("id", inspectionId);
    return returnValue ? sqlCache.get("ahj.inspection.findById", keyParam, AhjInspection.class) : Optional.empty();
  }

  public List<AhjInspection> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.inspection.searchAhjsByState", params, AhjInspection.class);
  }

  // CHECKLISTS
  public void createInspectionChecklistItem(Long inspectionId, Long itemId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjInspectionId", inspectionId);
    params.put("ahjChecklistId", itemId);

    sqlCache.update("ahj.inspection.checklist.create", params);
  }

  // CONTACTS
  public void saveInspectionContact(Long inspectionId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();

    params.put("ahjInspectionId", inspectionId);
    params.put("ahjContactId", contactId);
    sqlCache.update("ahj.inspection.contact.create", params);
  }

  // LINKS
  @SuppressWarnings("DuplicatedCode")
  public Optional<AhjLink> saveInspectionLink(Long ahjId, Long inspectionId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjInspectionId", inspectionId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.inspection.link.create", params, "id").longValue();

    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.inspection.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.inspection.link.findById", idParam, AhjLink.class);
  }

  public void deleteInspectionLink(Long ahjId, Long inspectionId, Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.inspection.link.delete", params);
  }

  // NOTE TEMPLATES
  public Optional<AhjNoteTemplate> saveNoteTemplate(Long ahjId, Long inspectionId, Long noteTemplateId, AhjNoteTemplate noteTemplate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("inspectionId", inspectionId);
    params.put("title", noteTemplate.getTitle());
    params.put("note", noteTemplate.getNote());

    if (noteTemplateId == null) {
      noteTemplateId = sqlCache.updateReturningId("ahj.inspection.note.template.create", params, "id").longValue();

      params.put("inspectionId", inspectionId);
      params.put("noteTemplateId", noteTemplateId);
      sqlCache.update("ahj.inspection.note.template.join", params);
    } else {
      params.put("id", noteTemplateId);
      sqlCache.update("ahj.inspection.note.template.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", noteTemplateId);
    return sqlCache.get("ahj.inspection.note.template.findById", idParam, AhjNoteTemplate.class);
  }

  public void deleteNoteTemplate(Long ahjId, Long inspectionId, Long noteTemplateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", noteTemplateId);

    sqlCache.update("ahj.inspection.note.template.delete", params);
  }

  public static class AhjInspectionDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjInspectionDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjNoteTemplate>> noteTemplateTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "schedulingLinks",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "fotLinks",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "resultsLinks",
        new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "failureChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "reinspectionsChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingWithAhjChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingWithBrsTechnicianChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "installationRequirements",
        new JsonCollectionDeserializer(requirementTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "noteTemplates",
        new JsonCollectionDeserializer(noteTemplateTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "utilityServiceDeptContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "feeContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "servicingFots",
        new JsonCollectionDeserializer(userRef, objectMapper));
    }
  }
}
