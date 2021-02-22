package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CallGroupPostalCode {

  private Long id, callGroupId;
  private String postalCode;
  private Boolean archived;
  private List<User> users;
}
