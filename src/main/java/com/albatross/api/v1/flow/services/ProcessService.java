package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.StatusType;
import com.albatross.api.v1.flow.model.Process;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepProcess;
import com.albatross.api.v1.flow.model.User;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProcessService {

    private final SqlCache sqlCache;

    private final ObjectMapper om;

    private final SecurityService securityService;

    public List<Process> getProcessesForCompany() {
      User user = securityService.getCurrentUser();
        return sqlCache.query("process.getAllForCompany", ImmutableMap.of("companyId", user.getCompanyId()), Process.class);
    }

    public Optional<Process> getProcess(Long companyId, Long processId) {
        return sqlCache.get("process.get", ImmutableMap.of("companyId", companyId, "processId", processId), new ProcessMapper<>(Process.class, om));
    }

    public void deleteProcess(Long processId) {
      User user = securityService.getCurrentUser();
        // delete company process
        sqlCache.update("process.deleteCompanyProcess",
                ImmutableMap.of("companyId", user.getCompanyId(),
                    "processId", processId));

        // delete process (this will likely change one day when we allow processes to be shared between companies)
        sqlCache.update("process.delete",
            ImmutableMap.of("processId", processId));
    }

    public void updateProcess(Process process) {
        User currentUser = securityService.getCurrentUser();

        sqlCache.update("process.update",
                ImmutableMap.of("companyId", process.getCompanyId(),
                    "id", process.getId(),
                    "processName", process.getProcessName(),
                    "modifiedById", currentUser.getId()));
    }

    public Optional<Process> insertProcess(Process process) {
        User user = securityService.getCurrentUser();
        // insert the row into process, this will likely change as we allow processes to be shared between companies
        // parentCompanyId will be used for sharing processes later on
        Long id = sqlCache.updateReturningId("process.insert",
            ImmutableMap.of("processName", process.getProcessName(),
                "createdById", user.getId(),
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
    public void deleteProcessStepFromProcess(Long processStepProcessId) {
        User currentUser = securityService.getCurrentUser();

        sqlCache.update("process.deleteProcessStepFromProcess",
            ImmutableMap.of("companyId", currentUser.getCompanyId(),
                "processStepProcessId", processStepProcessId,
                "modifiedById", currentUser.getId()));
    }

    public List<ProcessStep> availableProcessSteps(Long processId) {
      User user = securityService.getCurrentUser();
      List<ProcessStep> results = sqlCache.query("process.availableProcessSteps",
            ImmutableMap.of("processId", processId,
                            "companyId", user.getCompanyId()), ProcessStep.class);

        return results;
    }

    public Optional<ProcessStepProcess> getOneProcessStepProcess(Long id) {
        Optional<ProcessStepProcess> result = sqlCache.get("process.getOneProcessStepProcess",
            ImmutableMap.of("id", id), ProcessStepProcess.class);

        return result;
    }

    public Optional<ProcessStepProcess> insertProcessStepProcess(Long processId, ProcessStepProcess processStepProcess) {
        User currentUser = securityService.getCurrentUser();

        Long id = sqlCache.updateReturningId("process.insertProcessStepProcess",
            ImmutableMap.of("processId", processId,
                            "createdById", currentUser.getId(),
                            "orgId", processStepProcess.getOrgId(),
                            "initialStep", processStepProcess.isInitialStep(),
                            "processStepId", processStepProcess.getProcessStepId()), "id").longValue();

        return getOneProcessStepProcess(id);
    }

    public void updateProcessStepProcesses(Long processId, List<ProcessStepProcess> processStepProcesses) {
        User currentUser = securityService.getCurrentUser();

        for(ProcessStepProcess psp : processStepProcesses){
            sqlCache.update("process.updateProcessStepProcess",
                ImmutableMap.of("id", psp.getId(),
                    "modifiedById", currentUser.getId(),
                    "displayOrder", psp.getDisplayOrder()));
        }
    }

    public void setInitialProcessStep(Long processId, Long processStepProcessId) {
        User currentUser = securityService.getCurrentUser();

            sqlCache.update("process.setInitialProcessStep",
                ImmutableMap.of("processId", processId,
                    "modifiedById", currentUser.getId(),
                    "processStepProcessId", processStepProcessId));
    }
}
