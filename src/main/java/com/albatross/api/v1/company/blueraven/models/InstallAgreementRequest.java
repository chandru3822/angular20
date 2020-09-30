package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;
import java.util.HashMap;

@Data
public class InstallAgreementRequest {
  private Long projectId;
  private String customerName;
  private String owner_name;
  private Long proposalNbr;
  private Long proposal_nbr_id;
  private String product;
  private String financier;
  private String utility_company;
  private Date installation_agreement_request_submitted_date;
  private Date created_date;
  private Long created_by_user_id;
  private String project_props_owner;
  private Long statusId;
  private Boolean sendInstallationAgreement;
  private Boolean sendLoanpalDocs;
  private Boolean isSpanish;
  private Boolean request_successful;

  public HashMap<String, Object> toHashMap() {
    HashMap<String, Object> data = new HashMap<>();
    data.put("projectId", projectId);
    data.put("customer_name", customerName);
    data.put("owner_name", owner_name);
    data.put("proposalNbr", proposalNbr);
    data.put("proposal_nbr_id", proposal_nbr_id);
    data.put("product", product);
    data.put("financier", financier);
    data.put("utility_company", utility_company);
    data.put("submitted_date", installation_agreement_request_submitted_date);
    data.put("created_date", created_date);
    data.put("created_by_user_id", created_by_user_id);
    data.put("project_props_owner", project_props_owner);
    data.put("status_id", statusId);
    data.put("request_successful", request_successful);

    return data;
  }

  public void validateNewRequest() throws Exception {
    if (projectId == null) {
      throw new Exception("invalid Project ID");
    }
    if (proposalNbr == null || proposalNbr < 1) {
      throw new Exception("invalid proposal number");
    }
  }
}
