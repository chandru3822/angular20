package com.albatross.api.v1.flow.services.dto;

import com.albatross.api.v1.flow.model.ProcessStepProcess;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
public class DtoProcess {
    private Long id, companyId, createdById, modifiedById, parentCompanyId;
    private String processName;
    private Boolean archived;
    private List<ProcessStepProcess> processStepProcesses;
}
