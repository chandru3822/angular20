package com.albatross.api.v1.company.blueraven.controllers.proposal;

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
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.ListOfValue;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.queries.customFieldValues.CustomFieldValueQuery;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.graalvm.polyglot.Context;
import org.graalvm.polyglot.HostAccess;
import org.graalvm.polyglot.Value;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.text.NumberFormat;
import java.util.*;
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
  private final ProjectProcessStepService projectProcessStepService;
  private final ProjectService projectService;
  private final ProposalTemplateService proposalTemplateService;
  private final AttachmentService attachmentService;
  private final AppProperties appProperties;
  private final SecurityService securityService;
  private final ProposalVersionService proposalVersionService;

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
    return sqlCache.getBySql(ProposalQuery.getActiveDesign, Map.of("projectId", projectId), new ProposalDesignMapper<>(ProposalDesign.class, om));
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
//    log.debug("the new ppsId is: {}", ppsId);
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

  public Optional<ProposalCommission> getProposalCommissionDetails(@NonNull Long proposalId) {
    return sqlCache.getBySql(ProposalQuery.getCommissionDetails, Map.of("proposalId", proposalId), new ProposalCommissionMapper<>(ProposalCommission.class, om));
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
  private static final Long allowedOrgFieldId = 413L;
  private static final Long dealerFieldId = 407L;
  private static final Long financialProductFieldId = 128L;
  private static final Long rebatesFieldId = 415L;


  public Optional<Proposal> getProposal(@NonNull Long proposalId, Long userId) {

    Optional<Long> userOrgId = findUserOrgId(userId);

    Optional<Proposal> result =
      sqlCache.getBySql(
        ProposalQuery.get,
        Map.of("proposalId", proposalId),
        new ProposalMapper<>(Proposal.class, om));

    result.ifPresent(this::filterCustomFieldsByVisibility);

    // handle custom list of values
    result.ifPresent(
      proposal ->
        blueravenCustomFieldGroupService.handleCustomListOfValue(
          proposal.getCustomFieldGroups(), 3L, proposal.getProjectId()));

    // a little post-processing to filter out records that are not part of the current proposal version
    result.ifPresent(proposal -> proposal.getCustomFieldGroups()
      .forEach(cfg -> cfg.getCustomFieldValues().stream()
        .filter(cfv -> cfv.getCustomFieldId() != null)
        .filter(CustomFieldValue::getHasListValues)
        .forEach(cfv -> {
          // BRS needs to filter out financial products by state
          if (financialProductFieldId.equals(cfv.getCustomFieldId())) {
            filterValuesByCustomFieldId(proposal.getProposalVersionId(), cfv, excludedStateCustomFieldId, proposal.getStateId());
          }

          //BRS needs to filter out dealers by associated org
          if (dealerFieldId.equals(cfv.getCustomFieldId()) && userOrgId.isPresent()) {
            filterValuesByCustomFieldId(proposal.getProposalVersionId(), cfv, allowedOrgFieldId, userOrgId.get());
          }

          if (rebatesFieldId.equals(cfv.getCustomFieldId())) {
            List<Long> ids = filterRebatesByStateAndUtility(proposal.getProposalVersionId(), proposal.getStateId(), proposal.getUtilityCompanyId());
            List<ListOfValue> listOfValues = cfv.getListOfValues().stream()
              .filter(v -> ids.contains(v.getId()))
              .sorted(Comparator.comparing(ListOfValue::getName))
              .toList();

            cfv.setListOfValues(listOfValues);
          }
        })));

    //filter out any custom fields that _should_ have a list of values but don't (previously filtered)
    result.ifPresent(proposal -> proposal.getCustomFieldGroups()
      .forEach(cfg -> {
        List<CustomFieldValue> list = cfg.getCustomFieldValues().stream()
          .filter(cfv -> {
            if (!cfv.getHasListValues()) {
              return true;
            }
            return cfv.getListOfValues() != null && !cfv.getListOfValues().isEmpty();
          })
          .toList();

        cfg.setCustomFieldValues(list);
      }));

    return result;
  }

  private List<Long> filterRebatesByStateAndUtility(@NonNull Long proposalVersionId, Long stateId, Long utilityId) {
    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("utilityId", utilityId);
    params.put("stateId", stateId);

    return sqlCache.queryBySql(ProposalQuery.filterRebatesByStateAndUtility, params, new SingleColumnRowMapper<>(Long.class));
  }

  private void filterValuesByCustomFieldId(Long proposalVersionId, CustomFieldValue cfv, Long filterKeyId, Object filterVal) {
    List<Long> customFieldFilteredValues = proposalVersionService.getProposalValueFilterIdsByCustomFieldAndValue(proposalVersionId, cfv.getCustomFieldId(), filterKeyId, filterVal)
      .stream()
      .filter(Objects::nonNull)
      .toList();

    // only filter if we get some results back... otherwise, we are assuming not filtering is required
    if (!customFieldFilteredValues.isEmpty()) {
      List<ListOfValue> listOfValues = cfv.getListOfValues().stream()
        .filter(v -> customFieldFilteredValues.contains(v.getId()))
        .sorted(Comparator.comparing(ListOfValue::getName))
        .toList();

      cfv.setListOfValues(listOfValues);
    }
  }

  /**
   * Filters the custom fields of a proposal based on the visibility of their custom field group assignment
   *
   * @param proposal the proposal to filter the custom fields for
   */
  private void filterCustomFieldsByVisibility(Proposal proposal) {
    List<ProposalStepCustomFieldValue> values = getProjectProcessStepValues(proposal.getProjectProcessStepId());

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

  private void saveProjectDiscountAmount(Long projectId, BigDecimal amount) {
    //we divide the value in half because the user is only responsible for half, BRS will cover the other part
    int count = sqlCache.updateBySql(ProposalQuery.updateProposalDiscountAmount, Map.of("projectId", projectId, "amount", amount.divide(new BigDecimal(2), RoundingMode.HALF_UP)));
    if (count == 0) {
      log.warn("[Proposal] Unable to update commission_forfeited_by_closer amount for projectId={}", projectId);
    }
  }

  public Optional<Proposal> addProposal(Proposal proposal, @NonNull UserAccountDetails currentUser) {

    Long proposalVersionId = getProposalVersion(proposal.getProjectProcessStepId(), currentUser.getTrueUserId());

    Map<String, Object> params = new HashMap<>();
    params.put("proposalVersionId", proposalVersionId);
    params.put("projectProcessStepId", proposal.getProjectProcessStepId());
    params.put("userId", currentUser.getId());

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
    } catch (Exception e) {
      log.error("[Proposal] Error generating proposal", e);
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
        } catch (Exception e) {
          log.error("[Proposal] Error generating proposal", e);
          throw new ApiException("Error generating proposal");
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
    Proposal unlockedProposal = getUnlockedProposal(proposalId, currentUser.getId());

    //check to see if the proposal has a discount amount added
    getCustomFieldValue(unlockedProposal, DISCOUNT_AMOUNT_CFGA_ID)
      .filter(cfv -> cfv.getNumericValue() != null)
      .ifPresent(cfv -> {
        validateProposalDiscount(cfv.getNumericValue(), unlockedProposal);
        saveProjectDiscountAmount(unlockedProposal.getProjectId(), cfv.getNumericValue());
      });

    sqlCache.updateBySql(ProposalQuery.setLocked, Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));

    //insert values immediately in to proposal log history
    getCalculatedProposalValues(proposalId, ProposalGeneratedType.PRINT, true);

    return getProposal(proposalId, currentUser.getId());
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
