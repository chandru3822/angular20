package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;

import java.util.Date;
import java.util.List;

@Getter @Setter
@EqualsAndHashCode
@Data
@NoArgsConstructor
public class RebateBatchDetail {

  @Id
  private Long id;

  private Date batchDate, updatedDate;
  private Boolean voidedBatch;
  private Long updatedByUserId;
  private String updatedByUser;
  private List<RebatePayment> rebatePayments;
}
