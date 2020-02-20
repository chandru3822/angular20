package com.albatross.api.services;

import com.albatross.api.v1.flow.model.ProcessStepAction;
import com.albatross.api.v1.flow.model.ProcessStepLogic;
import com.albatross.api.v1.flow.model.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.services.*;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import javax.annotation.PostConstruct;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@Slf4j
@ExtendWith(SpringExtension.class)
@RequiredArgsConstructor(onConstructor = @__(@Autowired))
@SpringBootTest
public class ProjectProcessStepServiceTests {

  private ProjectProcessStepService projectProcessStepService;

  private final ObjectMapper om;

  private final Map<String, String> jsonObjects = new HashMap<>();

  private ProcessStepActionService processStepActionService = mock(ProcessStepActionService.class);

  ProjectProcessStepRequirementService projectProcessStepRequirementService = mock(ProjectProcessStepRequirementService.class);

  private ProcessStepAction action;

  private List<ProcessStepLogic> processStepLogicList;

  private List<ProjectProcessStepRequirement> projectProcessStepRequirements;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {

    projectProcessStepService = spy(new ProjectProcessStepService(null, null, null, null, null, processStepActionService, projectProcessStepRequirementService, null));

    ResourcePatternResolver patternResolver = new PathMatchingResourcePatternResolver();
    Resource[] resources = patternResolver.getResources("classpath*:**/*.json.xml");
    XmlMapper mapper = new XmlMapper();

    for (Resource resource : resources) {
      InputStream stream = resource.getInputStream();
      XMLStreamReader sr = XMLInputFactory.newInstance().createXMLStreamReader(stream);

      //noinspection unchecked
      Map<String, String> converted = mapper.readValue(sr, Map.class);
      jsonObjects.putAll(converted);
    }

    action = om.readValue(jsonObjects.get("processStepAction.action"), ProcessStepAction.class);
    processStepLogicList = om.readValue(jsonObjects.get("processStepLogic.trueAndTrueAndTrue"), new TypeReference<List<ProcessStepLogic>>() {});
    projectProcessStepRequirements = om.readValue(jsonObjects.get("projectProcessStepRequirement.scheduleWithSystemList"), new TypeReference<List<ProjectProcessStepRequirement>>() {});
  }

  @BeforeEach
  public void setup() {
    action.setProcessStepLogicList(processStepLogicList);
    when(processStepActionService.getActionById(anyLong())).thenReturn(action);
    when(projectProcessStepRequirementService.getByProjectProcessStepId(anyLong(), anyList())).thenReturn(projectProcessStepRequirements);
  }

  @Test
  public void alwaysEnabled() throws Exception {
    action.setAlwaysEnabled(true);
    boolean passed = projectProcessStepService.canPerformAction(1L, 1L);
    assertThat(passed).isTrue();
    verify(projectProcessStepRequirementService, never()).getByProjectProcessStepId(anyLong(), anyList());

    action.setAlwaysEnabled(false);
    projectProcessStepService.canPerformAction(1L, 1L);
    verify(projectProcessStepRequirementService).getByProjectProcessStepId(anyLong(), anyList());
  }

  @Test
  public void noLogicSteps() throws Exception {
    action.setProcessStepLogicList(List.of());
    boolean passed = projectProcessStepService.canPerformAction(1L, 1L);
    assertThat(passed).isFalse();
    verify(projectProcessStepRequirementService, never()).getByProjectProcessStepId(anyLong(), anyList());

    List<ProcessStepLogic> processStepLogicList = om.readValue(jsonObjects.get("processStepLogic.trueAndTrueAndTrue"), new TypeReference<List<ProcessStepLogic>>() {});
    action.setProcessStepLogicList(processStepLogicList);
    projectProcessStepService.canPerformAction(1L, 1L);
    verify(projectProcessStepRequirementService).getByProjectProcessStepId(anyLong(), anyList());
  }

  @Test
  public void noRequirements() throws Exception {
    when(projectProcessStepRequirementService.getByProjectProcessStepId(anyLong(), anyList())).thenReturn(List.of());
    boolean passed = projectProcessStepService.canPerformAction(1L, 1L);
    assertThat(passed).isTrue();

    // @TODO: Would be nice to verify that r.setFulfilled isn't ever called (meaning the code returns early when it should),
    //  but can't figure out how to mock local vars
  }

