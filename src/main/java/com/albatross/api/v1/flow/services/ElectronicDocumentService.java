package com.albatross.api.v1.flow.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.models.InstallAgreementProject;
import com.albatross.api.v1.company.blueraven.services.PandaDocService;
import com.albatross.api.v1.flow.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;

@Repository
@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
public class ElectronicDocumentService {
  private final SqlCache sqlCache;

  @Autowired
  private PandaDocService pandaDocService;

  @Autowired
  private SecurityService securityService;

  private final int PERMITTING_DOC_TYPE = 0;
  private final int UTILITY_DOC_TYPE = 1;

  public Page<InstallAgreementProject> getProjects(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    Boolean viewAll = securityService.userHasFeatureAccessLevel(user.getId(), user.getCompanyId(), user.getHighestCompanyId(), "INSTALLATION_AGREEMENT", List.of("VIEW_ALL"));
    HashMap<String, Object> params = new HashMap<>();
    params.put("view_all", viewAll);
    params.put("user_id", user.getId());
    params.put("parentCompanyId", user.getHighestParentCompanyId());
    params.put("isParent", user.getHighestParentCompanyId().equals(user.getCompanyId()));
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<InstallAgreementProject> results = sqlCache.query("electronicDocument.getProjects", params, InstallAgreementProject.class);
    Integer count = sqlCache.queryForObject("electronicDocument.getProjectsCount", params, Integer.class);

    Page<InstallAgreementProject> page = new PageImpl<>(results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
    return page;
  }

  public String getDocuments(Long projectId, int docType) {
      HashMap<String, Object> params = new HashMap<>();
      params.put("projectId", projectId);
      Optional<String> queryStr;
      JSONArray pandaDocs = new JSONArray();

      if (docType == PERMITTING_DOC_TYPE) {
          // Get the permitting document templates
          queryStr = sqlCache.get("electronicDocument.getAhjQueryStr", params, new SingleColumnRowMapper<>(String.class));
      }
      else if (docType == UTILITY_DOC_TYPE) {
          // Get the utility document templates
          queryStr = sqlCache.get("electronicDocument.getUtilityQueryStr", params, new SingleColumnRowMapper<>(String.class));
      }
      else {
          // Get the change order document templates
          queryStr = sqlCache.get("electronicDocument.getChangeOrderQueryStr", params, new SingleColumnRowMapper<>(String.class));
      }

      if (queryStr.isPresent()) {
          try {
              pandaDocs = pandaDocService.findTemplatesByName(queryStr.get());
          } catch (Exception e) {
              log.error("ELECTRONIC: find templates error {}", e.getMessage());
              e.printStackTrace();
          }
      }
      // If no templates are found, get the templates that have the State abbreviation in the name
      if (pandaDocs.isEmpty()) {
          Optional<String> stateQueryStr = sqlCache.get("electronicDocument.getStateQueryStr", params, new SingleColumnRowMapper<>(String.class));
          if (stateQueryStr.isPresent()) {
              try {
                  return pandaDocService.findTemplatesByName(stateQueryStr.get()).toString();
              } catch (Exception e) {
                  log.error("ELECTRONIC: find by name error {}", e.getMessage());
                  e.printStackTrace();
              }
          }
      }

      return pandaDocs.toString();
  }

  public String generateDoc(Long projectId, String templateId) throws Exception {
      return pandaDocService.generateElectronicDocument(projectId, templateId);
  }

}
