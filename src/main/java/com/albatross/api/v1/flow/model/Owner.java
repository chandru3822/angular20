package com.albatross.api.v1.flow.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;


@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter
@Setter
public class Owner {
    // an owner is a specific set of fields from other objects.  making it its own model for now
    private Long userId, userPositionId, positionId;
    private String firstName, lastName, fullName, position, phoneNumber, presignedUrl;
}
