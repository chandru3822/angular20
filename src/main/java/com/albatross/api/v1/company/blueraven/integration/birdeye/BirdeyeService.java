package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.config.company.blueraven.BirdeyeProperties;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.BirdeyeQuery;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import lombok.Getter;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.json.JSONObject;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
public class BirdeyeService {

  private static final String BIRD_EYE_FIELD_TYPE_ID = "Type";
  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final BirdeyeProperties birdeyeProperties;
  private final CustomFieldGroupService customFieldGroupService;
  private final CustomFieldValueService customFieldValueService;
  private final BirdEyeApi birdeyeApi;

  public BirdeyeService(SecurityService securityService, SqlCache sqlCache, BirdeyeProperties birdeyeProperties, CustomFieldGroupService customFieldGroupService, CustomFieldValueService customFieldValueService) {
    this.securityService = securityService;
    this.sqlCache = sqlCache;
    this.birdeyeProperties = birdeyeProperties;
    this.customFieldGroupService = customFieldGroupService;
    this.customFieldValueService = customFieldValueService;

    this.birdeyeApi = BirdEyeApi.connect(birdeyeProperties.getKey());
  }

  public List<BirdEyeApi.BirdEyeLocation> getLocations() {
    try {
      return birdeyeApi.getChildBusinesses(birdeyeProperties.getToplevelBusinessId())
        .stream()
        .filter(l -> l.getStatus().equalsIgnoreCase("active"))
        .toList();
    } catch (Exception e) {
      log.error("BIRDEYE: Birdeye unavailable, error={}", e.getMessage());
      throw new RuntimeException("Birdeye unavailable at this time.");
    }
  }

  public void saveCfgaValue(@NonNull Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("projectId", projectId, "userId", currentUser.trueUserId());
    sqlCache.queryBySql(BirdeyeQuery.saveReviewInviteSentValue, params, String.class);
  }

  public List<BirdEyeApi.BirdEyeReview> getReviews(LocalDate reviewedStart) {
    try {
      final BirdEyeApi.BirdEyeReviewRequest request = BirdEyeApi.BirdEyeReviewRequest.builder()
        .fromDate(reviewedStart)
        .build();

      return birdeyeApi.getReviewsByBusinessId(birdeyeProperties.getToplevelBusinessId(), request)
        .stream()
        .filter(review -> StringUtils.hasText(review.getCustomerId()))
        .toList();
    } catch (Exception e) {
      log.error("[BIRDEYE] Birdeye unavailable, error={}", e.getMessage());
      throw new RuntimeException("BirdEye unavailable at this time.");
    }
  }

  public BirdEyeReviewInvitation sendCheckIn(BirdEyeReviewInvitation invitation, BirdEyeCheckInType checkInType) {
    try {

      final List<String> requesterEmails = getRequestEmail(invitation.getProjectId());
      final String businessId = getBusinessId(invitation.getProjectId());

      invitation.setBirdeyeBusinessId(businessId);
      invitation.setRequestersEmails(requesterEmails);
      invitation.setAdditionalParams(Map.of(BIRD_EYE_FIELD_TYPE_ID, checkInType.getValue()));

      int invitationId = saveCheckIn(invitation);

      final BirdEyeApi.BirdEyeCustomerCheckinRequest.BirdEyeCustomerCheckinRequestBuilder request = BirdEyeApi.BirdEyeCustomerCheckinRequest.builder()
        .name(invitation.getCustomerName())
        .employees(invitation.getRequestersEmails().stream().map(BirdEyeApi.BirdEyeEmployee::new).toList())
        .additionalParam(BIRD_EYE_FIELD_TYPE_ID, checkInType.getValue());

      if (invitation.getSendSms() != null && invitation.getSendSms()) {
        String phone = birdeyeProperties.getServerDomain().equals(Domain.PROD) ? invitation.getCustomerPhone() : birdeyeProperties.getTestPhone();
        request.smsEnabled(1).phone(phone);
      } else {
        String email = birdeyeProperties.getServerDomain().equals(Domain.PROD) ? invitation.getCustomerEmail() : birdeyeProperties.getTestEmail();
        request.smsEnabled(0).emailId(email);
      }

//      TODO: handle and save any errors
      if (birdeyeProperties.getSendInvitesForReal()) {
        log.debug("[BIRDEYE] Sending review invitation to customer on project {}", invitation.getProjectId());
        final Optional<BirdEyeApi.BirdEyeCustomerCheckin> customerCheckIn = birdeyeApi.createCustomerCheckIn(invitation.getBirdeyeBusinessId(), request.build());
        customerCheckIn.ifPresent(customerId -> invitation.setBirdeyeCustomerId(customerId.getCustomerId()));
        saveBirdEyeCustomerId(invitationId, invitation.getBirdeyeCustomerId());

      } else {
        log.info(
          "[BIRDEYE] *Not* sending review invitation to customer on project {}; generating random Birdeye customerId for testing.",
          invitation.getProjectId());
        invitation.setBirdeyeCustomerId(RandomStringUtils.randomAlphanumeric(16));
      }

      return invitation;

    } catch (Exception e) {
      log.error("[BIRDEYE] Problem sending Birdeye review invitation, error={}", e.getMessage());
      throw new RuntimeException("Problem sending Birdeye review invitation: " + e.getMessage());
    }
  }

