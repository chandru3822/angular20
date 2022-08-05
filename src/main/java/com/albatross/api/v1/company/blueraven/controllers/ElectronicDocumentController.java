package com.albatross.api.v1.company.blueraven.controllers;

import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.services.ElectronicDocumentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@RestController
@RequestMapping(value = "/api/v1/flow/electronicDocument")
@RequiredArgsConstructor
public class ElectronicDocumentController {

  private final ElectronicDocumentService electronicDocumentService;

  @GetMapping(value = "/projects")
  public Page<InstallAgreementProject> getProjects(@RequestParam String query, Pageable pageable) {
    return electronicDocumentService.getProjects(query, pageable);
  }

  @GetMapping(value = "/getPermittingDocuments/{projectId}")
  public String getPermittingDocuments(@PathVariable Long projectId) {
    return electronicDocumentService.getDocuments(projectId, 0);
  }

  @GetMapping(value = "/getUtilityDocuments/{projectId}")
  public String getUtilityDocuments(@PathVariable Long projectId) {
    return electronicDocumentService.getDocuments(projectId, 1);
  }

  @GetMapping(value = "/getChangeOrderDocuments/{projectId}")
  public String getChangeOrderDocuments(@PathVariable Long projectId) {
    return electronicDocumentService.getDocuments(projectId, 2);
  }

  @GetMapping(value = "/generate/{projectId}/{templateIdsIn}")
  public List<String> getDocuments(
      @PathVariable Long projectId, @PathVariable String templateIdsIn, @RequestParam(required = false) String documentName) {
    try {
      String[] templateIds = templateIdsIn.split(",");
      List<String> docUrls = new ArrayList<>();
      for (String templateId : templateIds) {
        docUrls.add(electronicDocumentService.generateDoc(projectId, templateId, documentName));
      }
      return docUrls;
    } catch (Exception e) {
      log.error("ELECTRONIC: failed to generate document", e);
      return null;
    }
  }
}
