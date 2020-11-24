package com.albatross.api.v1.flow.controllers;

import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.flow.services.ElectronicDocumentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@Slf4j
@RequestMapping(value = "/api/v1/flow/electronicDocument")
public class ElectronicDocumentController {

  @Autowired
  ElectronicDocumentService electronicDocumentService;

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
  public ArrayList<String> getDocuments(@PathVariable Long projectId, @PathVariable String templateIdsIn) {
      try {
          String[] templateIds = templateIdsIn.split(",");
          ArrayList<String> docUrls = new ArrayList<>();
          for (String templateId: templateIds) {
              docUrls.add(electronicDocumentService.generateDoc(projectId, templateId));
          }
          return docUrls;
      } catch (Exception e) {
          log.error("PANDADOC: failed to generate document: {}", e.getMessage());
          e.printStackTrace();
          return null;
      }
  }

}
