package com.albatross.api.services;

import com.albatross.api.security.SecurityService;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.flow.model.ProcessStepAction;
import com.albatross.api.v1.flow.model.ProcessStepLogic;
import com.albatross.api.v1.flow.model.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.services.*;
import com.amazonaws.services.s3.AmazonS3;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.dataformat.xml.XmlMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.mockito.Spy;
import org.mockito.internal.matchers.Any;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.core.io.support.ResourcePatternResolver;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.util.ReflectionTestUtils;

import javax.annotation.PostConstruct;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@Slf4j
@RunWith(SpringRunner.class)
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
  public void dateTypeRequirement() throws Exception {
    List<ProcessStepLogic> logicList = om.readValue(jsonObjects.get("processStepLogic.true"), new TypeReference<List<ProcessStepLogic>>() {});
    action.setProcessStepLogicList(logicList);
    List<ProjectProcessStepRequirement> dateRequirement = om.readValue(jsonObjects.get("projectProcessStepRequirement.date"), new TypeReference<List<ProjectProcessStepRequirement>>(){});
    when(projectProcessStepRequirementService.getByProjectProcessStepId(anyLong(), anyList())).thenReturn(dateRequirement);
    boolean passed = projectProcessStepService.canPerformAction(1L, 1L);
    assertThat(passed).isFalse();
    verify(projectProcessStepService).calculateDateRequirement(dateRequirement.get(0));

    dateRequirement.get(0).setDateValue(new Timestamp(LocalDate.now().toEpochDay()));
    passed = projectProcessStepService.canPerformAction(1L, 1L);
    assertThat(passed).isTrue();
    verify(projectProcessStepService).isRequirementMet(any());
  }
}
