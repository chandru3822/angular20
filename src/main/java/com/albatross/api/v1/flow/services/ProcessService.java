package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.StatusType;
import com.albatross.api.v1.flow.model.ApiProcess;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepProcess;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.dto.DtoProcess;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Slf4j
@Service
public class ProcessService {
    @Autowired
    private SqlCache sqlCache;

    @Autowired
    ObjectMapper om;

    @Autowired
    SecurityService securityService;

    public Collection<DtoProcess> getProcessesForCompany(Long companyId) {
        return sqlCache.query("process.getAllForCompany",
                ImmutableMap.of("companyId", companyId),
                DtoProcess.class);
    }

    public Optional<DtoProcess> getProcess(Long companyId, Long processId) {
        return sqlCache.get("process.get",
                ImmutableMap.of("companyId", companyId,
                                "processId", processId),
            new ProcessMapper<>(DtoProcess.class, om));
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

    public static class ProcessMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public ProcessMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<ProcessStepProcess>> processStepProcessRef = new TypeReference<List<ProcessStepProcess>>() {};

            bw.registerCustomEditor(List.class, "processStepProcesses",
                new JsonCollectionDeserializer(processStepProcessRef, objectMapper));
        }
    }

    // process step process stuff, put in other service??
    public void deleteProcessStepFromProcess(Long companyId, Long processStepProcessId) {
        User currentUser = securityService.getCurrentUser();

        sqlCache.update("process.deleteProcessStepFromProcess",
            ImmutableMap.of("companyId", companyId,
                "processStepProcessId", processStepProcessId,
                "modifiedById", currentUser.getId()));
    }

    public List<ProcessStep> availableProcessSteps(Long companyId, Long processId) {
        List<ProcessStep> results = sqlCache.query("process.availableProcessSteps",
            ImmutableMap.of("processId", processId), ProcessStep.class);

        return results;
    }

    public Optional<ProcessStepProcess> getOneProcessStepProcess(Long id) {
        Optional<ProcessStepProcess> result = sqlCache.get("process.getOneProcessStepProcess",
            ImmutableMap.of("id", id), ProcessStepProcess.class);

        return result;
    }

    public Optional<ProcessStepProcess> insertProcessStepProcess(Long companyId, Long processId, Long processStepId) {
        User currentUser = securityService.getCurrentUser();

        Long id = sqlCache.updateReturningId("process.insertProcessStepProcess",
            ImmutableMap.of("processId", processId,
                            "createdById", currentUser.getId(),
                            "orgId", 248,
                            "processStepId", processStepId), "id").longValue();

        return getOneProcessStepProcess(id);
    }
}
