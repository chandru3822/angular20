package com.albatross.api.v1.flow.model.roundRobin;

import com.albatross.api.v1.flow.model.UserPosition;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode
@Data
@NoArgsConstructor
public class RoundRobinUser {

  private Long id, roundRobinId, userId, roundRobinUserTypeId, companyTimezoneId;
  private String firstName, lastName, fullName, position, timezone, title, roundRobinName;
  private Boolean archived, schedulable, scheduler;
  private List<UserPosition> userPositions;
}
