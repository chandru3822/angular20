package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.flow.model.User;

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

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

/**
 * Created by Joseph Canto on 2019-07-17.
 */
@Service
public class AhjPermitService {
  @Autowired
  private SqlCache sqlCache;
  private ObjectMapper om;

  public Optional<AhjPermitDetail> getAhjPermitDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjPermitDetail> permit = sqlCache.get("ahj.permit.detail", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
    if (permit.isPresent()) {
      return permit;
    } else {
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
  public Optional<AhjPermitDetail> createAhjPermit(Long ahjId, Long userId, AhjPermit permit) {
    return saveAhjPermit(ahjId, userId, null, permit);
  }

  @Transactional
  public Optional<AhjPermitDetail> saveAhjPermit(Long ahjId, Long userId, Long permitId, AhjPermit permit) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);
    params.put("depositAmount", permit.getDepositAmount());
    params.put("averagePermitFee", permit.getAveragePermitFee());
    params.put("engineeringLetterRequired", permit.getEngineeringLetterRequired());
    params.put("printLocation", permit.getPrintLocation());
    params.put("stampedPlan", permit.getStampedPlan());
    params.put("businessLicense", permit.getBusinessLicense());
    params.put("contractorLicense", permit.getContractorLicense());
    params.put("businessLicenseExpirationDate", permit.getBusinessLicenseExpirationDate());
    params.put("contractorLicenseExpirationDate", permit.getContractorLicenseExpirationDate());
    params.put("currentUser", userId);
    params.put("otherLicense", permit.getOtherLicense());
    params.put("otherLicenseExpirationDate", permit.getOtherLicenseExpirationDate());

    // NOTES
    params.put("submissionNote", permit.getSubmissionNote());
    params.put("revisionNote", permit.getRevisionNote());
    params.put("asBuiltNote", permit.getAsBuiltNote());
    params.put("deliveryNote", permit.getDeliveryNote());

    params.put("submittalTypeId", permit.getSubmittalTypeId());
    params.put("revisionSubmittalTypeId", permit.getRevisionSubmittalTypeId());
    params.put("asBuiltSubmittalTypeId", permit.getAsBuiltSubmittalTypeId());
    params.put("deliveryPickupTypeId", permit.getDeliveryPickupTypeId());
    params.put("submissionPaymentTypeId", permit.getSubmissionPaymentTypeId());
    params.put("revisionPaymentTypeId", permit.getRevisionPaymentTypeId());
    params.put("asBuiltPaymentTypeId", permit.getAsBuiltPaymentTypeId());
    params.put("followUpPaymentTypeId", permit.getFollowUpPaymentTypeId());
    params.put("deliveryPaymentTypeId", permit.getDeliveryPaymentTypeId());
    params.put("hoaApprovalRequiredTypeId", permit.getHoaApprovalRequiredTypeId());
    params.put("nemApprovalRequiredTypeId", permit.getNemApprovalRequiredTypeId());
    params.put("submittalTypeOther", permit.getSubmittalTypeOther());
    params.put("revisionSubmittalTypeOther", permit.getRevisionSubmittalTypeOther());
    params.put("asBuiltSubmittalTypeOther", permit.getAsBuiltSubmittalTypeOther());
    params.put("deliveryPickupTypeOther", permit.getDeliveryPickupTypeOther());
    params.put("submissionPaymentTypeOther", permit.getSubmissionPaymentTypeOther());
    params.put("revisionPaymentTypeOther", permit.getRevisionPaymentTypeOther());
    params.put("asBuiltPaymentTypeOther", permit.getAsBuiltPaymentTypeOther());
    params.put("followUpPaymentTypeOther", permit.getFollowUpPaymentTypeOther());
    params.put("deliveryPaymentTypeOther", permit.getDeliveryPaymentTypeOther());
    params.put("hoaApprovalRequiredTypeOther", permit.getHoaApprovalRequiredTypeOther());
    params.put("nemApprovalRequiredTypeOther", permit.getNemApprovalRequiredTypeOther());
    params.put("revisionFeeAmount", permit.getRevisionFeeAmount());
    params.put("asBuiltFeeAmount", permit.getAsBuiltFeeAmount());
    params.put("followUpFeeAmount", permit.getFollowUpFeeAmount());
    params.put("deliveryFeeAmount", permit.getDeliveryFeeAmount());
    params.put("approvalTimeline", permit.getApprovalTimeline());
    params.put("documentsAvailable", permit.getDocumentsAvailable());

    if (permitId == null) {
      sqlCache.update("ahj.permit.create", params);

    } else {
      params.put("id", permitId);
      sqlCache.update("ahj.permit.update", params);
    }

    return getAhjPermitDetailByAhjId(ahjId);
  }

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
      TypeReference<List<AhjBaseNoteTemplate>> baseNoteTemplateTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};
      TypeReference<List<AhjRequirement>> requirementRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "baseNoteTemplates",
        new JsonCollectionDeserializer(baseNoteTemplateTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "contacts",
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

      bw.registerCustomEditor(List.class, "checklist",
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

  public static class AhjPermitDetailMapper<T> extends BaseAhjDetailMapper<T> {

    public AhjPermitDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass, objectMapper);
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "links",
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
}