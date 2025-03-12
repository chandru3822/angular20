package com.albatross.api.v1.company.blueraven.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.services.queries.AwsQuery;
import com.albatross.api.v1.flow.controllers.AwsWebhookController;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.StringJoiner;

@Slf4j
@Service
@RequiredArgsConstructor
public class AwsService {

  private final SqlCache sqlCache;
  private static final Integer automationUserId = 2419699; // automation user, chosen by Sean McNees, 21-Feb-2025
  private static final Double highConfidenceThreshold = 90.0;
  private static final Double mediumConfidenceThreshold = 80.0;

  private HashMap<String, Object> getParams(String jobId, AwsWebhookController.UtilityBillResult awsResults) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("s3_key", "blueraven/uploads/" + jobId);
    params.put("premiseNumber", getValueIfHighConfidence(awsResults.getPremiseNumber()));
    params.put("customerName", getValueIfHighConfidence(awsResults.getCustomerName()));
    params.put("meterNumber", getValueIfHighConfidence(awsResults.getMeterNumber()));
    params.put("accountNumber", getValueIfHighConfidence(awsResults.getAccountNumber()));
    params.put("serviceAddress", getValueIfHighConfidence(awsResults.getServiceAddress()));
    params.put("otherNotes", getOtherNotesWithConfidenceLevels(awsResults));
    params.put("userId", automationUserId);
    return params;
  }

  private Object getValueIfHighConfidence(AwsWebhookController.TextractResult awsResult) {
    return awsResult != null && awsResult.getConfidence() >= highConfidenceThreshold ? awsResult.getText() : null;
  }

  private String getOtherNotesWithConfidenceLevels(AwsWebhookController.UtilityBillResult awsResults) {
    StringJoiner result = new StringJoiner("\n", "Automation by Albatross", "");

    return result.toString();
  }

  public void processUtilityBillResults(String jobId, AwsWebhookController.UtilityBillResult awsResults) {
    try {
      sqlCache.updateBySql(AwsQuery.updateProjectWithUtilityBillInfo, getParams(jobId, awsResults));
    } catch (Exception e) {
      log.error(e.getMessage(), e);
    }
  }
}
