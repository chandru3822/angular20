package com.albatross.api.services;

import com.albatross.api.v1.flow.model.ProcessStepAction;
import com.albatross.api.v1.flow.model.ProcessStepLogic;
import com.albatross.api.v1.flow.model.ProjectProcessStepRequirement;
import com.albatross.api.v1.flow.services.*;
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
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

@Slf4j
@RunWith(SpringRunner.class)
@SpringBootTest
@RequiredArgsConstructor(onConstructor =  @__(@Autowired))
public class ProjectProcessStepServiceTests {

  private final ProjectProcessStepService projectProcessStepService;

  private final ObjectMapper om;

  private final Map<String, String> jsonObjects = new HashMap<>();

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
  }

  @BeforeEach
  public void setup() throws IOException {
    ProcessStepAction action = om.readValue(this.jsonObjects.get("processStepAction.action"), ProcessStepAction.class);
    ProcessStepLogic logic = new ProcessStepLogic();
    logic.setProcessStepRequirementId(12L);
    logic.setRequirementNbr(12L);
    action.setProcessStepLogicList(List.of(logic));

    ProjectProcessStepRequirement projectProcessStepRequirement = new ProjectProcessStepRequirement();
    projectProcessStepRequirement.setId(20L);

    ProcessStepActionService processStepActionService = mock(ProcessStepActionService.class);
    ReflectionTestUtils.setField(projectProcessStepService, "processStepActionService", processStepActionService);

    ProjectProcessStepRequirementService projectProcessStepRequirementService = mock(ProjectProcessStepRequirementService.class);
    ReflectionTestUtils.setField(projectProcessStepService, "projectProcessStepRequirementService", projectProcessStepRequirementService);

    when(processStepActionService.getActionById(1L)).thenReturn(action);
    when(projectProcessStepRequirementService.getByProjectProcessStepId(7L, List.of(12L))).thenReturn(List.of(projectProcessStepRequirement));
  }

  @Test
  public void stuff() {
    try {
      boolean passed = this.projectProcessStepService.canPerformAction(1L, 7L);
      assertThat(passed).isTrue();
    } catch (Exception e) {
      log.error("test failed");
    }
  }
}