  private int saveCheckIn(BirdEyeReviewInvitation invitation) {
    String json = new JSONObject(invitation).toString();
    Map<String, Object> params =
      Map.of(
        "projectId", invitation.getProjectId(),
        "birdeyeBusinessId", invitation.getBirdeyeBusinessId(),
        "dateSent", OffsetDateTime.now(ZoneOffset.UTC),
        "rawInvitation", json);
    return sqlCache.updateBySqlReturningId(BirdeyeQuery.saveInvitation, params, "id").intValue();
  }

  private List<String> getRequestEmail(Long projectId) {
    Optional<String> email =
      sqlCache.getBySql(BirdeyeQuery.getEmail, Map.of("projectId", projectId), new SingleColumnRowMapper<>(String.class));
    return email.map(List::of).orElseGet(() -> List.of("support@blueravensolar.com"));
  }

  private String getBusinessId(Long projectId) {
    return sqlCache.getBySql(
        BirdeyeQuery.getBusinessId, Map.of("projectId", projectId),
        new SingleColumnRowMapper<>(String.class))
      .orElseThrow(() -> new RuntimeException("No Birdeye Business ID found for projectId=" + projectId));
  }

  private void saveBirdEyeCustomerId(int invitationId, String custId) {
    Map<String, Object> params =
      Map.of(
        "id", invitationId,
        "custId", custId);
    sqlCache.updateBySql(BirdeyeQuery.addCustomerId, params);
  }

  private OffsetDateTime getLastSyncDate(String businessNumber, String surveyId) {
    final List<OffsetDateTime> query = sqlCache.queryBySql(BirdeyeQuery.getLastSync, Map.of(
      "businessId", businessNumber,
      "surveyId", surveyId
    ), (rs, rowNum) -> {
      final Timestamp timestamp = rs.getTimestamp(1);
      return timestamp != null ? OffsetDateTime.ofInstant(timestamp.toInstant(), ZoneId.of("UTC")) : null;
    });
    return query.isEmpty() ? null : query.get(0);
  }

  private void setLastSyncDate(String businessNumber, String surveyId, OffsetDateTime lastSyncDate) {
    sqlCache.updateBySql(BirdeyeQuery.setLastSync, Map.of(
      "businessId", businessNumber,
      "surveyId", surveyId,
      "lastSync", lastSyncDate
    ));
  }

  public void syncSurveyResponses() {
    final String businessNumber = birdeyeProperties.getToplevelBusinessId();
    final String surveyId = birdeyeProperties.getSurveyId();
    final OffsetDateTime lastSyncDate = getLastSyncDate(businessNumber, surveyId);

    syncSurveyResponses(surveyId, businessNumber, lastSyncDate);

    setLastSyncDate(businessNumber, surveyId, OffsetDateTime.now(ZoneId.of("UTC")));
  }

  //quick and dirty implementation based on given timeline... we probably need to implement a proper queue or something for these
  private void syncSurveyResponses(String surveyId, String businessNumber, OffsetDateTime lastSyncDate) {

    final BirdEyeApi.BirdEyeSurvey survey = this.birdeyeApi.getSurvey(surveyId, businessNumber);

    // create a map based on the text of the question since we don't have any other way to tie it back
    final Map<String, BirdEyeApi.BirdEyeSurveyPageQuestion> questions = survey.getPages().stream()
      .filter(p -> !p.getQuestions().isEmpty())
      .flatMap(p -> p.getQuestions().stream())
      .collect(Collectors.toMap(BirdEyeApi.BirdEyeSurveyPageQuestion::getTitle, b -> b));

    final Long installationSurveyGroupId = birdeyeProperties.getSurveyGroupId();
    final Map<String, CustomField> customFields = customFieldGroupService.getCustomFieldsInGroup(installationSurveyGroupId)
      .stream()
      .collect(Collectors.toMap(CustomField::getFieldName, cf -> cf));

    boolean hasMoreSurveys = true;
    int pageSize = 25;
    int page = 0;

    while (hasMoreSurveys) {

      try {

        final BirdEyeApi.BirdeyeListSurveyRequest request = BirdEyeApi.BirdeyeListSurveyRequest.builder()
          .startDate(lastSyncDate)
          .build();

        final BirdEyeApi.BirdEyeSurveyResponseWrapper wrapper = this.birdeyeApi.getSurveyResponses(
          surveyId,
          businessNumber,
          request,
          BirdEyeApi.BirdEyeListPageable.builder()
            .size(pageSize)
            .page(page)
            .build());

        if (wrapper.getResponseList() != null && !wrapper.getResponseList().isEmpty()) {
          for (BirdEyeApi.BirdEyeSurveyResponse surveyResponse : wrapper.getResponseList()) {
            handleSurveyResponse(surveyResponse, businessNumber, questions, customFields);
          }
        }

        //get all those surveys
        page++;
        hasMoreSurveys = wrapper.getHasNext();

      } catch (Exception e) {
        log.error("[BIRDEYE] Error while syncing survey responses, error={}", e.getMessage());
      }
    }
  }

