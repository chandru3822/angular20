package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import lombok.Builder;
import lombok.Data;


@Data
@Builder
@JsonPropertyOrder({"First Name", "Last Name", "Email", "Address", "City", "State", "Postal Code",
    "Owner"})
public class ContactExportTemplate {
  public static ContactExportTemplate from(Contact other) {
    return ContactExportTemplate.builder()
        .firstName(other.getFirstName())
        .lastName(other.getLastName())
        .email(other.getEmail())
        .street1(other.getStreet1())
        .city(other.getCity())
        .state(other.getState())
        .postalCode(other.getPostalCode())
        .ownerFullName(other.getOwner() != null ? other.getOwner().getFullName() : null)
        .build();
  }

  /////////////////////////////////////////////////////////////////////////////
  // directly-sourced data — the data supplied by
  // Contact — starts here
  /////////////////////////////////////////////////////////////////////////////
  @JsonProperty("First Name")
  private String firstName;

  @JsonProperty("Last Name")
  private String lastName;

  @JsonProperty("Email")
  private String email;

  @JsonProperty("Address")
  private String street1;

  @JsonProperty("City")
  private String city;

  @JsonProperty("State")
  private String state;

  @JsonProperty("Postal Code")
  private String postalCode;

  @JsonProperty("Owner")
  private String ownerFullName;

  /////////////////////////////////////////////////////////////////////////////
  // derived values start here
  /////////////////////////////////////////////////////////////////////////////
//    @JsonProperty("Par")
//    public BigDecimal getPar() {
//      if (getActualLeadGenFDSPercent() == null || getWeightedPercentToPar() == null)
//        return null;
//      return getActualLeadGenFDSPercent()
//          .add(getWeightedPercentToPar().negate());
//    }

}
