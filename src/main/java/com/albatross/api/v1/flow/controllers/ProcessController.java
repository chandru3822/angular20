package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ApiProcess;
import com.albatross.api.v1.flow.services.ProcessService;
import com.albatross.api.v1.flow.services.dto.DtoProcess;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.linkTo;
import static org.springframework.hateoas.server.mvc.WebMvcLinkBuilder.methodOn;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/companies/{companyId}/processes")
public class ProcessController {
    @Autowired
    private ProcessService processService;

    @RequestMapping(value = "",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<List<ApiProcess>> getProcessesForCompany(@PathVariable Long companyId) {
        List<ApiProcess> processes = processService.getProcessesForCompany(companyId)
                .stream()
                .map(ApiProcess::from)
                .map(ProcessController::addLinks)
                .collect(Collectors.toList());
        return ResponseEntity.ok(processes);
    }

    @RequestMapping(value = "/{processId}",
            method = RequestMethod.GET,
            produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<ApiProcess> getProcess(@PathVariable Long companyId,
                                                 @PathVariable Long processId) {
        return processService.getProcess(companyId, processId)
                .map(ApiProcess::from)
                .map(ProcessController::addLinks)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @RequestMapping(value = "/{processId}",
        method = RequestMethod.DELETE,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public void deleteProcess(@PathVariable Long companyId,
                              @PathVariable Long processId) {
        processService.deleteProcess(companyId, processId);
    }

    @RequestMapping(value = "",
        method = RequestMethod.PUT,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public void updateProcess(@RequestBody ApiProcess process) {
        processService.updateProcess(process);
    }

    @RequestMapping(value = "",
        method = RequestMethod.POST,
        produces = MediaType.APPLICATION_JSON_VALUE)
    public Optional<DtoProcess> insertProcess(@RequestBody ApiProcess process) {
        return processService.insertProcess(process);
    }

    private static ApiProcess addLinks(ApiProcess p) {
        // self link
        p.add(linkTo(methodOn(ProcessController.class).getProcess(p.getCompanyId(), p.getId()))
                .withSelfRel());

        // add company link
        p.add(linkTo(methodOn(CompanyController.class).getCompany(p.getCompanyId()))
                .withRel("/rels/company"));

        // add processes link
        p.add(linkTo(methodOn(ProjectController.class).getProjectsForProcess(p.getCompanyId(),
                                                                             p.getId()))
                .withRel("/rels/process/projects"));

        return p;
    }
}