  private void handleSurveyResponse(BirdEyeApi.BirdEyeSurveyResponse response, String businessNumber, Map<String, BirdEyeApi.BirdEyeSurveyPageQuestion> questions, Map<String, CustomField> customFields) {

    try {
      //can we match this back up to a project?
      final BirdEyeReviewInvitation invitation = getInviteByCustomerId(response.getCustomerId())
        //if not, try to get the customer data from BirdEye
        .orElseGet(() -> {
          BirdEyeApi.BirdEyeCustomer customer = this.birdeyeApi.getCustomer(businessNumber, BirdEyeApi.BirdEyeCustomerGetRequest.builder()
            .phone(response.getCustomerPhone())
            .build());

          if (customer == null) {
            return null;
          }

          String fieldID = "Project ID";
          return customer.getCustomFields().stream()
            .filter(cf -> cf.getFieldName().equals(fieldID))
            .findFirst()
            .map(birdEyeCustomField ->
              new BirdEyeReviewInvitation(null,
                customer.getFirstName() + " " + customer.getLastName(),
                customer.getEmail(),
                customer.getPhone(),
                customer.getId(),
                businessNumber,
                customer.getId(),
                Long.valueOf(birdEyeCustomField.getFieldValue()),
                customer.getPhone() != null,
                false,
                List.of(),
                Map.of()))
            .orElse(null);
        });

      if (invitation != null) {

        for (BirdEyeApi.BirdEyeSurveyResponseAnswer answer : response.getAnswers()) {

          //names must match exactly
          final CustomField customField = customFields.getOrDefault(answer.getQuestionTitle(), null);
          if (customField == null) {
            log.debug("[BIRDEYE] Unable to match '{}' to a custom field", answer.getQuestionTitle());
            continue;
          }

          final CustomFieldValue cfv = new CustomFieldValue();
          cfv.setCustomFieldGroupId(customField.getCustomFieldGroupId());
          cfv.setCustomFieldGroupAssignmentId(customField.getId());
          cfv.setCustomFieldId(customField.getCustomFieldId());
          cfv.setTextValue(answer.getAnswer());

          customFieldValueService.updateCustomFieldValues(List.of(cfv), invitation.getProjectId(), ObjectType.PROJECT);

          final BirdEyeApi.BirdEyeSurveyPageQuestion surveyQuestion = questions.getOrDefault(answer.getQuestionTitle(), null);

          //send out a review invite if the 1st question "Are you happy with your installation experience?" is "yes"
          if (surveyQuestion != null && surveyQuestion.getOrder().equals(0) &&
            answer.getAnswer() != null && answer.getAnswer().equalsIgnoreCase("yes")) {
            try {
              sendCheckIn(invitation, BirdEyeCheckInType.REVIEW);
            } catch (Exception e) {
              log.error("[BIRDEYE] Error sending review check in for surveyResponseId={}, customerId={}", response.getResponseId(), response.getCustomerId());
            }
          }
        }
      } else {
        log.error("[BIRDEYE] Unable to send BirdEye Review Invitation to customerId={}. Unable to find associated projectId", response.getCustomerId());
      }
    } catch (Exception e) {
      log.error("[BIRDEYE] Unable to handle BirdEye survey response, responseId={}, customerId={}, message={}", response.getResponseId(), response.getCustomerId(), e.getMessage());
    }
  }

  /**
   * Retrieves the most current invitation associated to the customer
   *
   * @param customerId
   * @return
   */
  private Optional<BirdEyeReviewInvitation> getInviteByCustomerId(String customerId) {
    return sqlCache.getBySql(BirdeyeQuery.getProjectByCustomer, Map.of("customerId", customerId), BirdEyeReviewInvitation.class);
  }

  @RequiredArgsConstructor
  public enum Domain {
    PROD("api.birdeye.com"),
    DEVO("private-anon-8e8990eaa7-birdeye.apiary-proxy.com"),
    MOCK("private-anon-8e8990eaa7-birdeye.apiary-mock.com");

    @Getter
    private final String host;
  }

}
