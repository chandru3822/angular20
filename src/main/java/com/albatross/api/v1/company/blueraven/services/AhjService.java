package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.*;
//import com.albatross.api.v1.flow.model.User;

//import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.utils.SqlCache;
//import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
//import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.jdbc.core.BeanPropertyRowMapper;
//import org.springframework.jdbc.core.SingleColumnRowMapper;
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

//  public Optional<AhjPermitDetail> getAhjPermitDetailByAhjId(Long ahjId) {
//    HashMap<String, Object> params = new HashMap<>();
//    params.put("ahjId", ahjId);
//
//    Optional<AhjPermitDetail> permit = sqlCache.get("ahj.permit.detail", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
//    if (permit.isPresent()) {
//      return permit;
//    } else {
//      //add a blank permit and return that
//
//      Integer id = sqlCache.get("ahj.permit.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
//      if (id != null) {
//        Optional<AhjPermitDetail> permit2 = sqlCache.get("ahj.permit.detail", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
//        return permit2;
//      }
//    }
//    return null;
//  }
//
//  @Transactional
//  public Optional<AhjPermitDetail> createAhjPermit(Long ahjId, Long userId, AhjPermit permit) {
//    return saveAhjPermit(ahjId, userId, null, permit);
//  }
//
//  @Transactional
//  public Optional<AhjPermitDetail> saveAhjPermit(Long ahjId, Long userId, Long permitId, AhjPermit permit) {
//    HashMap<String, Object> params = new HashMap<>();
//    params.put("ahjId", ahjId);
//    params.put("depositAmount", permit.getDepositAmount());
//    params.put("averagePermitFee", permit.getAveragePermitFee());
//    params.put("engineeringLetterRequired", permit.getEngineeringLetterRequired());
//    params.put("printLocation", permit.getPrintLocation());
//    params.put("stampedPlan", permit.getStampedPlan());
//    params.put("businessLicense", permit.getBusinessLicense());
//    params.put("contractorLicense", permit.getContractorLicense());
//    params.put("businessLicenseExpirationDate", permit.getBusinessLicenseExpirationDate());
//    params.put("contractorLicenseExpirationDate", permit.getContractorLicenseExpirationDate());
//    params.put("currentUser", userId);
//    params.put("otherLicense", permit.getOtherLicense());
//    params.put("otherLicenseExpirationDate", permit.getOtherLicenseExpirationDate());
//
//    // NOTES
//    params.put("submissionNote", permit.getSubmissionNote());
//    params.put("revisionNote", permit.getRevisionNote());
//    params.put("asBuiltNote", permit.getAsBuiltNote());
//    params.put("deliveryNote", permit.getDeliveryNote());
//
//    params.put("submittalTypeId", permit.getSubmittalTypeId());
//    params.put("revisionSubmittalTypeId", permit.getRevisionSubmittalTypeId());
//    params.put("asBuiltSubmittalTypeId", permit.getAsBuiltSubmittalTypeId());
//    params.put("deliveryPickupTypeId", permit.getDeliveryPickupTypeId());
//    params.put("submissionPaymentTypeId", permit.getSubmissionPaymentTypeId());
//    params.put("revisionPaymentTypeId", permit.getRevisionPaymentTypeId());
//    params.put("asBuiltPaymentTypeId", permit.getAsBuiltPaymentTypeId());
//    params.put("followUpPaymentTypeId", permit.getFollowUpPaymentTypeId());
//    params.put("deliveryPaymentTypeId", permit.getDeliveryPaymentTypeId());
//    params.put("hoaApprovalRequiredTypeId", permit.getHoaApprovalRequiredTypeId());
//    params.put("nemApprovalRequiredTypeId", permit.getNemApprovalRequiredTypeId());
//    params.put("submittalTypeOther", permit.getSubmittalTypeOther());
//    params.put("revisionSubmittalTypeOther", permit.getRevisionSubmittalTypeOther());
//    params.put("asBuiltSubmittalTypeOther", permit.getAsBuiltSubmittalTypeOther());
//    params.put("deliveryPickupTypeOther", permit.getDeliveryPickupTypeOther());
//    params.put("submissionPaymentTypeOther", permit.getSubmissionPaymentTypeOther());
//    params.put("revisionPaymentTypeOther", permit.getRevisionPaymentTypeOther());
//    params.put("asBuiltPaymentTypeOther", permit.getAsBuiltPaymentTypeOther());
//    params.put("followUpPaymentTypeOther", permit.getFollowUpPaymentTypeOther());
//    params.put("deliveryPaymentTypeOther", permit.getDeliveryPaymentTypeOther());
//    params.put("hoaApprovalRequiredTypeOther", permit.getHoaApprovalRequiredTypeOther());
//    params.put("nemApprovalRequiredTypeOther", permit.getNemApprovalRequiredTypeOther());
//    params.put("revisionFeeAmount", permit.getRevisionFeeAmount());
//    params.put("asBuiltFeeAmount", permit.getAsBuiltFeeAmount());
//    params.put("followUpFeeAmount", permit.getFollowUpFeeAmount());
//    params.put("deliveryFeeAmount", permit.getDeliveryFeeAmount());
//    params.put("approvalTimeline", permit.getApprovalTimeline());
//    params.put("documentsAvailable", permit.getDocumentsAvailable());
//
//    if (permitId == null) {
//      sqlCache.update("ahj.permit.create", params);
//
//    } else {
//      params.put("id", permitId);
//      sqlCache.update("ahj.permit.update", params);
//    }
//
//    return getAhjPermitDetailByAhjId(ahjId);
//  }
//
//  public Optional<AhjInspection> createAhjInspection(Long ahjId, Long userId, AhjInspection inspection) {
//    return saveAhjInspection(ahjId, userId, null, inspection);
//  }
//
//  public Optional<AhjInspection> saveAhjInspection(Long ahjId, Long userId, Long inspectionId, AhjInspection inspection) {
//    HashMap<String, Object> params = new HashMap<>();
//    params.put("ahjId", ahjId);
//    params.put("inspectionFee", inspection.getInspectionFee());
//    params.put("reInspectionFee", inspection.getReInspectionFee());
//    params.put("paymentMethod", inspection.getPaymentMethod());
//    params.put("inspectionTimeWindow", inspection.getInspectionTimeWindow());
//    params.put("brsInspectionRep", inspection.getBrsInspectionRep());
//    params.put("portalUrl", inspection.getPortalUrl());
//    params.put("portalUsername", inspection.getPortalUsername());
//    params.put("portalPassword", inspection.getPortalPassword());
//    params.put("obtainingResultsMethod", inspection.getObtainingResultsMethod());
//    params.put("approvalDocumentMethod", inspection.getApprovalDocumentMethod());
//    params.put("obtainingResultsPortalUrl", inspection.getObtainingResultsPortalUrl());
//    params.put("obtainingResultsPortalUsername", inspection.getObtainingResultsPortalUsername());
//    params.put("obtainingResultsPortalPassword", inspection.getObtainingResultsPortalPassword());
//    params.put("businessLicense", inspection.getBusinessLicense());
//    params.put("contractorLicense", inspection.getContractorLicense());
//    params.put("homeownerRequiredOnSite", inspection.getHomeownerRequiredOnSite());
//    params.put("currentUser", userId);
//    params.put("callForTimeWindow", inspection.getCallForTimeWindow());
//    params.put("ladderRequired", inspection.getLadderRequired());
//    params.put("timeWindow", inspection.getTimeWindow());
//    params.put("timeWindowCallTime", inspection.getTimeWindowCallTime());
//    params.put("timeWindowPhone", inspection.getTimeWindowPhone());
//    params.put("fallProtectionRequired", inspection.getFallProtectionRequired());
//
//    //notes
//    params.put("schedulingNote", inspection.getSchedulingNote());
//    params.put("technicianInstructionNote", inspection.getTechnicianInstructionNote());
//    params.put("schedulingWithCustomerNote", inspection.getSchedulingWithCustomerNote());
//    params.put("obtainingResultsNote", inspection.getObtainingResultsNote());
//    params.put("reinspectionNote", inspection.getReinspectionNote());
//    params.put("documentationNote", inspection.getDocumentationNote());
//    params.put("mpuInspectionNote", inspection.getMpuInspectionNote());
//
//    //custom fields
//    params.put("homeownerRequired", inspection.getHomeownerRequired());
//    params.put("brsTechRequired", inspection.getBrsTechRequired());
//
//    //all the various type related fields
//    params.put("schedulingMethodTypeId", inspection.getSchedulingMethodTypeId());
//    params.put("schedulingMethodTypeOther", inspection.getSchedulingMethodTypeOther());
//    params.put("handyInformationTypeId", inspection.getHandyInformationTypeId());
//    params.put("handyInformationTypeOther", inspection.getHandyInformationTypeOther());
//    params.put("schedulingLeadTimeTypeId", inspection.getSchedulingLeadTimeTypeId());
//    params.put("schedulingLeadTimeTypeOther", inspection.getSchedulingLeadTimeTypeOther());
//    params.put("inspectionCapacityTypeId", inspection.getInspectionCapacityTypeId());
//    params.put("inspectionCapacityTypeOther", inspection.getInspectionCapacityTypeOther());
//    params.put("siteAccessTypeId", inspection.getSiteAccessTypeId());
//    params.put("siteAccessTypeOther", inspection.getSiteAccessTypeOther());
//    params.put("roughInspectionRequiredTypeId", inspection.getRoughInspectionRequiredTypeId());
//    params.put("roughInspectionRequiredTypeOther", inspection.getRoughInspectionRequiredTypeOther());
//    params.put("midpointInspectionLeadTimeTypeId", inspection.getMidpointInspectionLeadTimeTypeId());
//    params.put("midpointInspectionLeadTimeTypeOther", inspection.getMidpointInspectionLeadTimeTypeOther());
//    params.put("soladeckAccessTypeId", inspection.getSoladeckAccessTypeId());
//    params.put("soladeckAccessTypeOther", inspection.getSoladeckAccessTypeOther());
//    params.put("placardRequiredTypeId", inspection.getPlacardRequiredTypeId());
//    params.put("placardRequiredTypeOther", inspection.getPlacardRequiredTypeOther());
//    params.put("requiredInspectionTypes", inspection.getRequiredInspectionTypes());
//    params.put("representativeRequiredOnsiteTypeId", inspection.getRepresentativeRequiredOnsiteTypeId());
//    params.put("representativeRequiredOnsiteTypeOther", inspection.getRepresentativeRequiredOnsiteTypeOther());
//    params.put("specialEquipmentTypeId", inspection.getSpecialEquipmentTypeId());
//    params.put("specialEquipmentTypeOther", inspection.getSpecialEquipmentTypeOther());
//    params.put("plansRequiredTypeId", inspection.getPlansRequiredTypeId());
//    params.put("plansRequiredTypeOther", inspection.getPlansRequiredTypeOther());
//    params.put("specialDocumentsTypeId", inspection.getSpecialDocumentsTypeId());
//    params.put("specialDocumentsTypeOther", inspection.getSpecialDocumentsTypeOther());
//    params.put("resultsDocumentationTypeId", inspection.getResultsDocumentationTypeId());
//    params.put("resultsDocumentationTypeOther", inspection.getResultsDocumentationTypeOther());
//    params.put("reinspectionFeeTypeId", inspection.getReinspectionFeeTypeId());
//    params.put("reinspectionFeeTypeOther", inspection.getReinspectionFeeTypeOther());
//
//
//    if (inspectionId == null) {
//      inspectionId = sqlCache.updateReturningId("ahj.inspection.create", params, "id").longValue();
//    } else {
//      params.put("id", inspectionId);
//      sqlCache.update("ahj.inspection.update", params);
//    }
//
//    HashMap<String, Object> keyParam = new HashMap<>();
//    keyParam.put("id", inspectionId);
//
//    return sqlCache.get("ahj.inspection.findById", keyParam, AhjInspection.class);
//  }
//
//  public static class BaseAhjDetailMapper<T> extends BeanPropertyRowMapper<T> {
//    private final ObjectMapper objectMapper;
//
//    public BaseAhjDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
//      super(mappedClass);
//      this.objectMapper = objectMapper;
//    }
//
//    @Override
//    protected void initBeanWrapper(BeanWrapper bw) {
//      TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
//      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
//      TypeReference<List<AhjNote>> noteTypeRef = new TypeReference<>() {};
//      TypeReference<List<AhjBaseNoteTemplate>> baseNoteTemplateTypeRef = new TypeReference<>() {};
//      TypeReference<List<User>> userRef = new TypeReference<>() {};
//      TypeReference<List<AhjRequirement>> requirementRef = new TypeReference<>() {};
//
//      bw.registerCustomEditor(List.class, "baseNoteTemplates",
//        new JsonCollectionDeserializer(baseNoteTemplateTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "contacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "followUpContacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "printLocations",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "utilityServiceDeptContacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingContacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "obtainingResultsContacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "feeContacts",
//        new JsonCollectionDeserializer(contactTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "notes",
//        new JsonCollectionDeserializer(noteTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "specialInstructionsNotes",
//        new JsonCollectionDeserializer(noteTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingNotes",
//        new JsonCollectionDeserializer(noteTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "obtainingResultsNotes",
//        new JsonCollectionDeserializer(noteTypeRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "checklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "revisionChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "asBuiltChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "failureChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "obtainingResultsChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "reinspectionsChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingWithAhjChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingWithBrsTechnicianChecklist",
//        new JsonCollectionDeserializer(itemRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "servicingFots",
//        new JsonCollectionDeserializer(userRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "designRequirements",
//        new JsonCollectionDeserializer(requirementRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "electricalRequirements",
//        new JsonCollectionDeserializer(requirementRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "structuralRequirements",
//        new JsonCollectionDeserializer(requirementRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "utilityRequirements",
//        new JsonCollectionDeserializer(requirementRef, objectMapper));
//
//      bw.registerCustomEditor(List.class, "installationRequirements",
//        new JsonCollectionDeserializer(requirementRef, objectMapper));
//    }
//  }
//
//  public static class AhjPermitDetailMapper<T> extends BaseAhjDetailMapper<T> {
//
//    public AhjPermitDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
//      super(mappedClass, objectMapper);
//    }
//
//    @Override
//    protected void initBeanWrapper(BeanWrapper bw) {
//      TypeReference<List<AhjLink>> linkRef = new TypeReference<>() {};
//
//      bw.registerCustomEditor(List.class, "links",
//        new JsonCollectionDeserializer(linkRef, super.objectMapper));
//
//      bw.registerCustomEditor(List.class, "followUpLinks",
//        new JsonCollectionDeserializer(linkRef, super.objectMapper));
//
//      bw.registerCustomEditor(List.class, "schedulingLinks",
//        new JsonCollectionDeserializer(linkRef, super.objectMapper));
//
//      bw.registerCustomEditor(List.class, "fotLinks",
//        new JsonCollectionDeserializer(linkRef, super.objectMapper));
//
//      bw.registerCustomEditor(List.class, "resultsLinks",
//        new JsonCollectionDeserializer(linkRef, super.objectMapper));
//
//      super.initBeanWrapper(bw);
//    }
//  }
}