package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeCheckInType;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeReviewInvitation;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdeyeService;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.google.common.base.Preconditions.checkArgument;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/birdeye")
@RequiredArgsConstructor
public class BirdeyeReviewController {
  private final BirdeyeService birdeye;

  /**
   * Send (or re-send) an invite to a customer to review Blue Raven.
   *
   * @param invitation
   * @return
   */
  @PostMapping(value = "/invite")
  public ResponseEntity<BirdEyeResponse> invite(@RequestBody BirdEyeReviewInvitation invitation) {
    if (invitation.getSendSms() != null && invitation.getSendSms()) {
      checkArgument(
        StringUtils.isNotBlank(invitation.getCustomerPhone()),
        "Customer phone number must be specified if sendSms is set.");
    } else {
      checkArgument(
        StringUtils.isNotBlank(invitation.getCustomerEmail()),
        "Customer email must be specified if sendSms is not set.");
    }
    try {
      birdeye.sendCheckIn(invitation, BirdEyeCheckInType.SURVEY);
      birdeye.saveCfgaValue(invitation.getProjectId());
      return ResponseEntity.ok(new BirdEyeResponse("Invite sent."));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(new BirdEyeResponse(e.getMessage()));
    }
  }

  public record BirdEyeResponse(String message) {
  }
}
