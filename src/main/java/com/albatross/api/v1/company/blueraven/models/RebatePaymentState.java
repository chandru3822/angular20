package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

@Getter @Setter
public class RebatePaymentState {

  @Id
  private Long id;
  private String name;
}
