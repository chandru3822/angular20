package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalGeneratedType;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.jdbc.core.BeanPropertyRowMapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyMap;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProposalTemplateServiceTest {

  @Spy private ObjectMapper objectMapper = new ObjectMapper();
  @Mock private SqlCache sqlCache;
  @InjectMocks private ProposalTemplateService proposalTemplateService;

  @Test
  void getTemplateByIdWithContext() throws JsonProcessingException {

    final var JSON =
        "{\"type\": \"doc\", \"content\": [{\"type\": \"paragraph\", \"content\": [{\"type\": \"mention\", \"attrs\": {\"id\": \"first_name\", \"label\": null}}, {\"type\": \"mention\", \"attrs\": {\"id\": \"last_name\", \"label\": null}}]}]}";

    final var blockValue =
        objectMapper.readValue(JSON, new TypeReference<Map<String, Object>>() {});

    final var expectedSqlTemplate =
        new ProposalTemplate()
            .setId(1L)
            .setBlocks(
                List.of(new ProposalTemplateBlock().setBlockValue(new HashMap<>(blockValue))));

    when(sqlCache.get(any(String.class), anyMap(), any(BeanPropertyRowMapper.class)))
        .thenReturn(Optional.of(expectedSqlTemplate));

    final Map<String, Object> context = Map.of("first_name", "Darth", "last_name", "Vader");
    final ProposalTemplate templateByIdWithContext =
        proposalTemplateService.getTemplateById(1L, context, ProposalGeneratedType.MOBILE);

    assertNotNull(templateByIdWithContext);

    final List<ProposalTemplateBlock> blocks = templateByIdWithContext.getBlocks();
    assertEquals(1L, blocks.size());

    assertNotNull(blocks.get(0).getBlockValue());

    final String valueAsString = objectMapper.writeValueAsString(blocks.get(0).getBlockValue());

    assertTrue(valueAsString.contains("Darth"));
    assertTrue(valueAsString.contains("Vader"));
    assertFalse(valueAsString.contains("mention"));
  }
}
