package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.Id;

/**
 * Model for Adders that are used
 */
@Getter
@Setter
public class Adder {

  @Id
  private Long id, adderId, feeAmount, feeTypeId;
  private String adderName, feeType;

}
