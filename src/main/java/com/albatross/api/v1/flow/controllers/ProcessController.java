package com.albatross.api.v1.flow.controllers;

import com.albatross.api.security.SecurityService;
import com.albatross.api.v1.flow.model.CompanyProcess;
import com.albatross.api.v1.flow.model.ProcessStep;
import com.albatross.api.v1.flow.model.ProcessStepProcess;
import com.albatross.api.v1.flow.model.User;
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
@RequestMapping(value = "/api/v1/flow/processes")
public class ProcessController {

  private final SecurityService securityService;

    private final ProcessService processService;

    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<CompanyProcess>> getProcessesForCompany(@RequestParam(required = false) Long contactId) {
        return new ResponseEntity<>(processService.getProcessesForCompany(contactId), HttpStatus.OK);
    }

    @GetMapping(value = "/{processId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<CompanyProcess> getProcess(@PathVariable Long processId,
                                                     @RequestParam(required = false) Long projectId) {
      User user = securityService.getCurrentUser();
      return processService.getProcess(user.getCompanyId(), processId, projectId)
        .map(ResponseEntity::ok)
        .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping(value = "/{processId}")
    public ResponseEntity<?> deleteProcess(@PathVariable Long processId) {
        processService.deleteProcess(processId);
        return ResponseEntity.noContent().build();
    }

    @PutMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<?> updateProcess(@RequestBody CompanyProcess process) {
        processService.updateProcess(process);
        return ResponseEntity.noContent().build();
    }

    @PostMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<CompanyProcess> insertProcess(@RequestBody CompanyProcess process) {
        return processService.insertProcess(process);
    }

    // process step process stuff, put in different controller??
    @DeleteMapping(value = "/processStepProcess/{id}")
    public ResponseEntity<?> deleteProcessStepFromProcess(@PathVariable("id") Long processStepProcessId) {
        processService.deleteProcessStepFromProcess(processStepProcessId);
        return ResponseEntity.noContent().build();
    }

    @GetMapping(value = "/{companyProcessId}/availableProcessSteps", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<ProcessStep> availableProcessStepsForProcess(@PathVariable Long companyProcessId) {
        return processService.availableProcessSteps(companyProcessId);
    }

  @GetMapping(value = "/{companyProcessId}/nonAdminProcessStepsForProcess", produces = MediaType.APPLICATION_JSON_VALUE)
  public List<ProcessStep> nonAdminProcessStepsForProcess(@PathVariable Long companyProcessId,
                                                          @RequestParam(required = false) Long projectId) {
    return processService.nonAdminProcessStepsForProcess(companyProcessId, projectId);
  }

    @PostMapping(value = "/{companyProcessId}/processStep", produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<ProcessStepProcess> insertProcessStepProcess(@PathVariable Long companyProcessId, @RequestBody ProcessStepProcess processStepProcess) {
        return processService.insertProcessStepProcess(companyProcessId, processStepProcess);
    }

    @PutMapping(value = "/{companyProcessId}/processStepProcesses", produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<CompanyProcess>  updateProcessStepProcesses(@PathVariable Long companyProcessId,
                                                                @RequestBody List<ProcessStepProcess> processStepProcesses) {
        return processService.updateProcessStepProcesses(companyProcessId, processStepProcesses);
    }

    @PutMapping(value = "/{companyProcessId}/processStepProcess", produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<ProcessStepProcess> updateProcessStepProcess(@PathVariable Long companyProcessId,
                                         @RequestBody ProcessStepProcess processStepProcess) {
        return processService.updateProcessStepProcess(companyProcessId, processStepProcess);
    }

//    @PutMapping(value = "/{processId}/initialProcessStepProcess", produces = MediaType.APPLICATION_JSON_VALUE)
//    public Optional<ProcessStepProcess> updateProcessStepProcess(@PathVariable Long processId,
//                                      @RequestBody ProcessStepProcess processStepProcess) {
//        return processService.setInitialProcessStep(processId, processStepProcess);
//    }
}
