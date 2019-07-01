package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.flow.model.ApiProcess;
import com.albatross.api.v1.flow.services.ProcessService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
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

    private static ApiProcess addLinks(ApiProcess p) {
        // self link
        p.add(linkTo(methodOn(ProcessController.class).getProcess(p.getCompanyIdentifier(), p.getIdentifier()))
                .withSelfRel());

        // add company link
        p.add(linkTo(methodOn(CompanyController.class).getCompany(p.getCompanyIdentifier()))
                .withRel("/rels/company"));

        // add processes link
        p.add(linkTo(methodOn(ProjectController.class).getProjectsForProcess(p.getCompanyIdentifier(),
                                                                             p.getIdentifier()))
                .withRel("/rels/process/projects"));

        return p;
    }
}
