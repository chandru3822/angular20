package com.albatross.api.v1.company.blueraven.models.commissionManagement;

import lombok.Getter;
import lombok.Setter;

/**
 * Created by randa on 4/13/17.
 * !Describe Purpose!
 */
@Getter
@Setter
public class ResidualDetail {

    private String finalDesignCompleteDate, finalDesignSignedDate, utilityBillVerifiedDate, financialAgreementSignedDate,
      proofOfHomeownersInsuranceObtainedDate, substantialCompletionDate, cancelledDate, onHoldDate, state;

    private Long projectId, proofOfHomeownersInsuranceRequired;

    private Double totalCashDownPayment, firstCashPaymentAmount;
}
