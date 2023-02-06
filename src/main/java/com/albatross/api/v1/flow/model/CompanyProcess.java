package com.albatross.api.v1.flow.model;

import com.albatross.api.v1.flow.model.processStep.ProcessStepProcess;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.List;

@EqualsAndHashCode(callSuper = false)
@Data
@NoArgsConstructor
public class CompanyProcess {
    private Long id, companyId, createdById, modifiedById, parentCompanyId, processId;
    private String processName;
    private Boolean archived;
    private List<DenyListPosition> denyListPositions;
    private List<ProcessStepProcess> processStepProcesses;

}
