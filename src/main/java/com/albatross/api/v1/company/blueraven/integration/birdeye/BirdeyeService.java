package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.config.company.blueraven.BirdeyeProperties;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.integration.birdeye.models.*;
import com.albatross.api.v1.company.blueraven.services.queries.BirdeyeQuery;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ListOfValueService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
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
  private final ProjectProcessStepService projectProcessStepService;
  private final ListOfValueService listOfValueService;
  private final BirdEyeApi birdeyeApi;

  public BirdeyeService(SecurityService securityService, SqlCache sqlCache, BirdeyeProperties birdeyeProperties, CustomFieldGroupService customFieldGroupService, CustomFieldValueService customFieldValueService, ListOfValueService listOfValueService, ProjectProcessStepService projectProcessStepService) {
    this.securityService = securityService;
    this.sqlCache = sqlCache;
    this.birdeyeProperties = birdeyeProperties;
    this.customFieldGroupService = customFieldGroupService;
    this.customFieldValueService = customFieldValueService;
    this.listOfValueService = listOfValueService;
    this.projectProcessStepService = projectProcessStepService;

    this.birdeyeApi = BirdEyeApi.connect(birdeyeProperties.getKey());
  }

  public List<BirdEyeLocation> getLocations() {
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

  public void syncReviews() {
    String toplevelBusinessId = birdeyeProperties.getToplevelBusinessId();
    OffsetDateTime lastSyncDate = getLastSyncDate(toplevelBusinessId, BirdEyeSyncType.REVIEW, "review-sync");

    Long HOMEOWNER_PROCESS_STEP_ID = 3421L;

    Long HOMEOWNER_GROUP_ID = 6754L;

    Long HOMEOWNER_REVIEW_SITE = 11122L;
    Long HOMEOWNER_REVIEW_DATE = 122L;
    Long HOMEOWNER_REVIEW_SCORE = 123L;
    Long HOMEOWNER_REVIEW_TEXT = 11123L;

    //better way to do this?
    List<Long> REVIEW_CF_IDS = List.of(HOMEOWNER_REVIEW_SITE, HOMEOWNER_REVIEW_DATE, HOMEOWNER_REVIEW_SCORE, HOMEOWNER_REVIEW_TEXT);

    List<CustomField> customFieldsInGroup = customFieldGroupService.getCustomFieldsInGroup(HOMEOWNER_GROUP_ID)
      .stream()
      .filter(cf -> REVIEW_CF_IDS.contains(cf.getCustomFieldId()))
      .toList();

    List<BirdEyeReview> reviews = getReviews(toplevelBusinessId, lastSyncDate != null ? lastSyncDate.toLocalDate() : LocalDate.now());
    if (reviews == null || reviews.isEmpty()) {
      return;
    }

    //    Pull in list of values only once
    List<ListOfValue> reviewSites = listOfValueService.getByCustomFieldId(HOMEOWNER_REVIEW_SITE);
    List<ListOfValue> reviewScores = listOfValueService.getByCustomFieldId(HOMEOWNER_REVIEW_SCORE);

    reviews.stream()
      // only include reviews that have a customer id to match up in the database
      .filter(review -> review.getCustomerId() != null && review.getCustomerId().trim().length() > 0)
      .forEach(r -> {

        BirdEyeReviewInvitation invitation = getInviteByCustomerId(r.getCustomerId(), null, "");

        //we should *hopefully* have a match at this point
        if (invitation == null) {
          return;
        }

        List<CustomFieldValue> customFieldValues = customFieldsInGroup.stream()
          .map(cf -> {

            final CustomFieldValue cfv = new CustomFieldValue();
            cfv.setCustomFieldGroupAssignmentId(cf.getId());
            cfv.setCustomFieldGroupId(cf.getCustomFieldGroupId());
            cfv.setCustomFieldId(cf.getCustomFieldId());

            if (HOMEOWNER_REVIEW_SITE.equals(cf.getCustomFieldId())) {
              reviewSites.stream()
                .filter(l -> l.getName().equalsIgnoreCase(r.getSourceType()))
                .findFirst()
                .ifPresent(lov -> cfv.setIntValue(lov.getId()));
            } else if (HOMEOWNER_REVIEW_SCORE.equals(cf.getCustomFieldId())) {
              reviewScores.stream()
                .filter(l -> l.getName().equalsIgnoreCase(r.getRating().toString()))
                .findFirst()
                .ifPresent(lov -> cfv.setIntValue(lov.getId()));
            } else if (HOMEOWNER_REVIEW_DATE.equals(cf.getCustomFieldId())) {
              cfv.setDateValue(Timestamp.valueOf(r.getResponseDate().atStartOfDay(ZoneOffset.UTC).toLocalDateTime()));
            } else if (HOMEOWNER_REVIEW_TEXT.equals(cf.getCustomFieldId())) {
              cfv.setTextValue(r.getComments());
            }

            return cfv;
          }).toList();

        Long projectProcessStepId = projectProcessStepService.insertProjectProcessStep(invitation.getProjectId(), HOMEOWNER_PROCESS_STEP_ID, null, null, false, 1L, 3L);
        customFieldValueService.updateCustomFieldValues(customFieldValues, projectProcessStepId, ObjectType.PROCESS_STEP);
      });

    setLastSyncDate(toplevelBusinessId, BirdEyeSyncType.REVIEW, "review-sync");
  }

  private List<BirdEyeReview> getReviews(String businessId, LocalDate reviewedStart) {
    try {
      final BirdEyeReviewRequest request = BirdEyeReviewRequest.builder()
        .fromDate(reviewedStart)
        .build();

      return birdeyeApi.getReviewsByBusinessId(businessId, request)
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

      // in some places this is already set but if we don't have one try to associate it by the installation resource
      if (invitation.getBirdeyeBusinessId() == null) {
        final String businessId = getBusinessId(invitation.getProjectId());
        invitation.setBirdeyeBusinessId(businessId);
      }

      invitation.setRequestersEmails(requesterEmails);
      invitation.setAdditionalParams(Map.of(BIRD_EYE_FIELD_TYPE_ID, checkInType.getValue()));

      int invitationId = saveCheckIn(invitation);

      final BirdEyeCustomerCheckinRequest.BirdEyeCustomerCheckinRequestBuilder request = BirdEyeCustomerCheckinRequest.builder()
        .name(invitation.getCustomerName())
        .employees(invitation.getRequestersEmails().stream().map(BirdEyeEmployee::new).toList())
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
        final Optional<BirdEyeCustomerCheckin> customerCheckIn = birdeyeApi.createCustomerCheckIn(invitation.getBirdeyeBusinessId(), request.build());
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

  private OffsetDateTime getLastSyncDate(String businessNumber, BirdEyeSyncType syncType, String syncKey) {
    final List<OffsetDateTime> query = sqlCache.queryBySql(BirdeyeQuery.getLastSync, Map.of(
      "businessId", businessNumber,
      "syncKey", syncKey,
      "syncType", syncType.getType()
    ), (rs, rowNum) -> {
      final Timestamp timestamp = rs.getTimestamp(1);
      return timestamp != null ? OffsetDateTime.ofInstant(timestamp.toInstant(), ZoneId.of("UTC")) : null;
    });
    return query.isEmpty() ? null : query.get(0);
  }

  private void setLastSyncDate(String businessNumber, BirdEyeSyncType type, String syncKey) {
    sqlCache.updateBySql(BirdeyeQuery.setLastSync, Map.of(
      "businessId", businessNumber,
      "syncKey", syncKey,
      "syncType", type.getType(),
      "lastSync", OffsetDateTime.now(ZoneId.of("UTC"))
    ));
  }

  public void syncSurveyResponses() {
    final String businessNumber = birdeyeProperties.getToplevelBusinessId();
    final String surveyId = birdeyeProperties.getSurveyId();
    final OffsetDateTime lastSyncDate = getLastSyncDate(businessNumber, BirdEyeSyncType.SURVEY, surveyId);

    syncSurveyResponses(surveyId, businessNumber, lastSyncDate);

    setLastSyncDate(businessNumber, BirdEyeSyncType.SURVEY, surveyId);
  }

  //quick and dirty implementation based on given timeline... we probably need to implement a proper queue or something for these
  private void syncSurveyResponses(String surveyId, String businessNumber, OffsetDateTime lastSyncDate) {

    final BirdEyeSurvey survey = this.birdeyeApi.getSurvey(surveyId, businessNumber);

    // create a map based on the text of the question since we don't have any other way to tie it back
    final Map<String, BirdEyeSurveyPageQuestion> questions = survey.getPages().stream()
      .filter(p -> !p.getQuestions().isEmpty())
      .flatMap(p -> p.getQuestions().stream())
      .collect(Collectors.toMap(BirdEyeSurveyPageQuestion::getTitle, b -> b));

    final Long installationSurveyGroupId = birdeyeProperties.getSurveyGroupId();
    final Map<String, CustomField> customFields = customFieldGroupService.getCustomFieldsInGroup(installationSurveyGroupId)
      .stream()
      .collect(Collectors.toMap(CustomField::getFieldName, cf -> cf));

    boolean hasMoreSurveys = true;
    int pageSize = 25;
    int page = 0;

    while (hasMoreSurveys) {

      try {

        final BirdeyeListSurveyRequest request = BirdeyeListSurveyRequest.builder()
          .startDate(lastSyncDate)
          .build();

        final BirdEyeSurveyResponseWrapper wrapper = this.birdeyeApi.getSurveyResponses(
          surveyId,
          businessNumber,
          request,
          BirdEyeListPageable.builder()
            .size(pageSize)
            .page(page)
            .build());

        if (wrapper.getResponseList() != null && !wrapper.getResponseList().isEmpty()) {
          for (BirdEyeSurveyResponse surveyResponse : wrapper.getResponseList()) {
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

  private void handleSurveyResponse(BirdEyeSurveyResponse response, String businessNumber, Map<String, BirdEyeSurveyPageQuestion> questions, Map<String, CustomField> customFields) {

    try {
      final BirdEyeReviewInvitation invitation = getInviteByCustomerId(response.getCustomerId(), response.getCustomerPhone(), businessNumber);

      //can we match this back up to a project?
      if (invitation != null) {

        for (BirdEyeSurveyResponseAnswer answer : response.getAnswers()) {

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

          final BirdEyeSurveyPageQuestion surveyQuestion = questions.getOrDefault(answer.getQuestionTitle(), null);

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
   * @param customerPhone
   * @param businessNumber
   * @return
   */
  private BirdEyeReviewInvitation getInviteByCustomerId(String customerId, String customerPhone, String businessNumber) {
    return sqlCache.getBySql(BirdeyeQuery.getProjectByCustomer, Map.of("customerId", customerId), BirdEyeReviewInvitation.class)
      .orElseGet(() -> {

        if (customerPhone == null || customerPhone.trim().isEmpty()) {
          return null;
        }

        BirdEyeCustomer customer = this.birdeyeApi.getCustomer(businessNumber, BirdEyeCustomerGetRequest.builder()
          .phone(customerPhone)
          .build());

        if (customer == null) {
          return null;
        }

        String customerBusinessNumber = customer.getMappings().stream()
          .findFirst()
          .map(BirdEyeContactMapping::getBusinessNumber)
          .orElse(businessNumber);

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
              customerBusinessNumber,
              customer.getId(),
              Long.valueOf(birdEyeCustomField.getFieldValue()),
              customer.getPhone() != null,
              false,
              List.of(),
              Map.of()))
          .orElse(null);
      });
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
