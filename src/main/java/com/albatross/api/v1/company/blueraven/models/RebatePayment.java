package com.albatross.api.v1.company.blueraven.models;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;
import java.util.List;

@Getter @Setter
public class RebatePayment {
  private Long id, projectId, createdByUserId, approvedByUserId, updatedByUserId, paymentStateId, checkNumber;
  private String projectName, financier, product, state, voidNote, createdBy;
  private Date substantialCompletionDate, enteredIntoPaymentSystemDate, batchDate, lastPaymentDate;
  private Double totalPromotionAmount, paymentAmount, totalPaid, balanceOwed;
  private Integer numberOfPromotionPayments;
  private Long paymentId, paymentNbr;
  private List<Integer> paymentIds;
  private Boolean individual, selected;
}
