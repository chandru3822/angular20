package com.albatross.api.v1.flow.services.dto;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class DtoProcess {
    private Long id, companyId, createdById, modifiedById, parentCompanyId;
    private String processName;
    private Boolean archived;
}
