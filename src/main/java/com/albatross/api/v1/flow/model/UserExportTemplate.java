package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Data;


@Data
@Builder
@JsonPropertyOrder({"First Name", "Last Name", "Email", "Phone", "Status", "Position"})
public class UserExportTemplate {
  public static UserExportTemplate from(User other) {
    return UserExportTemplate.builder()
        .firstName(other.getFirstName())
        .lastName(other.getLastName())
        .email(other.getEmail())
        .phone(other.getPhoneNumber())
        .status(other.getUserStatusType())
        .position(other.getPosition())
        .build();
  }

  /////////////////////////////////////////////////////////////////////////////
  // directly-sourced data — the data supplied by
  // Org — starts here
  /////////////////////////////////////////////////////////////////////////////
  @JsonProperty("First Name")
  private String firstName;

  @JsonProperty("Last Name")
  private String lastName;

  @JsonProperty("Email")
  private String email;

  @JsonProperty("Phone")
  private String phone;

  @JsonProperty("Status")
  private String status;

  @JsonProperty("Position")
  private String position;
}
