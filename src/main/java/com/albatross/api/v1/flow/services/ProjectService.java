package com.albatross.api.v1.flow.services;

import com.albatross.api.convert.JsonCollectionDeserializer;
import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.*;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.collect.ImmutableMap;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.expression.ExpressionParser;
import org.springframework.expression.spel.standard.SpelExpressionParser;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.Assert;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@Service
public class ProjectService {

  // @TODO: Needs to be cleaned up. A lot of this should go into a ProjectProcessStepService file

  private final SqlCache sqlCache;

  private final SecurityService securityService;

  private final ProcessStepActionService processStepActionService;

  private final ProjectProcessStepRequirementService projectProcessStepRequirementService;

  private final AttachmentService attachmentService;

  private final ProjectProcessStepService projectProcessStepService;

  private final ProcessStepStatusService processStepStatusService;

  private String s3Url = "https://%s.s3.amazonaws.com/%s";

  private final AmazonS3 s3;

  private final ObjectMapper om;

  @Value("${aws.storageBucket}")
  private String storageBucket;

  public List<Project> getProjectsForProcess(Long processId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForCompanyProcess", ImmutableMap.of("companyId", user.getCompanyId() , "processId", processId), Project.class);
  }

  public Page<Project> searchProjects(String query, Pageable pageable) {
    User user = securityService.getCurrentUser();
    HashMap<String, Object> params = new HashMap<>();
    params.put("companyId", user.getCompanyId());
    params.put("query", query);
    params.put("limit", pageable.getPageSize());
    params.put("offset", pageable.getOffset());
    List<Project> projects = sqlCache.query("project.search", params, Project.class);
    Integer total = sqlCache.queryForObject("project.searchCount", params, Integer.class);
    return new PageImpl<>(projects, PageRequest.of(pageable.getPageNumber(), pageable.getPageSize()), total);
  }

  public Optional<Project> getProject(Long projectId) {
    return sqlCache.get("project.get", ImmutableMap.of("projectId", projectId), Project.class);
  }

  public Optional<Project> insertProject(Long customerId, Long processId, String projectName) {
    User user = securityService.getCurrentUser();

    Long id = sqlCache.updateReturningId("project.insert",
        ImmutableMap.of("customerId", customerId,
                        "createdById", user.getId(),
                        "projectName", projectName,
                        "processId", processId), "id").longValue();

    return getProject(id);
  }

