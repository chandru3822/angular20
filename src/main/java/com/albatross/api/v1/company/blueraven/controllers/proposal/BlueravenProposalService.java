package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.aurora.*;
import com.albatross.api.config.AppProperties;
import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.InvalidStateApiException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.LockedProposalException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.UnapprovedPostalCodeProposalException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.mappers.ProposalDesignMapper;
import com.albatross.api.v1.company.blueraven.controllers.proposal.mappers.ProposalMapper;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalPostalCodeStatus;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalResource;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.query.ProposalQuery;
import com.albatross.api.v1.company.blueraven.controllers.proposal.query.ProposalToolQuery;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.customFieldValues.CustomFieldValueQuery;
import com.albatross.api.v1.flow.services.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.HostAccess;
import org.graalvm.polyglot.Value;
import org.springframework.core.io.Resource;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.web.client.RestClient;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.text.NumberFormat;
import java.util.*;
import java.util.function.Predicate;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class BlueravenProposalService {
  private static final Long CREATE_PROPOSAL_DESIGN_ID = 3507L;
  private static final Long ZIP_CODE_APPROVAL_ID = 3546L;
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;
  private final CustomFieldValueService customFieldValueService;
  private final ProjectProcessStepService projectProcessStepService;
  private final AutoTriggerHandlerService autoTriggerHandlerService;
  private final ProjectService projectService;
  private final ProposalTemplateService proposalTemplateService;
  private final AttachmentService attachmentService;
  private final AppProperties appProperties;
  private final SecurityService securityService;
  private final ProposalVersionService proposalVersionService;
  private final AuroraProxy auroraProxy;

  public Page<ProposalProject> getProposalProjects(String query, Pageable pageable) {
    Map<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProposalProject> results =
      sqlCache.queryBySql(ProposalQuery.getProjects, params, ProposalProject.class);
    Integer count = sqlCache.queryForObjectBySql(ProposalQuery.getProjectsCount, params, Integer.class);
    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public Optional<ProposalProjectDetails> getProposalProjectById(Long id) {
    Map<String, Object> params = new HashMap<>();
    params.put("id", id);
    /* note: closerAppointmentStart was hacked/manually adjusted to
     return closerAppointmentStart - 450 mins so that both mobile and web,
     who were both already subtracting 30 mins, would change to 8 hours without requiring a
     mobile release */
    return sqlCache.getBySql(ProposalQuery.getProjectById, params, ProposalProjectDetails.class);
  }

  public void syncDesign(Long ppsId, String designId) {
    try {
      //set the process step status
      projectProcessStepService.setStatus(
        ppsId,
        2L, //root: complete
        2L, //company complete
        3L); //cancelled for any existing actives (should never be one)

      //handle auto triggers again
      autoTriggerHandlerService.handlePpsAutoTriggersAfterStatusUpdate(ppsId);

      AuroraProxy.AssetList results = auroraProxy.getDesignAssets(designId);
      //only upload to our side for CAD Auto Screenshot types and only do 1 of them
      Optional<AuroraAssetDTO> asset = results.getAssets().stream().filter(a -> a.getAssetType().equals("CAD Auto Screenshot")).findFirst();

      if (asset.isPresent()) {
        String filename = asset.get().getFilename() != null ? asset.get().getFilename() : "Aurora_Sales_AI_Upload.png";
        Resource resource = getResourceFromUrl(asset.get().getUrl());

        if (resource != null) {
          try (InputStream attachmentStream = resource.getInputStream()) {
            projectProcessStepService.addAttachmentByInputStream(
              ppsId,
              936L, //attachment type for 2D Proposal Image
              resource.contentLength(),
              MediaType.IMAGE_PNG_VALUE,
              filename,
              attachmentStream,
              filename);
          }
        }
      }
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  public Resource getResourceFromUrl(String url) {
    RestClient build = RestClient.builder()
      .requestFactory(new JdkClientHttpRequestFactory(HttpClient.newBuilder()
        .followRedirects(HttpClient.Redirect.NORMAL)
        .build()))
      .baseUrl(url)
      .build();

    return build
      .get()
      .accept(MediaType.APPLICATION_JSON)
      .retrieve()
      .body(Resource.class);
  }

  public AuroraDesignWrappedDTO duplicateExistingProposalAi(String auroraUserId, Long projectId, String designId, List<com.albatross.api.v1.flow.model.CustomFieldValue> values, Boolean useExactDesign) {
    //this function needs to:
    //try/catch finding a design by id
    //if successful, try/catch finding all designs on that same project and getting the first one ever created
    //if successful, duplicate that design
    //if successful, create a Create Proposal Design process step from that design
    //populate Utility Company, Estimated Annual Consumption, Design Name, and Design ID fields on that process step
    //set that process step status
    //either returns the aurora design url or just the design ID and frontend can handle url
    try {
      //get the design object for a design id we know of
      AuroraProxy.DesignSummary designSummary = auroraProxy.getDesignSummary(designId);
      if (designSummary.getProjectId().isPresent()) {
        //update the owner in aurora to the person creating the new design
        auroraProxy.updateAuroraProjectOwner(designSummary.getProjectId().get(), auroraUserId);

        //if not using the exact design id passed in then, using the project id of ^^ that design, get all designs for that project in aurora
        AuroraDesignListDTO designsForProject = new AuroraDesignListDTO();
        if (!useExactDesign) {
          designsForProject = auroraProxy.getDesignsForProject(designSummary.getProjectId().get());
        }

        if (useExactDesign || (null != designsForProject && null != designsForProject.getDesigns() && !designsForProject.getDesigns().isEmpty())) {

          //get the oldest one which is the last one in this array.
          AuroraDesignNotWrappedDTO firstDesign;
          if (useExactDesign) {
            firstDesign = new AuroraDesignNotWrappedDTO();
            //this is the only field we use and the first if check ensures this id is valid
            firstDesign.setId(designId);
          } else {
            firstDesign = designsForProject.getDesigns().stream().reduce((first, second) -> second).get();
          }

          //get the design name to use when duplicating
          com.albatross.api.v1.flow.model.CustomFieldValue designNameField = values.stream().filter(v -> v.getCustomFieldGroupAssignmentId().equals(26300L)).findFirst().orElse(null);
          String designName = null != designNameField ? designNameField.getTextValue() : null;
          //duplicate that first design with the design name passed in
          AuroraDesignWrappedDTO auroraDesignWrappedDTO = auroraProxy.duplicateDesign(firstDesign.getId(), designName);

          if (null != auroraDesignWrappedDTO.getId()) {
            //find the design on our side that is using the firstDesignId...check the designedByAuroraField
            Boolean designedByAurora = useExactDesign ? false : getDesignedByAuroraValue(projectId, firstDesign.getId());

            //then create the new pps
            handleNewPpsForAuroraDesign(projectId, auroraDesignWrappedDTO.getId(), values, designedByAurora);

            return auroraDesignWrappedDTO;
          } else {
            throw new RuntimeException("Error: Unable to duplicate DESIGN for project: " + designSummary.getProjectId().get());
          }
        } else {
          throw new RuntimeException("Error: Unable to find any DESIGNS for project: " + designSummary.getProjectId().get());
        }
      } else {
        throw new RuntimeException("Error: Unable to find original DESIGN for design: " + designId);
      }
    } catch (Exception e) {
      log.error("AURORA: Error Duplicating: {}", e.getMessage());
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        e.getMessage(),
        new Exception());
    }
  }

  public Boolean getDesignedByAuroraValue(Long projectId, String firstDesignId) {
    //using the first created aurora design id, find our pps using that design and find the designed by aurora value
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("firstDesignId", firstDesignId);

    Optional<Boolean> result = sqlCache.queryForObjectOptionalBySql(ProposalQuery.getDesignedByAuroraValue, params, Boolean.class);

    return result.orElse(false);
  }

  public AuroraDesignWrappedDTO doProposalAiRequest(Long projectId, List<com.albatross.api.v1.flow.model.CustomFieldValue> values) {
    Map<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    //first check to see if they are an existing aurora user
    Optional<String> auroraUserId = getAuroraUserId();

    if (auroraUserId.isPresent()) {
      //then check for any existing design id on a Create Proposal Design step, if found use the oldest, then do duplicateExistingProposalAi
      Optional<String> oldestDesignId = sqlCache.queryForObjectOptionalBySql(ProposalQuery.getOldestDesignIdForProject, params, String.class);
      if (oldestDesignId.isPresent()) {
        return duplicateExistingProposalAi(auroraUserId.get(), projectId, oldestDesignId.get(), values, false);
      } else {
        //then check for any existing design id on a Create Predesign step, if found use the oldest then do new function to be made
        Optional<String> createPredesignDesignId = sqlCache.queryForObjectOptionalBySql(ProposalQuery.getDesignIdForCreatePredesignStep, params, String.class);
        if (createPredesignDesignId.isPresent()) {
          return duplicateExistingProposalAi(auroraUserId.get(), projectId, createPredesignDesignId.get(), values, true);
        } else {
          //if none of those then createNewAuroraProjectAndDesign
          return createNewAuroraProjectAndDesign(auroraUserId.get(), projectId, values);
        }
      }
    } else {
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        "You can't create an Aurora design without an Aurora account. Contact SalesHR to get an Aurora account created.",
        new Exception());
    }
  }

  public Optional<String> getAuroraUserId() {
    User currentUser = securityService.getCurrentUser();
    Map<String, Object> params = new HashMap<>();
    params.put("userId", currentUser.getId());

    Optional<String> auroraUserId = sqlCache.queryForObjectOptionalBySql(ProposalQuery.getAuroraUserId, params, String.class);

    //if we dont have it stored locally try to find it from aurora then save it locally
    if (auroraUserId.isEmpty()) {
      try {
        AuroraUserListDTO users = auroraProxy.getUserList();
        Optional<AuroraUser> matchingUser = users.getUsers().stream().filter(u -> u.getEmail().equalsIgnoreCase(currentUser.getEmail())).findFirst();
        if (matchingUser.isPresent()) {
          //if an aurora user id was found, save it locally
          params.put("auroraUserId", matchingUser.get().getId());
          sqlCache.queryBySql(ProposalQuery.saveAuroraUserId, params, String.class);
          //return that id
          return Optional.ofNullable(matchingUser.get().getId());
        }
      } catch (IOException e) {
        throw new RuntimeException(e);
      }
    }

    return auroraUserId;
  }

  public void doUpdateMonthlyUsage(String projectId, List<Double> monthlyInputs){
      Optional<String> auroraUserId = getAuroraUserId();

      if (auroraUserId.isPresent()) {
          auroraProxy.updateAuroraDesignWithMonthlyEnergyUsage(auroraUserId.get(), projectId, monthlyInputs);
      } else {
          throw new ResponseStatusException(
                  HttpStatus.BAD_REQUEST,
                  "You can't create an Aurora design without an Aurora account. Contact SalesHR to get an Aurora account created.",
                  new Exception());
      }

  }
  public AuroraDesignWrappedDTO createNewAuroraProjectAndDesign(String auroraUserId, Long projectId, List<com.albatross.api.v1.flow.model.CustomFieldValue> values) {
    //this function needs to:
    //try/catch creating an aurora project
    //if successful, try/catch creating an aurora design with that project
    //if successful, create a Create Proposal Design process step
    //populate Utility Company, Estimated Annual Consumption, Design Name, and Design ID fields on that process step
    //set that process step status
    //either returns the aurora design url or just the design ID and frontend can handle url
    //https://v2.aurorasolar.com/projects/656dd9db-3657-4595-8344-a30f225b5686/designs/b9cfac2b-0f06-4e79-90cb-94f84e675a6d/e-proposal
    try {
      Optional<com.albatross.api.v1.flow.model.CustomFieldValue> nameFieldValue = values.stream().filter(v -> v.getCustomFieldGroupAssignmentId() == 26300).findFirst();
      if (nameFieldValue.isPresent()) {
        Project project = projectService.getProject(projectId).orElseThrow(NotFoundException::new);
        AuroraProjectDTO auroraProject = auroraProxy.createProject(project, auroraUserId);
        if (null != auroraProject.getId()) {
          AuroraDesignWrappedDTO auroraDesign = auroraProxy.createDesign(auroraProject.getId(), nameFieldValue.get().getTextValue());
          if (null != auroraDesign.getId()) {
            handleNewPpsForAuroraDesign(projectId, auroraDesign.getId(), values, true);
            return auroraDesign;
          } else {
            throw new RuntimeException("Error: Unable to create DESIGN for project: " + projectId);
          }
        } else {
          throw new RuntimeException("Error: Unable to create PROJECT for project: " + projectId);
        }
      } else {
        throw new RuntimeException("Error: No design name given for project: " + projectId);
      }
    } catch (Exception e) {
      log.error("AURORA: {}", e.getMessage());
      throw new ResponseStatusException(
        HttpStatus.BAD_REQUEST,
        e.getMessage(),
        new Exception());
    }
  }

  public void handleNewPpsForAuroraDesign(Long projectId, String designId, List<com.albatross.api.v1.flow.model.CustomFieldValue> values, Boolean designByAuroraValue) {
    //insert a new Create Proposal Design Process Step
    Long ppsId = insertProjectProcessStep(projectId, 3507L);

    //add the design id to the custom field values
    com.albatross.api.v1.flow.model.CustomFieldValue designFieldValue = new com.albatross.api.v1.flow.model.CustomFieldValue();
    designFieldValue.setTextValue(designId);
    designFieldValue.setCustomFieldGroupAssignmentId(22560L);
    values.add(designFieldValue);

    //add the Designed By Aurora boolean custom field value here
    com.albatross.api.v1.flow.model.CustomFieldValue designedByAuroraFieldValue = new com.albatross.api.v1.flow.model.CustomFieldValue();
    designedByAuroraFieldValue.setBooleanValue(designByAuroraValue);
    designedByAuroraFieldValue.setCustomFieldGroupAssignmentId(26962L);
    values.add(designedByAuroraFieldValue);

    //insert/update the custom field values
    customFieldValueService.updateCustomFieldValues(values, ppsId, com.albatross.api.v1.flow.enums.ObjectType.PROCESS_STEP);

    //set the process step status
    projectProcessStepService.setStatus(
      ppsId,
      1L, //root: active
      1649L, //company Pending Aurora Adjustments
      3L); //cancelled for any existing actives (should never be one)

    //do auto triggers at the end - per lowry
    autoTriggerHandlerService.handlePpsAutoTriggersAfterCfvUpdate(projectId, ppsId, values);
    autoTriggerHandlerService.handlePpsAutoTriggersAfterStatusUpdate(ppsId);

    //return the design id
  }

  public List<ProposalDesign> getProposalDesigns(@NonNull Long projectId) {
    List<ProposalDesign> results =
      sqlCache.queryBySql(
        ProposalQuery.getDesigns,
        Map.of("projectId", projectId), new ProposalDesignMapper<>(ProposalDesign.class, om));
    for (ProposalDesign pd : results) {
      for (Attachment a : pd.getAttachments()) {
        attachmentService.setAttachmentPresignedUrl(a);
      }
    }
    return results;
  }

  public Optional<ProposalDesign> getActiveDesign(@NonNull Long projectId) {
    Optional<ProposalDesign> activeDesign = sqlCache.getBySql(ProposalQuery.getActiveDesign, Map.of("projectId", projectId), new ProposalDesignMapper<>(ProposalDesign.class, om));

    if (activeDesign.isPresent() && activeDesign.get().getCompanyProcessStepStatusTypeId().equals(1649L)) {
      //need to get the aurora project id if this was created by aurora stuff
      try {
        AuroraProxy.DesignSummary designSummary = auroraProxy.getDesignSummary(activeDesign.get().getDesignId());
        if (designSummary.getProjectId().isPresent()) {
          activeDesign.get().setAuroraProjectId(designSummary.getProjectId().get());
        }
      } catch (IOException e) {
        throw new ResponseStatusException(
          HttpStatus.NOT_FOUND,
          "AURORA: Failed to find design summary for design " + activeDesign.get().getDesignId(),
          new Exception());
      }
    }

    return activeDesign;
  }

  public List<ProposalDesign> requestNewDesign(
    Long projectId,
    String description,
    String dueDate,
    List<MultipartFile> attachments,
    List<MultipartFile> utilityBillAttachments,
    @NonNull UserAccountDetails currentUser)
    throws IOException {

    final Project project = projectService.getProject(projectId).orElseThrow(NotFoundException::new);

    final ProposalPostalCodeStatus proposalPostalCodeStatus = getPostalCodeApprovalStatus(project.getId());
    if (!proposalPostalCodeStatus.isApproved()) {
      throw new UnapprovedPostalCodeProposalException();
    }

    // create new "create proposal design" step (active, cancel others)
    Long ppsId = insertProjectProcessStep(projectId, CREATE_PROPOSAL_DESIGN_ID);

    // upload attachments to the new step
    if (null != attachments && !attachments.isEmpty()) {
      for (MultipartFile a : attachments) {
        // Proposal Request Supporting Files
        String displayName = a.getName().substring(0, Integer.min(a.getName().length(), 100));
        projectProcessStepService.addAttachment(a, ppsId, 946L, displayName);
      }
    }
    // upload utility bill attachments to the new step
    if (null != utilityBillAttachments && !utilityBillAttachments.isEmpty()) {
      for (MultipartFile a : utilityBillAttachments) {
        String displayName = a.getName().substring(0, Integer.min(a.getName().length(), 100));
        projectService.addAttachment(a, projectId, 47L, displayName); // Utility Bill
      }
    }

    // save custom field data for description and due date
    // cfgaId for description field on proposal = 22679
    updateCustomFieldValue(projectId, currentUser.getTrueUserId(), 22679L, description);

    // cfgaId for due date field on proposal = 22678
    if (!ObjectUtils.isEmpty(dueDate)) {
      updateCustomFieldValue(projectId, currentUser.getTrueUserId(), 22678L, dueDate);
    }

    return getProposalDesigns(projectId);
  }

  private void updateCustomFieldValue(@NonNull Long projectId, @NonNull Long userId, @NonNull Long cfgaId, @NonNull String value) {
    final Map<String, Object> params = Map.of("projectId", projectId, "userId", userId, "cfgaId", cfgaId, "value", value);
    sqlCache.queryBySql(CustomFieldValueQuery.updateValueUsingFunction, params, String.class);
  }

  private Long insertProjectProcessStep(@NonNull Long projectId, @NonNull Long processStepId) {
    return projectProcessStepService.insertProjectProcessStep(
      projectId, processStepId, null, null, true, 1L, 3L);
  }

  public Optional<Long> getProposalVersionByProposalId(@NonNull Long proposalId) {
    return sqlCache.queryForObjectOptionalBySql(ProposalQuery.getProposalVersionId, Map.of("proposalId", proposalId), Long.class);
  }

  public List<ProposalCommissionDetail> getProposalCommissionDetails(@NonNull Long proposalId, Long financialProductId, Long brsProductId) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalId", proposalId);
    params.put("financialProductId", financialProductId);
    params.put("brsProductId", brsProductId);

    return sqlCache.queryBySql(ProposalQuery.getCommissionDetails, params, ProposalCommissionDetail.class);
  }

  public void updateProposalVersion(@NonNull Long proposalId, @NonNull Long versionId, @NonNull UserAccountDetails details) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalId", proposalId);
    params.put("versionId", versionId);
    params.put("userId", details.getTrueUserId());

    sqlCache.updateBySql(ProposalQuery.updateProposalVersion, params);
  }

  /*
    Find the org associated to a user where the org type is `Sales Dealer Partner`
   */
  private Optional<Long> findUserOrgId(Long userId) {
    if (userId == null) {
      return Optional.empty();
    }

    return sqlCache.getBySql(ProposalQuery.findUserOrgId, Map.of("userId", userId), new SingleColumnRowMapper<>(Long.class));
  }

  private static final Long excludedStateCustomFieldId = 405L;
  private static final Long dealerFieldId = 407L;
  private static final Long financialProductFieldId = 128L;
  private static final Long rebatesFieldId = 415L;
  private static final Long commissionStrategyFieldId = 467L;
  private static final Long flowPanelBrandFieldId = 204L;
  private static final Long brsPanelBrandFieldId = 138L;
  private static final Long brsPricePerWattFieldId = 724L;
  private static final Long brsOtherMaxDiscount = 135L;


  public Optional<Proposal> getProposal(@NonNull Long proposalId, Long userId) {
    Optional<Long> userOrgId = findUserOrgId(userId);
    Optional<Proposal> result =
      sqlCache.getBySql(
        ProposalQuery.get,
        Map.of("proposalId", proposalId),
        new ProposalMapper<>(Proposal.class, om));

    if (result.isEmpty()) {
      return result;
    }

    Proposal proposal = result.get();

    List<ProposalStepCustomFieldValue> proposalDesignStepValues = getProjectProcessStepValues(proposal.getProjectProcessStepId());

    // then populate the list of values
    blueravenCustomFieldGroupService.handleCustomListOfValue(
      proposal.getCustomFieldGroups(), 3L, proposal.getProjectId());

    Long proposalVersionId = proposal.getProposalVersionId();

    // a little post-processing to filter out records that are not part of the current proposal version
    proposal.getCustomFieldGroups()
      .forEach(cfg -> cfg.getCustomFieldValues().stream()
        .filter(cfv -> cfv.getCustomFieldId() != null)
        .forEach(cfv -> {
          if (financialProductFieldId.equals(cfv.getCustomFieldId())) {
            // BRS needs to filter out financial products by state
            filterCustomFieldValues(cfv,
              excludeValuesByCustomFieldId(proposal.getProposalVersionId(), cfv, excludedStateCustomFieldId, proposal.getStateId(), "PROPOSAL_FINANCE_PRODUCTS"), true);

            proposalDesignStepValues.stream()
              .filter(p -> p.getFieldId().equals(flowPanelBrandFieldId))
              .findFirst()
              .ifPresent(proposalStepCustomFieldValue ->
                filterCustomFieldValues(cfv,
                  getProposalVersionValues(proposalVersionId, cfv.getCustomFieldId(), brsPanelBrandFieldId, Long.valueOf(proposalStepCustomFieldValue.getValue().toString()), "PROPOSAL_FINANCE_PRODUCTS"), true));
          }

          //BRS needs to filter out dealers by associated org
          if (dealerFieldId.equals(cfv.getCustomFieldId()) && userOrgId.isPresent()) {
            filterCustomFieldValues(cfv, filterDealersByOrg(proposalVersionId, userOrgId.get()), true);
          }

          if (rebatesFieldId.equals(cfv.getCustomFieldId())) {
            filterCustomFieldValues(cfv, filterRebatesByStateAndUtility(proposalVersionId, proposal.getStateId(), proposal.getUtilityCompanyId()), false);
          }

          if (commissionStrategyFieldId.equals(cfv.getCustomFieldId())) {
            filterCustomFieldValues(cfv, filterCommissionStrategiesByUser(proposalVersionId, userId), false);
          }

          if (brsPricePerWattFieldId.equals(cfv.getCustomFieldId()) && proposal.getMinPricePerWatt() != null) {
            cfv.setMinValue(proposal.getMinPricePerWatt().doubleValue());
          }

          if (brsOtherMaxDiscount.equals(cfv.getCustomFieldId()) && proposal.getMaxDiscountAmount() != null) {
            cfv.setMaxValue(proposal.getMaxDiscountAmount().doubleValue());
          }

        }));

    //filter out any custom fields that _should_ have a list of values but don't (previously filtered)
    proposal.getCustomFieldGroups()
      .forEach(cfg -> cfg.setCustomFieldValues(cfg.getCustomFieldValues().stream()
        .filter(getCustomFieldValuePredicate())
        .toList()));

    return Optional.of(proposal);
  }

  private Predicate<CustomFieldValue> getCustomFieldValuePredicate() {
    return cfv -> {
      if (!cfv.getHasListValues()) {
        return true;
      }
      return cfv.getListOfValues() != null && !cfv.getListOfValues().isEmpty();
    };
  }

  private void filterCustomFieldValues(CustomFieldValue cfv, List<Long> filter, boolean skipIfEmpty) {
    if (filter == null || (filter.isEmpty() && skipIfEmpty)) {
      // only filter if we get some results back... otherwise, we are assuming not filtering is required
      return;
    }

    List<ListOfValue> listOfValues = cfv.getListOfValues().stream()
      .filter(v -> filter.contains(v.getId()))
      .sorted(Comparator.comparing(ListOfValue::getName))
      .toList();

    cfv.setListOfValues(listOfValues);
  }

  private List<Long> filterCommissionStrategiesByUser(@NonNull Long proposalVersionId, @NonNull Long userId) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("userId", userId);

    return sqlCache.queryBySql(ProposalQuery.filterCommissionStrategiesByUser, params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<Long> filterDealersByOrg(@NonNull Long proposalVersionId, Long orgId) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("orgId", orgId);

    return sqlCache.queryBySql(ProposalQuery.filterProposalDealerOrgs, params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<Long> filterRebatesByStateAndUtility(@NonNull Long proposalVersionId, Long stateId, Long utilityId) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("utilityId", utilityId);
    params.put("stateId", stateId);

    return sqlCache.queryBySql(ProposalQuery.filterRebatesByStateAndUtility, params, new SingleColumnRowMapper<>(Long.class));
  }

  private List<Long> getProposalVersionValues(Long proposalVersionId, Long targetCustomFieldId, Long customFieldId, Long intValue, String objectCode) {
    Map<String, Object> params = new HashMap<>();
    params.put("versionId", proposalVersionId);
    params.put("fieldId", targetCustomFieldId);
    params.put("objectCode", objectCode);
    params.put("customFieldId", customFieldId);
    params.put("intValue", intValue);

    return sqlCache.queryBySql(ProposalToolQuery.findProposalVersionValues, params, new SingleColumnRowMapper<>(Long.class));
  }

  //exclusions
  private List<Long> excludeValuesByCustomFieldId(Long proposalVersionId, CustomFieldValue cfv, Long filterKeyId, Object filterVal, String objectCode) {
    return proposalVersionService.getProposalValueFilterIdsByCustomFieldAndValue(proposalVersionId, cfv.getCustomFieldId(), filterKeyId, filterVal, objectCode)
      .stream()
      .filter(Objects::nonNull)
      .toList();
  }

  /**
   * Filters the custom fields of a proposal based on the visibility of their custom field group assignment
   *
   * @param proposal the proposal to filter the custom fields for
   * @param values
   */
  private void filterCustomFieldsByVisibility(Proposal proposal, List<ProposalStepCustomFieldValue> values) {
    if (values.isEmpty()) {
      return;
    }

    log.debug("[Proposal] Found {} custom field values for proposalId={}", values.size(), proposal.getId());

    try (Context ctx = Context.newBuilder("js").allowHostAccess(HostAccess.ALL).build()) {
      ctx.getBindings("js").putMember("context", new ProposalJsContext(values));

      for (CustomFieldGroup customFieldGroup : proposal.getCustomFieldGroups()) {
        List<CustomFieldValue> filteredList = customFieldGroup.getCustomFieldValues().stream()
          .filter(cfv -> {
            if (cfv.getVisibility() == null || cfv.getVisibility().trim().isEmpty()) {
              return true;
            }
            Value jsEval = ctx.eval("js", cfv.getVisibility());
            if (!jsEval.isBoolean()) {
              log.warn("[Proposal] Expression '{}' must evaluate to a boolean", cfv.getVisibility());
              return true;
            }
            return jsEval.asBoolean();
          })
          .toList();

        customFieldGroup.setCustomFieldValues(filteredList);
      }
    } catch (Exception e) {
      log.error("[Proposal] Error filtering custom fields", e);
    }
  }

  /**
   * Retrieves the custom field values associated with a project process step.
   *
   * @param projectProcessStepId the ID of the project process step
   * @return a list of ProposalStepCustomFieldValue objects representing the custom field values
   */
  private List<ProposalStepCustomFieldValue> getProjectProcessStepValues(Long projectProcessStepId) {
    try {
      TypeReference<List<ProposalStepCustomFieldValue>> typeReference = new TypeReference<>() {
      };

      Map<String, Object> params = Map.of("ppsId", projectProcessStepId);
      String retVal = sqlCache.queryForObjectBySql(ProposalQuery.getProjectProcessStepCustomFieldValuesAsJSON, params, String.class);

      return om.readValue(retVal, typeReference);
    } catch (Exception e) {
      log.error("[Proposal] Error generating context", e);
      return List.of();
    }
  }

  private static final Long DISCOUNT_AMOUNT_CFGA_ID = 167L;
  private static final Long SYSTEM_SIZE_CFGA_ID = 140L;

  @Transactional
  public Optional<Proposal> updateProposalCustomFieldValues(@NonNull Long proposalId, @NonNull List<CustomFieldValue> cfvs, @NonNull UserAccountDetails currentUser) {
    final Proposal unlockedProposal = getUnlockedProposal(proposalId, currentUser.getId());

    cfvs.stream()
      .filter(cfv -> cfv.getCustomFieldGroupAssignmentId().equals(DISCOUNT_AMOUNT_CFGA_ID))
      .filter(cfv -> cfv.getNumericValue() != null)
      .findFirst()
      .ifPresent(customFieldValue -> validateProposalDiscount(customFieldValue.getNumericValue(), unlockedProposal));

    blueravenCustomFieldValueService.updateCustomFieldValues(cfvs, unlockedProposal.getId(), ObjectType.PROPOSAL);

    return getProposal(proposalId, currentUser.getId());
  }

  private Optional<CustomFieldValue> getCustomFieldValue(Proposal proposal, Long cfgaId) {
    return proposal.getCustomFieldGroups().stream()
      .flatMap(cfg -> cfg.getCustomFieldValues().stream())
      .filter(cfv -> cfv.getCustomFieldGroupAssignmentId().equals(cfgaId))
      .findFirst();
  }

  public Optional<Proposal> addProposal(Proposal proposal, @NonNull UserAccountDetails currentUser) {

    Long proposalVersionId = getProposalVersion(proposal.getProjectProcessStepId(), currentUser.getTrueUserId());

    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("projectProcessStepId", proposal.getProjectProcessStepId());
    params.put("userId", currentUser.getTrueUserId());

    Long id = sqlCache.updateBySqlReturningId(ProposalQuery.insert, params, "id").longValue();
    return getProposal(id, currentUser.getId());
  }

  private Long getProposalVersion(Long processStepId, Long currentUserId) {
    Map<String, Object> params = Map.of("ppsId", processStepId, "currentUserId", currentUserId);
    return sqlCache.queryForObjectOptionalBySql(ProposalQuery.findVersionByProjectProcessStep, params, Long.class)
      .orElseThrow(() -> new ApiException("No published proposals available"));
  }

  public Optional<ProposalTemplate> getProposalTemplate(Long proposalId, Long templateId, ProposalGeneratedType generatedType, boolean isDebug) {
    try {
      Map<String, Object> context = getCalculatedProposalValues(proposalId, generatedType, false);
      return Optional.of(proposalTemplateService.getTemplateById(templateId, context, generatedType, isDebug));
    } catch (ApiException apiException) {
      throw apiException;
    } catch (Exception e) {
      log.error("[Proposal] Unknown error generating proposal", e);
      throw new ApiException("Error generating proposal template");
    }
  }

  public Optional<ProposalResource> generateProposalPDF(Long proposalId, Long templateId) {
    return getSimpleProposal(proposalId)
      .flatMap(proposal -> {
        try {
          final var context = getCalculatedProposalValues(proposalId, ProposalGeneratedType.PRINT, false);
          Resource pdf = proposalTemplateService.generatePdf(templateId, context, false);
          return Optional.of(new ProposalResource(pdf, proposal, context));
        } catch (ApiException apiException) {
          throw apiException;
        } catch (Exception e) {
          log.error("[Proposal] Error generating proposal", e);
          throw new ApiException("Unknown error generating proposal");
        }
      });
  }

  private Map<String, Object> getCalculatedProposalValues(
    @NonNull Long proposalId, ProposalGeneratedType proposalGeneratedType, boolean insertPropLogHistory) {

    Map<String, Object> context = new HashMap<>();

    try {
      Map<String, Object> params = Map.of(
        "proposalId", proposalId,
        "insertPropLogHistory", insertPropLogHistory,
        "currentUserId", securityService.getCurrentUser().trueUserId());

      context = sqlCache.queryForMapBySql(ProposalQuery.getCalculatedProposalValues, params);
    } catch (DataAccessException dataAccessException) {
      String errorMessage = dataAccessException.getCause().getMessage().split("\n")[0];
      errorMessage = errorMessage.replace("ERROR: ", "").trim();
      log.error("[Proposal] SQL Error generating calculated values for proposalId={}, msg={}", proposalId, errorMessage);
      throw new ApiException("Unable to generate proposal: " + errorMessage);
    } catch (Exception e) {
      log.error("[Proposal] Error generating calculated values for proposalId={}, msg={}", proposalId, e.getMessage());
    }

    try {
      Map<String, Object> proposalAttachments =
        sqlCache
          .queryBySql(ProposalQuery.getAttachments, Map.of("proposalId", proposalId), Attachment.class)
          .stream()
          .collect(
            Collectors.toMap(
              this::mapAttachmentTypeToProposalType,
              attachment -> buildUri(attachment.getUuid().toString(), proposalGeneratedType),
              (img1, img2) -> img1)); // if we have multiple just return one

      context.putAll(proposalAttachments);

    } catch (Exception e) {
      log.error("[Proposal] Error fetching attachments for proposalId={}, msg={}", proposalId, e.getMessage());
    }
    return context;
  }

  @Transactional
  public Optional<Proposal> lockProposal(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    Proposal unlockedProposal = getSimpleProposal(proposalId).filter(p -> !p.isLocked()).orElseThrow(LockedProposalException::new);

    //insert values immediately in to proposal log history
    getCalculatedProposalValues(unlockedProposal.getId(), ProposalGeneratedType.PRINT, true);

    sqlCache.updateBySql(ProposalQuery.setLocked, Map.of("id", unlockedProposal.getId(), "modifiedById", currentUser.getTrueUserId()));
    return getProposal(unlockedProposal.getId(), currentUser.getId());
  }

  private void validateProposalDiscount(BigDecimal amount, Proposal proposal) {
    getCustomFieldValue(proposal, SYSTEM_SIZE_CFGA_ID)
      .filter(cfv -> cfv.getNumericValue() != null)
      .filter(cfv -> cfv.getNumericValue().compareTo(BigDecimal.ZERO) > 0)
      .orElseThrow(() -> new InvalidStateApiException("System size is required for discount amount"));

    BigDecimal maxProposalDiscountAmount = proposal.getMaxDiscountAmount();
    if (amount != null && (amount.compareTo(BigDecimal.ZERO) <= 0 || amount.compareTo(maxProposalDiscountAmount) > 0)) {
      String currencyFormat = NumberFormat.getCurrencyInstance().format(maxProposalDiscountAmount);
      String errorMessage = "Proposal discount must be greater than $0 and less than max of %s".formatted(currencyFormat);

      throw new InvalidStateApiException(errorMessage);
    }
  }

  @Transactional
  public void archiveProposal(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    final Proposal proposal = getSimpleProposal(proposalId)
      .orElseThrow(() -> new NotFoundException("Proposal id=%s does not exist".formatted(proposalId)));

    if (proposal.isLocked()) {
      throw new InvalidStateApiException("Proposal has already been locked");
    }

    sqlCache.updateBySql(ProposalQuery.setArchived, Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }


  public void setCreditCheckSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.updateBySql(ProposalQuery.setCreditChecked, Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  public void setDocsAsSubmitted(@NonNull Long proposalId, @NonNull LoanDocType loanDocType, @NonNull UserAccountDetails details) {
    switch (loanDocType) {
      case FINANCE_DOCS -> setFinanceDocsSubmitted(proposalId, details);
      case INSTALLATION_AGREEMENT -> setInstallationAgreementDocsSubmitted(proposalId, details);
    }
  }

  private void setFinanceDocsSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.updateBySql(ProposalQuery.setFinanceDocsSent, Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  private void setInstallationAgreementDocsSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.updateBySql(ProposalQuery.setInstallationAgreementDocsSent, Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  public void setProposalAsProcessed(@NonNull Long proposalId) {
    sqlCache.updateBySql(ProposalQuery.setProcessed, Map.of("id", proposalId));
  }

  public Proposal setProposalName(@NonNull Long proposalId, @NonNull String proposalName, @NonNull UserAccountDetails currentUser) {
    final Proposal proposal = getUnlockedProposal(proposalId, currentUser.getId());

    sqlCache.updateBySql(ProposalQuery.setProposalName, Map.of(
      "id", proposalId,
      "name", proposalName.trim(),
      "modifiedById", currentUser.getTrueUserId()));

    //update name on proposal to avoid another db call
    proposal.setName(proposalName);

    return proposal;
  }

  private Proposal getUnlockedProposal(@NonNull Long proposalId, Long userId) {
    return getProposal(proposalId, userId).filter(p -> !p.isLocked()).orElseThrow(LockedProposalException::new);
  }

  public Optional<Proposal> getSimpleProposal(@NonNull Long proposalId) {
    return sqlCache.getBySql(ProposalQuery.simple, Map.of("proposalId", proposalId), new ProposalMapper<>(Proposal.class, om));
  }

  private URI buildUri(String uuid, ProposalGeneratedType proposalGeneratedType) {
    final var params = ProposalGeneratedType.getOptions(proposalGeneratedType);

    return UriComponentsBuilder.fromUri(appProperties.getHost())
      .pathSegment("public", "image", uuid)
      .queryParams(params)
      .build()
      .toUri();
  }

  private String mapAttachmentTypeToProposalType(Attachment attachment) {
    if (attachment.getAttachmentTypeId() == 936) {
      return "2D_PROPOSAL_IMAGE";
    }

    if (attachment.getAttachmentTypeId() == 937) {
      return "3D_PROPOSAL_IMAGE";
    }

    return "UNKNOWN";
  }

  public Optional<Proposal> createProposalDuplicate(@NonNull Long proposalId, @NonNull Long userId) {
    Long newProposalId = sqlCache.queryForObjectBySql(ProposalQuery.duplicate, Map.of(
      "proposalId", proposalId,
      "userId", userId
    ), Long.class);
    return getProposal(newProposalId, userId);
  }

  public ProposalPostalCodeStatus checkPostalCodeApproval(@NonNull Long projectId) {
    final Project project = projectService.getProject(projectId).orElseThrow(NotFoundException::new);
    return getPostalCodeApprovalStatus(project.getId());
  }

  @Transactional
  public Optional<ProposalDesign> requestPostalCodeApproval(@NonNull Long projectId, String comments, @NonNull Long userId) {
    final Long ppsId = insertProjectProcessStep(projectId, ZIP_CODE_APPROVAL_ID);
    log.debug("[Proposal] Requested Postal Code Approval - PPS #{}", ppsId);

    if (comments != null) {
//    Zip Code Approval Notes
      updateCustomFieldValue(projectId, userId, 23623L, comments);
    }

    return getActiveDesign(projectId);
  }

  /**
   * Checks to see if project postal code is in the approved list of postal codes for the current published proposal settings
   *
   * @return {@link ProposalPostalCodeStatus}
   */
  private ProposalPostalCodeStatus getPostalCodeApprovalStatus(@NonNull Long projectId) {
    final ProposalPostalCodeStatus other = new ProposalPostalCodeStatus();
    other.setApproved(false);

    final Map<String, Object> params = Map.of("projectId", projectId);
    return sqlCache.getBySql(ProposalQuery.postalCodeApproved, params, ProposalPostalCodeStatus.class).orElse(other);
  }

  public List<Long> getLockedProposalsBatchForProcessing() {
    return sqlCache.queryBySql(ProposalQuery.getLockedProposalsForProcessing, Map.of(), new SingleColumnRowMapper<>(Long.class));
  }

  @Transactional
  public void setProcessingErrorMessage(Long proposalId, String errorMessage, Long modifiedBy) {
    sqlCache.updateBySql(ProposalQuery.setProcessingErrorMessage,
      Map.of("id", proposalId, "errorMsg", errorMessage, "modifiedById", modifiedBy));
  }
}
