package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.enums.StatusType;
import com.albatross.api.v1.flow.model.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProcessService {

    private final SqlCache sqlCache;

    private final ObjectMapper om;

    private final SecurityService securityService;

    public List<CompanyProcess> getProcessesForCompany(Long contactId) {
      User user = securityService.getCurrentUser();
      Long companyId = user.getCompanyId();

        if(null != contactId) {
            //had to change this so that a parent looking at a child contact could still see processes
            HashMap<String, Object> params = new HashMap<>();
            params.put("contactId", contactId);
            companyId = sqlCache.queryForObject("contact.getCompanyId", params, Long.class);
        }

      return sqlCache.query("process.getAllForCompany", ImmutableMap.of("companyId", companyId), CompanyProcess.class);
    }

    public Optional<CompanyProcess> getProcess(Long companyId, Long processId, Long projectId) {
        if(null != projectId) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("projectId", projectId);
            companyId = sqlCache.queryForObject("project.getCompanyId", params, Long.class);
        }
        Optional<CompanyProcess> result = sqlCache.get("process.get",
          ImmutableMap.of("companyId", companyId,
                          "processId", processId),
          new ProcessMapper<>(CompanyProcess.class, om));
        return result;
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

    public void updateProcess(CompanyProcess process) {
        User currentUser = securityService.getCurrentUser();

        sqlCache.update("process.update",
                ImmutableMap.of("companyId", process.getCompanyId(),
                    "id", process.getId(),
                    "processName", process.getProcessName(),
                    "modifiedById", currentUser.trueUserId()));
    }

    public Optional<CompanyProcess> insertProcess(CompanyProcess process) {
        User user = securityService.getCurrentUser();
        // insert the row into process, this will likely change as we allow processes to be shared between companies
        // parentCompanyId will be used for sharing processes later on
        Long id = sqlCache.updateReturningId("process.insert",
            ImmutableMap.of("processName", process.getProcessName(),
                "createdById", user.trueUserId(),
                "parentCompanyId", process.getParentCompanyId()),
            "id").longValue();

        // add row to company_process, this uses the true companyId
        sqlCache.update("process.insertCompanyProcess",
            ImmutableMap.of("processId", id,
                "companyId", process.getCompanyId(),
                "statusTypeId", StatusType.ACTIVE.id));

        return getProcess(process.getCompanyId(), id, null);
    }

    // process step process stuff, put in other service??
    public void deleteProcessStepFromProcess(Long processStepProcessId) {
        User currentUser = securityService.getCurrentUser();

        sqlCache.update("process.deleteProcessStepFromProcess",
            ImmutableMap.of("companyId", currentUser.getCompanyId(),
                "processStepProcessId", processStepProcessId,
                "modifiedById", currentUser.trueUserId()));
    }

    public List<ProcessStep> availableProcessSteps(Long companyProcessId) {
      User user = securityService.getCurrentUser();
      List<ProcessStep> results = sqlCache.query("process.availableProcessSteps",
            ImmutableMap.of("companyProcessId", companyProcessId,
                            "companyId", user.getCompanyId()), ProcessStep.class);

        return results;
    }

    public List<ProcessStep> nonAdminProcessStepsForProcess(Long companyProcessId, Long projectId) {
        Long companyId;
        if(null != projectId) {
            HashMap<String, Object> params = new HashMap<>();
            params.put("projectId", projectId);
            companyId = sqlCache.queryForObject("project.getCompanyId", params, Long.class);
        } else {
            User user = securityService.getCurrentUser();
            companyId = user.getCompanyId();
        }
        List<ProcessStep> results = sqlCache.query("process.nonAdminProcessStepsForProcess",
          ImmutableMap.of("companyProcessId", companyProcessId,
            "companyId", companyId), ProcessStep.class);

        return results;
    }

    public Optional<ProcessStepProcess> getOneProcessStepProcess(Long id) {
        Optional<ProcessStepProcess> result = sqlCache.get("process.getOneProcessStepProcess",
            ImmutableMap.of("id", id), new ProcessStepProcessMapper<>(ProcessStepProcess.class, om));

        return result;
    }

    public Optional<ProcessStepProcess> insertProcessStepProcess(Long companyProcessId, ProcessStepProcess processStepProcess) {
        User currentUser = securityService.getCurrentUser();
        HashMap<String, Object> params = new HashMap<>();
        params.put("companyProcessId", companyProcessId);
        params.put("createdById", currentUser.trueUserId());
        params.put("processStepId", processStepProcess.getProcessStepId());

        Long id = sqlCache.updateReturningId("process.insertProcessStepProcess", params, "id").longValue();

        for(OwningPosition p : processStepProcess.getOwningPositions()) {
            params.put("processStepProcessId", id);
            params.put("positionId", p.getPositionId());

            //added unique constraint and changed to upsert. will unarchive if trying to add dupe
            sqlCache.update("process.insertOwningPosition", params);
        }

        return getOneProcessStepProcess(id);
    }

    public Optional<CompanyProcess> updateProcessStepProcesses(Long companyProcessId, List<ProcessStepProcess> processStepProcesses) {

        User user = securityService.getCurrentUser();

        for(ProcessStepProcess psp : processStepProcesses){
            updateProcessStepProcess(companyProcessId, psp);
        }

        return getProcess(user.getCompanyId(), companyProcessId, null);
    }

    public Optional<ProcessStepProcess> updateProcessStepProcess(Long companyProcessId, ProcessStepProcess processStepProcess) {
        User currentUser = securityService.getCurrentUser();

        HashMap<String, Object> params = new HashMap<>();
        params.put("companyProcessId", companyProcessId);
        params.put("modifiedById", currentUser.trueUserId());
        params.put("initialStep", processStepProcess.isInitialStep());
        params.put("displayOrder", processStepProcess.getDisplayOrder());
        params.put("companyProcessStepStatusTypeId", processStepProcess.getCompanyProcessStepStatusTypeId());
        params.put("processStepProcessId", processStepProcess.getId());

        sqlCache.update("process.updateProcessStepProcess", params);

        List<Long> usedPositionIds = processStepProcess.getOwningPositions().stream().map(OwningPosition::getPositionId).collect(Collectors.toList());
        //delete any existing rows that are not in the above list
        params.put("usedPositionIds", usedPositionIds);
        if(!usedPositionIds.isEmpty()) {
            sqlCache.update("process.deleteOldOwningPositions", params);
        }

        for(OwningPosition p : processStepProcess.getOwningPositions()) {
            //if there is an id, do nothing it has already been saved. otherwise insert a row
            if(null == p.getProcessStepProcessOwningPositionId()){
                params.put("positionId", p.getPositionId());
                params.put("createdById", currentUser.trueUserId());
                //added unique constraint and changed to upsert. will unarchive if trying to add dupe
                sqlCache.update("process.insertOwningPosition", params);
            }
        }

        return getOneProcessStepProcess(processStepProcess.getId());
    }

    public List<ProcessStepProcess> getInitialProcessStepProcesses(Long companyProcessId) {
        HashMap<String, Object> params = new HashMap<>();
        params.put("companyProcessId", companyProcessId);

        List<ProcessStepProcess> results = sqlCache.query("process.getInitialProcessStepProcesses", params, ProcessStepProcess.class);

        return results;
    }

//    public Optional<ProcessStepProcess> setInitialProcessStep(Long processId, ProcessStepProcess processStepProcess) {
//        User currentUser = securityService.getCurrentUser();
//
//        HashMap<String, Object> params = new HashMap<>();
//        params.put("processId", processId);
//        params.put("modifiedById", currentUser.trueUserId());
//        params.put("initialStep", processStepProcess.isInitialStep());
//        params.put("companyProcessStepStatusTypeId", processStepProcess.getCompanyProcessStepStatusTypeId());
//        params.put("processStepProcessId", processStepProcess.getId());
//
//        sqlCache.update("process.setInitialProcessStep", params);
//
//        return getOneProcessStepProcess(processStepProcess.getId());
//    }

    public static class ProcessMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public ProcessMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<ProcessStepProcess>> processStepProcessRef = new TypeReference<>() {};
            TypeReference<List<OwningPosition>> owningPositionsRef = new TypeReference<>() {};

            bw.registerCustomEditor(List.class, "processStepProcesses",
                new JsonCollectionDeserializer(processStepProcessRef, objectMapper));

            bw.registerCustomEditor(List.class, "owningPositions",
                new JsonCollectionDeserializer(owningPositionsRef, objectMapper));
        }
    }

    public static class ProcessStepProcessMapper<T> extends BeanPropertyRowMapper<T> {
        private final ObjectMapper objectMapper;

        public ProcessStepProcessMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
            super(mappedClass);
            this.objectMapper = objectMapper;
        }

        @Override
        protected void initBeanWrapper(BeanWrapper bw) {
            TypeReference<List<OwningPosition>> owningPositionsRef = new TypeReference<>() {};

            bw.registerCustomEditor(List.class, "owningPositions",
                new JsonCollectionDeserializer(owningPositionsRef, objectMapper));
        }
    }
}
