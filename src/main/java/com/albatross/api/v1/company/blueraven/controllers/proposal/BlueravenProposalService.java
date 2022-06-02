package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.config.PropertiesConfiguration;
import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.enums.ObjectType;
import com.albatross.api.v1.company.blueraven.models.*;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldGroupService;
import com.albatross.api.v1.company.blueraven.services.BlueravenCustomFieldValueService;
import com.albatross.api.v1.flow.model.Attachment;
import com.albatross.api.v1.flow.model.User;
import com.albatross.api.v1.flow.services.AttachmentService;
import com.albatross.api.v1.flow.services.ProjectProcessStepService;
import com.albatross.api.v1.flow.services.ProjectService;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3)")
@RequiredArgsConstructor
public class BlueravenProposalService {
  private final SqlCache sqlCache;
  private final ObjectMapper om;
  private final SecurityService securityService;
  private final BlueravenCustomFieldGroupService blueravenCustomFieldGroupService;
  private final BlueravenCustomFieldValueService blueravenCustomFieldValueService;
  private final ProjectProcessStepService projectProcessStepService;
  private final ProjectService projectService;
  private final AttachmentService attachmentService;
  private final PropertiesConfiguration propertiesConfiguration;

  public Page<ProposalProject> getProposalProjects(String query, Pageable pageable) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());

    List<ProposalProject> results =
        sqlCache.query("proposal.getProjects", params, ProposalProject.class);
    Integer count = sqlCache.queryForObject("proposal.getProjectsCount", params, Integer.class);

    return new PageImpl<>(
        results, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), count);
  }

  public List<ProposalDesign> getProposalDesigns(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    List<ProposalDesign> results =
        sqlCache.query(
            "proposal.getDesigns", params, new ProposalDesignMapper<>(ProposalDesign.class, om));
    for (ProposalDesign pd : results) {
      for (Attachment a : pd.getAttachments()) {
        attachmentService.setAttachmentPresignedUrl(a);
      }
    }
    return results;
  }

  public Optional<ProposalDesign> getActiveDesign(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);

    return sqlCache.get(
        "proposal.getActiveDesign", params, new ProposalDesignMapper<>(ProposalDesign.class, om));
  }

  public List<ProposalDesign> requestNewDesign(
      Long projectId, String description, String dueDate, List<MultipartFile> attachments, List<MultipartFile> utilityBillAttachments)
      throws IOException {
    User user = securityService.getCurrentUser();

    // create new "create proposal design" step (active, cancel others)
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("processStepId", 3507);
    params.put("userPositionId", null);
    params.put("userId", user.trueUserId());
    params.put("companyId", 3L);
    params.put("parentProjectProcessStepId", null);
    params.put("initialCompanyProcessStepStatusTypeId", 1L);
    params.put("existingCompanyProcessStepStatusTypeId", 3L);

    Long ppsId =
        sqlCache.queryForObject("projectProcessStep.insertProjectProcessStep", params, Long.class);
    //    Long ppsId = 3822530L;
    log.info("the new ppsId is: {}", ppsId);
    // upload attachments to the new step
    if (null != attachments && attachments.size() > 0) {
      for (MultipartFile a : attachments) {
        projectProcessStepService.addAttachment(a, ppsId, 946L); //Proposal Request Supporting Files
      }
    }
    // upload utility bill attachments to the new step
    if (null != utilityBillAttachments && utilityBillAttachments.size() > 0) {
      for (MultipartFile a : utilityBillAttachments) {
        projectService.addAttachment(a, projectId, 47L); //Utility Bill
      }
    }

    // save custom field data for description and due date
    // cfgaId for description field on proposal = 22679
    params.put("cfgaId", 22679);
    params.put("value", description);
    sqlCache.query("customFieldValue.updateValueUsingFunction", params, String.class);

    // cfgaId for due date field on proposal = 22678
    params.put("cfgaId", 22678);
    params.put("value", dueDate);
    sqlCache.query("customFieldValue.updateValueUsingFunction", params, String.class);

    return getProposalDesigns(projectId);
  }

  public Optional<Proposal> getProposal(Long proposalId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("proposalId", proposalId);

    Optional<Proposal> result =
        sqlCache.get("proposal.get", params, new ProposalMapper<>(Proposal.class, om));

    // handle custom list of values
    result.ifPresent(
        proposal ->
            blueravenCustomFieldGroupService.handleCustomListOfValue(
                proposal.getCustomFieldGroups(), 3L, proposal.getProjectId()));

    return result;
  }

  public Optional<Proposal> updateProposal(Long proposalId, List<CustomFieldValue> cfvs) {
    blueravenCustomFieldValueService.updateCustomFieldValues(
        cfvs, proposalId, ObjectType.PROPOSAL.textValue());

    return getProposal(proposalId);
  }

  public Optional<Proposal> addProposal(Proposal proposal) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());

    Long proposalVersionId =
        sqlCache.queryForObject("proposal.getCurrentVersion", params, Long.class);

    params.put("proposalVersionId", proposalVersionId);
    params.put("projectProcessStepId", proposal.getProjectProcessStepId());
    params.put("userId", user.getId());

    Long id = sqlCache.updateReturningId("proposal.insert", params, "id").longValue();
    return getProposal(id);
  }

  public Map<String, Object> getCalculatedProposalValues(
      @NonNull Long proposalId, boolean insertPropLogHistory) {

    final Optional<Proposal> proposal = getProposal(proposalId);
    if (proposal.isEmpty()) {
      throw new NotFoundException("Proposal id=%s does not exist".formatted(proposalId));
    }

    final Map<String, Object> context =
        sqlCache.queryForMap(
            "proposal.getCalculatedProposalValues",
            Map.of("proposalId", proposalId, "insertPropLogHistory", insertPropLogHistory));

    final Map<String, Object> proposalAttachments =
        getProposalAttachments(proposalId).stream()
            .collect(
                Collectors.toMap(
                    this::mapAttachmentTypeToProposalType,
                    attachment ->
                        "%s/public/attachment/%s/%s"
                            .formatted(
                                propertiesConfiguration.getApplicationHostUrl(),
                                attachment.getId(),
                                attachment.getUuid())));

    context.putAll(proposalAttachments);

    return context;
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

  private List<Attachment> getProposalAttachments(@NonNull Long proposalId) {
    return sqlCache.query(
        "proposal.getAttachments", Map.of("proposalId", proposalId), Attachment.class);
  }

  public static class ProposalDesignMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProposalDesignMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<List<Proposal>> proposalsRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "proposals", new JsonCollectionDeserializer(proposalsRef, objectMapper));

      TypeReference<List<Attachment>> attachmentsRef = new TypeReference<>() {};
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
      TypeReference<List<CustomFieldGroup>> cfgRef = new TypeReference<>() {};
      bw.registerCustomEditor(
          List.class, "customFieldGroups", new JsonCollectionDeserializer(cfgRef, objectMapper));
    }
  }
}
