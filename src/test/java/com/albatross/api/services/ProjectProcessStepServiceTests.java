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
import org.junit.runner.RunWith;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.*;

@Slf4j
@RunWith(SpringRunner.class)
@SpringBootTest
@RequiredArgsConstructor(onConstructor =  @__(@Autowired))
public class ProjectProcessStepServiceTests {

  private final ProjectProcessStepService projectProcessStepService;

  private final ObjectMapper om;

  private final Map<String, String> jsonObjects = new HashMap<>();

  private ProcessStepActionService processStepActionService = mock(ProcessStepActionService.class);

  ProjectProcessStepRequirementService projectProcessStepRequirementService = mock(ProjectProcessStepRequirementService.class);

  private ProcessStepAction action;

  private List<ProcessStepLogic> processStepLogicList;

  private List<ProjectProcessStepRequirement> processStepRequirements;

  @PostConstruct
  public void init() throws IOException, XMLStreamException {

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
    processStepLogicList = om.readValue(jsonObjects.get("processStepLogic.true"), new TypeReference<List<ProcessStepLogic>>() {});
    processStepRequirements = om.readValue(jsonObjects.get("processStepRequirement.scheduleWithSystemList"), new TypeReference<List<ProjectProcessStepRequirement>>() {});
  }

  @BeforeEach
  public void setup() throws IOException {
    action.setProcessStepLogicList(processStepLogicList);

    ReflectionTestUtils.setField(projectProcessStepService, "processStepActionService", processStepActionService);
    ReflectionTestUtils.setField(projectProcessStepService, "projectProcessStepRequirementService", projectProcessStepRequirementService);

    when(processStepActionService.getActionById(anyLong())).thenReturn(action);
    when(projectProcessStepRequirementService.getByProjectProcessStepId(anyLong(), anyList())).thenReturn(processStepRequirements);
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

    List<ProcessStepLogic> processStepLogicList = om.readValue(jsonObjects.get("processStepLogic.true"), new TypeReference<List<ProcessStepLogic>>() {});
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
}
