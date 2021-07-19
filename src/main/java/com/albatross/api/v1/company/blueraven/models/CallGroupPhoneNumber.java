package com.albatross.api.v1.company.blueraven.models;

import com.albatross.api.v1.flow.model.User;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.Date;
import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class CallGroupPhoneNumber {

  private Long id, callGroupId;
  private String phoneNumber;
  private Boolean archived, active, lastUsed, maxCallCountHit;
  private List<User> users;
  private Integer callCount;
  private Date dateCreated;
}
