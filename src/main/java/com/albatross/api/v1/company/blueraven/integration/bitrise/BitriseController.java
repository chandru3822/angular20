package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeCheckInType;
import com.albatross.api.v1.company.blueraven.integration.birdeye.BirdEyeReviewInvitation;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.StringUtils;
import org.json.JSONObject;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping(value = "/api/v1/company/blueraven/bitrise")
@RequiredArgsConstructor
public class BitriseController {
  private final BitriseService bitriseService;

  /**
   * Trigger a build of the mobile app
   *
   * @param request
   * @return
   */
  @PostMapping(value = "/build")
  public ResponseEntity<BitriseResponse> triggerBuild(@RequestBody BitriseBuildRequest request) {
    try {
      //well this seems like overkill. but it works finally
      BitriseApiBuildRequest fullRequest = new BitriseApiBuildRequest();

      BitriseApiBuildRequest.HookInfo hook = new BitriseApiBuildRequest.HookInfo();
      hook.setType("bitrise");
      fullRequest.setHook_info(hook);

      BitriseApiBuildRequest.BuildParams buildParams = new BitriseApiBuildRequest.BuildParams();
      buildParams.setBranch(request.getBranch());
      buildParams.setWorkflow_id("Cross_Platform");

      List<BitriseApiBuildRequest.EnvironmentField> fields = new ArrayList<>();

      BitriseApiBuildRequest.EnvironmentField field = new BitriseApiBuildRequest.EnvironmentField();
      field.setMapped_to("ENV_NAME");
      field.setValue(request.getDataSource());
      fields.add(field);

      BitriseApiBuildRequest.EnvironmentField field2 = new BitriseApiBuildRequest.EnvironmentField();
      field2.setMapped_to("VERSION_NAME");
      field2.setValue(request.getVersion());
      fields.add(field2);

      buildParams.setEnvironments(fields);

      fullRequest.setBuild_params(buildParams);

      bitriseService.triggerBitriseBuild(fullRequest);
      return ResponseEntity.ok(new BitriseResponse("Build Request Succeeded."));
    } catch (Exception e) {
      return ResponseEntity.badRequest().body(new BitriseResponse(e.getMessage()));
    }
  }

  public record BitriseResponse(String message) {
  }
}
