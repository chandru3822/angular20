package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class ContactLead {

  private String firstName,
      lastName,
      zip,
      phone,
      email,
      leadSourceDetail,
      leadSource,
      address,
      city,
      state,
      tcpaOptIn,
      activeProspectUrl,
      tier,
      leadType,
      ipAddress,
      market,
      website,
      company,
      country,
      leadId,
      roofMaterial,
      sunExposure,
      electricProvider,
      roofDesign,
      roofShade,
      comments,
      homeOwner,
      vendorId,
      referralGenerationRepresentative,
      gclid,
      companyBrand;
  private Long creditScore, leadLevel, ownerUserPositionId, objectCategoryId;
  private BigDecimal householdIncome, electricMonthly, leadPrice;
}