  public List<Attachment> getAttachments(Long projectId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    List<Attachment> attachments = sqlCache.query("project.getAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket);
  }

  // @TODO: this needs to work better with the attachment service's create method. Too much duped code right now and I hate it
  public Attachment addAttachment(MultipartFile file, Long projectId, Long attachmentTypeId) throws IOException {
    User currentUser = securityService.getCurrentUser();

    if (file.isEmpty()) {
      throw new RuntimeException("File cannot be empty");
    }

    //get keyPattern from attachmentType
    AttachmentType attachmentType = attachmentService.getAttachmentType(attachmentTypeId);
    String key = String.format( currentUser.getAwsBucket() + "/" + attachmentType.getKeyPattern(), UUID.randomUUID());

    ObjectMetadata metadata = new ObjectMetadata();
    metadata.setContentLength(file.getSize());
    metadata.setContentType(file.getContentType());
    metadata.setCacheControl("public, max-age=31536000");

    PutObjectRequest objectRequest = new PutObjectRequest(storageBucket, key, new ByteArrayInputStream(file.getBytes()), metadata);

    PutObjectResult result = s3.putObject(objectRequest
      .withCannedAcl(CannedAccessControlList.PublicRead));

    String url = s3.getUrl(currentUser.getAwsBucket(), key).toExternalForm();

    HashMap<String, Object> params = new HashMap<>();
    params.put("filename", file.getOriginalFilename());
    params.put("contentType", file.getContentType());
    params.put("key", key);
    params.put("size", file.getSize());
    params.put("createdById", currentUser.getId());
    params.put("attachmentTypeId", attachmentTypeId);

    Long attachmentId = sqlCache.updateReturningId("attachment.create", params, "id").longValue();

    params.clear();
    params.put("projectId", projectId);
    params.put("attachmentId", attachmentId);
    params.put("createdById", currentUser.getId());

    sqlCache.update("project.addAttachment", params);

    return attachmentService.findById(storageBucket, attachmentId);
  }

  public List<Project> getProjectsForCustomer(Long customerId) {
    User user = securityService.getCurrentUser();
    return sqlCache.query("project.getAllForCustomer", ImmutableMap.of("companyId", user.getCompanyId(), "customerId", customerId), Project.class);
  }

  public List<ProjectProcessStep> getProcessStepsByProjectId(Long projectId) {
    return sqlCache.query("project.getProcessStepsByProjectId", ImmutableMap.of("projectId", projectId), new ProjectProcessStepMapper<>(ProjectProcessStep.class, om));
  }

  public ProjectProcessStep getProjectProcessStep(Long stepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("stepId", stepId);
    ProjectProcessStep step = sqlCache.get("project.getProjectProcessStep", params, new ProjectProcessStepMapper<>(ProjectProcessStep.class, om)).orElse(null);

    if (step != null) {
      step.setActions(processStepActionService.getActionsForStep(step.getProcessStepId()));
    }

    return step;
  }

  public ProjectProcessStep saveProjectProcessStep(ProjectProcessStep pps) {
    User currentUser = securityService.getCurrentUser();

    //todo: handle the rest of the save ... if any - see userService.saveUser

    handleSavingCustomFieldValues(pps.getCustomFieldGroups(), pps.getProjectProcessStepId());

    return getProjectProcessStep(pps.getProjectProcessStepId());
  }

  public List<Attachment> getProjectProcessStepAttachments(Long projectProcessStepId) {
    HashMap<String, Object> params = new HashMap<>();
    params.put("projectProcessStepId", projectProcessStepId);
    List<Attachment> attachments = sqlCache.query("project.getProjectProcessStepAttachments", params, Attachment.class);
    return attachmentService.getAttachmentPresignedUrls(attachments, storageBucket);
  }

  public Boolean fieldHasValue (CustomFieldValue cv) {
    return null != cv.getDateValue() || null != cv.getTimestampValue() || null != cv.getBooleanValue() || null != cv.getTextValue()
        || null != cv.getNumericValue() || null != cv.getIntValue() || null != cv.getIntArrayValue();
  }

  public void handleSavingCustomFieldValues(List<CustomFieldGroup> groups, Long primaryId){
    User currentUser = securityService.getCurrentUser();
    for(CustomFieldGroup group : groups) {
      for(CustomFieldValue cfv : group.getCustomFieldValues()){
        //todo: only save if something changed
        if(fieldHasValue(cfv)) {
          HashMap<String, Object> params = new HashMap<>();
          params.put("dateValue", cfv.getDateValue());
          params.put("timestampValue", cfv.getTimestampValue());
          params.put("booleanValue", null != cfv.getBooleanValue() ? cfv.getBooleanValue() : false);
          params.put("textValue", cfv.getTextValue());
          params.put("numericValue", cfv.getNumericValue());
          params.put("intValue", cfv.getIntValue());
          params.put("intArrayValue", cfv.getIntArrayValue());
          params.put("projectProcessStepId", primaryId);
          params.put("customFieldGroupAssignmentId", cfv.getCustomFieldGroupAssignmentId());

          if(null != cfv.getId()){
            params.put("id", cfv.getId());
            params.put("modifiedById", currentUser.getId());
            sqlCache.update("customFieldValues.updateProjectProcessStepCustomFieldValue", params);
          } else {
            params.put("createdById", currentUser.getId());
            sqlCache.update("customFieldValues.insertProjectProcessStepCustomFieldValue", params);
          }
        }
      }
    }
  }

  public ProjectProcessStep insertProjectProcessStep(Long projectId, Long processStepId, Long statusTypeId, Long userPositionId) {
    User user = securityService.getCurrentUser();

    HashMap<String, Object> params = new HashMap<>();
    params.put("projectId", projectId);
    params.put("processStepId", processStepId);
    params.put("statusTypeId", statusTypeId);
    params.put("userPositionId", userPositionId);
    params.put("createdById", user.getId());
    Long id = sqlCache.updateReturningId("project.insertProjectProcessStep", params, "id").longValue();

    return getProjectProcessStep(id);
  }

  @Transactional
  public void performAction(Long actionId, Long projectProcessStepId) {
    /*
      **High level psuedo logic:**

        * transaction all queries so current state is kept on any errors
        * Performance will be key here as it will be hit a lot and business logic will grow

        * gather required data
        * set the parent step to the specified status
        * set them to the active status
        * recursively check if child processes have children and auto-triggered until all auto-triggered child process steps have been created with active statuses
     */

    List<CompanyProcessStepStatusType> companyStatusTypes = processStepStatusService.getStatusTypesForCompany();
    Optional<CompanyProcessStepStatusType> activeStatusType = companyStatusTypes.stream().filter(type -> type.getProcessStepStatusTypeId() == 1).findFirst();
    final Long activeStatusTypeId = activeStatusType.map(CompanyProcessStepStatusType::getProcessStepStatusTypeId).orElse(null);

    ProjectProcessStep projectProcessStep = this.getProjectProcessStep(projectProcessStepId);
    ProcessStepAction action = processStepActionService.getActionById(actionId);
    if (action.getCompanyProcessStepStatusTypeId() != null) {
      projectProcessStepService.setStatus(projectProcessStepId, action.getProcessStepStatusTypeId(), action.getCompanyProcessStepStatusTypeId());
    }

    List<ProjectProcessStep> newSteps = new ArrayList<>();
    action.getProcessStepActionChildProcesses().forEach(childStep -> {
      newSteps.add(this.insertProjectProcessStep(projectProcessStep.getProjectId(), childStep.getProcessStepId(), activeStatusTypeId, projectProcessStep.getOwner().getUserId()));
    });

    //@TODO: @humes (or anybody ;-)) use newSteps to recursively check for auto-triggered process step actions on child process steps (recursive to perform auto-triggers for each generation of child process steps)
  }

  public boolean canPerformAction(Long actionId, Long projectProcessStepId) throws Exception {

    ProcessStepAction action = processStepActionService.getActionById(actionId);
    List<ProjectProcessStepRequirement> requirements = projectProcessStepRequirementService.getByProjectProcessStepId(projectProcessStepId);

    // If there are not any requirements, then it can be completed
    if (requirements.isEmpty()) {
      return true;
    }

    // Check to if individual requirements are fulfilled and create a map of true/false with the requirementIds
    // @TODO: Unable to do this with a lambda like requirements.foreach(r ->... while being able to throw an exception ¯\_(ツ)_/¯
    for (ProjectProcessStepRequirement r: requirements) {
      try {
        r.setFulfilled(this.isRequirementMet(r));
      } catch (Exception e) {
        log.error(String.format("Exception while parsing date requirement value for process step requirement ID: %s", r.getId()));
        e.printStackTrace();
        throw e;
      }
    }

    StringBuilder logicString = new StringBuilder();

    // This should now just be creating logic by making a string of all the requirements in order and replacing requirementIds with their respective true/false value
    for (ProcessStepLogic logicStep: action.getProcessStepLogicList()) {
      if (logicStep.getOperationCode() != null) {
          logicString.append(" ").append(logicStep.getOperationCode()).append(" ");
      } else if (logicStep.getProcessStepRequirementId() != null) {
        Optional<ProjectProcessStepRequirement> requirement = requirements.stream().filter(r -> r.getId().equals(logicStep.getProcessStepRequirementId())).findFirst();
        requirement.ifPresent(r -> logicString.append(r.getFulfilled().toString()));
      }
    }

    ExpressionParser parser = new SpelExpressionParser();
    if (logicString.length() > 0) {
      return parser.parseExpression(logicString.toString()).getValue(Boolean.class);
    } else {
      return requirements.stream().allMatch(ProcessStepRequirement::getFulfilled);
    }
  }

  // It's assumed for date data types that it's always a data_type_requirement and never a literal comparison of values
  private boolean isRequirementMet(ProjectProcessStepRequirement r) throws Exception {

    boolean requirementMet = false;

    if (r.getProcessStepRequirementTypeId() == 1) {
//      go through requirement.data_type_id to select the correct value prop. Then use the operation type to dun the correct comparison

        switch (r.getDataTypeId().intValue()) {
          case 1:
            requirementMet = calculateDateRequirement(r);
            break;
          case 2:
            requirementMet = calculateTimestampRequirement(r);
            break;
          case 3:
            requirementMet = calculateBooleanRequirement(r);
            break;
          case 4:
            requirementMet = calculateNumericRequirement(r);
            break;
          case 5:
            requirementMet = calculateTextRequirement(r);
            break;
          case 6:
          case 9:
            requirementMet = (r.getHasListValues() || r.getCompanySystemListId() != null) ? caclulateDropdownRequirement(r) : calculateIntRequirement(r);
            break;
          case 7:
            requirementMet = calculateMultiselectRequirement(r);
            break;
          default:
            //@TODO: blow up with error?
        }
    } else if (r.getProcessStepRequirementTypeId() == 2) {
      Map<String, Object> params = prepareFunctionParams(r);
      String functionSignature = getFunctionSignature(r, params);
      Object returnValue = sqlCache.queryBySql("select * from " + r.getFunctionName(), params, Object.class);
      //@TODO: compare returnValue to the requirement value
    }
    return requirementMet;
  }

  private String getFunctionSignature(ProjectProcessStepRequirement r, Map<String, Object> params) {

    StringBuilder signature = new StringBuilder();

    return signature.toString();
  }

  private Map<String, Object> prepareFunctionParams(ProjectProcessStepRequirement r) throws Exception {
    Map<String, Object> params = new HashMap<>();

    r.getCompanyFunctionParams().forEach(param -> {
      switch (param.getParameterTypeId().intValue()) {
        case 1:
          Long systemValue = null;
          switch (param.getSystemValueId().intValue()) {
            case 1:
              systemValue = securityService.getCurrentUser().getId();
              break;
            case 2:
              systemValue = r.getProjectId();
              break;
            default:
              //@TODO: die a horrible death
          }
          params.put(param.getDisplayOrder().toString(), systemValue);
          break;
        case 2:
          params.put(param.getDisplayOrder().toString(), getTypedDynamicValue(param));
          break;
        case 3:
          try {
            params.put(param.getDisplayOrder().toString(), getParamValueByDataType(param));
          } catch (Exception e) {
            ///@TODO: throw ex
          }
          break;
        default:
          //@TODO: throw exception
      }
    });

    return params;
  }

  private Object getTypedDynamicValue(CompanyFunctionParam param) {

    String startingValue = param.getDynamicValue();
    Object typedValue = null;

    try {
      switch (param.getDataTypeId().intValue()) {
        case 1:
        case 2:
          typedValue = Timestamp.valueOf(startingValue);
          break;
        case 3:
          typedValue = Boolean.parseBoolean(startingValue);
          break;
        case 4:
          typedValue = Double.parseDouble(startingValue);
          break;
        case 5:
          typedValue = startingValue;
          break;
        case 6:
          typedValue = Long.parseLong(startingValue);
          break;
        default:

      }
    } catch (Exception e) {
      //@TODO: die here
    }

    return typedValue;
  }

  private Object getParamValueByDataType(CompanyFunctionParam param) throws Exception {

    Object paramValue = null;

    switch (param.getDataTypeId().intValue()) {
      case 1:
        paramValue = param.getDateValue();
        break;
      case 2:
        paramValue = param.getTimestampValue();
        break;
      case 3:
        paramValue = param.getBooleanValue();
        break;
      case 4:
        paramValue = param.getNumericValue();
        break;
      case 5:
        paramValue = param.getTextValue();
        break;
      case 6:
        paramValue = param.getIntValue();
        break;
      case 7:
        paramValue = param.getIntArrayValue();
        break;
      default:
        //@TODO: throw nasty exception
    }

    return paramValue;
  }

  private boolean calculateMultiselectRequirement(ProjectProcessStepRequirement r) throws Exception {

    List<Integer> fieldValue = r.getIntArrayValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
     try {
       List<Integer> reqValue = r.getListOfValueIds();
       passed = compareMultiselect(fieldValue, reqValue, r.getOperatorTypeId());
     } catch (Exception e) {
       throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", r.getOperatorTypeId()));
     }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 22:
          passed = fieldValue.isEmpty();
          break;
        case 23:
          passed = !fieldValue.isEmpty();
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", r.getOperatorTypeId()));
      }
    }
    return passed;
  }

  private boolean compareMultiselect(List<Integer> numbers, List<Integer> compareNumbers, Long operatorTypeId) throws Exception {

    boolean passed = false;
    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(numbers, compareNumbers);
        break;
      case 2:
        passed = !Objects.equals(numbers, compareNumbers);
        break;
      case 5:
        List<Integer> intersection = numbers.stream().filter(compareNumbers::contains).collect(Collectors.toList());
        passed = !intersection.isEmpty();
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Multiselect with operator of ID: %s", operatorTypeId));
    }
    return passed;
  }

  private boolean caclulateDropdownRequirement(ProjectProcessStepRequirement r) throws Exception {

    Long fieldValue = r.getIntValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        // @TODO: @humes, need to verify a value is properly fetched here if requirement is a system list
        Long reqValue = r.getListOfValueId();
        passed = compareDropdown(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 12:
        case 13:
        case 20:
        case 21:
        case 26:
        case 27:
          passed = compareDropdown(fieldValue, null, r.getOperatorTypeId());
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", r.getOperatorTypeId()));
      }
    }

    return passed;
  }

  private boolean compareDropdown(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Dropdown with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateIntRequirement(ProjectProcessStepRequirement r) throws Exception {

    Long fieldValue = r.getIntValue();
    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        Long reqValue = Long.parseLong(r.getRequirementValue());
        passed = compareInt(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 20:
          passed = fieldValue == null;
          break;
        case 21:
          passed = fieldValue != null;
          break;
        default:
          throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", r.getOperatorTypeId()));
      }
    }

    return passed;
  }

  private boolean compareInt(Long number, Long compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      case 3:
        passed = (number != null && compareNumber != null) && number > compareNumber;
        break;
      case 4:
        passed = (number != null && compareNumber != null) && number < compareNumber;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Int with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateTextRequirement(ProjectProcessStepRequirement r) throws Exception {

    String fieldValue = r.getTextValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        String reqValue = r.getRequirementValue();
        passed = compareText(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (Exception e) {
        throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 18:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue == null;
              break;
            case 2:
              passed = fieldValue != null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
        case 19:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null;
              break;
            case 2:
              passed = fieldValue == null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", r.getOperatorTypeId()));
          }
      }
    }
    return passed;
  }

  private boolean compareText(String text, String compareText, Long operatorTypeId) throws Exception {

    boolean passed = false;

    text = (text != null) ? text.trim().toLowerCase() : "";
    compareText = (compareText != null) ? compareText.trim().toLowerCase() : "";

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = text.equals(compareText);
        break;
      case 2:
        passed = !text.equals(compareText);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Text with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateNumericRequirement(ProjectProcessStepRequirement r) throws Exception {

    Double fieldValue = (r.getNumericValue() == null) ? null : r.getNumericValue().setScale(2, RoundingMode.DOWN).doubleValue();

    boolean passed = false;

    if (r.getDataTypeRequirementId() == null) {
      try {
        Double reqValue = new BigDecimal(r.getRequirementValue()).setScale(2, RoundingMode.DOWN).doubleValue();
        passed = compareNumeric(fieldValue, reqValue, r.getOperatorTypeId());
      } catch(Exception e) {
        throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
      }
    } else {
      switch(r.getDataTypeRequirementId().intValue()) {
        case 16:
            switch (r.getOperatorTypeId().intValue()) {
              case 1:
                passed = fieldValue == null;
                break;
              case 2:
                passed = fieldValue != null;
                break;
              default:
                throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
            }
          break;
        case 17:
          switch (r.getOperatorTypeId().intValue()) {
            case 1:
              passed = fieldValue != null;
              break;
            case 2:
              passed = fieldValue == null;
              break;
            default:
              throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", r.getOperatorTypeId()));
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareNumeric(Double number, Double compareNumber, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = Objects.equals(number, compareNumber);
        break;
      case 2:
        passed = !Objects.equals(number, compareNumber);
        break;
      case 3:
        passed = (number != null && compareNumber != null) && number > compareNumber;
        break;
      case 4:
        passed = (number != null && compareNumber != null) && number < compareNumber;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Numeric with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateBooleanRequirement(ProjectProcessStepRequirement r) throws Exception {

    Boolean fieldValue = r.getBooleanValue();
    Boolean reqValue = Boolean.parseBoolean(r.getRequirementValue());

    boolean passed = false;

    switch (r.getOperatorTypeId().intValue()) {
      case 1:
        passed = fieldValue == reqValue;
        break;
      case 2:
        passed = fieldValue != reqValue;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Boolean with operator of ID: %s", r.getOperatorTypeId()));
    }

    return passed;
  }

  private boolean calculateTimestampRequirement(ProjectProcessStepRequirement r) throws Exception {

    LocalDateTime fieldValue = (r.getTimestampValue() != null) ? r.getTimestampValue().toLocalDateTime().withMinute(0).withSecond(0).withNano(0) : null;
    LocalDateTime now = LocalDateTime.now().withMinute(0).withSecond(0).withNano(0);
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    boolean passed = false;

    if (null == r.getDataTypeRequirementId()) {
      try {
        LocalDateTime reqValue = LocalDateTime.parse(r.getRequirementValue());
        passed = compareDateTimes(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (DateTimeParseException e) {
        throw new Exception(String.format("Unable to parse Timestamp type requirement value of: %s", r.getRequirementValue()));
      }
    } else {
      switch (r.getDataTypeRequirementId().intValue()) {
        case 6:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue.toLocalDate(), now.minusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 7:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue.toLocalDate(), now.plusDays(Long.parseLong(secondaryValue)).toLocalDate(), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 8:
          passed = compareDates(fieldValue.toLocalDate(), now.toLocalDate(), r.getOperatorTypeId());
          break;
        case 9:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(fieldValue, now.minusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 10:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDateTimes(fieldValue, now.plusHours(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 11:
          passed = compareDateTimes(fieldValue, now, r.getOperatorTypeId());
          break;
        case 12:
          try {
            passed = compareNullDateTime(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 13:
          try {
            passed = compareNonNullDateTime(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
      }
    }

    return passed;
  }

  private boolean compareNullDateTime(LocalDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date == null;
        break;
      case 2:
        passed = date != null;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean compareNonNullDateTime(LocalDateTime date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date != null;
        break;
      case 2:
        passed = date == null;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean compareDateTimes(LocalDateTime date, LocalDateTime compareDate, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = (compareDate == null) ? date == null : date.isEqual(compareDate);
        break;
      case 2:
        passed = (compareDate == null) ? date != null : !date.isEqual(compareDate);
        break;
      case 3:
        passed = date.isAfter(compareDate);
        break;
      case 4:
        passed = date.isBefore(compareDate);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean calculateDateRequirement(ProjectProcessStepRequirement r) throws Exception {

    LocalDate fieldValue = (r.getDateValue() !=  null) ? r.getDateValue().toLocalDateTime().toLocalDate() : null;
    LocalDate now = LocalDate.now();
    String secondaryValue = (null != r.getDataTypeRequirementId() && r.getSecondaryRequirementValue() != null) ? r.getSecondaryRequirementValue() : null;

    boolean passed = false;

    if (null == r.getDataTypeRequirementId()) {
      // do direct literal operator compare
      // try to make a date out of the requirement value
      try {
        LocalDate reqValue = LocalDate.parse(r.getRequirementValue());
        passed = compareDates(fieldValue, reqValue, r.getOperatorTypeId());
      } catch (DateTimeParseException e) {
        throw new Exception(String.format("Unable to parse Date type requirement value of: %s", r.getRequirementValue()));
      }
    } else {
      // @TODO: Still need to decide how to handle stupid cases like the user inputting the field value is greater than null
      switch (r.getDataTypeRequirementId().intValue()) {
        case 1:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.minusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something
          }
          break;
        case 2:
          try {
            Assert.notNull(secondaryValue, "Unable to determine secondary value");
            passed = compareDates(fieldValue, now.plusDays(Long.parseLong(secondaryValue)), r.getOperatorTypeId());
          } catch (NumberFormatException e) {
            //@TODO: something?
          }
          break;
        case 3:
          passed = compareDates(fieldValue, now, r.getOperatorTypeId());
          break;
        case 4:
          try {
            passed = compareNullDate(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
        case 5:
          try {
            passed = compareNonNullDate(fieldValue, r.getOperatorTypeId());
          } catch (IllegalArgumentException e) {
            //@TODO: something?
          }
          break;
      }
    }

    return passed;
  }

  private boolean compareNonNullDate(LocalDate date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date != null;
        break;
      case 2:
        passed = date == null;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean compareNullDate(LocalDate date, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = date == null;
        break;
      case 2:
        passed = date != null;
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Timestamp with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  private boolean compareDates(LocalDate date, LocalDate compareDate, Long operatorTypeId) throws Exception {

    boolean passed = false;

    switch (operatorTypeId.intValue()) {
      case 1:
        passed = (compareDate == null) ? date == null : date.isEqual(compareDate);
        break;
      case 2:
        passed = (compareDate == null) ? date != null : !date.isEqual(compareDate);
        break;
      case 3:
        passed = date.isAfter(compareDate);
        break;
      case 4:
        passed = date.isBefore(compareDate);
        break;
      default:
        throw new Exception(String.format("Unable to parse data type of Date with operator of ID: %s", operatorTypeId));
    }

    return passed;
  }

  public static class ProjectProcessStepMapper<T> extends BeanPropertyRowMapper<T> {
    private final ObjectMapper objectMapper;

    public ProjectProcessStepMapper(Class<T> mappedClass, ObjectMapper objectMapper) {
      super(mappedClass);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      TypeReference<Owner> ownerRef = new TypeReference<>() {};
      bw.registerCustomEditor(Object.class, "owner", new JsonCollectionDeserializer(ownerRef, objectMapper));
    }
  }
}
