package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.ContactLead;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserPosition;
import com.albatross.api.v1.flow.services.UserPositionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ContactLeadService {
  private final SqlCache sqlCache;
  private final SecurityService securityService;
  private final UserPositionService userPositionService;

  public void saveContactLead(ContactLead cl) {
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", CleanString.replaceApostrophe(cl.getFirstName()));
    params.put("lastName", CleanString.replaceApostrophe(cl.getLastName()));
    params.put("street1", cl.getAddress());
    params.put("city", cl.getCity());
    params.put("state", cl.getState());
    params.put("postalCode", cl.getZip());
    params.put("phone", cl.getPhone());
    params.put("email", cl.getEmail());
    params.put("companyId", 3);
    params.put("createdById", currentUser.getId());
    UserPosition userPrimaryPosition = userPositionService.getUserPrimaryPosition(currentUser.getId());
    params.put("ownerUserPositionId", null == userPrimaryPosition || null == userPrimaryPosition.getId() ? null : userPrimaryPosition.getId());
    params.put("contactTypeId", ContactType.LEAD.id);
    Long contactId;
    if (cl.getState().length() == 2) {
      contactId = sqlCache.updateReturningId("contactLead.insertContactStateAbbr", params, "id").longValue();
    }
    else {
      contactId = sqlCache.updateReturningId("contactLead.insertContact", params, "id").longValue();
    }
    // handles saving 'Lead Source' custom field
    if (cl.getLeadSource() != null) {
      String leadSourceId = checkIfCustomFieldDropdownValueExists(520, cl.getLeadSource());
      CustomFieldValue leadSource = new CustomFieldValue();
      if (!leadSourceId.equalsIgnoreCase("null")) {
        leadSource.setCustomFieldGroupAssignmentId(395L);
        leadSource.setIntValue(Long.parseLong(leadSourceId));
        saveCustomFieldValue(leadSource, contactId, currentUser.getId());
      }
    }

    // handles saving 'Lead Source Detail' custom field
    if (cl.getLeadSourceDetail() != null) {
      String leadSourceDetailId = checkIfCustomFieldDropdownValueExists(543, cl.getLeadSourceDetail());
      CustomFieldValue leadSourceDetail = new CustomFieldValue();

      if (!leadSourceDetailId.equalsIgnoreCase("null")) {
        leadSourceDetail.setCustomFieldGroupAssignmentId(396L);
        leadSourceDetail.setIntValue(Long.parseLong(leadSourceDetailId));
        saveCustomFieldValue(leadSourceDetail, contactId, currentUser.getId());
      }
    }

    ArrayList<CustomFieldValue> cfvList = new ArrayList<>();

    if (cl.getTcpaOptIn() != null) {
      CustomFieldValue tcpa = new CustomFieldValue();
      tcpa.setCustomFieldGroupAssignmentId(19599L);
      tcpa.setTextValue(cl.getTcpaOptIn());
      cfvList.add(tcpa);
    }

    if (cl.getActiveProspectUrl() != null) {
      CustomFieldValue activeProspectUrl = new CustomFieldValue();
      activeProspectUrl.setCustomFieldGroupAssignmentId(19600L);
      activeProspectUrl.setTextValue(cl.getActiveProspectUrl());
      cfvList.add(activeProspectUrl);
    }

    if (cl.getVendorId() != null) {
      CustomFieldValue vendorId = new CustomFieldValue();
      vendorId.setCustomFieldGroupAssignmentId(19601L);
      vendorId.setTextValue(cl.getVendorId());
      cfvList.add(vendorId);
    }

    if (cl.getTier() != null) {
      CustomFieldValue tier = new CustomFieldValue();
      tier.setCustomFieldGroupAssignmentId(19602L);
      tier.setTextValue(cl.getTier());
      cfvList.add(tier);
    }

    if (cl.getLeadType() != null) {
      CustomFieldValue leadType = new CustomFieldValue();
      leadType.setCustomFieldGroupAssignmentId(19603L);
      leadType.setTextValue(cl.getLeadType());
      cfvList.add(leadType);
    }

    if (cl.getIpAddress() != null) {
      CustomFieldValue ipAddress = new CustomFieldValue();
      ipAddress.setCustomFieldGroupAssignmentId(19604L);
      ipAddress.setTextValue(cl.getIpAddress());
      cfvList.add(ipAddress);
    }

    if (cl.getMarket() != null) {
      CustomFieldValue market = new CustomFieldValue();
      market.setCustomFieldGroupAssignmentId(19605L);
      market.setTextValue(cl.getMarket());
      cfvList.add(market);
    }

    if (cl.getWebsite() != null) {
      CustomFieldValue website = new CustomFieldValue();
      website.setCustomFieldGroupAssignmentId(19606L);
      website.setTextValue(cl.getWebsite());
      cfvList.add(website);
    }

    if (cl.getCompany() != null) {
      CustomFieldValue company = new CustomFieldValue();
      company.setCustomFieldGroupAssignmentId(19607L);
      company.setTextValue(cl.getCompany());
      cfvList.add(company);
    }

    if (cl.getCountry() != null) {
      CustomFieldValue country = new CustomFieldValue();
      country.setCustomFieldGroupAssignmentId(19608L);
      country.setTextValue(cl.getCountry());
      cfvList.add(country);
    }

    if (cl.getRoofMaterial() != null) {
      CustomFieldValue roofMaterial = new CustomFieldValue();
      roofMaterial.setCustomFieldGroupAssignmentId(19609L);
      roofMaterial.setTextValue(cl.getRoofMaterial());
      cfvList.add(roofMaterial);
    }

    if (cl.getSunExposure() != null) {
      CustomFieldValue sunExposure = new CustomFieldValue();
      sunExposure.setCustomFieldGroupAssignmentId(19610L);
      sunExposure.setTextValue(cl.getSunExposure());
      cfvList.add(sunExposure);
    }

    if (cl.getElectricProvider() != null) {
      CustomFieldValue electricProvider = new CustomFieldValue();
      electricProvider.setCustomFieldGroupAssignmentId(19611L);
      electricProvider.setTextValue(cl.getElectricProvider());
      cfvList.add(electricProvider);
    }

    if (cl.getElectricMonthly() != null) {
      CustomFieldValue electricMonthly = new CustomFieldValue();
      electricMonthly.setCustomFieldGroupAssignmentId(19612L);
      electricMonthly.setNumericValue(cl.getElectricMonthly());
      cfvList.add(electricMonthly);
    }

    if (cl.getLeadId() != null) {
      CustomFieldValue leadId = new CustomFieldValue();
      leadId.setCustomFieldGroupAssignmentId(19613L);
      leadId.setTextValue(cl.getLeadId());
      cfvList.add(leadId);
    }

    if (cl.getRoofDesign() != null) {
      CustomFieldValue roofDesign = new CustomFieldValue();
      roofDesign.setCustomFieldGroupAssignmentId(19614L);
      roofDesign.setTextValue(cl.getRoofDesign());
      cfvList.add(roofDesign);
    }

    if (cl.getCreditScore() != null) {
      CustomFieldValue creditScore = new CustomFieldValue();
      creditScore.setCustomFieldGroupAssignmentId(19615L);
      creditScore.setIntValue(cl.getCreditScore());
      cfvList.add(creditScore);
    }

    if (cl.getHouseholdIncome() != null) {
      CustomFieldValue householdIncome = new CustomFieldValue();
      householdIncome.setCustomFieldGroupAssignmentId(19616L);
      householdIncome.setNumericValue(cl.getHouseholdIncome());
      cfvList.add(householdIncome);
    }

    if (cl.getRoofShade() != null) {
      CustomFieldValue roofShade = new CustomFieldValue();
      roofShade.setCustomFieldGroupAssignmentId(19617L);
      roofShade.setTextValue(cl.getRoofShade());
      cfvList.add(roofShade);
    }

    if (cl.getHomeOwner() != null) {
      CustomFieldValue homeOwner = new CustomFieldValue();
      homeOwner.setCustomFieldGroupAssignmentId(19618L);
      homeOwner.setTextValue(cl.getHomeOwner());
      cfvList.add(homeOwner);
    }

    if (cl.getComments() != null) {
      CustomFieldValue comments = new CustomFieldValue();
      comments.setCustomFieldGroupAssignmentId(19619L);
      comments.setTextValue(cl.getComments());
      cfvList.add(comments);
    }

    for (CustomFieldValue cfv: cfvList) {
      saveCustomFieldValue(cfv, contactId, currentUser.getId());
    }
  }

  private void saveCustomFieldValue(CustomFieldValue cfv, Long contactId, Long leadOwnerUserId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());
    params.put("textValue", cfv.getTextValue());
    params.put("intValue", cfv.getIntValue());
    params.put("numericValue", cfv.getNumericValue());
    params.put("leadOwnerUserId", leadOwnerUserId);

    sqlCache.update("contactLead.upsertCustomFieldValue", params);
  }

  private String checkIfCustomFieldDropdownValueExists(Integer listOfValueId, String customFieldDropdownValue) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("listOfValueId", listOfValueId);
    params.put("customFieldDropdownValue", customFieldDropdownValue);

    Optional<String> customFieldDropdownValueId = sqlCache.queryForObjectOptional("contactLead.checkIfCustomFieldDropdownValueExists", params, String.class);
    return customFieldDropdownValueId.orElse("null");
  }
}
