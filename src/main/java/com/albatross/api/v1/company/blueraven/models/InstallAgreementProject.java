package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

@Data
public class InstallAgreementProject {
  private Long project_id;
  private String customer_name, email, address, financier;
  private boolean credit_last_checked_by_sunpower;
}
