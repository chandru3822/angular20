package com.albatross.api.v1.flow.controllers;

import java.util.List;
import java.util.Optional;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.Process;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepProcess;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.ProcessService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@RequestMapping(value = "/api/v1/flow/processes")
public class ProcessController {

  private final SecurityService securityService;

    private final ProcessService processService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<Process>> getProcessesForCompany() {
        return new ResponseEntity<>(processService.getProcessesForCompany(), HttpStatus.OK);
    }

    @GetMapping(value = "/{processId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<Process> getProcess(@PathVariable Long processId) {
      User user = securityService.getCurrentUser();
        return processService.getProcess(user.getCompanyId(), processId)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping(value = "/{processId}")
    public ResponseEntity<?> deleteProcess(@PathVariable Long processId) {
        processService.deleteProcess(processId);
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
    public ResponseEntity<?> deleteProcessStepFromProcess(@PathVariable("id") Long processStepProcessId) {
        processService.deleteProcessStepFromProcess(processStepProcessId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping(value = "/availableProcessSteps/{processId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<ProcessStep> availableProcessStepsForProcess(@PathVariable Long processId) {
        return processService.availableProcessSteps(processId);
    }

    @PostMapping(value = "/{processId}/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<ProcessStepProcess> insertProcessStepProcess(@PathVariable Long processId, @RequestBody ProcessStepProcess processStepProcess) {
        return processService.insertProcessStepProcess(processId, processStepProcess);
    }
}
