package com.albatross.api.v1.flow.services.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class DtoProject {
    private Long id, processId, companyId, customerId;
    private String name;
}
