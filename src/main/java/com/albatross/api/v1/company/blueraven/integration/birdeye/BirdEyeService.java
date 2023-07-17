package com.albatross.api.v1.company.blueraven.integration.birdeye;

import com.albatross.api.config.company.blueraven.BirdEyeProperties;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.integration.birdeye.models.*;
import com.albatross.api.v1.flow.model.User;
import lombok.NonNull;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.RandomStringUtils;
import org.json.JSONObject;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
public class BirdEyeService {
  private final SecurityService securityService;
  private final SqlCache sqlCache;
  private final BirdEyeProperties birdeyeProperties;
  private final BirdEyeApi birdeyeApi;

  public BirdEyeService(SecurityService securityService, SqlCache sqlCache, BirdEyeProperties birdeyeProperties) {
    this.securityService = securityService;
    this.sqlCache = sqlCache;
    this.birdeyeProperties = birdeyeProperties;
    this.birdeyeApi = BirdEyeApi.connect(birdeyeProperties.getKey());
  }

  public void saveCfgaValue(@NonNull Long projectId) {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = Map.of("projectId", projectId, "userId", currentUser.trueUserId());
    sqlCache.queryBySql(BirdEyeQuery.saveReviewInviteSentValue, params, String.class);
  }

  public BirdEyeSurvey getSurvey(@NonNull String surveyId, @NonNull String businessNumber) {
    return this.birdeyeApi.getSurvey(surveyId, businessNumber);
  }

  public BirdEyeSurveyResponseWrapper getSurveyResponses(String surveyId, String businessNumber, OffsetDateTime lastSyncDate, int pageSize, int page) {

    final BirdeyeListSurveyRequest request = BirdeyeListSurveyRequest.builder()
      .startDate(lastSyncDate)
      .build();

    return this.birdeyeApi.getSurveyResponses(
      surveyId,
      businessNumber,
      request,
      BirdEyeListPageable.builder()
        .size(pageSize)
        .page(page)
        .build());
  }

  public List<BirdEyeReview> getReviews(String businessId, LocalDate startDate, LocalDate endDate) {
    try {
      final BirdEyeReviewRequest request = BirdEyeReviewRequest.builder()
        .fromDate(startDate) //inclusive
        .toDate(endDate) //exclusive
        .fetchExtraParams(true)
        .needCustomerInfo(true)
        .status(BirdEyeReviewStatus.all)
        .build();

      return birdeyeApi.getReviewsByBusinessId(businessId, request)
        .stream()
        .filter(review -> StringUtils.hasText(review.getCustomerId()))
        .toList();
    } catch (Exception e) {
      log.error("[BIRDEYE] BirdEye unable to fetch reviews for businessId={}, error={}", businessId, e.getMessage());
      throw new RuntimeException("BirdEye unable to fetch reviews at this time.");
    }
  }

  public BirdEyeReviewInvitation sendCheckIn(BirdEyeReviewInvitation invitation) {
    try {

      final BirdEyeOrgInfo orgInfo = getOrgInfo(invitation.getProjectId());

      invitation.setRequestersEmails(List.of(orgInfo.getOrgEmail()));

      // in some places this is already set but if we don't have one try to associate it by the installation resource
      if (invitation.getBirdeyeBusinessId() == null) {
        String birdeyeBusinessId = orgInfo.getBirdeyeBusinessId();
        if (!StringUtils.hasText(birdeyeBusinessId)) {
          throw new RuntimeException("BirdEye Business ID not found for projectId=" + invitation.getProjectId());
        }
        invitation.setBirdeyeBusinessId(birdeyeBusinessId);
      }

      int invitationId = saveCheckIn(invitation);

      final BirdEyeCustomerCheckinRequest.BirdEyeCustomerCheckinRequestBuilder request = BirdEyeCustomerCheckinRequest.builder()
        .name(invitation.getCustomerName())
        .employees(invitation.getRequestersEmails().stream().map(BirdEyeEmployee::new).toList());

      //set params from invitation
      if (invitation.getAdditionalParams() != null) {
        invitation.getAdditionalParams().forEach(request::additionalParam);
      }

      if (invitation.getSendSms() != null && invitation.getSendSms()) {
        String phone = birdeyeProperties.getServerDomain().equals(Domain.PROD) ? invitation.getCustomerPhone() : birdeyeProperties.getTestPhone();
        request.smsEnabled(1).phone(phone);
      } else {
        String email = birdeyeProperties.getServerDomain().equals(Domain.PROD) ? invitation.getCustomerEmail() : birdeyeProperties.getTestEmail();
        request.smsEnabled(0).emailId(email);
      }

      if (birdeyeProperties.getSendInvitesForReal()) {
        log.debug("[BIRDEYE] Sending review invitation to customer on projectId={}", invitation.getProjectId());
        final Optional<BirdEyeCustomerCheckin> customerCheckIn = birdeyeApi.createCustomerCheckIn(invitation.getBirdeyeBusinessId(), request.build());
        customerCheckIn.ifPresent(customerId -> invitation.setBirdeyeCustomerId(customerId.getCustomerId()));
        saveBirdEyeCustomerId(invitationId, invitation.getBirdeyeCustomerId());
      } else {
        log.info(
          "[BIRDEYE] *Not* sending review invitation to customer on projectId={}; generating random BirdEye customerId for testing.",
          invitation.getProjectId());
        invitation.setBirdeyeCustomerId(RandomStringUtils.randomAlphanumeric(16));
      }

      return invitation;

    } catch (Exception e) {
      log.error("[BIRDEYE] Problem sending BirdEye review invitation for projectId={}, error={}", invitation.getProjectId(), e.getMessage());
      throw new RuntimeException("Problem sending BirdEye review invitation: " + e.getMessage());
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
    return sqlCache.updateBySqlReturningId(BirdEyeQuery.saveInvitation, params, "id").intValue();
  }

  private BirdEyeOrgInfo getOrgInfo(@NonNull Long projectId) {
    Map<String, Object> params = Map.of("projectId", projectId);

    BirdEyeOrgInfo fallbackInfo = new BirdEyeOrgInfo();
    fallbackInfo.setOrgEmail("support@blueravensolar.com");
    fallbackInfo.setBirdeyeBusinessId(birdeyeProperties.getFallbackBusinessId());

    BirdEyeOrgInfo orgInfo = sqlCache.getBySql(BirdEyeQuery.getOrgInfo, params, new BeanPropertyRowMapper<>(BirdEyeOrgInfo.class))
      .orElse(fallbackInfo);

    if (orgInfo.getOrgEmail() == null){
      orgInfo.setOrgEmail("support@blueravensolar.com");
    }

    if (orgInfo.getBirdeyeBusinessId() == null){
      orgInfo.setBirdeyeBusinessId(birdeyeProperties.getFallbackBusinessId());
    }

    return orgInfo;
  }

  private void saveBirdEyeCustomerId(int invitationId, String custId) {
    Map<String, Object> params =
      Map.of(
        "id", invitationId,
        "custId", custId);
    sqlCache.updateBySql(BirdEyeQuery.addCustomerId, params);
  }

  /**
   * Retrieves the most current invitation associated to the customer
   *
   * @param customerId
   * @param customerPhone
   * @param businessNumber
   * @return
   */
  public BirdEyeReviewInvitation getInviteByCustomerId(String customerId, String customerPhone, String businessNumber) {
    return sqlCache.getBySql(BirdEyeQuery.getProjectByCustomer, Map.of("customerId", customerId), BirdEyeReviewInvitation.class)
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
}
