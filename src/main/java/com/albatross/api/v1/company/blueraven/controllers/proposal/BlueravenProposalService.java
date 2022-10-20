package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.config.AppProperties;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.LockedProposalException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.exceptions.UnapprovedPostalCodeProposalException;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalPostalCodeStatus;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.UserAccountDetails;
import com.albatross.api.v1.flow.model.project.Project;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.github.sonus21.rqueue.core.RqueueMessageEnqueuer;
import freemarker.template.TemplateException;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.ObjectUtils;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.IOException;
import java.net.URI;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3) && hasFeatureAccess('PROPOSALS')")
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
  private final RqueueMessageEnqueuer rqueueMessageEnqueuer;
  private final AppProperties appProperties;

  public Page<ProposalProject> getProposalProjects(String query, Pageable pageable) {
    Map<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProposalProject> results =
      sqlCache.query("proposal.getProjects", params, ProposalProject.class);
    Integer count = sqlCache.queryForObject("proposal.getProjectsCount", params, Integer.class);

    return new PageImpl<>(
      results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public List<ProposalDesign> getProposalDesigns(@NonNull Long projectId) {
    List<ProposalDesign> results =
      sqlCache.query(
        "proposal.getDesigns", Map.of("projectId", projectId), new ProposalDesignMapper<>(ProposalDesign.class, om));
    for (ProposalDesign pd : results) {
      for (Attachment a : pd.getAttachments()) {
        attachmentService.setAttachmentPresignedUrl(a);
      }
    }
    return results;
  }

  public Optional<ProposalDesign> getActiveDesign(@NonNull Long projectId) {
    return sqlCache.get("proposal.getActiveDesign", Map.of("projectId", projectId), new ProposalDesignMapper<>(ProposalDesign.class, om));
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
    log.debug("the new ppsId is: {}", ppsId);
    // upload attachments to the new step
    if (null != attachments && attachments.size() > 0) {
      for (MultipartFile a : attachments) {
        // Proposal Request Supporting Files
        projectProcessStepService.addAttachment(a, ppsId, 946L);
      }
    }
    // upload utility bill attachments to the new step
    if (null != utilityBillAttachments && utilityBillAttachments.size() > 0) {
      for (MultipartFile a : utilityBillAttachments) {
        projectService.addAttachment(a, projectId, 47L); // Utility Bill
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
    sqlCache.query("customFieldValue.updateValueUsingFunction", params, String.class);
  }

  private Long insertProjectProcessStep(@NonNull Long projectId, @NonNull Long processStepId) {
    return projectProcessStepService.insertProjectProcessStep(
      projectId, processStepId, null, null, true, 1L, 3L);
  }

  public Optional<Proposal> getProposal(@NonNull Long proposalId) {

    Optional<Proposal> result =
      sqlCache.get(
        "proposal.get",
        Map.of("proposalId", proposalId),
        new ProposalMapper<>(Proposal.class, om));

    // handle custom list of values
    result.ifPresent(
      proposal ->
        blueravenCustomFieldGroupService.handleCustomListOfValue(
          proposal.getCustomFieldGroups(), 3L, proposal.getProjectId()));

    return result;
  }

  public Optional<Proposal> updateProposalCustomFieldValues(Long proposalId, List<CustomFieldValue> cfvs) {
    final Proposal unlockedProposal = getUnlockedProposal(proposalId);
    blueravenCustomFieldValueService.updateCustomFieldValues(cfvs, unlockedProposal.getId(), ObjectType.PROPOSAL);
    return getProposal(proposalId);
  }

  public Optional<Proposal> addProposal(Proposal proposal, @NonNull UserAccountDetails currentUser) {

    Map<String, Object> params = new HashMap<>();
    params.put("companyId", currentUser.getCompanyId());

    Long proposalVersionId =
      sqlCache.queryForObject("proposal.getCurrentVersion", params, Long.class);

    if (proposalVersionId == null) {
      throw new ApiException("No published proposals available");
    }

    params.put("proposalVersionId", proposalVersionId);
    params.put("projectProcessStepId", proposal.getProjectProcessStepId());
    params.put("userId", currentUser.getId());

    Long id = sqlCache.updateReturningId("proposal.insert", params, "id").longValue();
    return getProposal(id);
  }

  public Optional<ProposalTemplate> getProposalTemplate(Long proposalId, Long templateId, ProposalGeneratedType generatedType, boolean isDebug) {
    return getProposal(proposalId)
      .map(proposal -> {
        Map<String, Object> context = new HashMap<>();
        try {
          context = getCalculatedProposalValues(proposal.getId(), generatedType, false);
        } catch (Exception e) {
          log.error("[BRS PROPOSAL] Error generating proposal", e);

          if (!(e instanceof DataIntegrityViolationException)) {
            throw new ApiException("Error generating proposal template");
          }
        }

        return proposalTemplateService.getTemplateById(templateId, context, generatedType, isDebug);
      });
  }

  public Optional<ContentAwareByteArrayOutputStream> generateProposalPDF(Long proposalId, Long templateId, boolean isFinal) {
    return getProposal(proposalId)
      .map(proposal -> {
        try {
          final var context = getCalculatedProposalValues(proposal.getId(), ProposalGeneratedType.PRINT, isFinal);
          return proposalTemplateService.generatePdf(templateId, context, false);
        } catch (IOException | TemplateException e) {
          log.error("Error generating proposal template");
          throw new ApiException(e);
        }
      });
  }

  private Map<String, Object> getCalculatedProposalValues(
    @NonNull Long proposalId, ProposalGeneratedType proposalGeneratedType, boolean insertPropLogHistory) {

    getProposal(proposalId)
      .orElseThrow(() -> new NotFoundException("Proposal id=%s does not exist".formatted(proposalId)));

    final Map<String, Object> context =
      sqlCache.queryForMap(
        "proposal.getCalculatedProposalValues",
        Map.of("proposalId", proposalId, "insertPropLogHistory", insertPropLogHistory));

    final Map<String, Object> proposalAttachments =
      sqlCache
        .query("proposal.getAttachments", Map.of("proposalId", proposalId), Attachment.class)
        .stream()
        .collect(
          Collectors.toMap(
            this::mapAttachmentTypeToProposalType,
            attachment -> buildUri(attachment.getUuid().toString(), proposalGeneratedType),
            (img1, img2) -> img1)); // if we have multiple just return one

    context.putAll(proposalAttachments);

    return context;
  }

  @Transactional
  public Optional<Proposal> lockProposal(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.update("proposal.setLocked", Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
    rqueueMessageEnqueuer.enqueue("proposal_job", UUID.randomUUID().toString(), new ProposalJobMessage(proposalId));
    return getProposal(proposalId);
  }

  @Transactional
  public void archiveProposal(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    final Proposal proposal = getProposal(proposalId)
      .orElseThrow(() -> new NotFoundException("Proposal id=%s does not exist".formatted(proposalId)));

    if (proposal.isLocked()) {
      throw new ApiException("Proposal has already been locked");
    }

    sqlCache.update("proposal.setArchived", Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }


  public void setCreditCheckSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.update("proposal.setCreditChecked", Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  public void setDocsAsSubmitted(@NonNull Long proposalId, @NonNull LoanDocType loanDocType, @NonNull UserAccountDetails details) {
    switch (loanDocType) {
      case FINANCE_DOCS -> setFinanceDocsSubmitted(proposalId, details);
      case INSTALLATION_AGREEMENT -> setInstallationAgreementDocsSubmitted(proposalId, details);
    }
  }

  private void setFinanceDocsSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.update("proposal.setFinanceDocsSent", Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  private void setInstallationAgreementDocsSubmitted(@NonNull Long proposalId, @NonNull UserAccountDetails currentUser) {
    sqlCache.update("proposal.setInstallationAgreementDocsSent", Map.of("id", proposalId, "modifiedById", currentUser.getTrueUserId()));
  }

  public void setProposalAsProcessed(@NonNull Long proposalId) {
    sqlCache.update("proposal.setProcessed", Map.of("id", proposalId));
  }

  public Proposal setProposalName(@NonNull Long proposalId, @NonNull String proposalName, @NonNull UserAccountDetails currentUser) {
    final Proposal proposal = getUnlockedProposal(proposalId);

    sqlCache.update("proposal.setProposalName", Map.of(
      "id", proposalId,
      "name", proposalName.trim(),
      "modifiedById", currentUser.getTrueUserId()));

    //update name on proposal to avoid another db call
    proposal.setName(proposalName);

    return proposal;
  }

  private Proposal getUnlockedProposal(@NonNull Long proposalId) {
    return getProposal(proposalId).filter(p -> !p.isLocked()).orElseThrow(LockedProposalException::new);
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
    Long newProposalId = sqlCache.queryForObject("proposal.duplicate", Map.of(
      "proposalId", proposalId,
      "userId", userId
    ), Long.class);
    return getProposal(newProposalId);
  }

  public ProposalPostalCodeStatus checkPostalCodeApproval(@NonNull Long projectId) {
    final Project project = projectService.getProject(projectId).orElseThrow(NotFoundException::new);
    return getPostalCodeApprovalStatus(project.getId());
  }

  @Transactional
  public Optional<ProposalDesign> requestPostalCodeApproval(@NonNull Long projectId, String comments, @NonNull Long userId) {
    final Long ppsId = insertProjectProcessStep(projectId, ZIP_CODE_APPROVAL_ID);
    log.debug("Requested Postal Code Approval - PPS #{}", ppsId);

    if (comments != null) {
//    Zip Code Approval Notes
      updateCustomFieldValue(projectId, userId, 23623L, comments);
    }

    return getActiveDesign(projectId);
  }

  /**
   * Checks to see if project postal code is in the approved list of postal codes for the current published proposal settings
   *
   * @return
   */
  private ProposalPostalCodeStatus getPostalCodeApprovalStatus(@NonNull Long projectId) {
    final ProposalPostalCodeStatus other = new ProposalPostalCodeStatus();
    other.setApproved(false);

    final Map<String, Object> params = Map.of("projectId", projectId);
    return sqlCache.get("proposal.postalCodeApproved", params, ProposalPostalCodeStatus.class).orElse(other);
  }

  public static class ProposalDesignMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProposalDesignMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Proposal>> proposalsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "proposals", new JsonCollectionDeserializer(proposalsRef, objectMapper));

      TypeReference<List<Attachment>> attachmentsRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "attachments", new JsonCollectionDeserializer(attachmentsRef, objectMapper));
    }
  }

  public static class ProposalMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProposalMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<CustomFieldGroup>> cfgRef = new TypeReference<>() {
      };
      bw.registerCustomEditor(
        List.class, "customFieldGroups", new JsonCollectionDeserializer(cfgRef, objectMapper));
    }
  }
}
