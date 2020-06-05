package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import lombok.Data;

import java.util.Arrays;
import java.util.List;

@Data
public class SupplementalCheckRecord implements com.albatross.api.v1.company.blueraven.models.wellsfargo.FlatFileRecord {
    private final com.albatross.api.v1.company.blueraven.models.wellsfargo.RecordType recordId = com.albatross.api.v1.company.blueraven.models.wellsfargo.RecordType.SUPPLEMENTAL_CHECK;

    // max length: 10; mandatory
    private Integer checkNumber;

    // max length: 18; optional
    private String documentTemplateNumber;

    // max length: 3; optional
    private String deliveryCode;

    // max length: 60; optional
    private String courierName;

    // max length: 55; optional
    private String courierAccount;

    // max length: 10; optional
    private String deliveryLocationCode;

    // max length: 50; optional
    private String deliveryLabelText;

    // max length: 50; optional
    private String checkImagingIdentifier;

    // max length: 80; optional
    private String checkImagingDescription;

    // max length: 1; optional
    private String printReadyDocuments;

    // max length: 130; optional
    private String marketingDescription;

    public List<Object> getFields() {
        return Arrays.asList(
                recordId,
                checkNumber,
                documentTemplateNumber,
                deliveryCode,
                courierName,
                courierAccount,
                deliveryLocationCode,
                deliveryLabelText,
                checkImagingIdentifier,
                checkImagingDescription,
                printReadyDocuments,
                marketingDescription
        );
    }
}
