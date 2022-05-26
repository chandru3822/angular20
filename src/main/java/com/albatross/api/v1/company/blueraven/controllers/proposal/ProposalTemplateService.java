package com.albatross.api.v1.company.blueraven.controllers.proposal;

import com.albatross.api.config.AppProperties;
import com.albatross.api.config.CachingConfig;
import com.albatross.api.convert.JsonObjectDeserializer;
import com.albatross.api.exception.ApiException;
import com.albatross.api.exception.NotFoundException;
import com.albatross.api.utils.SqlCache;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplate;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTemplateBlock;
import com.albatross.api.v1.company.blueraven.controllers.proposal.models.ProposalTheme;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.DocumentContext;
import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.Option;
import com.jayway.jsonpath.spi.json.JacksonJsonProvider;
import com.jayway.jsonpath.spi.mapper.JacksonMappingProvider;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import lombok.extern.slf4j.Slf4j;
import org.postgresql.util.PGobject;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.io.OutputStream;
import java.io.StringWriter;
import java.time.Duration;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

//  TODO:
//  * update template/theme

@Slf4j
@Service
@PreAuthorize("hasCompanyAccess(3)")
public class ProposalTemplateService {
  private final SqlCache sqlCache;
  private final ObjectMapper objectMapper;
  private final AppProperties appProperties;
  private final freemarker.template.Configuration freemarkerConfiguration;
  private final com.jayway.jsonpath.Configuration jsonPathConfiguration;

  public ProposalTemplateService(
      @Autowired SqlCache sqlCache,
      @Autowired ObjectMapper objectMapper,
      @Autowired AppProperties appProperties,
      @Autowired freemarker.template.Configuration freemarkerConfiguration ) {
    this.sqlCache = sqlCache;
    this.objectMapper = objectMapper;
    this.appProperties = appProperties;
    this.freemarkerConfiguration = freemarkerConfiguration;

    this.jsonPathConfiguration =
        com.jayway.jsonpath.Configuration.builder()
            .jsonProvider( new JacksonJsonProvider(objectMapper))
            .options(Option.DEFAULT_PATH_LEAF_TO_NULL, Option.SUPPRESS_EXCEPTIONS)
            .mappingProvider(new JacksonMappingProvider())
            .build();
  }

  public ProposalTemplate getTemplateById(Long templateId, Map<String, Object> context) {

    final ProposalTemplate template =
        sqlCache.get(
            "proposalTemplate.findById",
            Map.of("id", templateId),
            new ProposalTemplateMapper(objectMapper))
          .orElseThrow(NotFoundException::new);

    final List<ProposalTemplateBlock> mergedBlocks =
        template.getBlocks().stream()
            .map(block -> replaceVarFromContext(block, context))
            .map(block -> replaceImagePlaceholderFromContext(block, context))
            .toList();

    template.setBlocks(mergedBlocks);
    return template;
  }

  @SuppressWarnings("unchecked")
  private ProposalTemplateBlock replaceVarFromContext(
      ProposalTemplateBlock block, Map<String, Object> context) {
    // there isn't anything to process so just return as is
    if (block.getBlockValue() == null) {
      return block;
    }

    final DocumentContext documentContext =
        JsonPath.using(this.jsonPathConfiguration).parse(block.getBlockValue());

    final String replacementPath = "$..content[?(@.type=='mention')]";

    documentContext.map(replacementPath,
      (val, configuration) -> {
        if (val instanceof Map current){
          final Object id = getNestedValue(current, "attrs", "id");
          if (id != null){
            final Object replacementText = context.getOrDefault((String)id, null);
            if (replacementText != null){
              current.put("type", "text");
              current.put("text", replacementText.toString());
              current.remove("attrs");
            }else {
              log.debug("No replacement found for key={} in provided context", id);
            }
          }
        }
        return val;
      })
      .delete(replacementPath); //remove any variables not replaced

    return block;
  }

  private ProposalTemplateBlock replaceImagePlaceholderFromContext(ProposalTemplateBlock block, Map<String, Object> context){
    if (block.getBlockKind() == null){
      return block;
    }

    final Object actualImageUrl = context.getOrDefault(block.getBlockKind(), null);
    if (actualImageUrl != null){
      block.setBlockType("ImageBlock");
      block.setBlockValue(Map.of("url", actualImageUrl));
    }
    return block;
  }

  private <T> T getNestedValue(Map map, String... keys){
    Object value = map;
    for (String key : keys) {
      if (value instanceof Map){
        value = ((Map)value).get(key);
      }
    }
    return (T) value;
  }

  @Cacheable(value = CachingConfig.PROPOSAL_TEMPLATE,  key = "#templateId")
  public Optional<ProposalTemplate> getTemplateById(Long templateId) {
    return sqlCache.get(
        "proposalTemplate.findById",
        Map.of("id", templateId),
        new ProposalTemplateMapper(objectMapper));
  }

  @Transactional
  @CacheEvict(value = CachingConfig.PROPOSAL_TEMPLATE, key = "#templateId")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public void updateTemplate(Long templateId) {}

