package com.albatross.api.v1.flow.model.postalCode;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class PostalCodeZonePostalCode {

  //yes i renamed it to this cuz this kind of postal code is specific to postal code zones
  //and we needed to add a generic postal code object
  private Long id, postalCodeZoneId;
  private String postalCode;
  private Boolean archived, postalCodeZoneArchived;
  private List<User> users;
}
