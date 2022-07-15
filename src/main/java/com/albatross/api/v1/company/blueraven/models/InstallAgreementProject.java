package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

@Data
public class InstallAgreementProject {
  private Long project_id;
  private String customer_name, email, address, financier;
  private boolean sunpower_url_exists;
}
