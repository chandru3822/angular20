package com.albatross.api.v1.company.blueraven.services.ahj;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjContact;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjLink;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtility;
import com.albatross.api.v1.company.blueraven.models.ahj.AhjUtilityDetail;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AhjUtilityService {

  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final NamedParameterJdbcTemplate jdbc;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;

  public List<AhjUtility> getAllAhjUtilities() {
    HashMap<String, Object> params = new HashMap<>();
    return sqlCache.query("ahj.utility.list.all", params, AhjUtility.class);
  }

  public Optional<AhjUtilityDetail> getUtilityById(Long id) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", id);

    return sqlCache.get(
        "ahj.utility.detailById", params, new AhjUtilityDetailMapper<>(AhjUtilityDetail.class, om));
  }

  public Optional<AhjUtilityDetail> simpleUpdate(AhjUtility utility) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("utilityName", utility.getName());
    params.put("metroAreaId", utility.getMetroAreaId());
    params.put("companyStateId", utility.getCompanyStateId());
    params.put("archived", utility.getArchived());
    params.put("id", utility.getId());

    sqlCache.update("ahj.utility.simple.update", params);
    return getUtilityById(utility.getId());
  }

  public Optional<AhjUtilityDetail> updateUtility(AhjUtility utility) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("currentUser", currentUser.trueUserId());
    params.put("utilityName", utility.getName());
    params.put("metroAreaId", utility.getMetroAreaId());
    params.put("companyStateId", utility.getCompanyStateId());
    params.put("timelinesAndStages", utility.getTimelinesAndStages());
    params.put("regulatedBy", utility.getRegulatedBy());
    params.put("monthlyFacilityCharge", utility.getMonthlyFacilityCharge());
    params.put("populationOfService", utility.getPopulationOfService());
    params.put("netMeteringRate", utility.getNetMeteringRate());
    params.put("rebateRates", utility.getRebateRates());
    params.put("utilityRateNotes", utility.getUtilityRateNotes());
    params.put("customerSignatureInstructions", utility.getCustomerSignatureInstructions());
    params.put("expectedApprovalTimeline", utility.getExpectedApprovalTimeline());
    params.put("rejectionInstructions", utility.getRejectionInstructions());
    params.put("notes", utility.getNotes());
    params.put("overviewOfSubmissionProcess", utility.getOverviewOfSubmissionProcess());
    params.put("submissionInstructions", utility.getSubmissionInstructions());
    params.put("timelines", utility.getTimelines());
    params.put("ptoFollowupInstructions", utility.getPtoFollowupInstructions());
    params.put("finalCompletionInstructions", utility.getFinalCompletionInstructions());
    params.put("financierId", utility.getFinancierId());
    params.put("archived", utility.getArchived());

    Long id;

    if (null != utility.getId()) {
      id = utility.getId();
      params.put("id", utility.getId());
      sqlCache.update("ahj.utility.update", params);
    } else {
      id = sqlCache.updateReturningId("ahj.utility.insert", params, "id").longValue();
    }

    blueravenCustomFieldValueService.handleSavingCustomFieldValuesUsingGroups(
        ObjectType.AHJ_UTILITY.textValue(), utility.getCustomFieldGroups(), id);

    return getUtilityById(id);
  }

  // CONTACTS
  public Optional<AhjContact> getUtilityContactById(Long contactId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("id", contactId);

    return sqlCache.get("ahj.utility.contact.findById", params, AhjContact.class);
  }

  public Optional<AhjContact> saveUtilityContact(
      Long utilityId, Long contactId, AhjContact contact) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjUtilityId", utilityId);
    params.put("currentUser", currentUser.trueUserId());
    params.put("name", contact.getName());
    params.put("title", contact.getTitle());
    params.put("email", contact.getEmail());
    params.put("phoneNumber", contact.getPhoneNumber());
    params.put("address", contact.getAddress());
    params.put("notes", contact.getNotes());
    params.put("hours", contact.getHours());
    params.put("contactTypeId", contact.getContactTypeId());

    if (contactId == null) {
      contactId = sqlCache.updateReturningId("ahj.utility.contact.add", params, "id").longValue();
    } else {
      params.put("contactId", contactId);
      sqlCache.update("ahj.utility.contact.update", params);
    }

    return getUtilityContactById(contactId);
  }

  public void deleteUtilityContact(Long contactId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.utility.contact.delete", params);
  }

  // LINKS
  public Optional<AhjLink> saveUtilityLink(Long utilityId, Long linkId, AhjLink link) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("ahjUtilityId", utilityId);
    params.put("name", link.getName());
    params.put("link", link.getLink());
    params.put("username", link.getUsername());
    params.put("password", link.getPassword());
    params.put("notes", link.getNotes());
    params.put("currentUser", currentUser.trueUserId());
    params.put("linkTypeId", link.getLinkTypeId());

    if (linkId == null) {
      linkId = sqlCache.updateReturningId("ahj.utility.link.add", params, "id").longValue();
    } else {
      params.put("id", linkId);
      sqlCache.update("ahj.utility.link.update", params);
    }

    HashMap<String, Object> idParam = new HashMap<>();
    idParam.put("id", linkId);
    return sqlCache.get("ahj.utility.link.findById", idParam, AhjLink.class);
  }

  public void deleteUtilityLink(Long linkId) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("id", linkId);
    params.put("currentUser", currentUser.trueUserId());

    sqlCache.update("ahj.utility.link.delete", params);
  }

  public static class AhjUtilityDetailMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public AhjUtilityDetailMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<AhjLink>> linkTypeRef = new TypeReference<>() {};
      TypeReference<List<AhjContact>> contactTypeRef = new TypeReference<>() {};

      bw.registerCustomEditor(
          List.class,
          "links",
          new JsonCollectionDeserializer(linkTypeRef, objectMapper));

      bw.registerCustomEditor(
          List.class, "contacts", new JsonCollectionDeserializer(contactTypeRef, objectMapper));

    }
  }
}
