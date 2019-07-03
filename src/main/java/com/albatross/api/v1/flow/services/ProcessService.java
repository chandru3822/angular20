package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.StatusType;
import com.albatross.api.v1.flow.model.ApiProcess;
import com.albatross.api.v1.flow.services.dto.DtoProcess;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Optional;

@Slf4j
@Service
public class ProcessService {
    @Autowired
    private SqlCache sqlCache;

    public Collection<DtoProcess> getProcessesForCompany(Long companyId) {
        return sqlCache.query("process.getAllForCompany",
                ImmutableMap.of("companyId", companyId),
                DtoProcess.class);
    }

    public Optional<DtoProcess> getProcess(Long companyId, Long processId) {
        return sqlCache.get("process.get",
                ImmutableMap.of("companyId", companyId,
                                "processId", processId),
                DtoProcess.class);
    }

    public void deleteProcess(Long companyId, Long processId) {
        // delete company process
        sqlCache.update("process.deleteCompanyProcess",
                ImmutableMap.of("companyId", companyId,
                    "processId", processId));

        // delete process (this will likely change one day when we allow processes to be shared between companies)
        sqlCache.update("process.delete",
            ImmutableMap.of("processId", processId));
    }

    public void updateProcess(ApiProcess process) {
        sqlCache.update("process.update",
                ImmutableMap.of("companyId", process.getCompanyId(),
                    "id", process.getId(),
                    "processName", process.getProcessName(),
                    "modifiedById", process.getModifiedById()));
    }

    public Optional<DtoProcess> insertProcess(ApiProcess process) {
        // insert the row into process, this will likely change as we allow processes to be shared between companies
        // parentCompanyId will be used for sharing processes later on
        Long id = sqlCache.updateReturningId("process.insert",
            ImmutableMap.of("processName", process.getProcessName(),
                "createdById", process.getCreatedById(),
                "parentCompanyId", process.getParentCompanyId()),
            "id").longValue();

        // add row to company_process, this uses the true companyId
        sqlCache.update("process.insertCompanyProcess",
            ImmutableMap.of("processId", id,
                "companyId", process.getCompanyId(),
                "statusTypeId", StatusType.ACTIVE.id));

        return getProcess(process.getCompanyId(), id);
    }
}
