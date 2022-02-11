package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.*;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

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
  private SecurityService securityService;

  @Autowired
  private BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public Optional<AhjPermitDetail> getAhjPermitDetailByAhjId(Long ahjId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjId", ahjId);

    Optional<AhjPermitDetail> permit = sqlCache.get("ahj.permit.detailByAhj", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
    if (permit.isPresent()) {
      return permit;
    } else {
      User currentUser = securityService.getCurrentUser();
      params.put("currentUser", currentUser.trueUserId());

      // add a blank permit and return that
      Integer id = sqlCache.get("ahj.permit.createBlank", params, new SingleColumnRowMapper<>(Integer.class)).get();
      if (id != null) {
        Optional<AhjPermitDetail> permit2 = sqlCache.get("ahj.permit.detailByAhj", params, new AhjPermitDetailMapper<>(AhjPermitDetail.class, om));
        return permit2;
      }
    }
    return null;
  }

  @Transactional
  public Optional<AhjPermitDetail> saveAhjPermit(Long ahjId, Long permitId, AhjPermit permit, Boolean returnValue) {
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
    params.put("currentUser", currentUser.trueUserId());
    params.put("otherLicense", permit.getOtherLicense());
    params.put("otherLicenseExpirationDate", permit.getOtherLicenseExpirationDate());
    params.put("revisionFeeAmount", permit.getRevisionFeeAmount());
    params.put("asBuiltFeeAmount", permit.getAsBuiltFeeAmount());
    params.put("followUpFeeAmount", permit.getFollowUpFeeAmount());
    params.put("deliveryFeeAmount", permit.getDeliveryFeeAmount());
    params.put("approvalTimeline", permit.getApprovalTimeline());
    params.put("documentsAvailable", permit.getDocumentsAvailable());
    params.put("brsTechnicianPermitSubmissionInstructions", permit.getBrsTechnicianPermitSubmissionInstructions());
    params.put("cancellationAndRefundInstructions", permit.getCancellationAndRefundInstructions());
    params.put("brsTechnicianPermitPickupAndDeliveryInstructions", permit.getBrsTechnicianPermitPickupAndDeliveryInstructions());
    params.put("approvalInstructions", permit.getApprovalInstructions());

    // NOTES
    params.put("submissionNote", permit.getSubmissionNote());
    params.put("revisionNote", permit.getRevisionNote());
    params.put("asBuiltNote", permit.getAsBuiltNote());
    params.put("nonStandardNote", permit.getNonStandardNote());
    params.put("deliveryNote", permit.getDeliveryNote());

    if (permit.getUpdateAllInState() != null && permit.getUpdateAllInState()) {
      params.put("ahjIds", permit.getAhjIds());
      sqlCache.update("ahj.permit.updateAllAhjPermitsInState", params);
      blueravenCustomFieldValueService.bulkHandleSavingCustomFieldValuesUsingGroups(ObjectType.AHJ_PERMIT.textValue(), permit.getCustomFieldGroups(), permit.getPermitIds());
    } else {
      params.put("ahjId", ahjId);

      if (permitId == null) {
        sqlCache.updateReturningId("ahj.permit.create", params, "id").longValue();
      } else {
        params.put("id", permitId);
        sqlCache.update("ahj.permit.update", params);
        blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(ObjectType.AHJ_PERMIT.textValue(), permit.getCustomFieldGroups(), permitId);
      }
    }

    return returnValue ? getAhjPermitDetailByAhjId(ahjId) : Optional.empty();
  }

  public List<AhjPermit> searchAhjsByState(Long stateId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stateId", stateId);
    return sqlCache.query("ahj.permit.searchAhjsByState", params, AhjPermit.class);
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
    params.put("currentUser", currentUser.trueUserId());
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
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.permit.link.delete", params);
  }

  public static class AhjPermitDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjPermitDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkRef = new TypeReference<>() {};
      TypeReference<List<AhjChecklistItem>> itemRef = new TypeReference<>() {};
      TypeReference<List<AhjNote>> noteTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};
      TypeReference<List<User>> userRef = new TypeReference<>() {};

      bw.registerCustomEditor(List.class, "submissionLinks",
        new JsonCollectionDeserializer(linkRef, objectMapper));

      bw.registerCustomEditor(List.class, "followUpLinks",
        new JsonCollectionDeserializer(linkRef, objectMapper));

      bw.registerCustomEditor(List.class, "submissionChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "revisionChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "asBuiltChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "nonStandardChecklist",
        new JsonCollectionDeserializer(itemRef, objectMapper));

      bw.registerCustomEditor(List.class, "notes",
        new JsonCollectionDeserializer(noteTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "submissionContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "followUpContacts",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "printLocations",
        new JsonCollectionDeserializer(contactTypeRef, objectMapper));

      bw.registerCustomEditor(List.class, "servicingFots",
        new JsonCollectionDeserializer(userRef, objectMapper));
    }
  }
}