  @Transactional
  @CacheEvict(value = CachingConfig.PROPOSAL_TEMPLATE,  key = "#templateId")
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<ProposalTemplateBlock> updateTemplateBlocks(
      Long templateId, List<ProposalTemplateBlock> blocks, Long currentUserId) {

    final List<Map<String, Object>> params =
        blocks.stream()
            .map(
                block -> {
                  final Map<String, Object> map = new HashMap<>();
                  map.put("id", block.getId());
                  map.put("templateId", templateId);
                  map.put("version", block.getVersion());
                  map.put("themeValueId", block.getThemeKeyId());
                  map.put("blockTypeId", block.getBlockTypeId());
                  map.put("blockKindId", block.getBlockKindId());
                  map.put("blockStyle", getPGobject(block.getBlockStyle()));
                  map.put("blockValue", getPGobject(block.getBlockValue()));
                  map.put("blockOrder", block.getBlockOrder());
                  map.put("parentId", block.getParentId());
                  map.put("modifiedById", currentUserId);
                  return map;
                })
            .toList();

    sqlCache.updateBatch("proposalTemplate.updateBlocks", params);

    final Set<Integer> updated =
        blocks.stream().map(ProposalTemplateBlock::getId).collect(Collectors.toSet());

    return getTemplateBlocks(updated);
  }

  @Cacheable(value = CachingConfig.PROPOSAL_TEMPLATE)
  @PreAuthorize("hasFeatureAccessLevel('PROPOSALS_ADMIN')")
  public List<String> getAvailableTags(){
    return sqlCache.queryForList("proposalTemplate.availableTags", Map.of(), String.class);
  }

  public void generatePdf(Long templateId, Map<String, Object> context, OutputStream outputStream, HandleContentLength func) throws IOException, TemplateException {
    final ProposalTemplate proposalTemplate = getTemplateById(templateId, context);
    generatePdf(proposalTemplate.getBlocks(), proposalTemplate.getTheme().getThemeStyle(), outputStream, func);
  }

  public void generatePdf(List<ProposalTemplateBlock> blocks, Object theme, OutputStream outputStream, HandleContentLength func) throws IOException, TemplateException {

    final String generatedHtml = generateHtml(blocks, theme);

    final Flux<DataBuffer> pdf = WebClient.create()
      .post()
      .uri(appProperties.getHtmlToPdfApi())
      .contentType(MediaType.APPLICATION_FORM_URLENCODED)
      .accept(MediaType.APPLICATION_PDF)
      .body(BodyInserters.fromFormData("html", generatedHtml))
      .exchangeToFlux(response -> {
        response.headers().header(HttpHeaders.CONTENT_LENGTH).stream()
          .findFirst()
          .ifPresent(val -> func.handle(Long.parseLong(val)));

        if (response.statusCode() == HttpStatus.OK) {
          return response.bodyToFlux(DataBuffer.class);
        }
        return Flux.empty();
      })
      .doOnError((e) -> {
        throw new ApiException("Error processing PDF");
      });

    DataBufferUtils.write(pdf, outputStream).blockLast();
  }

  private String generateHtml(List<ProposalTemplateBlock> blocks, Object theme) throws TemplateException, IOException {
    final Instant start = Instant.now();

    final StringWriter stringWriter = new StringWriter();
    final Template template = freemarkerConfiguration.getTemplate("proposal/index.ftlh");
    template.process(Map.of("template", blocks, "theme",theme ), stringWriter);
    final String processedTemplate = stringWriter.toString();

    log.debug("Duration of template processing:  {}", Duration.between(start, Instant.now()));
    log.debug(processedTemplate);
    return processedTemplate;
  }

  private List<ProposalTemplateBlock> getTemplateBlocks(Set<Integer> ids) {
    return sqlCache.query(
        "proposalTemplate.findBlocksByIds",
        Map.of("ids", ids),
        new ProposalTemplateBlockMapper(objectMapper));
  }

  private PGobject getPGobject(Object original) {

    if (original == null) {
      return null;
    }

    try {
      final PGobject pGobject = new PGobject();
      pGobject.setType("jsonb");
      pGobject.setValue(objectMapper.writeValueAsString(original));
      return pGobject;
    } catch (Exception e) {
      log.warn("Error creating PGObject for obj={}, msg={}", original, e.getMessage());
      throw new RuntimeException("Error creating object");
    }
  }

  @FunctionalInterface
  public interface HandleContentLength {
    void handle(Long contentLength);
  }

  private static class ProposalTemplateBlockMapper
      extends BeanPropertyRowMapper<ProposalTemplateBlock> {
    private final ObjectMapper objectMapper;

    public ProposalTemplateBlockMapper(ObjectMapper objectMapper) {
      super(ProposalTemplateBlock.class);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      super.initBeanWrapper(bw);

      final TypeReference<Map<String, Object>> mapTypeReference = new TypeReference<>() {};
      bw.registerCustomEditor(
          Object.class, "blockStyle", new JsonObjectDeserializer<>(mapTypeReference, objectMapper));
      bw.registerCustomEditor(
          Object.class, "blockValue", new JsonObjectDeserializer<>(mapTypeReference, objectMapper));
    }
  }

  private static class ProposalTemplateMapper extends BeanPropertyRowMapper<ProposalTemplate> {
    private final ObjectMapper objectMapper;

    public ProposalTemplateMapper(ObjectMapper objectMapper) {
      super(ProposalTemplate.class);
      this.objectMapper = objectMapper;
    }

    @Override
    protected void initBeanWrapper(BeanWrapper bw) {
      super.initBeanWrapper(bw);

      final TypeReference<ProposalTheme> proposalThemeTypeReference = new TypeReference<>() {};
      final TypeReference<List<ProposalTemplateBlock>> blockTypeReference = new TypeReference<>() {};
      bw.registerCustomEditor(
          ProposalTheme.class,
          "theme",
          new JsonObjectDeserializer<>(proposalThemeTypeReference, objectMapper));
      bw.registerCustomEditor(
          List.class, "blocks", new JsonObjectDeserializer<>(blockTypeReference, objectMapper));
    }
  }
}
