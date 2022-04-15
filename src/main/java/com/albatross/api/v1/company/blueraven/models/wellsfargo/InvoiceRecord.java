package com.albatross.api.v1.company.blueraven.models.wellsfargo;

import lombok.Data;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

@Data
public class InvoiceRecord implements FlatFileRecord {
  private final RecordType recordId = RecordType.INVOICE;

  // max length: 30; mandatory
  private String number;

  // max length: 10; optional
  private Date date = new Date();

  // max length: 80; optional
  private String description;

  // max length: 18; optional
  private Double netAmount;

  // max length: 18; optional
  private Double grossAmount;

  // max length: 18; optional
  private Double discountTaken;

  // max length: 15; optional
  private String purchaseOrderNumber;

  // max length: 3; optional
  private String invoiceType = "IV";

  // max length: 70; optional
  private String facilityName;

  // max length: 80; optional
  private String purchaseOrderDescription;

  // max length: 35; optional
  private String sepaDocumentTypeCode;

  // max length: 35; optional
  private String sepaDocumentIssuer;

  // max length: 35; optional
  private String sepaDocumentReferenceNumber;

  public List<Object> getFields() {
    return Arrays.asList(
        recordId,
        number,
        date,
        description,
        netAmount,
        grossAmount,
        discountTaken,
        purchaseOrderNumber,
        invoiceType,
        facilityName,
        purchaseOrderDescription,
        sepaDocumentTypeCode,
        sepaDocumentIssuer,
        sepaDocumentReferenceNumber);
  }
}
