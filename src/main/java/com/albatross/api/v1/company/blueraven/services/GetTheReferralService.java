package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.HttpResponse;
import com.albatross.api.utils.HttpUtils;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.GetTheReferralQuery;
import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.IOUtils;
import org.apache.http.client.utils.URIBuilder;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.ObjectUtils;

import java.io.InputStream;
import java.nio.charset.Charset;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class GetTheReferralService {

  @Value(value = "${getthereferral.api.host}")
  private String apiUrl;

  @Value(value = "${getthereferral.api.token}")
  private String accessToken;

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private static final String VERIFIED_STATUS_ID = "2";
  private static final String SOLD_STATUS_ID = "3";
  private static final String CLOSED_STATUS_ID = "4";
  private static final String WORKING_STATUS_ID = "5";

  // These values are stored in Albatross on the contact custom field GtR Lead Status
  private static Integer PROJECT_CREATED_GTR_STATUS = 1;
  private static Integer CONTACT_PITCHED_GTR_STATUS = 2;
  private static Integer SUBSTANTIALLY_COMPLETE_GTR_STATUS = 3;
  private static Integer PROJECT_COMPLETED_GTR_STATUS = 4;

  private static final Long REFERRAL_CFGA_ID = 996L;
  private static final Long GTR_ADVOCATE_ID_CFGA_ID = 27363L;
  private static final Long GTR_LEAD_STATUS_ID_CFGA_ID = 27364L;

  private static final String PROJECT_CONSULTATION_GTR_STATUS_ID = "1";
  private static final String QUALIFICATION_GTR_STATUS_ID = "2";
  private static final String DESIGN_GTR_STATUS_ID = "3";
  private static final String INSTALLATION_PREP_GTR_STATUS_ID = "4";
  private static final String INSTALLATION_GTR_STATUS_ID = "5";
  private static final String INSPECTION_GTR_STATUS_ID = "6";
  private static final String ENERGIZATION_GTR_STATUS_ID = "7";
  private static final String ENERGIZED_GTR_STATUS_ID = "8";

  private static final Long PROJECT_CONSULTATION_PROJECT_STATUS_TYPE_ID = 69L;
  private static final Long QUALIFICATION_PROJECT_STATUS_TYPE_ID = 63L;
  private static final Long DESIGN_PROJECT_STATUS_TYPE_ID = 64L;
  private static final Long INSTALLATION_PREP_PROJECT_STATUS_TYPE_ID = 65L;
  private static final Long INSTALLATION_PROJECT_STATUS_TYPE_ID = 66L;
  private static final Long INSPECTION_PROJECT_STATUS_TYPE_ID = 67L;
  private static final Long ENERGIZATION_PROJECT_STATUS_TYPE_ID = 218L;
  private static final Long ENERGIZED_PROJECT_STATUS_TYPE_ID = 68L;


  // Get any advocates from last day from GtR, find the contact ID that is associated with it
  // and store the GtR Advocate ID on the contact
  public void getAdvocates() {
    if (ObjectUtils.isEmpty(accessToken) || ObjectUtils.isEmpty(accessToken == null)) {
      return;
    }

    try {
      LocalDateTime date = LocalDateTime.now().minusDays(1);
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
      String formattedDate = date.format(dtf);

      URIBuilder b = new URIBuilder(apiUrl + "/advocates");
      b.addParameter("page_size", "250");
      b.addParameter("added_after", formattedDate);
      b.addParameter("page", "1");
      String url = b.build().toString().replaceAll("\\+", "%20");
      HttpResponse resp = GET(url, null);
      JSONObject respJSON = resp.getJSON();
      JSONObject pagination = respJSON.getJSONObject("pagination");
      final int LAST_PAGE = pagination.getInt("lastPage") + 1;
      // Paginate through the advocates
      for (int i = 1; i < LAST_PAGE; i++) {
        b.setParameter("page", String.valueOf(i));
        url = b.build().toString().replaceAll("\\+", "%20");
        resp = GET(url, null);
        respJSON = resp.getJSON();
        JSONArray advocates = respJSON.getJSONArray("advocates");
        for (int j = 0; j < advocates.length(); j++) {
          JSONObject advocate = advocates.getJSONObject(j);
          JSONObject advocateAttributes = advocate.getJSONObject("attributes");
          String email = advocateAttributes.getString("email");
          Long advocateId = advocateAttributes.getLong("advocate_id");

          HashMap<String, Object> params = new HashMap<>();
          params.put("email", email);
          // Contact ID of the referee
          Optional<Long> contactId =
            sqlCache.getBySql(
              GetTheReferralQuery.getContactIdByEmail,
              params,
              new SingleColumnRowMapper<>(Long.class));
          if (contactId.isPresent()) {
            updateContactCustomFieldValue(contactId.get(), GTR_ADVOCATE_ID_CFGA_ID, advocateId.toString(), null);
          }
        }
      }
    } catch (Exception e) {
      String msg = "GetTheReferral: Error getting advocates, msg=" +e.getMessage();
      log.error(msg);
    }
  }

  // Get any referee's from the last day from GtR, find the contact that referred them and update their Referrals
  public void getLeads() {
    if (ObjectUtils.isEmpty(accessToken) || ObjectUtils.isEmpty(accessToken == null)) {
      return;
    }

    try {
      LocalDateTime date = LocalDateTime.now().minusDays(1);
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
      String formattedDate = date.format(dtf);

      URIBuilder b = new URIBuilder(apiUrl + "/leads");
      b.addParameter("page_size", "250");
      b.addParameter("added_after", formattedDate);
      b.addParameter("page", "1");

      String url = b.build().toString().replaceAll("\\+", "%20");
      HttpResponse resp = GET(url, null);
      JSONObject respJSON = resp.getJSON();
      JSONObject pagination = respJSON.getJSONObject("pagination");
      final int LAST_PAGE = pagination.getInt("lastPage") + 1;
      // Paginate through the advocates
      for (int i = 1; i < LAST_PAGE; i++) {
        b.setParameter("page", String.valueOf(i));
        url = b.build().toString().replaceAll("\\+", "%20");
        resp = GET(url, null);
        respJSON = resp.getJSON();
        JSONArray leads = respJSON.getJSONArray("leads");
        for (int j = 0; j < leads.length(); j++) {
          JSONObject lead = leads.getJSONObject(j);
          JSONObject leadAttributes = lead.getJSONObject("attributes");
          Long advocateId = leadAttributes.getLong("advocate_id");

          HashMap<String, Object> params = new HashMap<>();
          params.put("advocateId", advocateId.toString());

          // Contact ID of the referee
          Optional<Long> refereeContactId =
            sqlCache.getBySql(
              GetTheReferralQuery.getContactIdByAdvocateId,
              params,
              new SingleColumnRowMapper<>(Long.class));

          if (refereeContactId.isPresent()) {
            params.put("contactId", refereeContactId.get());
            // Get any existing referrals from the Advocates contact
            Optional<String> existingReferrals =
              sqlCache.getBySql(
                GetTheReferralQuery.getContactReferralsByContactId,
                params,
                new SingleColumnRowMapper<>(String.class));
            String refValue = "";
            if (existingReferrals.isPresent() && !existingReferrals.get().isEmpty()) {
              // If the referral has already been added, skip adding it again
              if (existingReferrals.get().contains(refereeContactId.get().toString())) {
                continue;
              }

              refValue = existingReferrals.get() + ", " + refereeContactId.get();
            }
            else {
              refValue = refereeContactId.get().toString();
            }

            updateContactCustomFieldValue(refereeContactId.get(), REFERRAL_CFGA_ID, refValue, null);
          }
        }
      }
    } catch (Exception e) {
      String msg = "GetTheReferral: Error getting advocates, msg=" +e.getMessage();
      log.error(msg);
    }
  }

  public void updateAdvocateLeadStatuses() {
    try {
      updateAdvocatesLeadStatus(sqlCache.queryBySql(GetTheReferralQuery.getProjectCreatedMilestoneContacts, null,
        GetTheReferralProject.class), VERIFIED_STATUS_ID, PROJECT_CREATED_GTR_STATUS);
      updateAdvocatesLeadStatus(sqlCache.queryBySql(GetTheReferralQuery.getPitchedMilestoneContacts, null,
        GetTheReferralProject.class), WORKING_STATUS_ID, CONTACT_PITCHED_GTR_STATUS);
      updateAdvocatesLeadStatus(sqlCache.queryBySql(GetTheReferralQuery.getSubstantiallyCompleteMilestoneContacts, null,
        GetTheReferralProject.class), SOLD_STATUS_ID, SUBSTANTIALLY_COMPLETE_GTR_STATUS);
      updateAdvocatesLeadStatus(sqlCache.queryBySql(GetTheReferralQuery.getProjectCompleteMilestoneContacts, null,
        GetTheReferralProject.class), CLOSED_STATUS_ID, PROJECT_COMPLETED_GTR_STATUS);
    } catch (Exception e) {
      String msg = "GetTheReferral: Error updating advocate status, msg=" +e.getMessage();
      log.error(msg);
    }
  }

  private void updateAdvocatesLeadStatus(List<GetTheReferralProject> gtrContacts, String leadStatus, Integer albaGtRLeadStatus) {
    try {
      String url = apiUrl + "/advocates/updateProjectStage";
      for (GetTheReferralProject gtrContact: gtrContacts) {
        JSONObject body = new JSONObject();
        body.put("email", gtrContact.getContactEmail());
        body.put("stage", leadStatus);

        HttpResponse resp = POST(url, IOUtils.toInputStream(body.toString(), (Charset) null));
        JSONObject respJSON = resp.getJSON();
        if (respJSON.has("error")) {
          String msg = "GetTheReferral: Error updating advocate stage:" + respJSON.getString("error");
          log.error(msg);
        }
        else {
          updateContactCustomFieldValue(gtrContact.getContactId(), GTR_LEAD_STATUS_ID_CFGA_ID, null, albaGtRLeadStatus);
        }
      }
    } catch (Exception e) {
      String msg = "GetTheReferral: Error updating advocate stage, msg=" +e.getMessage();
      log.error(msg);
    }
  }

  public void updateAdvocateStatusInGtr() {
    try {
      List<GetTheReferralProject> projects = sqlCache.queryBySql(GetTheReferralQuery.getAdvocateProjectStatusUpdates, null, GetTheReferralProject.class);
      for (GetTheReferralProject project: projects) {
        JSONObject body = new JSONObject();
        body.put("email", project.getContactEmail());
        String leadStatus = getLeadStatus(project.getCompanyProjectStatusTypeId());
        // Only push the lead status for a subset of statuses
        if (!leadStatus.isEmpty()) {
          body.put("stage", "abc");//leadStatus);
          String url = apiUrl + "/advocates/updateProjectStage";
          HttpResponse resp = POST(url, IOUtils.toInputStream(body.toString(), (Charset) null));
          JSONObject respJSON = resp.getJSON();
          if (respJSON.has("error")) {
            String msg = "GetTheReferral: Error updating project stage in GtR: " + respJSON.getString("error");
            log.error(msg);
          }
        }
      }
    } catch (Exception e) {
      String msg = "GetTheReferral: Error updating project stage in GtR, msg=" +e.getMessage();
      log.error(msg);
    }
  }

  private String getLeadStatus(Long companyProjectStatusTypeId) {
    String leadStatus = "";
    if (companyProjectStatusTypeId == PROJECT_CONSULTATION_PROJECT_STATUS_TYPE_ID) {
      leadStatus = PROJECT_CONSULTATION_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == QUALIFICATION_PROJECT_STATUS_TYPE_ID) {
      leadStatus = QUALIFICATION_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == DESIGN_PROJECT_STATUS_TYPE_ID) {
      leadStatus = DESIGN_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == INSTALLATION_PREP_PROJECT_STATUS_TYPE_ID) {
      leadStatus = INSTALLATION_PREP_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == INSTALLATION_PROJECT_STATUS_TYPE_ID) {
      leadStatus = INSTALLATION_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == INSPECTION_PROJECT_STATUS_TYPE_ID) {
      leadStatus = INSPECTION_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == ENERGIZATION_PROJECT_STATUS_TYPE_ID) {
      leadStatus = ENERGIZATION_GTR_STATUS_ID;
    } else if (companyProjectStatusTypeId == ENERGIZED_PROJECT_STATUS_TYPE_ID) {
      leadStatus = ENERGIZED_GTR_STATUS_ID;
    }

    return leadStatus;
  }

  private void updateContactCustomFieldValue(Long contactId, Long cfgaId, String textValue, Integer intValue) {
    User currentUser = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("dateValue", null);
    params.put("timestampValue", null);
    params.put("booleanValue", null);
    params.put("textValue", textValue);
    params.put("numericValue", null);
    params.put("richTextValue", null);
    params.put("intValue", intValue);
    params.put("intArrayValue", null);
    params.put("customFieldGroupAssignmentId", cfgaId);
    params.put("contactId", contactId);
    params.put("userId", currentUser.trueUserId());
    sqlCache.updateBySql(GetTheReferralQuery.upsertCustomFieldValue, params);
  }

  private HttpResponse request(String method, String url, InputStream content) throws Exception {
    log.debug("GtR: sending to GtR url: {}", url);
    Map<String, String> headers = new HashMap<>();
    headers.put("Authorization", "Bearer %s".formatted(accessToken));
    headers.put("Content-Type", "application/json");
    return HttpUtils.call(method, url, headers, content);
  }

  private HttpResponse POST(String url, InputStream content) throws Exception {
    return request("POST", url, content);
  }

  private HttpResponse GET(String url, InputStream content) throws Exception {
    return request("GET", url, content);
  }

  @Data
  private static class GetTheReferralProject {
    private Long contactId, companyProjectStatusTypeId;
    private String contactEmail;
  }
}
