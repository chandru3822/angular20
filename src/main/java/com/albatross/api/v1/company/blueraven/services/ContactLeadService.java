package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.CleanString;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.ContactLead;
import com.albatross.api.v1.flow.enums.ContactType;
import com.albatross.api.v1.flow.enums.State;
import com.albatross.api.v1.flow.model.*;
import com.albatross.api.v1.flow.services.HubspotWebhookService;
import com.albatross.api.v1.flow.services.SMSService;
import com.albatross.api.v1.flow.services.UserPositionService;
import com.mypurecloud.sdk.v2.ApiException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ContactLeadService {
  private final SqlCache sqlCache;
  private final GenesysService genesysService;

  @Autowired
  private HubspotWebhookService hubspotWebhookService;

  @Value(value = "${app.ricochet.enabled:false}")
  private Boolean ricochetEnabled;

  private final SMSService smsService;
  private final SecurityService securityService;
  private final UserPositionService userPositionService;

  public void saveContactLead(ContactLead cl) {
    RicochetLead ricochetLead = new RicochetLead();
    User currentUser = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("firstName", CleanString.replaceApostrophe(cl.getFirstName()));
    params.put("lastName", CleanString.replaceApostrophe(cl.getLastName()));
    params.put("street1", cl.getAddress());
    params.put("city", cl.getCity());
    params.put("postalCode", cl.getZip());
    params.put("email", cl.getEmail());
    params.put("companyId", 3);
    params.put("createdById", currentUser.getId());
    UserPosition userPrimaryPosition = userPositionService.getUserPrimaryPosition(currentUser.getId());
    params.put("ownerUserPositionId", null == userPrimaryPosition || null == userPrimaryPosition.getId() ? null : userPrimaryPosition.getId());
    params.put("contactTypeId", ContactType.LEAD.id);

    try {
      params.put("phone", smsService.cleanPhoneNumber(cl.getPhone()));
    } catch (Exception e) {
      params.put("phone", cl.getPhone());
    }

    Long contactId;

    String state = cl.getState();
    if (state != null) {
      // If State abbreviation was entered
      if (State.valueOfName(state) != State.UNKNOWN) {
        params.put("state", State.valueOfName(state).toString());
        // Case for State full name
        contactId = sqlCache.updateReturningId("contactLead.insertContact", params, "id").longValue();
      }
      else if (State.valueOfAbbreviation(state.toUpperCase()) != State.UNKNOWN) {
        // Case for State abbreviation
        params.put("state", State.valueOfAbbreviation(state.toUpperCase()).toString());
        contactId = sqlCache.updateReturningId("contactLead.insertContact", params, "id").longValue();
      }
      else {
        // Case for invalid State
        contactId = sqlCache.updateReturningId("contactLead.insertContactNoState", params, "id").longValue();
      }
    }
    else {
      // Case for no State
      contactId = sqlCache.updateReturningId("contactLead.insertContactNoState", params, "id").longValue();
    }
    ricochetLead.setContactId(contactId);

    ArrayList<CustomFieldValue> cfvList = new ArrayList<>();
    // handles saving 'Lead Source' custom field
    if (cl.getLeadSource() != null) {
      String leadSourceId = checkIfCustomFieldDropdownValueExists(520, cl.getLeadSource());
      CustomFieldValue leadSource = new CustomFieldValue();
      leadSource.setFieldName("Lead Source");
      ricochetLead.setLead_source(cl.getLeadSource());
      if (!leadSourceId.equalsIgnoreCase("null")) {
        leadSource.setCustomFieldGroupAssignmentId(395L);
        leadSource.setIntValue(Long.parseLong(leadSourceId));
        leadSource.setFieldValue(cl.getLeadSource());
        cfvList.add(leadSource);
      }
    }

    // handles saving 'Lead Source Detail' custom field
    if (cl.getLeadSourceDetail() != null) {
      String leadSourceDetailId = checkIfCustomFieldDropdownValueExists(543, cl.getLeadSourceDetail());
      CustomFieldValue leadSourceDetail = new CustomFieldValue();
      leadSourceDetail.setFieldName("Lead Source Detail");
      ricochetLead.setLead_source_detail(cl.getLeadSourceDetail());
      if (!leadSourceDetailId.equalsIgnoreCase("null")) {
        leadSourceDetail.setCustomFieldGroupAssignmentId(396L);
        leadSourceDetail.setIntValue(Long.parseLong(leadSourceDetailId));
        leadSourceDetail.setFieldValue(cl.getLeadSourceDetail());
        cfvList.add(leadSourceDetail);
      }
    }

    String leadStatusId = checkIfCustomFieldDropdownValueExists(696, "New");

    // handles saving 'Lead Status' custom field
    if (!leadStatusId.equalsIgnoreCase("null")) {
      CustomFieldValue leadStatus = new CustomFieldValue();
      leadStatus.setFieldName("Lead Status");
      leadStatus.setCustomFieldGroupAssignmentId(399L);
      leadStatus.setIntValue(Long.parseLong(leadStatusId));
      leadStatus.setFieldValue("New");
      cfvList.add(leadStatus);
    }

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

    if (cl.getLeadPrice() != null) {
      CustomFieldValue leadPrice = new CustomFieldValue();
      leadPrice.setCustomFieldGroupAssignmentId(19695L);
      leadPrice.setNumericValue(cl.getLeadPrice());
      cfvList.add(leadPrice);
    }

    for (CustomFieldValue cfv: cfvList) {
      saveCustomFieldValue(cfv, contactId, currentUser.getId());
    }

    try {
      genesysService.addContact(contactId, cfvList);
    } catch (ApiException e) {
      JSONObject apiException = new JSONObject(e.getRawBody());
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, apiException.getString("message"));
    }
    catch (IOException e) {
      String msg = "GENE: Error adding contact: {}";
      log.error(msg, e.getMessage());
    }

    try {
      if (ricochetEnabled) {
        postToRicochet(ricochetLead, params);
      }
      else {
        log.info("RICOCHET: not enabled");
      }

    } catch (Exception e) {
      String msg = "RICO: Failed to post Contact Lead information to Ricochet.";
      log.error(msg, e);
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

  public void processCustomFieldValues(RicochetLead lead, Long contactId, Long leadOwnerUserId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("contactId", contactId);
    params.put("leadOwnerUserId", leadOwnerUserId);

    // if "null" is returned for leadStatusId, then we don't want to save it, b/c that means it's not one of the existing options, and we don't save new values
    String leadStatusId = checkIfCustomFieldDropdownValueExists(696, lead.getStatus());

    // handles saving 'Lead Status' custom field
    if (!leadStatusId.equalsIgnoreCase("null")) {
      CustomFieldValue leadStatus = new CustomFieldValue();
      leadStatus.setCustomFieldGroupAssignmentId(399L);
      leadStatus.setIntValue(Long.parseLong(leadStatusId));
      saveCustomFieldValue(leadStatus, contactId, leadOwnerUserId);
    }

    // handles saving 'Lead Source' custom field
    if (!lead.getLead_source().isBlank()) {
      String leadSourceId = checkIfCustomFieldDropdownValueExists(520, lead.getLead_source());
      CustomFieldValue leadSource = new CustomFieldValue();

      if (leadSourceId.equalsIgnoreCase("null")) {
        params.put("listOfValueId", 520);
        params.put("customFieldDropdownValue", lead.getLead_source());
        leadSourceId = sqlCache.updateReturningId("contactLead.insertCustomFieldDropdownValue", params, "id").toString();
      }

      leadSource.setCustomFieldGroupAssignmentId(395L);
      leadSource.setIntValue(Long.parseLong(leadSourceId));
      saveCustomFieldValue(leadSource, contactId, leadOwnerUserId);
    }

    // handles saving 'Lead Source Detail' custom field
    if (!lead.getLead_source_detail().isBlank()) {
      String leadSourceDetailId = checkIfCustomFieldDropdownValueExists(543, lead.getLead_source_detail());
      CustomFieldValue leadSourceDetail = new CustomFieldValue();

      if (leadSourceDetailId.equalsIgnoreCase("null")) {
        params.put("listOfValueId", 543);
        params.put("customFieldDropdownValue", lead.getLead_source_detail());
        leadSourceDetailId = sqlCache.updateReturningId("contactLead.insertCustomFieldDropdownValue", params, "id").toString();
      }

      leadSourceDetail.setCustomFieldGroupAssignmentId(396L);
      leadSourceDetail.setIntValue(Long.parseLong(leadSourceDetailId));
      saveCustomFieldValue(leadSourceDetail, contactId, leadOwnerUserId);
    }

    // handles saving 'Hubspot ID' custom field
    CustomFieldValue hubspotId = new CustomFieldValue();
    hubspotId.setCustomFieldGroupAssignmentId(397L);

    if (lead.getHubspot_id() != null) {
      hubspotId.setTextValue(lead.getHubspot_id().toString());
    } else {
      hubspotId.setTextValue(null);
    }

    saveCustomFieldValue(hubspotId, contactId, leadOwnerUserId);
  }

  private void postToRicochet(RicochetLead lead, HashMap<String, Object> params) throws Exception {
    // Not needed for non-Ricochet leads
    lead.setHubspot_id(null);
    lead.setStatus("New");
    lead.setLeadOwner(null);

    if (lead.getLead_source() == null) {
      lead.setLead_source("Organic");
    }

    if (lead.getLead_source_detail() == null) {
      lead.setLead_source_detail("DigitalOrganic");
    }

    RicochetLead.Customer customer = new RicochetLead.Customer();
    customer.setFirstName(params.containsKey("firstName") ? (String) params.get("firstName") : null);
    customer.setLastName(params.containsKey("lastName") ? (String) params.get("lastName") : null);
    customer.setPhone1(params.containsKey("phone") ? (String) params.get("phone") : null);
    customer.setEmail(params.containsKey("email") ? (String) params.get("email") : null);

    RicochetLead.Address address = new RicochetLead.Address();
    address.setZip(params.containsKey("postalCode") ? (String) params.get("postalCode") : null);
    address.setState(params.containsKey("state") ? (String) params.get("state") : null);
    address.setAddress1(params.containsKey("street1") ? (String) params.get("street1") : null);
    address.setCity(params.containsKey("city") ? (String) params.get("city") : null);

    customer.setAddress(address);
    lead.setCustomer(customer);

    // handles sending lead information to Ricochet
    hubspotWebhookService.postLeadToRicochet(lead);
  }
}
