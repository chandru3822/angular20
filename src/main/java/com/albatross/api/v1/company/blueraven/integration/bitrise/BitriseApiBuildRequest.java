package com.albatross.api.v1.company.blueraven.integration.bitrise;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;


@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonIgnoreProperties(ignoreUnknown = true)
public class BitriseApiBuildRequest {

  private HookInfo hook_info;
  private BuildParams build_params;

  @Data
  public static class HookInfo {
    String type = "bitrise";
  }

  @Data
  public static class BuildParams {
    String branch;
    List<EnvironmentField> environments;
  }

  @Data
  public static class EnvironmentField {
    Boolean is_expand = true;
    String mapped_to;
    String value;
  }
}