  @Test
  public void compareDatesTest() throws Exception {
    LocalDate today = LocalDate.now();
    assertThat(projectProcessStepService.compareDates(null, today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDates(null, today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDates(null, today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDates(null, today, 4L)).isFalse();

    assertThat(projectProcessStepService.compareDates(today, today, 1L)).isTrue();
    assertThat(projectProcessStepService.compareDates(today, today, 2L)).isFalse();
    assertThat(projectProcessStepService.compareDates(today, today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDates(today, today, 4L)).isFalse();

    assertThat(projectProcessStepService.compareDates(today.minusDays(1), today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDates(today.minusDays(1), today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDates(today.minusDays(1), today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDates(today.minusDays(1), today, 4L)).isTrue();

    assertThat(projectProcessStepService.compareDates(today.plusDays(1), today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDates(today.plusDays(1), today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDates(today.plusDays(1), today, 3L)).isTrue();
    assertThat(projectProcessStepService.compareDates(today.plusDays(1), today, 4L)).isFalse();
  }

  @Test
  public void compareNullDateTest() throws Exception {
    LocalDate today = LocalDate.now();
    assertThat(projectProcessStepService.compareNullDate(null, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNullDate(null, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNullDate(null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNullDate(null, 4L)).isFalse();

    assertThat(projectProcessStepService.compareNullDate(today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNullDate(today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNullDate(today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNullDate(today, 4L)).isFalse();
  }

  @Test
  public void compareNonNullDateTest() throws Exception {
    LocalDate today = LocalDate.now();
    assertThat(projectProcessStepService.compareNonNullDate(null, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDate(null, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNonNullDate(null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDate(null, 4L)).isFalse();

    assertThat(projectProcessStepService.compareNonNullDate(today, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNonNullDate(today, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDate(today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDate(today, 4L)).isFalse();
  }

  @Test
  public void calculateDateRequirementTest() throws Exception {
    LocalDate today = LocalDate.now();
    ProjectProcessStepRequirement r = om.readValue(jsonObjects.get("projectProcessStepRequirement.date"), new TypeReference<ProjectProcessStepRequirement>(){});
    r.setDataTypeId(1L);
    r.setSecondaryRequirementValue("1");

    // Check date value of today

    r.setDateValue(Timestamp.valueOf(today.atStartOfDay()));
    r.setDataTypeRequirementId(1L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(2L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(3L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(4L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(5L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    // Check past date value

    r.setDateValue(Timestamp.valueOf(today.minusDays(3).atStartOfDay()));
    r.setDataTypeRequirementId(1L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(2L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(3L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(4L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(5L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    // Check future date value

    r.setDateValue(Timestamp.valueOf(today.plusDays(3).atStartOfDay()));
    r.setDataTypeRequirementId(1L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(2L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(3L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(4L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();

    r.setDataTypeRequirementId(5L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    // Check null date value

    r.setDateValue(null);
    r.setDataTypeRequirementId(1L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(2L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(3L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(4L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();

    r.setDataTypeRequirementId(5L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateDateRequirement(r)).isTrue();
  }

  @Test
  public void compareDateTimesTest() throws Exception {
    LocalDateTime today = LocalDateTime.now();
    assertThat(projectProcessStepService.compareDateTimes(null, today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(null, today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDateTimes(null, today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(null, today, 4L)).isFalse();

    assertThat(projectProcessStepService.compareDateTimes(today, today, 1L)).isTrue();
    assertThat(projectProcessStepService.compareDateTimes(today, today, 2L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(today, today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(today, today, 4L)).isFalse();

    assertThat(projectProcessStepService.compareDateTimes(today.minusHours(1), today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(today.minusHours(1), today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDateTimes(today.minusHours(1), today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(today.minusHours(1), today, 4L)).isTrue();

    assertThat(projectProcessStepService.compareDateTimes(today.plusHours(1), today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareDateTimes(today.plusHours(1), today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareDateTimes(today.plusHours(1), today, 3L)).isTrue();
    assertThat(projectProcessStepService.compareDateTimes(today.plusHours(1), today, 4L)).isFalse();
  }

  @Test
  public void compareNullDateTimeTest() throws Exception {
    LocalDateTime today = LocalDateTime.now();
    assertThat(projectProcessStepService.compareNullDateTime(null, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNullDateTime(null, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNullDateTime(null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNullDateTime(null, 4L)).isFalse();

    assertThat(projectProcessStepService.compareNullDateTime(today, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNullDateTime(today, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNullDateTime(today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNullDateTime(today, 4L)).isFalse();
  }

  @Test
  public void compareNonNullDateTimeTest() throws Exception {
    LocalDateTime today = LocalDateTime.now();
    assertThat(projectProcessStepService.compareNonNullDateTime(null, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDateTime(null, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNonNullDateTime(null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDateTime(null, 4L)).isFalse();

    assertThat(projectProcessStepService.compareNonNullDateTime(today, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNonNullDateTime(today, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDateTime(today, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNonNullDateTime(today, 4L)).isFalse();
  }

  @Test
  public void calculateTimestampRequirementTest() throws Exception {
    LocalDateTime today = LocalDateTime.now();
    ProjectProcessStepRequirement r = om.readValue(jsonObjects.get("projectProcessStepRequirement.timestamp"), new TypeReference<ProjectProcessStepRequirement>(){});
    r.setDataTypeId(2L);
    r.setSecondaryRequirementValue("1");

    // Check timestamp value of today

    r.setTimestampValue(Timestamp.valueOf(today));
    r.setDataTypeRequirementId(6L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(7L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(8L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(9L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(10L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(11L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(12L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(13L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    // Check past timestamp value

    r.setTimestampValue(Timestamp.valueOf(today.minusDays(3)));
    r.setDataTypeRequirementId(6L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(7L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(8L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setTimestampValue(Timestamp.valueOf(today.minusHours(3)));
    r.setDataTypeRequirementId(9L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(10L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(11L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();

    r.setDataTypeRequirementId(12L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(13L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    // Check future timestamp value

    r.setTimestampValue(Timestamp.valueOf(today.plusDays(3)));
    r.setDataTypeRequirementId(6L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(7L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(8L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setTimestampValue(Timestamp.valueOf(today.plusHours(3)));
    r.setDataTypeRequirementId(9L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(10L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(11L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(12L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(13L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    // Check null timestamp value

    r.setTimestampValue(null);
    r.setDataTypeRequirementId(6L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(7L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(8L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(9L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(10L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(11L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(12L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();

    r.setDataTypeRequirementId(13L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateTimestampRequirement(r)).isFalse();
  }

  @Test
  public void calculateBooleanRequirementTest() throws Exception {
    ProjectProcessStepRequirement r = om.readValue(jsonObjects.get("projectProcessStepRequirement.boolean"), new TypeReference<ProjectProcessStepRequirement>(){});
    r.setDataTypeId(3L);

    // Check true boolean value

    r.setBooleanValue(true);
    r.setDataTypeRequirementId(14L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();

    r.setDataTypeRequirementId(15L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();

    // Check false boolean value

    r.setBooleanValue(false);
    r.setDataTypeRequirementId(14L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();

    r.setDataTypeRequirementId(15L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();

    // Check null boolean value

    r.setBooleanValue(null);
    r.setDataTypeRequirementId(14L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();

    r.setDataTypeRequirementId(15L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateBooleanRequirement(r)).isFalse();
  }

  @Test
  public void compareNumericTest() throws Exception {
    Double number = 10d;
    Double compareNumber = 10d;

    // Compare equal

    assertThat(projectProcessStepService.compareNumeric(number, compareNumber, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber, 4L)).isFalse();

    // Compare larger user input

    assertThat(projectProcessStepService.compareNumeric(number + 10, compareNumber, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number + 10, compareNumber, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(number + 10, compareNumber, 3L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(number + 10, compareNumber, 4L)).isFalse();

    // Compare larger required value

    assertThat(projectProcessStepService.compareNumeric(number, compareNumber + 10, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber + 10, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber + 10, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, compareNumber + 10, 4L)).isTrue();

    // Compare user input of null

    assertThat(projectProcessStepService.compareNumeric(null, compareNumber, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(null, compareNumber, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(null, compareNumber, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(null, compareNumber, 4L)).isFalse();

    // Compare required value of null

    assertThat(projectProcessStepService.compareNumeric(number, null, 1L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, null, 2L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(number, null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(number, null, 4L)).isFalse();

    // Compare all null

    assertThat(projectProcessStepService.compareNumeric(null, null, 1L)).isTrue();
    assertThat(projectProcessStepService.compareNumeric(null, null, 2L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(null, null, 3L)).isFalse();
    assertThat(projectProcessStepService.compareNumeric(null, null, 4L)).isFalse();
  }

  @Test
  public void calculateNumericRequirementTest() throws Exception {
    ProjectProcessStepRequirement r = om.readValue(jsonObjects.get("projectProcessStepRequirement.numeric"), new TypeReference<ProjectProcessStepRequirement>(){});
    r.setDataTypeId(4L);

    // Check requirement value gets compared

    r.setNumericValue(BigDecimal.valueOf(10L));
    r.setRequirementValue("10");
    r.setDataTypeRequirementId(null);
    r.setOperatorTypeId(1L);

    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isTrue();
    verify(projectProcessStepService).compareNumeric(anyDouble(), anyDouble(), anyLong());

    // Compare regular value

    r.setRequirementValue(null);
    r.setDataTypeRequirementId(16L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();

    r.setDataTypeRequirementId(17L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();

    // Compare null value

    r.setNumericValue(null);
    r.setDataTypeRequirementId(16L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isTrue();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();

    r.setDataTypeRequirementId(17L);
    r.setOperatorTypeId(1L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(2L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isTrue();
    r.setOperatorTypeId(3L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
    r.setOperatorTypeId(4L);
    assertThat(projectProcessStepService.calculateNumericRequirement(r)).isFalse();
  }

  // Possibly use this in the future
//  @Test
//  public void dateTypeRequirementWithNullValue() throws Exception {
//
//    List<ProcessStepLogic> logicList = om.readValue(jsonObjects.get("processStepLogic.true"), new TypeReference<List<ProcessStepLogic>>() {});
//    action.setProcessStepLogicList(logicList);
//    ProjectProcessStepRequirement dateRequirement = om.readValue(jsonObjects.get("projectProcessStepRequirement.date"), new TypeReference<ProjectProcessStepRequirement>(){});
//    when(projectProcessStepRequirementService.getByProjectProcessStepId(anyLong(), anyList())).thenReturn(List.of(dateRequirement));
//
//    // Check null date value going through available data_type_requirements and available operator types
//
//    dateRequirement.setDataTypeRequirementId(1L);
//    dateRequirement.setOperatorTypeId(1L);
//    boolean passed = projectProcessStepService.canPerformAction(1L, 1L);
//    assertThat(passed).isFalse();
//    verify(projectProcessStepService).calculateDateRequirement(dateRequirement);
//
//    dateRequirement.setOperatorTypeId(2L);
//    passed = projectProcessStepService.canPerformAction(1L, 1L);
//    assertThat(passed).isTrue();
//    verify(projectProcessStepService, times(2)).calculateDateRequirement(any());
//
//    dateRequirement.setOperatorTypeId(3L);
//    passed = projectProcessStepService.canPerformAction(1L, 1L);
//    assertThat(passed).isFalse();
//    verify(projectProcessStepService, times(3)).calculateDateRequirement(any());
//
//    dateRequirement.setOperatorTypeId(4L);
//    passed = projectProcessStepService.canPerformAction(1L, 1L);
//    assertThat(passed).isFalse();
//    verify(projectProcessStepService, times(4)).calculateDateRequirement(any());
//
//    try {
//      dateRequirement.setOperatorTypeId(5L);
//      projectProcessStepService.canPerformAction(1L, 1L);
//    } catch (Exception e) {
//      verify(projectProcessStepService, times(5)).calculateDateRequirement(any());
//    }
//  }
}
