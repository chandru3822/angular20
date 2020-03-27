package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.AhjPermitCycleTimeStats;
import com.albatross.api.v1.company.blueraven.models.ahj.cycle_times.PermitCycleTimeDbProcessor;
import com.albatross.api.v1.flow.model.User;
import lombok.extern.slf4j.Slf4j;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.fasterxml.jackson.core.type.TypeReference;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import com.albatross.api.utils.SqlCache;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-17.
 */
@Slf4j
@Service
public class AhjPermitService {
  @Autowired
  private SqlCache sqlCache;

  @Autowired
  private ObjectMapper om;

  @Autowired
  private AhjService ahjService;

  @Autowired
  private SecurityService securityService;

  @Autowired
  private BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;

  public Optional<AhjPermitDetail> getAhjPermitDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjPermitDetail> permit = sqlCache.get("ahj.permit.detail", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
    if (permit.isPresent()) {
      return permit;
    } else {
      User currentUser = securityService.getCurrentUser();
      params.put("currentUser", currentUser.getId());

      //add a blank permit and return that
      Integer id = sqlCache.get("ahj.permit.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
      if (id != null) {
        Optional<AhjPermitDetail> permit2 = sqlCache.get("ahj.permit.detail", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
        return permit2;
      }
    }
    return null;
  }

  @Transactional
  public Optional<AhjPermitDetail> saveAhjPermit(Long ahjId, Long permitId, AhjPermit permit) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("depositAmount", permit.getDepositAmount());
    params.put("averagePermitFee", permit.getAveragePermitFee());
    params.put("engineeringLetterRequired", permit.getEngineeringLetterRequired());
    params.put("printLocation", permit.getPrintLocation());
    params.put("stampedPlan", permit.getStampedPlan());
    params.put("businessLicense", permit.getBusinessLicense());
    params.put("contractorLicense", permit.getContractorLicense());
    params.put("businessLicenseExpirationDate", permit.getBusinessLicenseExpirationDate());
    params.put("contractorLicenseExpirationDate", permit.getContractorLicenseExpirationDate());
    params.put("currentUser", currentUser.getId());
    params.put("otherLicense", permit.getOtherLicense());
    params.put("otherLicenseExpirationDate", permit.getOtherLicenseExpirationDate());
    params.put("revisionFeeAmount", permit.getRevisionFeeAmount());
    params.put("asBuiltFeeAmount", permit.getAsBuiltFeeAmount());
    params.put("followUpFeeAmount", permit.getFollowUpFeeAmount());
    params.put("deliveryFeeAmount", permit.getDeliveryFeeAmount());
    params.put("approvalTimeline", permit.getApprovalTimeline());
    params.put("documentsAvailable", permit.getDocumentsAvailable());

    // NOTES
    params.put("submissionNote", permit.getSubmissionNote());
    params.put("revisionNote", permit.getRevisionNote());
    params.put("asBuiltNote", permit.getAsBuiltNote());
    params.put("deliveryNote", permit.getDeliveryNote());

    if (!permit.getUpdateAllInState()) {
      params.put("ahjId", ahjId);
      Long pId;

      if (permitId == null) {
        pId = permitId;
        sqlCache.updateReturningId("ahj.permit.create", params, "id");
      } else {
        pId = permitId;
        params.put("id", permitId);
        sqlCache.update("ahj.permit.update", params);
      }
      blueravenCustomFieldGroupService.handleSavingCustomFieldValues(permit.getCustomFieldGroups(), pId);
    } else {
      params.put("ahjIds", permit.getAhjIds());
      sqlCache.update("ahj.permit.updateAllAhjPermitsInState", params);
      blueravenCustomFieldGroupService.bulkHandleSavingCustomFieldValues(permit.getCustomFieldGroups(), permit.getPermitIds());
    }

    return getAhjPermitDetailByAhjId(ahjId);
  }

  // CHECKLISTS
  public void createPermitChecklistItem(Long permitId, Long itemId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjPermitId", permitId);
    params.put("ahjChecklistId", itemId);

    sqlCache.update("ahj.permit.checklist.create", params);
  }

  // CONTACTS
  public void savePermitContact(Long permitId, Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjPermitId", permitId);
    params.put("ahjContactId", contactId);

    sqlCache.update("ahj.permit.contact.create", params);
  }

  // PERMIT LINKS
  public Optional<AhjLink> savePermitLink(Long ahjId, Long permitId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjPermitId", permitId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.getId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.permit.link.create", params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.permit.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.permit.link.findById", idParam, AhjLink.class);
  }

  public void deletePermitLink(Long ahjId, Long permitId, Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.getId());

    sqlCache.update("ahj.permit.link.delete", params);
  }

