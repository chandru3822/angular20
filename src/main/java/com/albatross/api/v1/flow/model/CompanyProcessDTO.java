package com.albatross.api.v1.flow.model;

import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(callSuper = false)
@Data
public class CompanyProcessDTO extends CompanyProcess {
    // the public API may pass an ownerId to use for initial process step creation
    private Long ownerUserPositionId;
}
