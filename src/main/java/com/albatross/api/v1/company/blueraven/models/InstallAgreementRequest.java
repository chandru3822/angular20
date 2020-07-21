package com.albatross.api.v1.company.blueraven.models;

import lombok.Data;

import java.util.Date;
import java.util.HashMap;

@Data
public class InstallAgreementRequest {
  private Long project_id;
  private String customer_name;
  private String owner_name;
  private Long proposal_nbr;
  private Long proposal_nbr_id;
  private String product;
  private String financier;
  private Date installation_agreement_request_submitted_date;
  private Date created_date;
  private Long created_by_user_id;
  private String project_props_owner;
  private Long statusId;
  private Boolean send_installation_agreement;
  private Boolean send_loanpal_docs;
  private Boolean isSpanish;
  private Boolean request_successful;

  public HashMap<String, Object> toHashMap() {
    HashMap<String, Object> data = new HashMap<>();
    data.put("project_id", project_id);
    data.put("customer_name", customer_name);
    data.put("owner_name", owner_name);
    data.put("proposal_nbr", proposal_nbr);
    data.put("proposal_nbr_id", proposal_nbr_id);
    data.put("product", product);
    data.put("financier", financier);
    data.put("submitted_date", installation_agreement_request_submitted_date);
    data.put("created_date", created_date);
    data.put("created_by_user_id", created_by_user_id);
    data.put("project_props_owner", project_props_owner);
    data.put("status_id", statusId);
    data.put("request_successful", request_successful);

    return data;
  }

  public void validateNewRequest() throws Exception {
    if (project_id == null) {
      throw new Exception("invalid Project ID");
    }
    if (proposal_nbr == null || proposal_nbr < 1) {
      throw new Exception("invalid proposal number");
    }
  }
}
