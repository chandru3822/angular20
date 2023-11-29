package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.config.company.blueraven.BirdEyeProperties;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.integration.birdeye.models.*;
import com.albatross.api.v1.flow.enums.ObjectType;
import com.albatross.api.v1.flow.model.CustomField;
import com.albatross.api.v1.flow.model.CustomFieldValue;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.services.CustomFieldGroupService;
import com.albatross.api.v1.flow.services.CustomFieldValueService;
import com.albatross.api.v1.flow.services.ListOfValueService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BirdEyeSyncService {

  private final ProjectProcessStepService projectProcessStepService;
  private final BirdEyeProperties birdeyeProperties;
  private final SqlCache sqlCache;
  private final BirdEyeService birdeyeService;
  private final CustomFieldGroupService customFieldGroupService;
  private final CustomFieldValueService customFieldValueService;
  private final ListOfValueService listOfValueService;

  public void syncSurveyResponses() {
    final String businessNumber = birdeyeProperties.getToplevelBusinessId();
    final List<BirdEyeSyncableSurvey> surveyIds = sqlCache.queryBySql(BirdEyeQuery.getSyncableSurveys, null, new BeanPropertyRowMapper<>(BirdEyeSyncableSurvey.class));

    for (BirdEyeSyncableSurvey survey : surveyIds) {
      final OffsetDateTime lastSyncDate = getLastSyncDate(businessNumber, BirdEyeSyncType.SURVEY, survey.getBirdeyeSurveyId());
      syncSurveyResponses(survey.getBirdeyeSurveyId(), survey.getCustomFieldGroupId(), businessNumber, lastSyncDate);
      setLastSyncDate(businessNumber, BirdEyeSyncType.SURVEY, survey.getBirdeyeSurveyId());
    }
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

    LocalDate reviewedStart = lastSyncDate != null ? lastSyncDate.toLocalDate() : LocalDate.now();
    List<BirdEyeReview> reviews = birdeyeService.getReviews(toplevelBusinessId, reviewedStart.minusDays(1), LocalDate.now());
    if (reviews == null || reviews.isEmpty()) {
      return;
    }

    //    Pull in list of values only once
    List<ListOfValue> reviewSites = listOfValueService.getByCustomFieldId(HOMEOWNER_REVIEW_SITE);
    List<ListOfValue> reviewScores = listOfValueService.getByCustomFieldId(HOMEOWNER_REVIEW_SCORE);

    reviews.stream()
      // only include reviews that have a customer id to match up in the database
      .filter(review -> review.getCustomerId() != null && !review.getCustomerId().trim().isEmpty())
      .forEach(r -> {

        BirdEyeReviewInvitation invitation = birdeyeService.getInviteByCustomerId(r.getCustomerId(), null, "");

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
              cfv.setDateValue(Timestamp.valueOf(r.getReviewDate().atStartOfDay(ZoneOffset.UTC).toLocalDateTime()));
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

  //quick and dirty implementation based on given timeline... we probably need to implement a proper queue or something for these
  private void syncSurveyResponses(String surveyId, Long customFieldGroupId, String businessNumber, OffsetDateTime lastSyncDate) {
    try {
      final BirdEyeSurvey survey = birdeyeService.getSurvey(surveyId, businessNumber);

      // create a map based on the text of the question since we don't have any other way to tie it back
      final Map<String, BirdEyeSurveyPageQuestion> questions = survey.getPages().stream()
        .filter(p -> !p.getQuestions().isEmpty())
        .flatMap(p -> p.getQuestions().stream())
        .filter(p -> !Boolean.TRUE.equals(p.getHidden()))
        .collect(Collectors.toMap(BirdEyeSurveyPageQuestion::getTitle, b -> b));

      final Map<String, CustomField> customFields = customFieldGroupService.getCustomFieldsInGroup(customFieldGroupId)
        .stream()
        .collect(Collectors.toMap(CustomField::getFieldName, cf -> cf));

      boolean hasMoreSurveys = true;
      int pageSize = 100;
      int page = 0;

      while (hasMoreSurveys) {

        final BirdEyeSurveyResponseWrapper wrapper = birdeyeService.getSurveyResponses(surveyId, businessNumber, lastSyncDate, pageSize, page);
        if (wrapper.getResponseList() != null && !wrapper.getResponseList().isEmpty()) {
          for (BirdEyeSurveyResponse surveyResponse : wrapper.getResponseList()) {
            //only send follow-up when the survey equals 29921
            // (TODO: need a better way to handle this)
            handleSurveyResponse(surveyResponse, businessNumber, questions, customFields, Objects.equals(surveyId, "29921"));
          }
        }

        //get all those surveys
        page++;
        //need to fix because the birdeye api is stupid and doesn't return "true" when there are clearly more response
        int currentPageEnd = (wrapper.getPageNo() * wrapper.getPageSize()) + wrapper.getPageSize();
        hasMoreSurveys = wrapper.getHasNext() || wrapper.getTotalResponses() > currentPageEnd;
      }
    } catch (Exception e) {
      log.error("[BIRDEYE] Error while syncing survey responses, error={}", e.getMessage());
    }
  }

  private OffsetDateTime getLastSyncDate(String businessNumber, BirdEyeSyncType syncType, String syncKey) {
    Map<String, Object> params = Map.of(
      "businessId", businessNumber,
      "syncKey", syncKey,
      "syncType", syncType.getType()
    );
    final List<OffsetDateTime> query = sqlCache.queryBySql(BirdEyeQuery.getLastSync, params, (rs, rowNum) -> {
      final Timestamp timestamp = rs.getTimestamp(1);
      return timestamp != null ? OffsetDateTime.ofInstant(timestamp.toInstant(), ZoneId.of("UTC")) : null;
    });
    return query.isEmpty() ? null : query.get(0);
  }

  private void setLastSyncDate(String businessNumber, BirdEyeSyncType type, String syncKey) {
    sqlCache.updateBySql(BirdEyeQuery.setLastSync, Map.of(
      "businessId", businessNumber,
      "syncKey", syncKey,
      "syncType", type.getType(),
      "lastSync", OffsetDateTime.now(ZoneId.of("UTC"))
    ));
  }

  private void handleSurveyResponse(BirdEyeSurveyResponse response, String businessNumber, Map<String, BirdEyeSurveyPageQuestion> questions, Map<String, CustomField> customFields, boolean sendFollowUp) {

    try {
      final BirdEyeReviewInvitation invitation = birdeyeService.getInviteByCustomerId(response.getCustomerId(), response.getCustomerPhone(), businessNumber);

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

          if (sendFollowUp) {
            final BirdEyeSurveyPageQuestion surveyQuestion = questions.getOrDefault(answer.getQuestionTitle(), null);
            //send out a review invite if the 1st question "Are you happy with your installation experience?" is "yes"
            if (surveyQuestion != null && surveyQuestion.getOrder().equals(0) &&
                answer.getAnswer() != null && answer.getAnswer().equalsIgnoreCase("yes")) {
              try {
                invitation.setAdditionalParams(Map.of(BirdEyeReviewInvitation.FIELD_TYPE_ID, BirdEyeCheckInType.REVIEW.getValue()));
                birdeyeService.sendCheckIn(invitation);
              } catch (Exception e) {
                log.error("[BIRDEYE] Error sending review check in for surveyResponseId={}, customerId={}", response.getResponseId(), response.getCustomerId());
              }
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
}
