package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.birdeye.BirdeyeLocation;
import com.albatross.api.v1.company.blueraven.models.birdeye.BirdeyeReviewInvitation;
import com.albatross.api.v1.company.blueraven.models.birdeye.BirdeyeService;
import com.google.common.base.Supplier;
import com.google.common.base.Suppliers;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.concurrent.TimeUnit;

import static com.google.common.base.Preconditions.checkArgument;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/birdeye")
public class BirdeyeReviewController {
  @Autowired BirdeyeService birdeye;

  private Supplier<List<BirdeyeLocation>> locations;

  public BirdeyeReviewController(BirdeyeService birdeye) {
    checkArgument(birdeye != null);
    this.birdeye = birdeye;
    this.locations = Suppliers.memoizeWithExpiration(birdeye::getLocations, 1, TimeUnit.HOURS);
  }

  /**
   * Send (or re-send) an invite to a customer to review Blue Raven.
   *
   * @param invitation
   * @return
   */
  @PostMapping(value = "/invite")
  public ResponseEntity<String> invite(@RequestBody BirdeyeReviewInvitation invitation) {
    JSONObject result = new JSONObject();
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
      birdeye.sendInvitation(invitation);
      //only save the cfga value if the invite request told us to.  mobile has made this change on their side.
      if(null != invitation.getSaveCfv() && invitation.getSaveCfv()) {
        birdeye.saveCfgaValue(invitation.getProjectId());
      }
      result.put("message", "Invite sent.");
      return ResponseEntity.ok(result.toString());
    } catch (Exception e) {
      result.put("message", e.getMessage());
      return ResponseEntity.badRequest().body(result.toString());
    }
  }
}
