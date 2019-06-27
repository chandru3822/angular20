package com.albatross.api.v1.flow.services;

import com.albatross.api.utils.SqlCache;
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
}
