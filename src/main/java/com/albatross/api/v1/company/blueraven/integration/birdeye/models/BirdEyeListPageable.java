package com.albatross.api.v1.company.blueraven.integration.birdeye.models;

import lombok.Builder;

@Builder
public
class BirdEyeListPageable {
  @Builder.Default
  private Integer page = 0;
  private Integer size;
  private String sortby, sorder;
}
