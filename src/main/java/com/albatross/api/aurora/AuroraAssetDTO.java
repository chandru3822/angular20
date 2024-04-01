package com.albatross.api.aurora;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AuroraAssetDTO {

    @JsonProperty("url")
    private String url;

    @JsonProperty("filename")
    private String filename;

  @JsonProperty("asset_type")
  private String assetType;

}
