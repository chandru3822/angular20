package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.Process;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepProcess;
import com.albatross.api.v1.flow.services.ProcessService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/{companyId}/processes")
public class ProcessController {
    
    private final ProcessService processService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Process>> getProcessesForCompany(@PathVariable Long companyId) {
        return new ResponseEntity<>(processService.getProcessesForCompany(companyId), HttpStatus.OK);
    }

    @GetMapping(value = "/{processId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Process> getProcess(@PathVariable Long companyId, @PathVariable Long processId) {
        return processService.getProcess(companyId, processId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping(value = "/{processId}")
    public ResponseEntity<?> deleteProcess(@PathVariable Long companyId, @PathVariable Long processId) {
        processService.deleteProcess(companyId, processId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateProcess(@RequestBody Process process) {
        processService.updateProcess(process);
        return ResponseEntity.noContent().build();
    }

    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<Process> insertProcess(@RequestBody Process process) {
        return processService.insertProcess(process);
    }

    // process step process stuff, put in different controller??
    @DeleteMapping(value = "/processStepProcess/{id}")
    public ResponseEntity<?> deleteProcessStepFromProcess(@PathVariable Long companyId, @PathVariable("id") Long processStepProcessId) {
        processService.deleteProcessStepFromProcess(companyId, processStepProcessId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping(value = "/availableProcessSteps/{processId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<ProcessStep> availableProcessStepsForProcess(@PathVariable Long companyId, @PathVariable Long processId) {
        return processService.availableProcessSteps(companyId, processId);
    }

    @PostMapping(value = "/{processId}/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<ProcessStepProcess> insertProcessStepProcess(@PathVariable Long companyId,
                                                                 @PathVariable Long processId,
                                                                 @RequestBody ProcessStepProcess processStepProcess) {
        return processService.insertProcessStepProcess(processId, processStepProcess);
    }
}