  public List<AhjPermit> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.permit.searchAhjsByState", params, AhjPermit.class);
  }

  @SuppressWarnings({"Duplicates", "unchecked", "WeakerAccess"})
  public static class BaseAhjDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public BaseAhjDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjNote>> noteTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjNoteTemplate>> baseNoteTemplateTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "baseNoteTemplates",
        new JsonCollectionDeserializer(baseNoteTemplateTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "submissionContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "followUpContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "printLocations",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "utilityServiceDeptContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "feeContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "notes",
        new JsonCollectionDeserializer(noteTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "specialInstructionsNotes",
        new JsonCollectionDeserializer(noteTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "schedulingNotes",
        new JsonCollectionDeserializer(noteTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "obtainingResultsNotes",
        new JsonCollectionDeserializer(noteTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "submissionChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "revisionChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "asBuiltChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

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

      bw.registerCustomEditor(List.class, "servicingFots",
        new JsonCollectionDeserializer(userRef, objectMapper));

      bw.registerCustomEditor(List.class, "designRequirements",
        new JsonCollectionDeserializer(requirementRef, objectMapper));

      bw.registerCustomEditor(List.class, "electricalRequirements",
        new JsonCollectionDeserializer(requirementRef, objectMapper));

      bw.registerCustomEditor(List.class, "structuralRequirements",
        new JsonCollectionDeserializer(requirementRef, objectMapper));

      bw.registerCustomEditor(List.class, "utilityRequirements",
        new JsonCollectionDeserializer(requirementRef, objectMapper));

      bw.registerCustomEditor(List.class, "installationRequirements",
        new JsonCollectionDeserializer(requirementRef, objectMapper));
    }
  }

  @SuppressWarnings({"unchecked", "WeakerAccess"})
  public static class AhjPermitDetailMapper<T> extends BaseAhjDetailMapper<T> {

    public AhjPermitDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass, objectMapper);
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "submissionLinks",
        new JsonCollectionDeserializer(linkRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "followUpLinks",
        new JsonCollectionDeserializer(linkRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "schedulingLinks",
        new JsonCollectionDeserializer(linkRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "fotLinks",
        new JsonCollectionDeserializer(linkRef, super.objectMapper));

      bw.registerCustomEditor(List.class, "resultsLinks",
        new JsonCollectionDeserializer(linkRef, super.objectMapper));

      super.initBeanWrapper(bw);
    }
  }

  public Optional<AhjPermitCycleTimeStats> getPermitCycleTimeStats(Long ahjId, LocalDate startDate, LocalDate endDate) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    log.debug("Retrieving permit cycle time summary statistics using params: {}", params);

    PermitCycleTimeDbProcessor resultProcessor = new PermitCycleTimeDbProcessor();
    sqlCache.query("ahj.permit.cycleTime.summaryStats", params, resultProcessor);
    log.debug("Stats: {}", resultProcessor.getStats());
    return resultProcessor.getStats();
  }

  public String getPermitCycleTimeDetails(Long ahjId, LocalDate startDate, LocalDate endDate, String status) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("status", status);

    Optional<String> result = sqlCache.get("ahj.permit.cycleTime.permits", params, SingleColumnRowMapper.newInstance(String.class));
    return result.orElse("");
  }

  public String getAsBuiltsCycleTimeDetails(Long ahjId, LocalDate startDate, LocalDate endDate, String status) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("startDate", startDate);
    params.put("endDate", endDate);
    params.put("status", status);

    Optional<String> result = sqlCache.get("ahj.permit.cycleTime.asBuilts", params, SingleColumnRowMapper.newInstance(String.class));
    return result.orElse("");
  }
}
