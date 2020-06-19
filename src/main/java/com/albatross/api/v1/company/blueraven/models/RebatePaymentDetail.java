package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;

@Data
public class RebatePaymentDetail {
    private Long projectId, paymentId;
    private Date substantialCompletionDate, paymentDate;
    private Integer paymentNumber, totalPayments;
    private Double paymentAmount, paidToDate, totalPromotionalAmount;
    private String firstName, lastName, fullName, street1, street2, city, state, stateAbbr, postalCode,
        mailingStreet1, mailingStreet2, mailingCity, mailingState, mailingPostalCode;
}
